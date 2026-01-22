import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/subscription_model.dart';
import '../../data/repositories/subscription_repository.dart';
import '../../data/services/self_training_service.dart';

/// 현재 사용자의 구독 상태 실시간 감시
final currentSubscriptionProvider = StreamProvider.family<SubscriptionModel?, String>((ref, userId) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return repository.watchByUserId(userId);
});

/// 프리미엄 여부 확인
final isPremiumProvider = FutureProvider.family<bool, String>((ref, userId) async {
  final service = ref.watch(selfTrainingServiceProvider);
  return service.checkPremiumAccess(userId);
});

/// 특정 기능 접근 가능 여부
final hasFeatureAccessProvider = FutureProvider.family<bool, ({String userId, String feature})>((ref, params) async {
  final service = ref.watch(selfTrainingServiceProvider);
  return service.hasFeatureAccess(params.userId, params.feature);
});

/// 남은 질문 횟수
final availableQuestionCountProvider = FutureProvider.family<int, String>((ref, userId) async {
  final service = ref.watch(selfTrainingServiceProvider);
  return service.getAvailableQuestionCount(userId);
});

/// 구독 관리 Notifier
class SubscriptionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// 프리미엄 구독 시작
  Future<void> startPremium(String userId) async {
    final service = ref.read(selfTrainingServiceProvider);
    await service.startPremiumSubscription(userId);
  }

  /// 프리미엄 구독 해지
  Future<void> cancelPremium(String userId) async {
    final service = ref.read(selfTrainingServiceProvider);
    await service.cancelPremiumSubscription(userId);
  }
}

final subscriptionNotifierProvider = AsyncNotifierProvider<SubscriptionNotifier, void>(() {
  return SubscriptionNotifier();
});
