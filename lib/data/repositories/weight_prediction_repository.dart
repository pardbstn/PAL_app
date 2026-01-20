import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weight_prediction_model.dart';
import 'base_repository.dart';

/// WeightPredictionRepository Provider
final weightPredictionRepositoryProvider =
    Provider<WeightPredictionRepository>((ref) {
  return WeightPredictionRepository(firestore: ref.watch(firestoreProvider));
});

/// AI 체중 예측 결과 Repository
/// 회원별 체중 예측 데이터를 Firestore에 저장/조회
class WeightPredictionRepository {
  final FirebaseFirestore _firestore;

  WeightPredictionRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  /// 컬렉션 참조
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('predictions');

  /// 해당 회원의 가장 최근 예측 결과 조회
  ///
  /// [memberId] 회원 ID
  /// Returns 가장 최근 예측 결과, 없으면 null
  Future<WeightPredictionModel?> getLatestPrediction(String memberId) async {
    try {
      final snapshot = await _collection
          .where('memberId', isEqualTo: memberId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return WeightPredictionModel.fromFirestore(snapshot.docs.first);
    } on FirebaseException catch (e) {
      print('[WeightPredictionRepository] getLatestPrediction 오류: $e');
      rethrow;
    }
  }

  /// 해당 회원의 가장 최근 예측 결과 실시간 구독
  ///
  /// [memberId] 회원 ID
  /// Returns 실시간 Stream, 예측이 없으면 null 방출
  Stream<WeightPredictionModel?> watchLatestPrediction(String memberId) {
    return _collection
        .where('memberId', isEqualTo: memberId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return WeightPredictionModel.fromFirestore(snapshot.docs.first);
    });
  }

  /// 새 예측 결과 저장
  ///
  /// [prediction] 저장할 예측 모델
  /// Returns 생성된 문서 ID
  Future<String> savePrediction(WeightPredictionModel prediction) async {
    try {
      final docRef = await _collection.add(prediction.toFirestore());
      print('[WeightPredictionRepository] 예측 저장 완료: ${docRef.id}');
      return docRef.id;
    } on FirebaseException catch (e) {
      print('[WeightPredictionRepository] savePrediction 오류: $e');
      rethrow;
    }
  }

  /// 예측 결과 업데이트
  ///
  /// [predictionId] 예측 문서 ID
  /// [data] 업데이트할 필드 Map
  Future<void> updatePrediction(
    String predictionId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _collection.doc(predictionId).update(data);
      print('[WeightPredictionRepository] 예측 업데이트 완료: $predictionId');
    } on FirebaseException catch (e) {
      print('[WeightPredictionRepository] updatePrediction 오류: $e');
      rethrow;
    }
  }

  /// 해당 회원의 예측 히스토리 조회
  ///
  /// [memberId] 회원 ID
  /// [limit] 조회할 최대 개수 (기본값: 10)
  /// Returns 최근 순으로 정렬된 예측 목록
  Future<List<WeightPredictionModel>> getPredictionHistory(
    String memberId, {
    int limit = 10,
  }) async {
    try {
      final snapshot = await _collection
          .where('memberId', isEqualTo: memberId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => WeightPredictionModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      print('[WeightPredictionRepository] getPredictionHistory 오류: $e');
      rethrow;
    }
  }

  /// 예측 히스토리 실시간 구독
  ///
  /// [memberId] 회원 ID
  /// [limit] 조회할 최대 개수 (기본값: 10)
  /// Returns 최근 순으로 정렬된 예측 목록 Stream
  Stream<List<WeightPredictionModel>> watchPredictionHistory(
    String memberId, {
    int limit = 10,
  }) {
    return _collection
        .where('memberId', isEqualTo: memberId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => WeightPredictionModel.fromFirestore(doc))
          .toList();
    });
  }

  /// 예측 결과 삭제
  ///
  /// [predictionId] 삭제할 예측 문서 ID
  Future<void> deletePrediction(String predictionId) async {
    try {
      await _collection.doc(predictionId).delete();
      print('[WeightPredictionRepository] 예측 삭제 완료: $predictionId');
    } on FirebaseException catch (e) {
      print('[WeightPredictionRepository] deletePrediction 오류: $e');
      rethrow;
    }
  }

  /// 특정 예측 조회
  ///
  /// [predictionId] 예측 문서 ID
  /// Returns 예측 결과, 없으면 null
  Future<WeightPredictionModel?> getPrediction(String predictionId) async {
    try {
      final doc = await _collection.doc(predictionId).get();
      if (!doc.exists) return null;
      return WeightPredictionModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      print('[WeightPredictionRepository] getPrediction 오류: $e');
      rethrow;
    }
  }

  /// 특정 예측 실시간 구독
  ///
  /// [predictionId] 예측 문서 ID
  /// Returns 예측 결과 Stream
  Stream<WeightPredictionModel?> watchPrediction(String predictionId) {
    return _collection.doc(predictionId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return WeightPredictionModel.fromFirestore(doc);
    });
  }

  /// 트레이너의 모든 회원 예측 조회
  ///
  /// [trainerId] 트레이너 ID
  /// [limit] 조회할 최대 개수 (기본값: 50)
  /// Returns 최근 순으로 정렬된 예측 목록
  Future<List<WeightPredictionModel>> getPredictionsByTrainer(
    String trainerId, {
    int limit = 50,
  }) async {
    try {
      final snapshot = await _collection
          .where('trainerId', isEqualTo: trainerId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => WeightPredictionModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      print('[WeightPredictionRepository] getPredictionsByTrainer 오류: $e');
      rethrow;
    }
  }

  /// 회원의 예측 존재 여부 확인
  ///
  /// [memberId] 회원 ID
  /// Returns 예측이 있으면 true
  Future<bool> hasPrediction(String memberId) async {
    try {
      final snapshot = await _collection
          .where('memberId', isEqualTo: memberId)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } on FirebaseException catch (e) {
      print('[WeightPredictionRepository] hasPrediction 오류: $e');
      rethrow;
    }
  }

  /// 회원의 모든 예측 삭제
  ///
  /// [memberId] 회원 ID
  /// 회원 탈퇴 시 사용
  Future<void> deleteAllPredictions(String memberId) async {
    try {
      final snapshot = await _collection
          .where('memberId', isEqualTo: memberId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      print(
          '[WeightPredictionRepository] 회원 예측 전체 삭제 완료: $memberId (${snapshot.docs.length}개)');
    } on FirebaseException catch (e) {
      print('[WeightPredictionRepository] deleteAllPredictions 오류: $e');
      rethrow;
    }
  }
}
