import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/data/models/member_model.dart';
import 'package:flutter_pal_app/data/models/user_model.dart';
import 'package:flutter_pal_app/data/repositories/member_repository.dart';
import 'package:flutter_pal_app/data/repositories/user_repository.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';

/// 회원 + 사용자 정보 결합 클래스
class MemberWithUser {
  final MemberModel member;
  final UserModel? user;

  const MemberWithUser({required this.member, this.user});

  /// 회원 이름 (UserModel에서 가져옴, 없으면 기본값)
  String get name => user?.name ?? '회원';

  /// 프로필 이미지 URL
  String? get profileImageUrl => user?.profileImageUrl;

  /// 이메일
  String? get email => user?.email;

  /// 전화번호
  String? get phone => user?.phone;
}

/// 현재 트레이너의 회원 목록 (실시간 스트림)
/// Firestore에서 trainerId로 필터링된 회원 목록을 실시간 구독
final membersProvider = StreamProvider<List<MemberModel>>((ref) {
  final trainer = ref.watch(currentTrainerProvider);
  final memberRepository = ref.watch(memberRepositoryProvider);

  // 트레이너 정보가 없으면 빈 스트림 반환
  if (trainer == null || trainer.id.isEmpty) {
    return Stream.value([]);
  }

  return memberRepository.watchByTrainerId(trainer.id);
});

/// 회원 목록 + 사용자 정보 (FutureProvider)
/// Future.wait으로 병렬 쿼리 최적화
final membersWithUserProvider =
    FutureProvider<List<MemberWithUser>>((ref) async {
  final membersAsync = ref.watch(membersProvider);
  final userRepository = ref.watch(userRepositoryProvider);

  return membersAsync.when(
    loading: () => <MemberWithUser>[],
    error: (_, _) => <MemberWithUser>[],
    data: (members) async {
      if (members.isEmpty) return <MemberWithUser>[];

      // 병렬로 모든 사용자 정보 조회 (N+1 → 1+N 병렬)
      final userFutures = members.map((m) => userRepository.get(m.userId));
      final users = await Future.wait(userFutures);

      final List<MemberWithUser> result = [];
      for (int i = 0; i < members.length; i++) {
        result.add(MemberWithUser(member: members[i], user: users[i]));
      }

      return result;
    },
  );
});

/// 정렬된 회원 목록 + 사용자 정보
final sortedMembersWithUserProvider =
    Provider<AsyncValue<List<MemberWithUser>>>((ref) {
  final membersWithUserAsync = ref.watch(membersWithUserProvider);
  final sortOption = ref.watch(memberSortOptionProvider);

  return membersWithUserAsync.whenData((membersWithUser) {
    final sorted = List<MemberWithUser>.from(membersWithUser);

    switch (sortOption) {
      case MemberSortOption.nameAsc:
        sorted.sort((a, b) => a.name.compareTo(b.name));
      case MemberSortOption.nameDesc:
        sorted.sort((a, b) => b.name.compareTo(a.name));
      case MemberSortOption.remainingSessionsAsc:
        sorted.sort((a, b) =>
            a.member.remainingSessions.compareTo(b.member.remainingSessions));
      case MemberSortOption.remainingSessionsDesc:
        sorted.sort((a, b) =>
            b.member.remainingSessions.compareTo(a.member.remainingSessions));
      case MemberSortOption.progressAsc:
        sorted.sort(
            (a, b) => a.member.progressRate.compareTo(b.member.progressRate));
      case MemberSortOption.progressDesc:
        sorted.sort(
            (a, b) => b.member.progressRate.compareTo(a.member.progressRate));
    }

    return sorted;
  });
});

/// 특정 회원 1명 조회 (실시간 스트림)
/// family modifier로 memberId를 받아서 해당 회원만 구독
final memberByIdProvider =
    StreamProvider.family<MemberModel?, String>((ref, memberId) {
  final memberRepository = ref.watch(memberRepositoryProvider);

  if (memberId.isEmpty) {
    return Stream.value(null);
  }

  return memberRepository.watch(memberId);
});

/// 특정 회원 1명 조회 (Future, 일회성)
final memberByIdFutureProvider =
    FutureProvider.family<MemberModel?, String>((ref, memberId) async {
  final memberRepository = ref.watch(memberRepositoryProvider);

  if (memberId.isEmpty) {
    return null;
  }

  return memberRepository.get(memberId);
});

