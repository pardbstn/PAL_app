import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';
import '../models/trainer_stats_model.dart';

/// 트레이너 통계 레포지토리
class TrainerStatsRepository {
  final FirebaseFirestore _firestore;

  TrainerStatsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// 통계 조회
  Future<TrainerStatsModel?> getStats(String trainerId) async {
    final doc = await _firestore
        .collection(FirestoreCollections.trainers)
        .doc(trainerId)
        .collection(FirestoreCollections.stats)
        .doc('current')
        .get();
    if (!doc.exists) return null;
    return TrainerStatsModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  /// 통계 업데이트
  Future<void> updateStats(String trainerId, TrainerStatsModel stats) async {
    await _firestore
        .collection(FirestoreCollections.trainers)
        .doc(trainerId)
        .collection(FirestoreCollections.stats)
        .doc('current')
        .set(stats.toJson());
  }

  /// 응답 시간 업데이트 (메시지 발송 시 호출)
  Future<void> updateResponseTime(String trainerId, double newAvgMinutes) async {
    await _firestore
        .collection(FirestoreCollections.trainers)
        .doc(trainerId)
        .collection(FirestoreCollections.stats)
        .doc('current')
        .update({
      'avgResponseTimeMinutes': newAvgMinutes,
      'lastCalculated': FieldValue.serverTimestamp(),
    });
  }

  /// 능동적 메시지 수 증가
  Future<void> incrementProactiveMessage(String trainerId) async {
    await _firestore
        .collection(FirestoreCollections.trainers)
        .doc(trainerId)
        .collection(FirestoreCollections.stats)
        .doc('current')
        .update({
      'proactiveMessageCount': FieldValue.increment(1),
      'lastCalculated': FieldValue.serverTimestamp(),
    });
  }

  /// 식단 피드백 수 증가
  Future<void> incrementDietFeedback(String trainerId) async {
    await _firestore
        .collection(FirestoreCollections.trainers)
        .doc(trainerId)
        .collection(FirestoreCollections.stats)
        .doc('current')
        .update({
      'dietFeedbackCount': FieldValue.increment(1),
      'lastCalculated': FieldValue.serverTimestamp(),
    });
  }

  /// 데이터 조회 수 증가
  Future<void> incrementDataView(String trainerId) async {
    await _firestore
        .collection(FirestoreCollections.trainers)
        .doc(trainerId)
        .collection(FirestoreCollections.stats)
        .doc('current')
        .update({
      'weeklyMemberDataViewCount': FieldValue.increment(1),
      'lastCalculated': FieldValue.serverTimestamp(),
    });
  }

  /// 통계 스트림 (실시간)
  Stream<TrainerStatsModel?> watchStats(String trainerId) {
    return _firestore
        .collection(FirestoreCollections.trainers)
        .doc(trainerId)
        .collection(FirestoreCollections.stats)
        .doc('current')
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return TrainerStatsModel.fromJson({...doc.data()!, 'id': doc.id});
    });
  }
}
