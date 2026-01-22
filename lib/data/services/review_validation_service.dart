import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trainer_review_model.dart';
import '../models/trainer_performance_model.dart';
import '../repositories/trainer_review_repository.dart';
import '../repositories/trainer_performance_repository.dart';
import '../repositories/member_repository.dart';
import '../repositories/schedule_repository.dart';

final reviewValidationServiceProvider = Provider<ReviewValidationService>((ref) {
  return ReviewValidationService(
    reviewRepository: ref.watch(trainerReviewRepositoryProvider),
    performanceRepository: ref.watch(trainerPerformanceRepositoryProvider),
    memberRepository: ref.watch(memberRepositoryProvider),
    scheduleRepository: ref.watch(scheduleRepositoryProvider),
  );
});

class ReviewValidationService {
  final TrainerReviewRepository reviewRepository;
  final TrainerPerformanceRepository performanceRepository;
  final MemberRepository memberRepository;
  final ScheduleRepository scheduleRepository;

  ReviewValidationService({
    required this.reviewRepository,
    required this.performanceRepository,
    required this.memberRepository,
    required this.scheduleRepository,
  });

  /// 평가 자격 검증
  Future<ReviewEligibility> validateReviewEligibility(
    String memberId,
    String trainerId,
  ) async {
    // 1. 이미 평가했는지 확인
    final hasReviewed = await reviewRepository.hasReviewed(memberId, trainerId);
    if (hasReviewed) {
      return ReviewEligibility.alreadyReviewed;
    }

    // 2. 회원 정보 조회
    final member = await memberRepository.get(memberId);
    if (member == null) {
      return ReviewEligibility.noCompletedPt;
    }

    // 3. PT 8회 이상 완료 확인
    final completedSessions = member.ptInfo.completedSessions;
    if (completedSessions < 8) {
      return ReviewEligibility.notEnoughSessions;
    }

    // 4. PT 종료 확인 (완료 횟수 == 총 횟수)
    final isCompleted = member.ptInfo.completedSessions >= member.ptInfo.totalSessions;
    if (isCompleted) {
      // PT 종료 후 14일 이내인지 확인 (startDate + 예상 기간으로 추정)
      final ptStartDate = member.ptInfo.startDate;
      final estimatedEndDate = ptStartDate.add(Duration(days: member.ptInfo.totalSessions * 3)); // 주 2-3회 가정
      final daysSinceEnd = DateTime.now().difference(estimatedEndDate).inDays;
      if (daysSinceEnd > 14) {
        return ReviewEligibility.expired;
      }
    }

    return ReviewEligibility.eligible;
  }

  /// 이상 패턴 감지 (24시간 내 5개 이상 평가)
  Future<bool> detectAnomalousPattern(String trainerId) async {
    final reviews = await reviewRepository.getByTrainerId(trainerId);
    final last24Hours = DateTime.now().subtract(const Duration(hours: 24));

    final recentReviews = reviews.where(
      (r) => r.createdAt.isAfter(last24Hours)
    ).toList();

    return recentReviews.length >= 5;
  }

  /// 트레이너 성과 지표 계산 및 업데이트
  Future<TrainerPerformanceModel> calculateAndUpdatePerformance(
    String trainerId,
  ) async {
    // 1. 평점 계산
    final averageRating = await reviewRepository.getAverageRating(trainerId);
    final totalReviews = await reviewRepository.getReviewCount(trainerId);

    // 2. 회원 정보로 통계 계산
    final members = await memberRepository.getByTrainerId(trainerId);
    final totalMembers = members.length;

    // 활성 회원 (PT 진행 중)
    final activeMembers = members.where((m) =>
      m.ptInfo.completedSessions < m.ptInfo.totalSessions
    ).length;

    // 재등록률 계산 - 현재 모델에 registrationCount가 없으므로 0으로 설정
    // TODO: 추후 registrationCount 필드 추가 시 구현
    const reregistrationRate = 0.0;

    // 3. 목표달성률 계산 - 현재 모델에 currentWeight가 없으므로 간소화
    // PT 완료 회원 비율로 대체
    final completedMembers = members.where((m) =>
      m.ptInfo.completedSessions >= m.ptInfo.totalSessions
    ).length;
    final goalAchievementRate = totalMembers > 0
        ? completedMembers / totalMembers
        : 0.0;

    // 4. 출석률 계산
    double totalAttendanceRate = 0.0;
    for (final member in members) {
      final total = member.ptInfo.totalSessions;
      final completed = member.ptInfo.completedSessions;
      if (total > 0) {
        totalAttendanceRate += completed / total;
      }
    }
    final attendanceRate = totalMembers > 0
        ? totalAttendanceRate / totalMembers
        : 0.0;

    // 5. 평균 체성분 변화 - 현재 모델에 weight 데이터 없으므로 0
    // TODO: body_record 연동 시 구현
    const avgBodyChange = 0.0;

    // 6. 성과 모델 생성 및 저장
    final performance = TrainerPerformanceModel(
      id: trainerId,
      trainerId: trainerId,
      reregistrationRate: reregistrationRate,
      goalAchievementRate: goalAchievementRate,
      avgBodyCompositionChange: avgBodyChange,
      attendanceManagementRate: attendanceRate,
      totalReviews: totalReviews,
      averageRating: averageRating,
      totalMembers: totalMembers,
      activeMembers: activeMembers,
      updatedAt: DateTime.now(),
    );

    await performanceRepository.updateAllMetrics(performance);

    // 7. 평가 5개 이상이면 공개 처리
    if (totalReviews >= 5) {
      await reviewRepository.makeReviewsPublic(trainerId);
    }

    return performance;
  }

  /// 평가 제출 처리
  Future<String> submitReview(TrainerReviewModel review) async {
    // 자격 재검증
    final eligibility = await validateReviewEligibility(
      review.memberId,
      review.trainerId,
    );

    if (eligibility != ReviewEligibility.eligible) {
      throw Exception('평가 자격이 없습니다: ${eligibility.name}');
    }

    // 이상 패턴 감지
    final isAnomalous = await detectAnomalousPattern(review.trainerId);
    if (isAnomalous) {
      // TODO: 관리자에게 알림 발송
      print('Warning: Anomalous review pattern detected for trainer ${review.trainerId}');
    }

    // 평가 저장
    final reviewId = await reviewRepository.create(review);

    // 성과 지표 업데이트
    await calculateAndUpdatePerformance(review.trainerId);

    return reviewId;
  }
}
