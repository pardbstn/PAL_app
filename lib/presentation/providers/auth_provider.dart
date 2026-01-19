import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_pal_app/data/models/models.dart';
import 'package:flutter_pal_app/data/repositories/repositories.dart';

/// 사용자 역할 enum
enum UserRole { trainer, member }

/// 인증 상태 클래스
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final UserRole? userRole;
  final String? userId;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? errorMessage;
  final UserModel? userModel;
  final TrainerModel? trainerModel;
  final MemberModel? memberModel;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.userRole,
    this.userId,
    this.email,
    this.displayName,
    this.photoUrl,
    this.errorMessage,
    this.userModel,
    this.trainerModel,
    this.memberModel,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    UserRole? userRole,
    String? userId,
    String? email,
    String? displayName,
    String? photoUrl,
    String? errorMessage,
    UserModel? userModel,
    TrainerModel? trainerModel,
    MemberModel? memberModel,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      userRole: userRole ?? this.userRole,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      errorMessage: errorMessage,
      userModel: userModel ?? this.userModel,
      trainerModel: trainerModel ?? this.trainerModel,
      memberModel: memberModel ?? this.memberModel,
    );
  }
}

/// 인증 상태 Notifier
class AuthNotifier extends Notifier<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  UserRepository get _userRepository => ref.read(userRepositoryProvider);
  TrainerRepository get _trainerRepository =>
      ref.read(trainerRepositoryProvider);
  MemberRepository get _memberRepository => ref.read(memberRepositoryProvider);

  @override
  AuthState build() {
    // Firebase Auth 상태 변화 리스닝
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        // Firestore에서 사용자 정보 로드
        await _loadUserData(user.uid);
      } else {
        state = const AuthState();
      }
    });

    return const AuthState();
  }

  /// Firestore에서 사용자 데이터 로드
  Future<void> _loadUserData(String uid) async {
    try {
      var userModel = await _userRepository.get(uid);

      // Firebase Auth UID로 찾지 못한 경우, 이메일로 검색 (트레이너가 사전 등록한 회원)
      if (userModel == null) {
        final email = _auth.currentUser?.email;
        if (email != null) {
          final userByEmail = await _userRepository.getByEmail(email);
          if (userByEmail != null) {
            // 기존 문서 ID (Firestore 자동 생성 ID)
            final oldUserId = userByEmail.uid;

            // Firebase Auth UID로 새 문서 생성
            final migratedUser = UserModel(
              uid: uid,
              email: userByEmail.email,
              name: userByEmail.name,
              role: userByEmail.role,
              profileImageUrl: _auth.currentUser?.photoURL ?? userByEmail.profileImageUrl,
              phone: userByEmail.phone,
              createdAt: userByEmail.createdAt,
              updatedAt: DateTime.now(),
            );
            await _userRepository.createWithUid(uid, migratedUser);

            // members 컬렉션에서 userId 업데이트
            final oldMember = await _memberRepository.getByUserId(oldUserId);
            if (oldMember != null) {
              await _memberRepository.update(oldMember.id, {'userId': uid});
            }

            // 기존 문서 삭제
            await _userRepository.delete(oldUserId);

            userModel = migratedUser;
          }
        }
      }

      if (userModel != null) {
        final role = userModel.role == UserRoleType.trainer
            ? UserRole.trainer
            : UserRole.member;

        // 회원인데 memberCode가 없으면 자동 생성
        if (role == UserRole.member && userModel.memberCode == null) {
          final newCode = _generateMemberCode();
          await _userRepository.update(uid, {'memberCode': newCode});
          userModel = userModel.copyWith(memberCode: newCode);
        }

        TrainerModel? trainerModel;
        MemberModel? memberModel;

        if (role == UserRole.trainer) {
          trainerModel = await _trainerRepository.getByUserId(uid);
          // 트레이너 프로필이 없으면 자동 생성
          if (trainerModel == null) {
            final trainerId = await _trainerRepository.createForUser(uid);
            trainerModel = await _trainerRepository.get(trainerId);
          }
        } else {
          memberModel = await _memberRepository.getByUserId(uid);
          // 회원 프로필이 없으면 실시간 감시 시작 (나중에 트레이너가 등록할 수 있음)
          if (memberModel == null) {
            _memberRepository.watchByUserId(uid).listen((member) {
              if (member != null && state.memberModel == null) {
                state = state.copyWith(memberModel: member);
              }
            });
          }
        }

        state = state.copyWith(
          isAuthenticated: true,
          userId: uid,
          email: userModel.email,
          displayName: userModel.name,
          photoUrl: userModel.profileImageUrl,
          userRole: role,
          userModel: userModel,
          trainerModel: trainerModel,
          memberModel: memberModel,
        );
      } else {
        // Firestore에 사용자 정보가 없으면 기본 상태만 설정
        final user = _auth.currentUser;
        state = state.copyWith(
          isAuthenticated: true,
          userId: uid,
          email: user?.email,
          displayName: user?.displayName,
          photoUrl: user?.photoURL,
        );
      }
    } catch (e) {
      // 에러 발생 시 기본 인증 상태만 유지
      final user = _auth.currentUser;
      state = state.copyWith(
        isAuthenticated: true,
        userId: uid,
        email: user?.email,
        displayName: user?.displayName,
        photoUrl: user?.photoURL,
      );
    }
  }

  /// 역할 설정
  void setRole(UserRole role) {
    state = state.copyWith(userRole: role);
  }

  /// Firestore에 사용자 저장/업데이트
  Future<void> _saveUserToFirestore(User user, UserRole role) async {
    final now = DateTime.now();
    final roleType =
        role == UserRole.trainer ? UserRoleType.trainer : UserRoleType.member;

    // 1. Firebase Auth UID로 기존 사용자 확인
    var existingUser = await _userRepository.get(user.uid);

    if (existingUser != null) {
      // 기존 사용자 - 마지막 로그인 시간 업데이트
      await _userRepository.update(user.uid, {
        'updatedAt': now,
      });

      // 역할이 변경된 경우 역할 프로필 확인/생성
      if (existingUser.role != roleType) {
        await _createRoleProfile(user.uid, role);
      }
      return;
    }

    // 2. UID로 못 찾은 경우, 이메일로 검색 (트레이너가 사전 등록한 회원)
    if (user.email != null) {
      final userByEmail = await _userRepository.getByEmail(user.email!);
      if (userByEmail != null) {
        // 기존 문서 ID (Firestore 자동 생성 ID)
        final oldUserId = userByEmail.uid;

        // Firebase Auth UID로 새 문서 생성
        final migratedUser = UserModel(
          uid: user.uid,
          email: userByEmail.email,
          name: userByEmail.name.isNotEmpty
              ? userByEmail.name
              : user.displayName ?? user.email?.split('@').first ?? '사용자',
          role: userByEmail.role, // 트레이너가 설정한 역할 유지
          profileImageUrl: user.photoURL ?? userByEmail.profileImageUrl,
          phone: userByEmail.phone,
          createdAt: userByEmail.createdAt,
          updatedAt: now,
        );
        await _userRepository.createWithUid(user.uid, migratedUser);

        // members 컬렉션에서 userId 업데이트
        final oldMember = await _memberRepository.getByUserId(oldUserId);
        if (oldMember != null) {
          await _memberRepository.update(oldMember.id, {'userId': user.uid});
        }

        // trainers 컬렉션에서도 userId 업데이트 (트레이너로 전환하는 경우)
        final oldTrainer = await _trainerRepository.getByUserId(oldUserId);
        if (oldTrainer != null) {
          await _trainerRepository.update(oldTrainer.id, {'userId': user.uid});
        }

        // 기존 문서 삭제
        await _userRepository.delete(oldUserId);
        return;
      }
    }

    // 3. 완전히 새로운 사용자 생성
    // 회원인 경우 4자리 회원 코드 생성
    String? memberCode;
    if (role == UserRole.member) {
      memberCode = _generateMemberCode();
    }

    final userModel = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? user.email?.split('@').first ?? '사용자',
      role: roleType,
      profileImageUrl: user.photoURL,
      phone: user.phoneNumber,
      memberCode: memberCode,
      createdAt: now,
      updatedAt: now,
    );

    await _userRepository.create(userModel);

    // 역할에 따른 프로필 생성
    await _createRoleProfile(user.uid, role);
  }

  /// 4자리 회원 코드 생성 (0000-9999)
  String _generateMemberCode() {
    final random = Random();
    return random.nextInt(10000).toString().padLeft(4, '0');
  }

  /// 역할별 프로필 생성
  Future<void> _createRoleProfile(String userId, UserRole role) async {
    final now = DateTime.now();

    if (role == UserRole.trainer) {
      // 트레이너 프로필 생성
      final existingTrainer = await _trainerRepository.getByUserId(userId);
      if (existingTrainer == null) {
        final trainer = TrainerModel(
          id: '',
          userId: userId,
          subscriptionTier: SubscriptionTier.free,
          memberIds: [],
          aiUsage: AiUsage(
            curriculumCount: 0,
            predictionCount: 0,
            resetDate: DateTime(now.year, now.month, 1),
          ),
        );
        await _trainerRepository.create(trainer);
      }
    } else {
      // 회원 프로필은 트레이너가 등록할 때 생성
      // 여기서는 기본 프로필만 생성
      final existingMember = await _memberRepository.getByUserId(userId);
      if (existingMember == null) {
        final member = MemberModel(
          id: '',
          userId: userId,
          trainerId: '', // 트레이너 배정 전
          goal: FitnessGoal.fitness,
          experience: ExperienceLevel.beginner,
          ptInfo: PtInfo(
            totalSessions: 0,
            completedSessions: 0,
            startDate: now,
          ),
        );
        await _memberRepository.create(member);
      }
    }
  }

  /// 이메일/비밀번호 로그인
  Future<void> signInWithEmail(
    String email,
    String password,
    UserRole role,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        // Firestore에 사용자 저장/업데이트
        await _saveUserToFirestore(credential.user!, role);

        // 사용자 데이터 로드
        await _loadUserData(credential.user!.uid);

        state = state.copyWith(
          isLoading: false,
          userRole: role,
        );
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e.code),
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '로그인 중 오류가 발생했습니다.',
      );
      rethrow;
    }
  }

  /// 이메일/비밀번호 회원가입
  Future<void> signUpWithEmail(
    String email,
    String password,
    UserRole role,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        // Firestore에 사용자 저장
        await _saveUserToFirestore(credential.user!, role);

        // 사용자 데이터 로드
        await _loadUserData(credential.user!.uid);

        state = state.copyWith(
          isLoading: false,
          userRole: role,
        );
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e.code),
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '회원가입 중 오류가 발생했습니다.',
      );
      rethrow;
    }
  }

  /// 구글 소셜 로그인
  Future<void> signInWithGoogle(UserRole role) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 구글 로그인 플로우 시작
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // 사용자가 로그인 취소
        state = state.copyWith(isLoading: false);
        return;
      }

      // 구글 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Firebase 인증 자격 증명 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase에 로그인
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Firestore에 사용자 저장/업데이트
        await _saveUserToFirestore(userCredential.user!, role);

        // 사용자 데이터 로드
        await _loadUserData(userCredential.user!.uid);

        state = state.copyWith(
          isLoading: false,
          userRole: role,
        );
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e.code),
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '구글 로그인 중 오류가 발생했습니다.',
      );
      rethrow;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// 비밀번호 재설정 이메일 전송
  Future<void> sendPasswordResetEmail(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      state = state.copyWith(isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e.code),
      );
      rethrow;
    }
  }

  /// 사용자 프로필 업데이트
  Future<void> updateProfile({
    String? name,
    String? photoUrl,
    String? phone,
  }) async {
    if (state.userId == null) return;

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (photoUrl != null) updates['profileImageUrl'] = photoUrl;
    if (phone != null) updates['phone'] = phone;

    if (updates.isNotEmpty) {
      await _userRepository.update(state.userId!, updates);
      await _loadUserData(state.userId!);
    }
  }

  /// Firebase Auth 에러 메시지 변환
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return '등록되지 않은 이메일입니다.';
      case 'wrong-password':
        return '비밀번호가 올바르지 않습니다.';
      case 'invalid-email':
        return '유효하지 않은 이메일 형식입니다.';
      case 'user-disabled':
        return '비활성화된 계정입니다.';
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'weak-password':
        return '비밀번호가 너무 약합니다. 6자 이상 입력해주세요.';
      case 'operation-not-allowed':
        return '이메일/비밀번호 로그인이 비활성화되어 있습니다.';
      case 'too-many-requests':
        return '너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요.';
      case 'invalid-credential':
        return '이메일 또는 비밀번호가 올바르지 않습니다.';
      default:
        return '인증 오류가 발생했습니다. ($code)';
    }
  }
}

/// 인증 상태 Provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

/// 로그인 여부 Provider
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// 로딩 상태 Provider
final isAuthLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

/// 사용자 역할 Provider
final userRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(authProvider).userRole;
});

/// 현재 사용자 Provider
final currentUserProvider = Provider<User?>((ref) {
  return FirebaseAuth.instance.currentUser;
});

/// 현재 사용자 모델 Provider
final currentUserModelProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).userModel;
});

/// 현재 트레이너 모델 Provider
final currentTrainerProvider = Provider<TrainerModel?>((ref) {
  return ref.watch(authProvider).trainerModel;
});

/// 현재 회원 모델 Provider
final currentMemberProvider = Provider<MemberModel?>((ref) {
  return ref.watch(authProvider).memberModel;
});
