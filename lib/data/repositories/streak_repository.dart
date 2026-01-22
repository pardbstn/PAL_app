import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/streak_model.dart';
import 'base_repository.dart';

final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  return StreakRepository(firestore: ref.watch(firestoreProvider));
});

class StreakRepository extends BaseRepository<StreakModel> {
  StreakRepository({required super.firestore})
      : super(collectionPath: 'streaks');

  /// 스트릭 조회 (memberId가 문서 ID)
  @override
  Future<StreakModel?> get(String memberId) async {
    final doc = await collection.doc(memberId).get();
    if (!doc.exists) return null;
    return StreakModel.fromFirestore(doc);
  }

  /// 모든 스트릭 조회
  @override
  Future<List<StreakModel>> getAll() async {
    final snapshot = await collection.get();
    return snapshot.docs.map((doc) => StreakModel.fromFirestore(doc)).toList();
  }

  /// 스트릭 생성
  @override
  Future<String> create(StreakModel streak) async {
    await collection.doc(streak.memberId).set(streak.toFirestore());
    return streak.memberId;
  }

  /// 스트릭 업데이트
  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    await collection.doc(id).update(data);
  }

  /// 스트릭 삭제
  @override
  Future<void> delete(String id) async {
    await collection.doc(id).delete();
  }

  /// 스트릭 실시간 감시
  @override
  Stream<StreakModel?> watch(String memberId) {
    return collection.doc(memberId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return StreakModel.fromFirestore(doc);
    });
  }

  /// 모든 스트릭 실시간 감시
  @override
  Stream<List<StreakModel>> watchAll() {
    return collection.snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => StreakModel.fromFirestore(doc)).toList());
  }

  /// 스트릭 생성 또는 업데이트
  Future<void> createOrUpdate(StreakModel streak) async {
    await collection.doc(streak.memberId).set(
      streak.toFirestore(),
      SetOptions(merge: true),
    );
  }

  /// 체중 스트릭 업데이트
  Future<StreakModel> updateWeightStreak(String memberId, DateTime recordDate) async {
    final existing = await get(memberId);
    final now = DateTime.now();
    final recordDay = DateTime(recordDate.year, recordDate.month, recordDate.day);

    if (existing == null) {
      // 새 스트릭 생성
      final newStreak = StreakModel(
        id: memberId,
        memberId: memberId,
        weightStreak: 1,
        longestWeightStreak: 1,
        lastWeightRecordDate: recordDay,
        updatedAt: now,
      );
      await createOrUpdate(newStreak);
      return newStreak;
    }

    // 연속 기록 체크
    final lastDate = existing.lastWeightRecordDate;
    int newStreak = existing.weightStreak;

    if (lastDate != null) {
      final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
      final diff = recordDay.difference(lastDay).inDays;

      if (diff == 0) {
        // 같은 날 - 변경 없음
        return existing;
      } else if (diff == 1) {
        // 연속 - 스트릭 증가
        newStreak = existing.weightStreak + 1;
      } else {
        // 끊김 - 리셋
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }

    final longestStreak = newStreak > existing.longestWeightStreak
        ? newStreak
        : existing.longestWeightStreak;

    await collection.doc(memberId).update({
      'weightStreak': newStreak,
      'longestWeightStreak': longestStreak,
      'lastWeightRecordDate': Timestamp.fromDate(recordDay),
      'updatedAt': Timestamp.fromDate(now),
    });

    return existing.copyWith(
      weightStreak: newStreak,
      longestWeightStreak: longestStreak,
      lastWeightRecordDate: recordDay,
      updatedAt: now,
    );
  }

  /// 식단 스트릭 업데이트
  Future<StreakModel> updateDietStreak(String memberId, DateTime recordDate) async {
    final existing = await get(memberId);
    final now = DateTime.now();
    final recordDay = DateTime(recordDate.year, recordDate.month, recordDate.day);

    if (existing == null) {
      final newStreak = StreakModel(
        id: memberId,
        memberId: memberId,
        dietStreak: 1,
        longestDietStreak: 1,
        lastDietRecordDate: recordDay,
        updatedAt: now,
      );
      await createOrUpdate(newStreak);
      return newStreak;
    }

    final lastDate = existing.lastDietRecordDate;
    int newStreak = existing.dietStreak;

    if (lastDate != null) {
      final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
      final diff = recordDay.difference(lastDay).inDays;

      if (diff == 0) {
        return existing;
      } else if (diff == 1) {
        newStreak = existing.dietStreak + 1;
      } else {
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }

    final longestStreak = newStreak > existing.longestDietStreak
        ? newStreak
        : existing.longestDietStreak;

    await collection.doc(memberId).update({
      'dietStreak': newStreak,
      'longestDietStreak': longestStreak,
      'lastDietRecordDate': Timestamp.fromDate(recordDay),
      'updatedAt': Timestamp.fromDate(now),
    });

    return existing.copyWith(
      dietStreak: newStreak,
      longestDietStreak: longestStreak,
      lastDietRecordDate: recordDay,
      updatedAt: now,
    );
  }

  /// 배지 추가
  Future<void> addBadge(String memberId, String badgeCode) async {
    await collection.doc(memberId).update({
      'badges': FieldValue.arrayUnion([badgeCode]),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// 스트릭 리셋 (자정에 체크용)
  Future<void> resetStaleStreaks() async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final cutoff = DateTime(yesterday.year, yesterday.month, yesterday.day);

    // 체중 스트릭 리셋
    final weightStale = await collection
        .where('lastWeightRecordDate', isLessThan: Timestamp.fromDate(cutoff))
        .where('weightStreak', isGreaterThan: 0)
        .get();

    final batch = firestore.batch();
    for (final doc in weightStale.docs) {
      batch.update(doc.reference, {
        'weightStreak': 0,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    }

    // 식단 스트릭 리셋
    final dietStale = await collection
        .where('lastDietRecordDate', isLessThan: Timestamp.fromDate(cutoff))
        .where('dietStreak', isGreaterThan: 0)
        .get();

    for (final doc in dietStale.docs) {
      batch.update(doc.reference, {
        'dietStreak': 0,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    }

    await batch.commit();
  }
}
