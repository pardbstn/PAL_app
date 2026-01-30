import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:flutter_naver_login/interface/types/naver_account_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_pal_app/data/models/models.dart';
import 'package:flutter_pal_app/data/repositories/repositories.dart';
import 'package:flutter_pal_app/data/services/fcm_service.dart';

/// 사용자 역할 enum
enum UserRole { trainer, member }

/// 인증 상태 클래스
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final bool isPendingRoleSelection; // 신규 사용자 역할 선택 대기 중
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
    this.isPendingRoleSelection = false,
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
    bool? isPendingRoleSelection,
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
      isPendingRoleSelection: isPendingRoleSelection ?? this.isPendingRoleSelection,
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
        // 로딩 시작
        state = state.copyWith(isLoading: true);

        // Firestore에서 사용자 정보 로드 (타임아웃 10초)
        try {
          await _loadUserData(user.uid).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint('[Auth] 사용자 데이터 로드 타임아웃');
              // 타임아웃 시 기본 인증 상태만 설정
              state = state.copyWith(
                isLoading: false,
                isAuthenticated: true,
                userId: user.uid,
                email: user.email,
                displayName: user.displayName,
                photoUrl: user.photoURL,
              );
            },
          );
        } catch (e) {
          debugPrint('[Auth] 사용자 데이터 로드 오류: $e');
          // 오류 발생해도 기본 인증 상태 설정
          state = state.copyWith(
            isLoading: false,
            isAuthenticated: true,
            userId: user.uid,
            email: user.email,
            displayName: user.displayName,
            photoUrl: user.photoURL,
          );
        }
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
              if (member != null) {
                // memberModel이 바뀌면 항상 업데이트 (trainerId 등이 나중에 추가될 수 있음)
                state = state.copyWith(memberModel: member);
              }
            });
          } else {
            // 회원 프로필이 있으면 실시간 감시로 업데이트 추적 (trainerId 변경 등)
            _memberRepository.watchByUserId(uid).listen((member) {
              if (member != null && member.id == memberModel?.id) {
                state = state.copyWith(memberModel: member);
              }
            });
          }
        }

        state = state.copyWith(
          isLoading: false,
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
          isLoading: false,
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
      // 기존 사용자의 역할은 변경하지 않음 (이미 호출 전에 역할이 결정됨)
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

    // 기본 이름 설정: 역할에 따라 "트레이너" 또는 "회원"
    final defaultName = role == UserRole.trainer ? '트레이너' : '회원';

    final userModel = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? defaultName,
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
        final memberId = await _memberRepository.create(member);
        // 생성된 회원 프로필을 다시 조회하여 상태 업데이트
        final createdMember = await _memberRepository.get(memberId);
        if (createdMember != null) {
          state = state.copyWith(memberModel: createdMember);
        }
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
        final user = credential.user!;

        // 1. Firestore에서 사용자 존재 여부 확인 (UID로 검색)
        var existingUser = await _userRepository.get(user.uid);

        // 2. UID로 못 찾은 경우, 이메일로 검색
        if (existingUser == null && user.email != null) {
          existingUser = await _userRepository.getByEmail(user.email!);
        }

        // 3. 사용자가 등록되어 있지 않으면 로그아웃 후 에러
        if (existingUser == null) {
          await _auth.signOut();
          state = state.copyWith(
            isLoading: false,
            errorMessage: '가입되지 않은 계정입니다. 회원가입을 먼저 해주세요.',
          );
          throw Exception('가입되지 않은 계정입니다. 회원가입을 먼저 해주세요.');
        }

        // 4. 기존 사용자는 저장된 역할 사용 (선택된 역할 무시)
        final finalRole = existingUser.role == UserRoleType.trainer
            ? UserRole.trainer
            : UserRole.member;
        debugPrint('[Auth] 이메일 로그인 - 저장된 역할 사용: $finalRole');

        // 5. Firestore에 사용자 업데이트 (마이그레이션 등)
        await _saveUserToFirestore(user, finalRole);

        // 사용자 데이터 로드
        await _loadUserData(user.uid);

        // FCM 토큰 저장
        await _saveFcmToken(user.uid);

        state = state.copyWith(
          isLoading: false,
          userRole: finalRole,
        );
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e.code),
      );
      rethrow;
    } catch (e) {
      // 이미 상태가 설정된 경우 (사용자 검증 실패) 그대로 유지
      if (state.errorMessage == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '로그인 중 오류가 발생했습니다.',
        );
      }
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
        final user = credential.user!;

        // 신규 사용자 - 역할 선택 화면으로 이동
        debugPrint('[Auth] 이메일 회원가입 - 역할 선택 대기');
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          isPendingRoleSelection: true,
          userId: user.uid,
          email: user.email,
          displayName: user.displayName,
          photoUrl: user.photoURL,
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
      debugPrint('[Auth] 구글 로그인 시작...');
      GoogleSignInAccount? googleUser;
      try {
        // 기존 로그인 세션 클리어 후 다시 시도
        await _googleSignIn.signOut();
        googleUser = await _googleSignIn.signIn();
      } catch (e) {
        debugPrint('[Auth] 구글 SDK 오류: $e');
        // 사용자가 취소한 경우 에러 메시지 없이 로딩만 해제
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('canceled') || errorStr.contains('cancelled') || errorStr.contains('user canceled') || errorStr.contains('sign_in_canceled')) {
          state = state.copyWith(isLoading: false);
          return;
        }
        state = state.copyWith(
          isLoading: false,
          errorMessage: '구글 로그인에 실패했습니다. 다시 시도해주세요.',
        );
        return;
      }

      if (googleUser == null) {
        // 사용자가 로그인 취소
        debugPrint('[Auth] 구글 로그인 취소됨');
        state = state.copyWith(isLoading: false);
        return;
      }
      debugPrint('[Auth] 구글 사용자: ${googleUser.email}');

      // 구글 인증 정보 가져오기
      debugPrint('[Auth] 구글 인증 정보 가져오는 중...');
      final GoogleSignInAuthentication googleAuth;
      try {
        googleAuth = await googleUser.authentication;
      } catch (e) {
        debugPrint('[Auth] 구글 인증 정보 오류: $e');
        state = state.copyWith(
          isLoading: false,
          errorMessage: '구글 인증 정보를 가져올 수 없습니다.',
        );
        return;
      }

      // Firebase 인증 자격 증명 생성
      debugPrint('[Auth] Firebase 자격 증명 생성 중...');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase에 로그인
      debugPrint('[Auth] Firebase 로그인 중...');
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final user = userCredential.user!;
        debugPrint('[Auth] Firebase 로그인 성공: ${user.uid}');

        // 1. Firestore에서 기존 사용자 존재 여부 확인 (UID로 검색)
        var existingUser = await _userRepository.get(user.uid);

        // 2. UID로 못 찾은 경우, 이메일로 검색
        if (existingUser == null && user.email != null) {
          existingUser = await _userRepository.getByEmail(user.email!);
        }

        // 3. 기존 사용자인 경우 저장된 역할 사용, 신규면 역할 선택 화면으로
        if (existingUser != null) {
          // 기존 사용자는 저장된 역할 사용
          final finalRole = existingUser.role == UserRoleType.trainer
              ? UserRole.trainer
              : UserRole.member;
          debugPrint('[Auth] 기존 사용자 - 저장된 역할 사용: $finalRole');

          // Firestore에 사용자 저장/업데이트
          await _saveUserToFirestore(user, finalRole);

          // 사용자 데이터 로드
          await _loadUserData(user.uid);

          // FCM 토큰 저장
          await _saveFcmToken(user.uid);

          state = state.copyWith(
            isLoading: false,
            userRole: finalRole,
          );
        } else {
          // 신규 사용자 - 역할 선택 화면으로 이동
          debugPrint('[Auth] 신규 사용자 - 역할 선택 대기');
          state = state.copyWith(
            isLoading: false,
            isAuthenticated: true,
            isPendingRoleSelection: true,
            userId: user.uid,
            email: user.email,
            displayName: user.displayName,
            photoUrl: user.photoURL,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('[Auth] Firebase 인증 오류: ${e.code}');
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e.code),
      );
    } catch (e) {
      debugPrint('[Auth] 구글 로그인 최종 오류: $e');
      // 이미 상태가 설정된 경우 그대로 유지
      if (state.errorMessage == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '구글 로그인 중 오류가 발생했습니다.',
        );
      }
    }
  }

  /// 카카오 소셜 로그인
  Future<void> signInWithKakao(UserRole role) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 1단계: 카카오 로그인 플로우
      debugPrint('[Auth] 카카오 로그인 시작...');
      try {
        if (await kakao.isKakaoTalkInstalled()) {
          await kakao.UserApi.instance.loginWithKakaoTalk();
        } else {
          await kakao.UserApi.instance.loginWithKakaoAccount();
        }
        debugPrint('[Auth] 카카오 로그인 성공');
      } catch (e) {
        debugPrint('[Auth] 카카오 SDK 오류: $e');
        // 사용자가 취소한 경우 에러 메시지 없이 로딩만 해제
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('canceled') || errorStr.contains('cancelled') || errorStr.contains('user canceled')) {
          state = state.copyWith(isLoading: false);
          return;
        }
        state = state.copyWith(
          isLoading: false,
          errorMessage: '카카오 로그인에 실패했습니다.',
        );
        return;
      }

      // 2단계: 카카오 사용자 정보 가져오기
      debugPrint('[Auth] 카카오 사용자 정보 조회 중...');
      final kakao.User kakaoUser;
      try {
        kakaoUser = await kakao.UserApi.instance.me();
        debugPrint('[Auth] 카카오 사용자 ID: ${kakaoUser.id}');
      } catch (e) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '카카오 사용자 정보 오류: $e',
        );
        return;
      }

      final userId = kakaoUser.id.toString();
      final email = kakaoUser.kakaoAccount?.email;
      final name = kakaoUser.kakaoAccount?.profile?.nickname;
      final profileImage = kakaoUser.kakaoAccount?.profile?.profileImageUrl;

      // 3단계: Firebase Custom Token 발급
      debugPrint('[Auth] Custom Token 발급 중...');
      final String customToken;
      try {
        customToken = await _getCustomToken(
          provider: 'kakao',
          userId: userId,
          email: email,
          name: name,
          profileImage: profileImage,
        );
        debugPrint('[Auth] Custom Token 발급 성공');
      } catch (e) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Custom Token 오류: $e',
        );
        return;
      }

      // 4단계: Firebase에 Custom Token으로 로그인
      debugPrint('[Auth] Firebase 로그인 중...');
      final userCredential = await _auth.signInWithCustomToken(customToken);

      if (userCredential.user != null) {
        await _handleSocialLoginSuccess(userCredential.user!, role);
      }
    } catch (e) {
      debugPrint('[Auth] 카카오 로그인 최종 에러: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: '로그인 오류: $e',
      );
    }
  }

  /// 네이버 소셜 로그인
  Future<void> signInWithNaver(UserRole role) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 1단계: 네이버 로그인 플로우
      debugPrint('[Auth] 네이버 로그인 시작...');
      final NaverLoginResult result;
      try {
        result = await FlutterNaverLogin.logIn();
        debugPrint('[Auth] 네이버 로그인 결과: ${result.status}');
      } catch (e) {
        debugPrint('[Auth] 네이버 SDK 오류: $e');
        // 사용자가 취소한 경우 에러 메시지 없이 로딩만 해제
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('canceled') || errorStr.contains('cancelled') || errorStr.contains('user canceled')) {
          state = state.copyWith(isLoading: false);
          return;
        }
        state = state.copyWith(
          isLoading: false,
          errorMessage: '네이버 로그인에 실패했습니다.',
        );
        return;
      }

      // 에러인 경우 (2.x에서는 cancelledByUser가 error로 통합됨)
      if (result.status == NaverLoginStatus.error) {
        state = state.copyWith(isLoading: false);
        return;
      }

      if (result.status != NaverLoginStatus.loggedIn) {
        state = state.copyWith(isLoading: false);
        return;
      }

      // 2단계: 네이버 사용자 정보 가져오기
      debugPrint('[Auth] 네이버 사용자 정보 조회 중...');
      final NaverAccountResult accountResult;
      try {
        accountResult = await FlutterNaverLogin.getCurrentAccount();
        debugPrint('[Auth] 네이버 사용자 ID: ${accountResult.id}');
      } catch (e) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '네이버 사용자 정보 오류: $e',
        );
        return;
      }

      final userId = accountResult.id;
      final email = accountResult.email;
      final name = accountResult.name;
      final profileImage = accountResult.profileImage;

      // userId가 null인 경우 로그인 실패 처리
      if (userId == null || userId.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '네이버 사용자 ID를 가져올 수 없습니다.',
        );
        return;
      }

      // 3단계: Firebase Custom Token 발급
      debugPrint('[Auth] Custom Token 발급 중...');
      final String customToken;
      try {
        customToken = await _getCustomToken(
          provider: 'naver',
          userId: userId,
          email: email,
          name: name,
          profileImage: profileImage,
        );
        debugPrint('[Auth] Custom Token 발급 성공');
      } catch (e) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Custom Token 오류: $e',
        );
        return;
      }

      // 4단계: Firebase에 Custom Token으로 로그인
      debugPrint('[Auth] Firebase 로그인 중...');
      final userCredential = await _auth.signInWithCustomToken(customToken);

      if (userCredential.user != null) {
        await _handleSocialLoginSuccess(userCredential.user!, role);
      }
    } catch (e) {
      debugPrint('[Auth] 네이버 로그인 최종 에러: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: '로그인 오류: $e',
      );
    }
  }

  /// Apple 소셜 로그인 (Custom Token 방식)
  Future<void> signInWithApple(UserRole role) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      debugPrint('[Auth] Apple 로그인 시작...');

      // 1단계: Apple 로그인 자격 증명 요청
      final AuthorizationCredentialAppleID appleCredential;
      try {
        // Android에서는 웹 기반 인증 사용
        final isAndroid = !kIsWeb && Platform.isAndroid;

        appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          webAuthenticationOptions: isAndroid
              ? WebAuthenticationOptions(
                  clientId: 'com.palapp.health123.service',
                  redirectUri: Uri.parse(
                    'https://ptmate-1a542.firebaseapp.com/__/auth/handler',
                  ),
                )
              : null,
        );
        debugPrint('[Auth] Apple 자격 증명 획득 성공');
      } catch (e) {
        debugPrint('[Auth] Apple SDK 오류: $e');
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('canceled') ||
            errorStr.contains('cancelled') ||
            errorStr.contains('user canceled') ||
            errorStr.contains('authorizationerror')) {
          state = state.copyWith(isLoading: false);
          return;
        }
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Apple 로그인에 실패했습니다.',
        );
        return;
      }

      // 2단계: JWT에서 사용자 정보 추출
      String? userId;
      String? email;

      if (appleCredential.identityToken != null) {
        final parts = appleCredential.identityToken!.split('.');
        if (parts.length >= 2) {
          final payload = parts[1];
          final normalized = base64Url.normalize(payload);
          final decoded = utf8.decode(base64Url.decode(normalized));
          debugPrint('[Auth] JWT Payload: $decoded');

          final payloadMap = Map<String, dynamic>.from(
            const JsonDecoder().convert(decoded) as Map,
          );
          userId = payloadMap['sub'] as String?;
          email = payloadMap['email'] as String?;
        }
      }

      // userIdentifier를 사용 (더 안정적)
      userId ??= appleCredential.userIdentifier;

      if (userId == null || userId.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Apple 사용자 ID를 가져올 수 없습니다.',
        );
        return;
      }

      // 이름 정보 (Apple은 최초 로그인 시에만 제공)
      String? name;
      if (appleCredential.givenName != null || appleCredential.familyName != null) {
        name = '${appleCredential.familyName ?? ''}${appleCredential.givenName ?? ''}'.trim();
      }

      debugPrint('[Auth] Apple 사용자 ID: $userId');
      debugPrint('[Auth] Apple 이메일: $email');
      debugPrint('[Auth] Apple 이름: $name');

      // 3단계: Firebase Custom Token 발급
      debugPrint('[Auth] Custom Token 발급 중...');
      final String customToken;
      try {
        customToken = await _getCustomToken(
          provider: 'apple',
          userId: userId,
          email: email,
          name: name,
        );
        debugPrint('[Auth] Custom Token 발급 성공');
      } catch (e) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Custom Token 오류: $e',
        );
        return;
      }

      // 4단계: Firebase에 Custom Token으로 로그인
      debugPrint('[Auth] Firebase 로그인 중...');
      final userCredential = await _auth.signInWithCustomToken(customToken);

      if (userCredential.user != null) {
        await _handleSocialLoginSuccess(userCredential.user!, role);
      }
    } catch (e, stackTrace) {
      debugPrint('[Auth] Apple 로그인 최종 오류: $e');
      debugPrint('[Auth] Stack trace: $stackTrace');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Apple 로그인 오류: ${e.toString().length > 100 ? e.toString().substring(0, 100) : e.toString()}',
      );
    }
  }

  /// 랜덤 nonce 문자열 생성
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// SHA256 해시 생성
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Cloud Function에서 Custom Token 발급
  Future<String> _getCustomToken({
    required String provider,
    required String userId,
    String? email,
    String? name,
    String? profileImage,
  }) async {
    final functions = FirebaseFunctions.instanceFor(region: 'asia-northeast3');
    final callable = functions.httpsCallable('createCustomToken');

    final result = await callable.call({
      'provider': provider,
      'userId': userId,
      'email': email,
      'name': name,
      'profileImage': profileImage,
    });

    final data = result.data as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception('Custom token 생성 실패');
    }

    return data['customToken'] as String;
  }

  /// 소셜 로그인 성공 후 공통 처리
  Future<void> _handleSocialLoginSuccess(User user, UserRole role) async {
    // 기존 사용자 확인
    var existingUser = await _userRepository.get(user.uid);

    if (existingUser == null && user.email != null) {
      existingUser = await _userRepository.getByEmail(user.email!);
    }

    if (existingUser != null) {
      // 기존 사용자는 저장된 역할 사용
      final finalRole = existingUser.role == UserRoleType.trainer
          ? UserRole.trainer
          : UserRole.member;
      debugPrint('[Auth] 기존 사용자 - 저장된 역할 사용: $finalRole');

      // Firestore 업데이트 (마지막 로그인 시간 등)
      await _saveUserToFirestore(user, finalRole);

      // 사용자 데이터 로드
      await _loadUserData(user.uid);

      // FCM 토큰 저장
      await _saveFcmToken(user.uid);

      state = state.copyWith(
        isLoading: false,
        userRole: finalRole,
      );
    } else {
      // 신규 사용자 - 역할 선택 화면으로 이동
      debugPrint('[Auth] 신규 사용자 - 역할 선택 대기');
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        isPendingRoleSelection: true,
        userId: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );
    }
  }

  /// 역할 선택 후 회원가입 완료 (신규 소셜 로그인 사용자용)
  Future<void> completeSignupWithRole(UserRole role) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Firestore에 사용자 저장
      await _saveUserToFirestore(user, role);

      // 사용자 데이터 로드
      await _loadUserData(user.uid);

      // FCM 토큰 저장
      await _saveFcmToken(user.uid);

      state = state.copyWith(
        isLoading: false,
        isPendingRoleSelection: false,
        userRole: role,
      );
    } catch (e) {
      debugPrint('[Auth] 회원가입 완료 오류: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: '회원가입 중 오류가 발생했습니다.',
      );
      rethrow;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      // 소셜 로그인 로그아웃
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
        _tryKakaoLogout(),
        _tryNaverLogout(),
      ]);
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// 카카오 로그아웃 (예외 무시)
  Future<void> _tryKakaoLogout() async {
    try {
      await kakao.UserApi.instance.logout();
    } catch (_) {
      // 카카오 로그인이 아닌 경우 무시
    }
  }

  /// 네이버 로그아웃 (예외 무시)
  Future<void> _tryNaverLogout() async {
    try {
      await FlutterNaverLogin.logOut();
    } catch (_) {
      // 네이버 로그인이 아닌 경우 무시
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

  /// 트레이너 데이터 새로고침
  ///
  /// Firestore에서 트레이너 모델을 다시 가져와 상태 업데이트
  /// 구독 티어 변경 등 외부에서 Firestore를 직접 수정한 경우 호출
  Future<void> refreshTrainerData() async {
    if (state.userId == null || state.userRole != UserRole.trainer) return;

    try {
      final trainerModel = await _trainerRepository.getByUserId(state.userId!);
      if (trainerModel != null) {
        state = state.copyWith(trainerModel: trainerModel);
      }
    } catch (e) {
      debugPrint('refreshTrainerData error: $e');
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
        return '이메일 또는 비밀번호가 올바르지 않습니다.\n소셜 로그인으로 가입했다면 해당 방법으로 로그인해주세요.';
      default:
        return '인증 오류가 발생했습니다. ($code)';
    }
  }

  /// FCM 토큰 저장
  Future<void> _saveFcmToken(String uid) async {
    try {
      final fcmService = FCMService();
      final token = await fcmService.getToken();
      if (token != null) {
        await _userRepository.saveFcmToken(uid, token);
        debugPrint('[Auth] FCM 토큰 저장 완료');
      }
    } catch (e) {
      // FCM 토큰 저장 실패는 로그인을 막지 않음
      debugPrint('[Auth] FCM 토큰 저장 실패: $e');
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
