import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/data/models/member_model.dart';
import 'package:flutter_pal_app/data/models/schedule_model.dart';
import 'package:flutter_pal_app/data/models/insight_model.dart';
import 'package:flutter_pal_app/presentation/widgets/insights/insight_mini_chart.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/providers/members_provider.dart';
import 'package:flutter_pal_app/presentation/providers/schedule_provider.dart';
import 'package:flutter_pal_app/presentation/providers/insight_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/animated/animated_widgets.dart';
import 'package:flutter_pal_app/presentation/widgets/common/app_card.dart';
import 'package:flutter_pal_app/core/theme/app_tokens.dart';
import 'package:flutter_pal_app/presentation/widgets/trainer/reregistration_alert_card.dart';
import 'package:flutter_pal_app/presentation/providers/reregistration_provider.dart';
import 'package:flutter_pal_app/presentation/providers/trainer_rating_provider.dart';
import 'package:flutter_pal_app/presentation/providers/trainer_diet_feed_provider.dart';
import 'package:flutter_pal_app/data/models/diet_record_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 트레이너 홈 (대시보드) 화면
/// 프리미엄 화이트 + 쉐도우 스타일의 깔끔한 UI 제공
class TrainerHomeScreen extends ConsumerWidget {
  const TrainerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final displayName = authState.displayName ?? '트레이너님';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? null : Colors.transparent,
      body: Container(
        decoration: isDarkMode
            ? null
            : const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0055FF),
                    Color(0xFF4D8BFF),
                    Color(0xFFE0F0FF),
                    Colors.white,
                  ],
                  stops: [0.0, 0.3, 0.6, 1.0],
                ),
              ),
        foregroundDecoration: isDarkMode
            ? null
            : const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.8,
                  colors: [
                    Color(0x26FFFFFF),
                    Colors.transparent,
                  ],
                  stops: [0.0, 1.0],
                ),
              ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // 앱바
              _buildSliverAppBar(context),

              // 컨텐츠 (회원 앱과 동일한 패딩 16)
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                  // 블루 브랜딩 히어로 헤더
                  _BlueBrandingHeader(
                    userName: displayName,
                    onNotification: () => context.push('/notifications?userId=${authState.userId ?? ''}'),
                    onSettings: () => context.go('/trainer/settings'),
                  ),
                  const SizedBox(height: 16),

                  // 오늘 일정 (순차 등장 - 100ms)
                  Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            context,
                            '오늘 일정',
                            Icons.calendar_today,
                          ),
                          const SizedBox(height: 16),
                          _TodayScheduleSection(),
                        ],
                      )
                      .animate()
                      .fadeIn(delay: 50.ms, duration: 200.ms)
                      .slideY(begin: 0.02, duration: 200.ms),
                  const SizedBox(height: 28),

                  // 회원 현황 (순차 등장 - 200ms)
                  Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            context,
                            '회원 현황',
                            Icons.people_alt,
                          ),
                          const SizedBox(height: 16),
                          _MemberStatsSection(),
                        ],
                      )
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 200.ms)
                      .slideY(begin: 0.02, duration: 200.ms),
                  const SizedBox(height: 28),

                  // TODO: 식단 피드 기능 임시 비활성화 - 추후 개선 예정
                  // const _RecentDietPhotosSection()
                  //     .animate()
                  //     .fadeIn(delay: 112.ms, duration: 200.ms)
                  //     .slideY(begin: 0.02, duration: 200.ms),

                  // 내 평점 (순차 등장 - 250ms)
                  _TrainerRatingSection(
                        trainerId: authState.trainerModel?.id ?? '',
                      )
                      .animate()
                      .fadeIn(delay: 125.ms, duration: 200.ms)
                      .slideY(begin: 0.02, duration: 200.ms),
                  const SizedBox(height: 28),

                  // 재등록 대기
                  _ReregistrationAlertSection(),
                  const SizedBox(height: 28),

                  // PT 종료 임박 (순차 등장 - 300ms)
                  Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            context,
                            'PT 종료 임박',
                            Icons.warning_amber_rounded,
                          ),
                          const SizedBox(height: 16),
                          _EndingSoonSection(),
                        ],
                      )
                      .animate()
                      .fadeIn(delay: 150.ms, duration: 200.ms)
                      .slideY(begin: 0.02, duration: 200.ms),
                  const SizedBox(height: 28),

                  // AI 인사이트 (순차 등장 - 400ms)
                  _AiInsightSection()
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 200.ms)
                      .slideY(begin: 0.02, duration: 200.ms),
                  const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Sliver 앱바 (회원 앱과 동일하게 빈 앱바)
  Widget _buildSliverAppBar(BuildContext context) {
    return const SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 0, // 회원 앱과 동일하게 앱바 숨김
    );
  }

  // _buildWelcomeSection → _BlueBrandingHeader 위젯으로 대체됨

  /// 섹션 헤더
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    ).animate().fadeIn(duration: 200.ms);
  }
}