/// 전체 회원 수
final membersCountProvider = Provider<AsyncValue<int>>((ref) {
  final membersAsync = ref.watch(membersProvider);
  return membersAsync.whenData((members) => members.length);
});

/// PT 진행 중인 활성 회원만 필터링
/// 남은 회차(remainingSessions)가 0보다 큰 회원
final activeMembersProvider = Provider<AsyncValue<List<MemberModel>>>((ref) {
  final membersAsync = ref.watch(membersProvider);

  return membersAsync.whenData((members) {
    return members.where((m) => m.remainingSessions > 0).toList();
  });
});

/// 활성 회원 수
final activeMembersCountProvider = Provider<AsyncValue<int>>((ref) {
  final activeMembersAsync = ref.watch(activeMembersProvider);
  return activeMembersAsync.whenData((members) => members.length);
});

/// PT 완료된 회원 (남은 회차가 0인 회원)
final completedMembersProvider = Provider<AsyncValue<List<MemberModel>>>((ref) {
  final membersAsync = ref.watch(membersProvider);

  return membersAsync.whenData((members) {
    return members.where((m) => m.remainingSessions <= 0).toList();
  });
});

/// 목표별 회원 필터링
final membersByGoalProvider =
    Provider.family<AsyncValue<List<MemberModel>>, FitnessGoal>((ref, goal) {
  final membersAsync = ref.watch(membersProvider);

  return membersAsync.whenData((members) {
    return members.where((m) => m.goal == goal).toList();
  });
});

/// 회원 검색 (이름으로)
/// 실제 검색 시에는 UserModel의 name이 필요하므로
/// MemberWithUser 형태로 확장 필요
class MemberSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
  void clear() => state = '';
}

final memberSearchQueryProvider =
    NotifierProvider<MemberSearchNotifier, String>(() => MemberSearchNotifier());

/// 회원 정렬 옵션
enum MemberSortOption {
  nameAsc,
  nameDesc,
  remainingSessionsAsc,
  remainingSessionsDesc,
  progressAsc,
  progressDesc,
}

class MemberSortNotifier extends Notifier<MemberSortOption> {
  @override
  MemberSortOption build() => MemberSortOption.remainingSessionsDesc;

  void setSortOption(MemberSortOption option) => state = option;
}

final memberSortOptionProvider =
    NotifierProvider<MemberSortNotifier, MemberSortOption>(
        () => MemberSortNotifier());

/// 정렬된 회원 목록
final sortedMembersProvider = Provider<AsyncValue<List<MemberModel>>>((ref) {
  final membersAsync = ref.watch(membersProvider);
  final sortOption = ref.watch(memberSortOptionProvider);

  return membersAsync.whenData((members) {
    final sorted = List<MemberModel>.from(members);

    switch (sortOption) {
      case MemberSortOption.nameAsc:
      case MemberSortOption.nameDesc:
        // 이름 정렬은 UserModel 연동 후 구현
        break;
      case MemberSortOption.remainingSessionsAsc:
        sorted.sort((a, b) => a.remainingSessions.compareTo(b.remainingSessions));
      case MemberSortOption.remainingSessionsDesc:
        sorted.sort((a, b) => b.remainingSessions.compareTo(a.remainingSessions));
      case MemberSortOption.progressAsc:
        sorted.sort((a, b) => a.progressRate.compareTo(b.progressRate));
      case MemberSortOption.progressDesc:
        sorted.sort((a, b) => b.progressRate.compareTo(a.progressRate));
    }

    return sorted;
  });
});

/// 회원 관리 Notifier (CRUD 액션)
class MembersNotifier extends AsyncNotifier<void> {
  MemberRepository get _repository => ref.read(memberRepositoryProvider);

  @override
  Future<void> build() async {}

