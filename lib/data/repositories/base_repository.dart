import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firestore 인스턴스 Provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// 기본 Repository 클래스
/// 모든 Firestore Repository의 베이스 클래스
abstract class BaseRepository<T> {
  final FirebaseFirestore firestore;
  final String collectionPath;

  BaseRepository({
    required this.firestore,
    required this.collectionPath,
  });

  /// 컬렉션 레퍼런스
  CollectionReference<Map<String, dynamic>> get collection =>
      firestore.collection(collectionPath);

  /// 단일 문서 가져오기
  Future<T?> get(String id);

  /// 모든 문서 가져오기
  Future<List<T>> getAll();

  /// 문서 생성
  Future<String> create(T item);

  /// 문서 업데이트
  Future<void> update(String id, Map<String, dynamic> data);

  /// 문서 삭제
  Future<void> delete(String id);

  /// 문서 존재 여부 확인
  Future<bool> exists(String id) async {
    final doc = await collection.doc(id).get();
    return doc.exists;
  }

  /// 실시간 스트림 (단일 문서)
  Stream<T?> watch(String id);

  /// 실시간 스트림 (전체)
  Stream<List<T>> watchAll();
}
