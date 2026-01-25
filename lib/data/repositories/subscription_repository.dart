import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription_model.dart';
import 'base_repository.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository(firestore: ref.watch(firestoreProvider));
});

class SubscriptionRepository extends BaseRepository<SubscriptionModel> {
  SubscriptionRepository({required super.firestore})
      : super(collectionPath: 'subscriptions');

  @override
  Future<SubscriptionModel?> get(String id) async {
    final doc = await collection.doc(id).get();
    if (!doc.exists) return null;
    return SubscriptionModel.fromFirestore(doc);
  }

  @override
  Future<List<SubscriptionModel>> getAll() async {
    final snapshot = await collection.get();
    return snapshot.docs.map((doc) => SubscriptionModel.fromFirestore(doc)).toList();
  }

  /// 구독 생성
  @override
  Future<String> create(SubscriptionModel subscription) async {
    final docRef = await collection.add(subscription.toFirestore());
    return docRef.id;
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    await collection.doc(id).update(data);
  }

  @override
  Future<void> delete(String id) async {
    await collection.doc(id).delete();
  }

  @override
  Stream<SubscriptionModel?> watch(String id) {
    return collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return SubscriptionModel.fromFirestore(doc);
    });
  }

  @override
  Stream<List<SubscriptionModel>> watchAll() {
    return collection.snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => SubscriptionModel.fromFirestore(doc)).toList());
  }

  /// 사용자별 구독 조회
  Future<SubscriptionModel?> getByUserId(String userId) async {
    final snapshot = await collection
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return SubscriptionModel.fromFirestore(snapshot.docs.first);
  }

  /// 사용자별 구독 실시간 감시
  Stream<SubscriptionModel?> watchByUserId(String userId) {
    return collection
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return SubscriptionModel.fromFirestore(snapshot.docs.first);
        });
  }

  /// 플랜 업그레이드
  Future<void> upgradeToPremium(String userId) async {
    final existing = await getByUserId(userId);
    final now = DateTime.now();

    if (existing != null) {
      await collection.doc(existing.id).update({
        'plan': SubscriptionPlan.premium.name,
        'startDate': Timestamp.fromDate(now),
        'endDate': Timestamp.fromDate(now.add(const Duration(days: 30))),
        'monthlyQuestionCount': 3,
        'features': SubscriptionModelX.premiumFeatures,
      });
    } else {
      final newSub = SubscriptionModel(
        id: '',
        userId: userId,
        plan: SubscriptionPlan.premium,
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
        isActive: true,
        features: SubscriptionModelX.premiumFeatures,
        monthlyQuestionCount: 3,
        createdAt: now,
      );
      await create(newSub);
    }
  }

  /// 플랜 다운그레이드 (무료로)
  Future<void> downgradeToFree(String userId) async {
    final existing = await getByUserId(userId);
    if (existing == null) return;

    await collection.doc(existing.id).update({
      'plan': SubscriptionPlan.free.name,
      'endDate': null,
      'monthlyQuestionCount': 0,
      'features': <String>[],
    });
  }

  /// 구독 비활성화
  Future<void> deactivate(String subscriptionId) async {
    await collection.doc(subscriptionId).update({
      'isActive': false,
    });
  }

  /// 질문 횟수 차감
  Future<bool> decrementQuestionCount(String userId) async {
    final existing = await getByUserId(userId);
    if (existing == null || existing.monthlyQuestionCount <= 0) return false;

    await collection.doc(existing.id).update({
      'monthlyQuestionCount': FieldValue.increment(-1),
    });
    return true;
  }

  /// 월간 질문 횟수 리셋 (매월 1일)
  Future<void> resetMonthlyQuestionCounts() async {
    final snapshot = await collection
        .where('plan', isEqualTo: SubscriptionPlan.premium.name)
        .where('isActive', isEqualTo: true)
        .get();

    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'monthlyQuestionCount': 3});
    }
    await batch.commit();
  }

  /// 만료된 구독 처리
  Future<void> processExpiredSubscriptions() async {
    final now = DateTime.now();
    final snapshot = await collection
        .where('endDate', isLessThan: Timestamp.fromDate(now))
        .where('isActive', isEqualTo: true)
        .get();

    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isActive': false,
        'plan': SubscriptionPlan.free.name,
      });
    }
    await batch.commit();
  }

  /// 기능 접근 권한 확인 - 모든 기능 무료 개방
  Future<bool> hasFeatureAccess(String userId, String feature) async {
    // 모든 기능 무료 개방 - 제한 없음
    return true;
  }
}
