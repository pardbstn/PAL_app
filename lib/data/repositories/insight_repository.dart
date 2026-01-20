/// 인사이트 Repository
///
/// AI가 생성한 회원 관리 인사이트 데이터 액세스 레이어
/// 트레이너에게 회원 관리에 필요한 알림과 추천을 제공하는 저장소
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/insight_model.dart';
import 'base_repository.dart';

/// InsightRepository Provider
final insightRepositoryProvider = Provider<InsightRepository>((ref) {
  return InsightRepository(firestore: ref.watch(firestoreProvider));
});

/// 인사이트 Repository
/// 트레이너용 AI 인사이트 데이터 CRUD 및 실시간 구독 제공
class InsightRepository extends BaseRepository<InsightModel> {
  InsightRepository({required super.firestore})
      : super(collectionPath: 'insights');

  // ============================================================
  // BaseRepository 필수 메서드 구현
  // ============================================================

  /// 단일 인사이트 조회
  @override
  Future<InsightModel?> get(String id) async {
    final doc = await collection.doc(id).get();
    if (!doc.exists) return null;
    return InsightModel.fromFirestore(doc);
  }

  /// 모든 인사이트 조회
  @override
  Future<List<InsightModel>> getAll() async {
    final snapshot = await collection.get();
    return snapshot.docs
        .map((doc) => InsightModel.fromFirestore(doc))
        .toList();
  }

  /// 인사이트 생성
  @override
  Future<String> create(InsightModel insight) async {
    final docRef = await collection.add(insight.toFirestore());
    return docRef.id;
  }

