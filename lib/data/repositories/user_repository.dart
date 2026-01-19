import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import 'base_repository.dart';

/// UserRepository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(firestore: ref.watch(firestoreProvider));
});

/// 사용자 Repository
class UserRepository extends BaseRepository<UserModel> {
  UserRepository({required super.firestore}) : super(collectionPath: 'users');

  @override
  Future<UserModel?> get(String id) async {
    final doc = await collection.doc(id).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  @override
  Future<List<UserModel>> getAll() async {
    final snapshot = await collection.get();
    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  @override
  Future<String> create(UserModel user) async {
    // UID가 비어있으면 자동 생성
    if (user.uid.isEmpty) {
      final docRef = await collection.add(user.toFirestore());
      return docRef.id;
    }
    // UID를 문서 ID로 사용
    await collection.doc(user.uid).set(user.toFirestore());
    return user.uid;
  }

  /// 새 사용자 생성 (UID 지정)
  Future<void> createWithUid(String uid, UserModel user) async {
    await collection.doc(uid).set(user.toFirestore());
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await collection.doc(id).update(data);
  }

  @override
  Future<void> delete(String id) async {
    await collection.doc(id).delete();
  }

  @override
  Stream<UserModel?> watch(String id) {
    return collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  @override
  Stream<List<UserModel>> watchAll() {
    return collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    });
  }

  /// 이메일로 사용자 찾기
  Future<UserModel?> getByEmail(String email) async {
    final snapshot =
        await collection.where('email', isEqualTo: email).limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    return UserModel.fromFirestore(snapshot.docs.first);
  }

  /// 역할별 사용자 목록
  Future<List<UserModel>> getByRole(UserRoleType role) async {
    final snapshot =
        await collection.where('role', isEqualTo: role.name).get();
    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  /// 이름과 회원 코드로 사용자 찾기 (예: "홍길동", "1234")
  Future<UserModel?> getByNameAndCode(String name, String memberCode) async {
    final snapshot = await collection
        .where('name', isEqualTo: name)
        .where('memberCode', isEqualTo: memberCode)
        .where('role', isEqualTo: 'member')
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return UserModel.fromFirestore(snapshot.docs.first);
  }
}
