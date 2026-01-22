import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription_model.dart';
import '../models/trainer_request_model.dart';
import '../repositories/subscription_repository.dart';
import '../repositories/trainer_request_repository.dart';

final selfTrainingServiceProvider = Provider<SelfTrainingService>((ref) {
  return SelfTrainingService(
    subscriptionRepository: ref.watch(subscriptionRepositoryProvider),
    requestRepository: ref.watch(trainerRequestRepositoryProvider),
  );
});

/// 월간 리포트 데이터
class MonthlyReport {
  final String memberId;
  final DateTime month;
  final double? startWeight;
  final double? endWeight;
  final double? weightChange;
  final int totalWorkouts;
  final int dietRecords;
  final double avgCalories;
  final int weightStreak;
  final int dietStreak;
  final List<String> achievements;
  final String aiSummary;

  MonthlyReport({
    required this.memberId,
    required this.month,
    this.startWeight,
    this.endWeight,
    this.weightChange,
    required this.totalWorkouts,
    required this.dietRecords,
    required this.avgCalories,
    required this.weightStreak,
    required this.dietStreak,
    required this.achievements,
    required this.aiSummary,
  });
}

class SelfTrainingService {
  final SubscriptionRepository subscriptionRepository;
  final TrainerRequestRepository requestRepository;

  SelfTrainingService({
    required this.subscriptionRepository,
    required this.requestRepository,
  });

  /// 프리미엄 기능 접근 확인
  Future<bool> checkPremiumAccess(String userId) async {
    return await subscriptionRepository.hasFeatureAccess(userId, 'premium');
  }

  /// 특정 기능 접근 확인
  Future<bool> hasFeatureAccess(String userId, String feature) async {
    return await subscriptionRepository.hasFeatureAccess(userId, feature);
  }

  /// 남은 질문 횟수 조회
  Future<int> getAvailableQuestionCount(String userId) async {
    final subscription = await subscriptionRepository.getByUserId(userId);
    return subscription?.monthlyQuestionCount ?? 0;
  }

  /// 트레이너 질문 요청 생성
  Future<String?> createTrainerRequest({
    required String memberId,
    required String trainerId,
    required RequestType requestType,
    required String content,
    List<String>? attachmentUrls,
  }) async {
    // 프리미엄 질문권 사용 가능한지 확인 (question 타입만)
    if (requestType == RequestType.question) {
      final subscription = await subscriptionRepository.getByUserId(memberId);
      if (subscription != null && subscription.isPremium && subscription.hasQuestionRemaining) {
        // 질문권 차감
        await subscriptionRepository.decrementQuestionCount(memberId);
      }
    }

    final request = TrainerRequestModel(
      id: '',
      memberId: memberId,
      trainerId: trainerId,
      requestType: requestType,
      content: content,
      attachmentUrls: attachmentUrls ?? [],
      price: requestType.price,
      createdAt: DateTime.now(),
    );

    return await requestRepository.create(request);
  }

  /// 프리미엄 구독 시작
  Future<void> startPremiumSubscription(String userId) async {
    await subscriptionRepository.upgradeToPremium(userId);
  }

  /// 프리미엄 구독 해지
  Future<void> cancelPremiumSubscription(String userId) async {
    await subscriptionRepository.downgradeToFree(userId);
  }

  /// 월간 리포트 생성 (프리미엄 기능)
  Future<MonthlyReport?> generateMonthlyReport(String memberId) async {
    // 프리미엄 확인
    final hasPremium = await checkPremiumAccess(memberId);
    if (!hasPremium) return null;

    // TODO: 실제 데이터 조회 로직 구현
    // 현재는 더미 데이터 반환
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    return MonthlyReport(
      memberId: memberId,
      month: monthStart,
      startWeight: null, // body_record_repository에서 조회
      endWeight: null,
      weightChange: null,
      totalWorkouts: 0, // schedule_repository에서 조회
      dietRecords: 0, // diet_record_repository에서 조회
      avgCalories: 0.0,
      weightStreak: 0, // streak_repository에서 조회
      dietStreak: 0,
      achievements: [], // 이번 달 획득한 배지
      aiSummary: '이번 달 리포트가 준비 중입니다.',
    );
  }

  /// 회원의 요청 내역 조회
  Future<List<TrainerRequestModel>> getMemberRequests(String memberId) async {
    return await requestRepository.getByMemberId(memberId);
  }

  /// 트레이너의 대기 중인 요청 조회
  Future<List<TrainerRequestModel>> getPendingRequests(String trainerId) async {
    final requests = await requestRepository.getByTrainerId(trainerId);
    return requests.where((r) => r.isPending).toList();
  }

  /// 트레이너 답변 등록
  Future<void> submitTrainerResponse(String requestId, String response) async {
    await requestRepository.submitResponse(requestId, response);
  }

  /// 만료된 요청 처리
  Future<void> processExpiredRequests() async {
    await requestRepository.processExpiredRequests();
  }

  /// 구독 상태 조회
  Future<SubscriptionModel?> getSubscriptionStatus(String userId) async {
    return await subscriptionRepository.getByUserId(userId);
  }

  /// 트레이너 월간 수익 계산
  Future<int> calculateMonthlyRevenue(String trainerId) async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    return await requestRepository.calculateTrainerRevenue(
      trainerId,
      from: monthStart,
    );
  }
}