  /// 인사이트 업데이트
  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    await collection.doc(id).update(data);
  }

  /// 인사이트 삭제
  @override
  Future<void> delete(String id) async {
    await collection.doc(id).delete();
  }

  /// 단일 인사이트 실시간 감시
  @override
  Stream<InsightModel?> watch(String id) {
    return collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return InsightModel.fromFirestore(doc);
    });
  }

  /// 모든 인사이트 실시간 감시
  @override
  Stream<List<InsightModel>> watchAll() {
    return collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => InsightModel.fromFirestore(doc))
          .toList();
    });
  }

  // ============================================================
  // 커스텀 메서드
  // ============================================================

  /// 트레이너의 인사이트 목록 실시간 감시
  ///
  /// [trainerId] 트레이너 ID
  /// [unreadOnly] true이면 읽지 않은 인사이트만 조회
  ///
  /// 만료되지 않은 인사이트만 반환하며, 생성일 기준 내림차순 정렬
  Stream<List<InsightModel>> watchTrainerInsights(
    String trainerId, {
    bool unreadOnly = false,
  }) {
    final now = DateTime.now();

    Query<Map<String, dynamic>> query = collection
        .where('trainerId', isEqualTo: trainerId)
        .orderBy('createdAt', descending: true);

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => InsightModel.fromFirestore(doc))
          .where((insight) {
            // 만료 필터: expiresAt이 null이거나 현재 시간 이후
            final notExpired =
                insight.expiresAt == null || insight.expiresAt!.isAfter(now);
            // 읽음 필터: unreadOnly가 true이면 읽지 않은 것만
            final passReadFilter = !unreadOnly || !insight.isRead;
            return notExpired && passReadFilter;
          })
          .toList();
    });
  }

  /// 트레이너의 인사이트 목록 조회 (일회성)
  ///
  /// [trainerId] 트레이너 ID
  /// [limit] 최대 조회 개수 (기본값: 20)
  ///
  /// 만료되지 않은 인사이트만 반환하며, 생성일 기준 내림차순 정렬
  Future<List<InsightModel>> getTrainerInsights(
    String trainerId, {
    int limit = 20,
  }) async {
    final now = DateTime.now();

    final snapshot = await collection
        .where('trainerId', isEqualTo: trainerId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => InsightModel.fromFirestore(doc))
        .where((insight) =>
            insight.expiresAt == null || insight.expiresAt!.isAfter(now))
        .toList();
  }

  /// 읽지 않은 인사이트 개수 실시간 감시
  ///
  /// [trainerId] 트레이너 ID
  ///
  /// 만료되지 않고 읽지 않은 인사이트 개수를 실시간으로 반환
  Stream<int> watchUnreadCount(String trainerId) {
    final now = DateTime.now();

    return collection
        .where('trainerId', isEqualTo: trainerId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => InsightModel.fromFirestore(doc))
          .where((insight) =>
              insight.expiresAt == null || insight.expiresAt!.isAfter(now))
          .length;
    });
  }

  /// 인사이트 읽음 처리
  ///
  /// [insightId] 인사이트 ID
  Future<void> markAsRead(String insightId) async {
    await collection.doc(insightId).update({
      'isRead': true,
    });
  }

  /// 트레이너의 모든 인사이트 읽음 처리
  ///
  /// [trainerId] 트레이너 ID
  ///
  /// 해당 트레이너의 모든 읽지 않은 인사이트를 배치로 읽음 처리
  Future<void> markAllAsRead(String trainerId) async {
    final snapshot = await collection
        .where('trainerId', isEqualTo: trainerId)
        .where('isRead', isEqualTo: false)
        .get();

    if (snapshot.docs.isEmpty) return;

    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  /// 인사이트 조치 완료 처리
  ///
  /// [insightId] 인사이트 ID
  Future<void> markActionTaken(String insightId) async {
    await collection.doc(insightId).update({
      'isActionTaken': true,
    });
  }

  /// 인사이트 저장 (단일)
  ///
  /// [insight] 저장할 인사이트 모델
  ///
  /// 새 인사이트를 생성하고 문서 ID를 반환
  Future<void> saveInsight(InsightModel insight) async {
    await collection.add(insight.toFirestore());
  }

  /// 인사이트 저장 (배치)
  ///
  /// [insights] 저장할 인사이트 목록
  ///
  /// 여러 인사이트를 배치로 한 번에 저장
  Future<void> saveInsights(List<InsightModel> insights) async {
    if (insights.isEmpty) return;

    final batch = firestore.batch();
    for (final insight in insights) {
      final docRef = collection.doc();
      batch.set(docRef, insight.toFirestore());
    }
    await batch.commit();
  }

  /// 인사이트 삭제 (단일)
  ///
  /// [insightId] 삭제할 인사이트 ID
  Future<void> deleteInsight(String insightId) async {
    await collection.doc(insightId).delete();
  }

  /// 만료된 인사이트 삭제
  ///
  /// [trainerId] 트레이너 ID
  ///
  /// 해당 트레이너의 만료된 인사이트를 배치로 삭제
  Future<void> deleteExpiredInsights(String trainerId) async {
    final now = DateTime.now();

    final snapshot = await collection
        .where('trainerId', isEqualTo: trainerId)
        .where('expiresAt', isLessThan: Timestamp.fromDate(now))
        .get();

    if (snapshot.docs.isEmpty) return;

    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// 인사이트 유형별 조회
  ///
  /// [trainerId] 트레이너 ID
  /// [type] 인사이트 유형
  ///
  /// 해당 트레이너의 특정 유형 인사이트 목록 반환
  Future<List<InsightModel>> getInsightsByType(
    String trainerId,
    InsightType type,
  ) async {
    final now = DateTime.now();

    final snapshot = await collection
        .where('trainerId', isEqualTo: trainerId)
        .where('type', isEqualTo: type.name)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => InsightModel.fromFirestore(doc))
        .where((insight) =>
            insight.expiresAt == null || insight.expiresAt!.isAfter(now))
        .toList();
  }

  /// 회원별 인사이트 조회
  ///
  /// [memberId] 회원 ID
  ///
  /// 특정 회원에 관련된 모든 인사이트 목록 반환
  Future<List<InsightModel>> getInsightsByMember(String memberId) async {
    final now = DateTime.now();

    final snapshot = await collection
        .where('memberId', isEqualTo: memberId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => InsightModel.fromFirestore(doc))
        .where((insight) =>
            insight.expiresAt == null || insight.expiresAt!.isAfter(now))
        .toList();
  }
}
