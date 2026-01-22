import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../models/reregistration_alert_model.dart';
import '../models/member_model.dart';
import '../repositories/notification_repository.dart';
import '../repositories/reregistration_alert_repository.dart';
import '../repositories/member_repository.dart';

final reregistrationServiceProvider = Provider<ReregistrationService>((ref) {
  return ReregistrationService(
    notificationRepository: ref.watch(notificationRepositoryProvider),
    alertRepository: ref.watch(reregistrationAlertRepositoryProvider),
    memberRepository: ref.watch(memberRepositoryProvider),
  );
});

class ReregistrationService {
  final NotificationRepository notificationRepository;
  final ReregistrationAlertRepository alertRepository;
  final MemberRepository memberRepository;

  ReregistrationService({
    required this.notificationRepository,
    required this.alertRepository,
    required this.memberRepository,
  });

  /// 회원의 수업 진행률 계산
  double calculateProgressRate(MemberModel member) {
    final total = member.ptInfo.totalSessions;
    final completed = member.ptInfo.completedSessions;
    if (total == 0) return 0.0;
    return completed / total;
  }

  /// 수업 진행 상태 체크 및 알림 생성/업데이트
  Future<bool> checkAndCreateAlert(MemberModel member) async {
    final progressRate = calculateProgressRate(member);

    // 기존 알림 확인
    final existingAlert = await alertRepository.getByMemberId(member.id);

    if (existingAlert != null) {
      // 진행률 업데이트
      await alertRepository.updateProgress(
        member.id,
        member.ptInfo.completedSessions,
        member.ptInfo.totalSessions,
      );

      // 80% 이상이고 아직 알림 미발송인 경우
      if (progressRate >= 0.8 && existingAlert.alertSentAt == null) {
        await sendReregistrationNotification(member);
        return true;
      }
      return false;
    }

    // 새 알림 생성
    final alert = ReregistrationAlertModel(
      id: '',
      memberId: member.id,
      trainerId: member.trainerId,
      totalSessions: member.ptInfo.totalSessions,
      completedSessions: member.ptInfo.completedSessions,
      progressRate: progressRate,
      createdAt: DateTime.now(),
    );
    await alertRepository.create(alert);

    // 80% 이상이면 바로 알림
    if (progressRate >= 0.8) {
      await sendReregistrationNotification(member);
      return true;
    }

    return false;
  }

  /// 재등록 안내 알림 발송
  Future<void> sendReregistrationNotification(MemberModel member) async {
    final progressRate = calculateProgressRate(member);
    final remaining = member.ptInfo.totalSessions - member.ptInfo.completedSessions;

    // 회원에게 알림
    final notification = NotificationModel(
      id: '',
      userId: member.userId,
      type: NotificationType.reregistration,
      title: '🎯 PT 수업이 거의 끝나가요!',
      body: '현재 ${(progressRate * 100).toInt()}% 진행 완료! 남은 $remaining회, 지금까지의 변화를 확인하고 다음 목표를 세워보세요.',
      data: {
        'memberId': member.id,
        'trainerId': member.trainerId,
        'action': 'reregistration',
      },
      createdAt: DateTime.now(),
    );
    await notificationRepository.create(notification);

    // 알림 발송 시간 기록
    final alert = await alertRepository.getByMemberId(member.id);
    if (alert != null) {
      await alertRepository.markAlertSent(alert.id);
    }
  }

  /// 80% 이상 도달했지만 알림 미발송인 회원들 일괄 처리
  Future<int> processAllPendingAlerts() async {
    final alerts = await alertRepository.getReadyToAlert();
    int count = 0;

    for (final alert in alerts) {
      final member = await memberRepository.get(alert.memberId);
      if (member != null) {
        await sendReregistrationNotification(member);
        count++;
      }
    }

    return count;
  }

  /// 재등록 완료 처리
  Future<void> markReregistered(String memberId) async {
    await alertRepository.markAsReregistered(memberId);
  }

  /// 트레이너의 재등록 대기 회원 수 조회
  Future<int> getPendingCount(String trainerId) async {
    final alerts = await alertRepository.getPendingByTrainerId(trainerId);
    return alerts.where((a) => a.shouldSendAlert || a.alertSentAt != null).length;
  }
}