/// 오늘 일정 섹션 (ScheduleModel 기반)
class _TodayScheduleSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainer = ref.watch(currentTrainerProvider);

    // 트레이너 정보가 아직 로드되지 않았으면 로딩 표시
    if (trainer == null) {
      // 인증 상태 확인
      final authState = ref.watch(authProvider);
      if (!authState.isAuthenticated) {
        return _buildErrorCard(context, '로그인이 필요해요', ref);
      }
      // 트레이너 정보 로딩 중
      debugPrint('[TodaySchedule] 트레이너 정보 로딩 중');
      return _buildScheduleShimmer();
    }

    final trainerId = trainer.id;
    debugPrint('[TodaySchedule] trainerId: $trainerId');

    final todaySchedulesAsync = ref.watch(todaySchedulesProvider(trainerId));

    return todaySchedulesAsync.when(
      loading: () => _buildScheduleShimmer(),
      error: (error, stack) {
        debugPrint('[TodaySchedule] 에러 발생: $error');
        debugPrint('[TodaySchedule] 스택: $stack');
        return _buildErrorCard(
          context,
          '일정을 불러올 수 없어요',
          ref,
          trainerId: trainerId,
        );
      },
      data: (schedules) {
        debugPrint('[TodaySchedule] 일정 로드 완료: ${schedules.length}개');
        // 예정된 일정만 필터링 (완료/취소된 일정 제외 + 시간 지난 일정 제외)
        final now = DateTime.now();
        final activeSchedules = schedules
            .where((s) => s.status == ScheduleStatus.scheduled)
            .where((s) => s.endTime.isAfter(now)) // 시간 지난 일정 제외
            .toList();
        debugPrint(
          '[TodaySchedule] 활성 일정 수 (시간 필터 후): ${activeSchedules.length}개',
        );

        if (activeSchedules.isEmpty) {
          return _buildEmptyScheduleCard(context);
        }

        return _buildPremiumCard(
          context,
          child: Column(
            children: [
              for (int i = 0; i < activeSchedules.length; i++) ...[
                _buildScheduleItem(context, activeSchedules[i], i),
                if (i < activeSchedules.length - 1)
                  Divider(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.1),
                    height: 24,
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyScheduleCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _buildPremiumCard(
      context,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(
                Icons.event_available,
                size: 48,
                color: isDark ? Colors.grey[500] : Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                '오늘 예정된 일정이 없어요',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleItem(
    BuildContext context,
    ScheduleModel schedule,
    int index,
  ) {
    // PT 일정과 개인 일정에 따른 색상 구분
    final isPt = schedule.isPtSchedule;
    final itemColor = isPt ? AppTheme.primary : AppTheme.secondary;
    final avatarColor = _getAvatarColor(index);

    return InkWell(
          onTap: () => context.go('/trainer/calendar'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                // 시간
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: itemColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    schedule.timeString,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: itemColor,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 아이콘/아바타
                CircleAvatar(
                  radius: 20,
                  backgroundColor: avatarColor.withValues(alpha: 0.2),
                  child: isPt
                      ? Text(
                          schedule.displayTitle.isNotEmpty
                              ? schedule.displayTitle[0]
                              : '?',
                          style: TextStyle(
                            color: avatarColor,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Icon(Icons.event_note, color: avatarColor, size: 20),
                ),
                const SizedBox(width: 12),
                // 제목 & 상태
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.displayTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isPt
                                  ? AppTheme.primary.withValues(alpha: 0.1)
                                  : AppTheme.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isPt ? 'PT' : '개인',
                              style: TextStyle(
                                color: isPt
                                    ? AppTheme.primary
                                    : AppTheme.secondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            schedule.status.label,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 화살표
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn()
        .slideX(begin: 0.05);
  }

  Color _getAvatarColor(int index) {
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
    ];
    return colors[index % colors.length];
  }

  Widget _buildScheduleShimmer() {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return _buildPremiumCard(
          context,
          child: Shimmer.fromColors(
            baseColor: isDark
                ? const Color(0xFF424242)
                : const Color(0xFFE0E0E0),
            highlightColor: isDark
                ? const Color(0xFF616161)
                : const Color(0xFFF5F5F5),
            child: Column(
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 80,
                              height: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 120,
                              height: 12,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorCard(
    BuildContext context,
    String message,
    WidgetRef ref, {
    String? trainerId,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _buildPremiumCard(
      context,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 40,
                color: isDark ? Colors.grey[500] : Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              if (trainerId != null) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    // Provider 새로고침
                    ref.invalidate(todaySchedulesProvider(trainerId));
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('다시 시도'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 프리미엄 화이트 카드 (흰색 배경 + 쉐도우)
  Widget _buildPremiumCard(BuildContext context, {required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.md,
      ),
      child: child,
    );
  }
}

/// 회원 현황 섹션
class _MemberStatsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(memberStatsProvider);

    return statsAsync.when(
      loading: () => _buildStatsShimmer(),
      error: (error, _) => _buildErrorRow(context),
      data: (stats) => Row(
        children: [
          Expanded(
            child:
                _AnimatedStatCard(
                      label: '전체 회원',
                      value: stats.totalMembers,
                      suffix: '명',
                      icon: Icons.people,
                      iconColor: AppTheme.primary,
                      onTap: () => context.go('/trainer/members'),
                    )
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 0),
                      duration: 400.ms,
                    )
                    .slideX(begin: 0.1),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                _AnimatedStatCard(
                      label: 'PT 진행중',
                      value: stats.activeMembers,
                      suffix: '명',
                      icon: Icons.people,
                      iconColor: AppTheme.secondary,
                    )
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 100),
                      duration: 400.ms,
                    )
                    .slideX(begin: 0.1),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                _AnimatedStatCard(
                      label: 'PT 완료',
                      value: stats.completedMembers,
                      suffix: '명',
                      icon: Icons.people,
                      iconColor: Colors.grey,
                    )
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 200),
                      duration: 400.ms,
                    )
                    .slideX(begin: 0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsShimmer() {
    return Row(
      children: List.generate(
        3,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: index > 0 ? 12 : 0),
            child: AppCard(
              padding: const EdgeInsets.all(16),
              child: Builder(
                builder: (context) {
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  return Shimmer.fromColors(
                    baseColor: isDark
                        ? const Color(0xFF424242)
                        : const Color(0xFFE0E0E0),
                    highlightColor: isDark
                        ? const Color(0xFF616161)
                        : const Color(0xFFF5F5F5),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        Container(width: 50, height: 24, color: Colors.white),
                        const SizedBox(height: 6),
                        Container(width: 60, height: 12, color: Colors.white),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorRow(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: index > 0 ? 12 : 0),
            child: AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      color: Colors.grey,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '-',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '-',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 재등록 대기 섹션
class _ReregistrationAlertSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainer = ref.watch(currentTrainerProvider);
    final membersWithUserAsync = ref.watch(membersWithUserProvider);

    // 트레이너 정보가 없으면 빈 위젯 반환
    if (trainer == null) {
      return const SizedBox.shrink();
    }

    final trainerId = trainer.id;

    // 회원 이름 조회 함수
    String getMemberName(String memberId) {
      return membersWithUserAsync.when(
        data: (members) {
          final member = members
              .where((m) => m.member.id == memberId)
              .firstOrNull;
          return member?.name ?? '알 수 없는 회원';
        },
        loading: () => '로딩중...',
        error: (_, _) => '알 수 없음',
      );
    }

    // 회원 프로필 URL 조회 함수
    String? getMemberProfileUrl(String memberId) {
      return membersWithUserAsync.when(
        data: (members) {
          final member = members
              .where((m) => m.member.id == memberId)
              .firstOrNull;
          return member?.user?.profileImageUrl;
        },
        loading: () => null,
        error: (_, _) => null,
      );
    }

    return ReregistrationAlertList(
      trainerId: trainerId,
      getMemberName: getMemberName,
      getMemberProfileUrl: getMemberProfileUrl,
      maxItems: 3,
      onContactMember: (memberId) {
        // 회원 상세 페이지로 이동
        context.push('/trainer/members/$memberId');
      },
      onMarkComplete: (memberId) {
        // 재등록 완료 처리
        ref
            .read(reregistrationNotifierProvider.notifier)
            .markReregistered(memberId);
      },
    );
  }
}

/// PT 종료 임박 섹션
class _EndingSoonSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final endingSoonAsync = ref.watch(endingSoonMembersWithUserProvider);

    return endingSoonAsync.when(
      loading: () => _buildEndingSoonShimmer(),
      error: (error, _) => _buildErrorCard(context, '데이터를 불러올 수 없어요'),
      data: (members) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        if (members.isEmpty) {
          return _buildEndingSoonPremiumCard(
            context,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.thumb_up_alt_outlined,
                      size: 48,
                      color: AppTheme.secondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '종료 임박 회원이 없어요',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return _buildEndingSoonPremiumCard(
          context,
          child: Column(
            children: [
              for (int i = 0; i < members.length; i++) ...[
                _buildEndingSoonItem(context, members[i], i),
                if (i < members.length - 1)
                  Divider(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.1),
                    height: 24,
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildEndingSoonItem(
    BuildContext context,
    MemberWithUser mwu,
    int index,
  ) {
    final remaining = mwu.member.remainingSessions;
    final urgencyColor = remaining <= 2 ? AppTheme.error : AppTheme.tertiary;

    return InkWell(
          onTap: () => context.push('/trainer/members/${mwu.member.id}'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                // 아바타
                CircleAvatar(
                  radius: 22,
                  backgroundColor: urgencyColor.withValues(alpha: 0.2),
                  child: Text(
                    mwu.name.isNotEmpty ? mwu.name[0] : '?',
                    style: TextStyle(
                      color: urgencyColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // 이름 & 남은 회차
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mwu.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '남은 회차: $remaining회',
                        style: TextStyle(
                          color: urgencyColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // 연장 버튼
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '연장 안내',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn()
        .slideX(begin: 0.05);
  }

  Widget _buildEndingSoonShimmer() {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return _buildEndingSoonPremiumCard(
          context,
          child: Shimmer.fromColors(
            baseColor: isDark
                ? const Color(0xFF424242)
                : const Color(0xFFE0E0E0),
            highlightColor: isDark
                ? const Color(0xFF616161)
                : const Color(0xFFF5F5F5),
            child: Column(
              children: List.generate(
                2,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 80,
                              height: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 100,
                              height: 12,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 70,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorCard(BuildContext context, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _buildEndingSoonPremiumCard(
      context,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            message,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  /// PT 종료 임박 섹션용 프리미엄 화이트 카드
  Widget _buildEndingSoonPremiumCard(
    BuildContext context, {
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.md,
      ),
      child: child,
    );
  }
}

/// AI 인사이트 섹션
class _AiInsightSection extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AiInsightSection> createState() => _AiInsightSectionState();
}

class _AiInsightSectionState extends ConsumerState<_AiInsightSection> {
  /// 이전 생성 성공 상태 (SnackBar 중복 방지)
  bool _previousSuccessState = false;

  /// 이전 에러 메시지 (SnackBar 중복 방지)
  String? _previousErrorMessage;

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(memberStatsProvider);
    final endingSoonAsync = ref.watch(endingSoonMembersWithUserProvider);
    final aiInsightsAsync = ref.watch(trainerInsightsProvider);
    final unreadCountAsync = ref.watch(unreadInsightCountProvider);
    final generationState = ref.watch(insightsGenerationProvider);
    final trainerId = ref.watch(currentTrainerIdProvider);

    // 생성 성공/실패 시 SnackBar 표시
    _handleGenerationSuccess(context, generationState);
    _handleGenerationError(context, generationState);

    // 로딩 중
    if (statsAsync.isLoading || endingSoonAsync.isLoading) {
      return _buildInsightShimmer();
    }

    // 에러
    if (statsAsync.hasError || endingSoonAsync.hasError) {
      return _buildInsightShimmer();
    }

    final stats = statsAsync.value!;
    final endingSoon = endingSoonAsync.value!;

    // 읽지 않은 개수
    final unreadCount = unreadCountAsync.value ?? 0;

    // AI 인사이트 (최대 5개)
    final aiInsights = aiInsightsAsync.when(
      data: (insights) => insights.take(5).toList(),
      loading: () => <InsightModel>[],
      error: (_, _) => <InsightModel>[],
    );

    return Column(
      children: [
        // 섹션 헤더
        _buildSectionHeader(
          context,
          unreadCount: unreadCount,
          isLoading: generationState.isLoading,
          trainerId: trainerId,
        ),
        const SizedBox(height: 16),

        // 로딩 상태 체크
        if (generationState.isLoading) ...[
          // 로딩 상태
          _buildInsightShimmer(),
        ] else if (aiInsights.isEmpty) ...[
          // 빈 상태 (AI 인사이트 없음)
          _buildEmptyState(context, trainerId),
          const SizedBox(height: 16),
          // 로컬 인사이트 폴백 (Free tier일 때도 보이도록)
          ..._buildLocalInsights(stats, endingSoon),
        ] else ...[
          // 회원 앱과 동일한 가로 스크롤 인사이트 카드 (최대 5개)
          SizedBox(
            height: 240,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: aiInsights.length > 5 ? 5 : aiInsights.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return _buildAiInsightCard(context, aiInsights[index], index);
              },
            ),
          ),
        ],
      ],
    );
  }

  /// 생성 성공 처리 (SnackBar 표시)
  void _handleGenerationSuccess(
    BuildContext context,
    InsightsGenerationState state,
  ) {
    // 성공 상태로 변경되었을 때만 SnackBar 표시
    if (state.isSuccess && !_previousSuccessState) {
      // 인사이트 목록 새로고침
      ref.invalidate(trainerInsightsProvider);
      ref.invalidate(unreadInsightCountProvider);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final result = state.result;
        final newSaved = result?.stats?.newSaved ?? 0;
        final totalGenerated = result?.stats?.totalGenerated ?? 0;
        final skipped = result?.stats?.skippedDuplicates ?? 0;

        String message;
        Color bgColor;

        if (newSaved > 0) {
          message = '$newSaved개의 새 인사이트가 생성됐어요';
          bgColor = AppTheme.secondary;
        } else if (totalGenerated > 0 && skipped > 0) {
          message = '새 인사이트 없음 (이미 생성된 $skipped개 제외)';
          bgColor = AppTheme.tertiary;
        } else {
          message = '분석할 데이터가 부족해요. 회원 데이터를 추가해 주세요.';
          bgColor = AppTheme.tertiary;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            backgroundColor: bgColor,
            duration: const Duration(seconds: 4),
          ),
        );

        // 알림 표시 후 상태 초기화 (재진입 시 중복 알림 방지)
        ref.read(insightsGenerationProvider.notifier).reset();
      });
    }
    _previousSuccessState = state.isSuccess;
  }

  /// 생성 실패 처리 (에러 SnackBar 표시)
  void _handleGenerationError(
    BuildContext context,
    InsightsGenerationState state,
  ) {
    // 에러 상태로 변경되었을 때만 SnackBar 표시
    final errorMessage = state.errorMessage;
    if (errorMessage != null &&
        !state.isLoading &&
        !state.isSuccess &&
        errorMessage != _previousErrorMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.error,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: '다시 시도',
              textColor: Colors.white,
              onPressed: () {
                final trainerId = ref.read(currentTrainerIdProvider);
                if (trainerId != null) {
                  ref
                      .read(insightsGenerationProvider.notifier)
                      .generate(trainerId: trainerId);
                }
              },
            ),
          ),
        );
      });
    }
    _previousErrorMessage = errorMessage;
  }

  /// 섹션 헤더 (타이틀 + 새로고침) - 회원 앱과 동일
  Widget _buildSectionHeader(
    BuildContext context, {
    required int unreadCount,
    required bool isLoading,
    required String? trainerId,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'AI 인사이트',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        // 새로고침 버튼
        IconButton(
          icon: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh, size: 20),
          onPressed: isLoading || trainerId == null
              ? null
              : () {
                  ref
                      .read(insightsGenerationProvider.notifier)
                      .generate(trainerId: trainerId);
                },
          tooltip: '인사이트 새로고침',
        ),
      ],
    ).animate().fadeIn(delay: 250.ms, duration: 200.ms);
  }

  /// 빈 상태 카드
  Widget _buildEmptyState(BuildContext context, String? trainerId) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      variant: AppCardVariant.outlined,
      padding: const EdgeInsets.all(24),
      animate: true,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb_outline,
              color: AppTheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '새로운 인사이트가 없어요',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'AI에게 회원 분석을 요청해보세요',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: trainerId == null
                ? null
                : () {
                    ref
                        .read(insightsGenerationProvider.notifier)
                        .generate(trainerId: trainerId);
                  },
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('인사이트 생성하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// AI 인사이트 카드 (회원 앱과 동일한 가로 스크롤 카드 스타일)
  Widget _buildAiInsightCard(
    BuildContext context,
    InsightModel insight,
    int index,
  ) {
    final insightsService = ref.read(insightsServiceProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final typeColor = insight.typeColor;
    final priorityColor = insight.priorityColor;

    return GestureDetector(
          onTap: () {
            // 읽음 처리
            if (!insight.isRead) {
              insightsService.markAsRead(insight.id);
            }
            // 회원 상세로 이동 (memberId가 있을 경우)
            if (insight.memberId != null && insight.memberId!.isNotEmpty) {
              context.push('/trainer/members/${insight.memberId}');
            }
          },
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  typeColor.withValues(alpha: 0.1),
                  typeColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.gray100,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 상단: 유형 아이콘 + 유형 태그
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          insight.typeIcon,
                          color: typeColor,
                          size: 18,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // 읽지 않은 표시
                    if (!insight.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    // 유형 태그
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getTypeLabel(insight.type),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: typeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 중간: 제목 (회원명 포함)
                Text(
                  insight.memberName != null
                      ? '${insight.memberName} - ${insight.title}'
                      : insight.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // 메시지
                Flexible(
                  child: Text(
                    insight.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // 하단: 미니 차트 (데이터가 있는 경우)
                if (insight.graphData != null &&
                    insight.graphType != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 60,
                    child: InsightMiniChart(
                      graphType: insight.graphType!,
                      data: insight.graphData!,
                      primaryColor: priorityColor,
                      width: double.infinity,
                      height: 60,
                    ),
                  ),
                ],
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 300 + (50 * index)),
          duration: 200.ms,
        )
        .slideX(begin: 0.05);
  }

  String _getTypeLabel(InsightType type) {
    switch (type) {
      case InsightType.churnRisk:
        return '이탈 위험';
      case InsightType.attendanceAlert:
        return '출석 알림';
      case InsightType.noshowPattern:
        return '노쇼';
      case InsightType.renewalLikelihood:
        return '재등록';
      case InsightType.ptExpiry:
        return 'PT 종료';
      case InsightType.performance:
        return '성과';
      case InsightType.workoutVolume:
        return '운동량';
      case InsightType.performanceRanking:
        return '랭킹';
      case InsightType.recommendation:
        return '추천';
      case InsightType.workoutRecommendation:
        return '운동 추천';
      case InsightType.plateauDetection:
        return '정체기';
      default:
        return '기타';
    }
  }

  /// 로컬 인사이트 빌드 (Free tier 폴백)
  List<Widget> _buildLocalInsights(
    MemberStats stats,
    List<MemberWithUser> endingSoon,
  ) {
    final List<_InsightItem> insights = [];

    // PT 종료 임박 인사이트
    if (endingSoon.isNotEmpty) {
      final urgentCount = endingSoon
          .where((m) => m.member.remainingSessions <= 2)
          .length;
      if (urgentCount > 0) {
        insights.add(
          _InsightItem(
            icon: Icons.warning_amber_rounded,
            iconColor: AppTheme.error,
            title: 'PT 연장 필요',
            description: '$urgentCount명의 회원이 2회 이하로 남았어요. 연장 상담이 필요해요.',
            actionLabel: '확인하기',
            gradientColors: [
              AppTheme.error.withValues(alpha: 0.8),
              AppTheme.error.withValues(alpha: 0.6),
            ],
          ),
        );
      }
    }

    // 활성 회원 인사이트
    if (stats.activeMembers > 0) {
      final avgProgress = (stats.averageProgress * 100).round();
      if (avgProgress >= 70) {
        insights.add(
          _InsightItem(
            icon: Icons.emoji_events,
            iconColor: AppTheme.secondary,
            title: '우수한 진행률',
            description: '회원들의 평균 진행률이 $avgProgress%예요. 훌륭해요!',
            actionLabel: '상세보기',
            gradientColors: [
              AppTheme.secondary.withValues(alpha: 0.8),
              AppTheme.secondary.withValues(alpha: 0.6),
            ],
          ),
        );
      } else if (avgProgress < 50) {
        insights.add(
          _InsightItem(
            icon: Icons.trending_up,
            iconColor: AppTheme.primary,
            title: '진행률 향상 필요',
            description: '회원들의 평균 진행률이 $avgProgress%예요. 동기부여가 필요할 수 있어요.',
            actionLabel: '확인하기',
            gradientColors: [
              AppTheme.primary.withValues(alpha: 0.8),
              AppTheme.primary.withValues(alpha: 0.6),
            ],
          ),
        );
      }
    }

    // 신규 회원 인사이트
    if (stats.totalMembers == 0) {
      insights.add(
        _InsightItem(
          icon: Icons.person_add,
          iconColor: AppTheme.primary,
          title: '첫 회원을 등록해보세요',
          description: 'PAL과 함께 회원 관리를 시작해보세요!',
          actionLabel: '회원 추가',
          gradientColors: [
            AppTheme.primary.withValues(alpha: 0.8),
            AppTheme.primary.withValues(alpha: 0.6),
          ],
        ),
      );
    }

    // 기본 인사이트 (아무것도 없을 때)
    if (insights.isEmpty) {
      insights.add(
        _InsightItem(
          icon: Icons.check_circle,
          iconColor: AppTheme.secondary,
          title: '모든 것이 순조로워요',
          description: '${stats.activeMembers}명의 회원이 열심히 운동 중이에요.',
          actionLabel: '확인하기',
          gradientColors: [
            AppTheme.secondary.withValues(alpha: 0.8),
            AppTheme.secondary.withValues(alpha: 0.6),
          ],
        ),
      );
    }

    return [
      for (int i = 0; i < insights.length; i++) ...[
        _buildLocalInsightCard(insights[i], i),
        if (i < insights.length - 1) const SizedBox(height: 16),
      ],
    ];
  }

  /// 로컬 인사이트 카드 (기존 스타일 유지)
  Widget _buildLocalInsightCard(_InsightItem insight, int index) {
    return Container(
      child: AppCard(
        variant: AppCardVariant.standard,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: insight.iconColor,
                width: 4,
              ),
            ),
          ),
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: insight.iconColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(insight.icon, color: insight.iconColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      insight.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                insight.description,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: insight.iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: insight.iconColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    insight.actionLabel,
                    style: TextStyle(
                      color: insight.iconColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(
      delay: Duration(milliseconds: 350 + (50 * index)),
      duration: 200.ms,
    ).slideY(begin: 0.02);
  }

  Widget _buildSeeMoreButton(
    BuildContext context,
    AsyncValue<int> unreadCount,
  ) {
    return GestureDetector(
      onTap: () => context.push('/trainer/insights'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 18, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text(
              '모든 AI 인사이트 보기',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            unreadCount.when(
              data: (count) => count > 0
                  ? Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primary),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 200.ms);
  }

  Widget _buildInsightShimmer() {
    return Column(
      children: List.generate(
        2,
        (index) => Padding(
          padding: EdgeInsets.only(top: index > 0 ? 16 : 0),
          child: AppCard(
            variant: AppCardVariant.standard,
            child: Builder(
              builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return Shimmer.fromColors(
                  baseColor: isDark
                      ? const Color(0xFF424242)
                      : const Color(0xFFE0E0E0),
                  highlightColor: isDark
                      ? const Color(0xFF616161)
                      : const Color(0xFFF5F5F5),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 120,
                              height: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              height: 12,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// 인사이트 아이템 데이터 클래스 (로컬 인사이트용)
class _InsightItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String actionLabel;
  final List<Color> gradientColors;

  _InsightItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.gradientColors,
  });
}

/// 애니메이션 카운터가 적용된 통계 카드
/// 숫자가 0부터 목표값까지 카운트업되는 효과 제공
class _AnimatedStatCard extends StatelessWidget {
  final String label;
  final int value;
  final String suffix;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const _AnimatedStatCard({
    required this.label,
    required this.value,
    required this.suffix,
    required this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveIconColor = iconColor ?? colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘 원형 배경 (옅은 색상 유지)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: effectiveIconColor, size: 24),
            ),
            const SizedBox(height: 12),
            // 카운트업 애니메이션 적용
            AnimatedCounter(
              value: value,
              suffix: suffix,
              duration: const Duration(milliseconds: 1000),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 트레이너 평점 카드 섹션
class _TrainerRatingSection extends ConsumerWidget {
  final String trainerId;

  const _TrainerRatingSection({required this.trainerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (trainerId.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ratingAsync = ref.watch(trainerRatingProvider(trainerId));

    return GestureDetector(
      onTap: () => context.push('/trainer/rating'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '내 평점',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '상세 보기',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : const Color(0xFF64748B),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: isDark ? Colors.white54 : const Color(0xFF64748B),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 평점 표시
            ratingAsync.when(
              data: (rating) {
                final overall = rating?.overall ?? 0.0;
                final reviewCount = rating?.reviewCount ?? 0;
                return Row(
                  children: [
                    // 별점
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFF8A00),
                      size: 28,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      overall > 0 ? overall.toStringAsFixed(1) : '-',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '($reviewCount개 리뷰)',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox(height: 28),
              error: (_, __) => const Text('평점 로딩 실패'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 브랜딩 히어로 헤더 - 화이트 스타일
class _BlueBrandingHeader extends StatelessWidget {
  final String userName;
  final VoidCallback onNotification;
  final VoidCallback onSettings;

  const _BlueBrandingHeader({
    required this.userName,
    required this.onNotification,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '안녕하세요, $userName님!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                  color: isDark ? null : Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getTimeBasedGreeting(),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark
                      ? theme.colorScheme.onSurfaceVariant
                      : Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.notifications_none_rounded,
            color: isDark ? AppColors.gray400 : Colors.white,
          ),
          onPressed: onNotification,
        ),
        IconButton(
          icon: Icon(
            Icons.settings_rounded,
            color: isDark ? AppColors.gray400 : Colors.white,
          ),
          onPressed: onSettings,
        ),
      ],
    );
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '좋은 아침이에요! 오늘도 화이팅!';
    } else if (hour < 18) {
      return '오늘도 화이팅! 멋진 하루 보내세요!';
    } else {
      return '좋은 저녁이에요! 오늘 하루도 수고하셨어요!';
    }
  }
}

/// 최근 회원 식단 사진 섹션
class _RecentDietPhotosSection extends ConsumerWidget {
  const _RecentDietPhotosSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(recentMemberDietPhotosProvider);

    return feedAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, _) => const SizedBox.shrink(),
      data: (feedItems) {
        if (feedItems.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '회원 식단 기록',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPhotoFeed(context, feedItems),
            const SizedBox(height: 28),
          ],
        );
      },
    );
  }

  Widget _buildPhotoFeed(
    BuildContext context,
    List<DietPhotoFeedItem> items,
  ) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _buildPhotoCard(context, items[index], index);
        },
      ),
    );
  }

  Widget _buildPhotoCard(
    BuildContext context,
    DietPhotoFeedItem item,
    int index,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final record = item.record;
    final mealColor = _getMealTypeColor(record.mealType);

    return GestureDetector(
      onTap: () => context.push('/trainer/members/${item.memberId}'),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 음식 사진
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: record.imageUrl!,
                    width: 160,
                    height: 120,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 160,
                      height: 120,
                      color: isDark
                          ? const Color(0xFF424242)
                          : const Color(0xFFE0E0E0),
                      child: const Center(
                        child: Icon(
                          Icons.restaurant,
                          color: Colors.grey,
                          size: 28,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 160,
                      height: 120,
                      color: isDark
                          ? const Color(0xFF424242)
                          : const Color(0xFFE0E0E0),
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
                // 식사 타입 배지 (오른쪽 상단)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: mealColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      record.mealTypeLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // 회원 아바타 (왼쪽 하단)
                Positioned(
                  bottom: -12,
                  left: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor:
                          AppTheme.primary.withValues(alpha: 0.2),
                      child: Text(
                        item.memberName.isNotEmpty
                            ? item.memberName[0]
                            : '?',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // 하단 정보
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 16, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 회원 이름
                    Text(
                      item.memberName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // 음식명 + 시간
                    Text(
                      '${record.displayFoodName} · ${_getRelativeTime(record.createdAt)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 50 * index))
        .fadeIn(duration: 200.ms)
        .slideX(begin: 0.05);
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.md,
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.restaurant_outlined,
              size: 48,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              '아직 회원들의 식단 사진이 없어요',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '회원들이 식단을 기록하면 여기에 표시돼요',
              style: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[500],
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.md,
            ),
            child: Shimmer.fromColors(
              baseColor: isDark
                  ? const Color(0xFF424242)
                  : const Color(0xFFE0E0E0),
              highlightColor: isDark
                  ? const Color(0xFF616161)
                  : const Color(0xFFF5F5F5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 160,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 16, 10, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 120,
                          height: 11,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getMealTypeColor(MealType type) {
    return switch (type) {
      MealType.breakfast => const Color(0xFFFF9800),
      MealType.lunch => const Color(0xFF4CAF50),
      MealType.dinner => const Color(0xFF2196F3),
      MealType.snack => const Color(0xFF9C27B0),
    };
  }

  String _getRelativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}시간 전';
    } else {
      return '${diff.inDays}일 전';
    }
  }
}
