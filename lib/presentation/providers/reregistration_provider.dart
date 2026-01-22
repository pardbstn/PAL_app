import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/reregistration_alert_model.dart';
import '../../data/models/member_model.dart';
import '../../data/repositories/reregistration_alert_repository.dart';
import '../../data/services/reregistration_service.dart';

/// 트레이너별 재등록 대기 알림 실시간 감시
final reregistrationAlertsProvider = StreamProvider.family<List<ReregistrationAlertModel>, String>((ref, trainerId) {
  final repository = ref.watch(reregistrationAlertRepositoryProvider);
  return repository.watchByTrainerId(trainerId);
});

/// 특정 회원의 재등록 알림 조회
final memberReregistrationAlertProvider = FutureProvider.family<ReregistrationAlertModel?, String>((ref, memberId) async {
  final repository = ref.watch(reregistrationAlertRepositoryProvider);
  return repository.getByMemberId(memberId);
});

/// 재등록 서비스 Notifier
class ReregistrationNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// 회원 수업 체크 및 알림 생성
  Future<bool> checkAndCreateAlert(MemberModel member) async {
    final service = ref.read(reregistrationServiceProvider);
    return await service.checkAndCreateAlert(member);
  }

  /// 재등록 완료 처리
  Future<void> markReregistered(String memberId) async {
    final service = ref.read(reregistrationServiceProvider);
    await service.markReregistered(memberId);
  }

  /// 대기 중인 알림 일괄 처리
  Future<int> processAllPendingAlerts() async {
    final service = ref.read(reregistrationServiceProvider);
    return await service.processAllPendingAlerts();
  }
}

final reregistrationNotifierProvider = AsyncNotifierProvider<ReregistrationNotifier, void>(() {
  return ReregistrationNotifier();
});

/// 트레이너의 재등록 대기 회원 수
final pendingReregistrationCountProvider = FutureProvider.family<int, String>((ref, trainerId) async {
  final service = ref.watch(reregistrationServiceProvider);
  return service.getPendingCount(trainerId);
});