  /// 회원 추가
  Future<String> addMember({
    required String userId,
    required FitnessGoal goal,
    required ExperienceLevel experience,
    required int totalSessions,
    double? targetWeight,
    String? memo,
  }) async {
    state = const AsyncValue.loading();

    try {
      final trainer = ref.read(currentTrainerProvider);
      if (trainer == null) {
        throw Exception('트레이너 정보를 찾을 수 없어요');
      }

      final member = MemberModel(
        id: '',
        userId: userId,
        trainerId: trainer.id,
        goal: goal,
        experience: experience,
        ptInfo: PtInfo(
          totalSessions: totalSessions,
          completedSessions: 0,
          startDate: DateTime.now(),
        ),
        targetWeight: targetWeight,
        memo: memo,
      );

      final memberId = await _repository.create(member);
      state = const AsyncValue.data(null);
      return memberId;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// 회원 정보 수정
  Future<void> updateMember(
    String memberId,
    Map<String, dynamic> updates,
  ) async {
    state = const AsyncValue.loading();

    try {
      await _repository.update(memberId, updates);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// 회원 목표 변경
  Future<void> updateGoal(String memberId, FitnessGoal goal) async {
    await _repository.updateGoal(memberId, goal);
  }

  /// 회원 목표 체중 변경
  Future<void> updateTargetWeight(String memberId, double weight) async {
    await _repository.updateTargetWeight(memberId, weight);
  }

  /// 회원 메모 수정
  Future<void> updateMemo(String memberId, String memo) async {
    await _repository.updateMemo(memberId, memo);
  }

  /// PT 회차 완료 처리
  Future<void> completeSession(String memberId) async {
    await _repository.incrementCompletedSession(memberId);
  }

  /// PT 회차 직접 수정
  Future<void> updateSessionProgress(
    String memberId, {
    int? completedSessions,
    int? totalSessions,
  }) async {
    await _repository.updateSessionProgress(
      memberId,
      completedSessions: completedSessions,
      totalSessions: totalSessions,
    );
  }

  /// 회원 삭제
  Future<void> deleteMember(String memberId) async {
    state = const AsyncValue.loading();

    try {
      await _repository.delete(memberId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

/// 회원 관리 Provider
final membersNotifierProvider =
    AsyncNotifierProvider<MembersNotifier, void>(() {
  return MembersNotifier();
});

/// 회원 통계 (대시보드용)
final memberStatsProvider = Provider<AsyncValue<MemberStats>>((ref) {
  final membersAsync = ref.watch(membersProvider);

  return membersAsync.whenData((members) {
    final total = members.length;
    final active = members.where((m) => m.remainingSessions > 0).length;
    final completed = total - active;

    // 목표별 분포
    final goalDistribution = <FitnessGoal, int>{};
    for (final goal in FitnessGoal.values) {
      goalDistribution[goal] = members.where((m) => m.goal == goal).length;
    }

    // 평균 진행률
    final avgProgress = members.isEmpty
        ? 0.0
        : members.map((m) => m.progressRate).reduce((a, b) => a + b) /
            members.length;

    // 총 남은 회차
    final totalRemainingSessions =
        members.fold(0, (sum, m) => sum + m.remainingSessions);

    return MemberStats(
      totalMembers: total,
      activeMembers: active,
      completedMembers: completed,
      goalDistribution: goalDistribution,
      averageProgress: avgProgress,
      totalRemainingSessions: totalRemainingSessions,
    );
  });
});

/// 회원 통계 모델
class MemberStats {
  final int totalMembers;
  final int activeMembers;
  final int completedMembers;
  final Map<FitnessGoal, int> goalDistribution;
  final double averageProgress;
  final int totalRemainingSessions;

  const MemberStats({
    required this.totalMembers,
    required this.activeMembers,
    required this.completedMembers,
    required this.goalDistribution,
    required this.averageProgress,
    required this.totalRemainingSessions,
  });
}

/// PT 종료 임박 회원 (남은 회차 5회 이하)
final endingSoonMembersProvider = Provider<AsyncValue<List<MemberModel>>>((ref) {
  final membersAsync = ref.watch(membersProvider);

  return membersAsync.whenData((members) {
    return members
        .where((m) => m.remainingSessions > 0 && m.remainingSessions <= 5)
        .toList()
      ..sort((a, b) => a.remainingSessions.compareTo(b.remainingSessions));
  });
});

/// PT 종료 임박 회원 + 사용자 정보
/// Future.wait으로 병렬 쿼리 최적화
final endingSoonMembersWithUserProvider =
    FutureProvider<List<MemberWithUser>>((ref) async {
  final endingSoonAsync = ref.watch(endingSoonMembersProvider);
  final userRepository = ref.watch(userRepositoryProvider);

  return endingSoonAsync.when(
    loading: () => <MemberWithUser>[],
    error: (_, _) => <MemberWithUser>[],
    data: (members) async {
      if (members.isEmpty) return <MemberWithUser>[];

      // 병렬로 모든 사용자 정보 조회
      final userFutures = members.map((m) => userRepository.get(m.userId));
      final users = await Future.wait(userFutures);

      final List<MemberWithUser> result = [];
      for (int i = 0; i < members.length; i++) {
        result.add(MemberWithUser(member: members[i], user: users[i]));
      }

      return result;
    },
  );
});
