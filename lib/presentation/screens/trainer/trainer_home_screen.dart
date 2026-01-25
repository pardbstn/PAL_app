import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/data/models/member_model.dart';
import 'package:flutter_pal_app/data/models/schedule_model.dart';
import 'package:flutter_pal_app/data/models/insight_model.dart';
import 'package:flutter_pal_app/data/models/trainer_model.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/providers/members_provider.dart';
import 'package:flutter_pal_app/presentation/providers/schedule_provider.dart';
import 'package:flutter_pal_app/presentation/providers/insight_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/animated/animated_widgets.dart';
import 'package:flutter_pal_app/presentation/widgets/common/app_card.dart';

import 'package:flutter_pal_app/presentation/widgets/glass_card.dart';
import 'package:flutter_pal_app/presentation/widgets/insights/churn_gauge_chart.dart';
import 'package:flutter_pal_app/presentation/widgets/insights/volume_bar_chart.dart';
import 'package:flutter_pal_app/presentation/widgets/trainer/reregistration_alert_card.dart';
import 'package:flutter_pal_app/presentation/providers/reregistration_provider.dart';
import 'package:flutter_pal_app/presentation/providers/trainer_rating_provider.dart';
import 'package:flutter_pal_app/presentation/providers/trainer_badge_provider.dart';

/// 트레이너 홈 (대시보드) 화면
/// 프리미엄 화이트 + 쉐도우 스타일의 깔끔한 UI 제공
class TrainerHomeScreen extends ConsumerWidget {
  const TrainerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final displayName = authState.displayName ?? '트레이너님';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 앱바
            _buildSliverAppBar(context),

            // 컨텐츠
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 환영 메시지 (순차 등장 - 0ms)
                  _buildWelcomeSection(context, displayName),
                  const SizedBox(height: 28),

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
                      .fadeIn(delay: 100.ms, duration: 400.ms)
                      .slideY(begin: 0.05, duration: 400.ms),
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
                      .fadeIn(delay: 200.ms, duration: 400.ms)
                      .slideY(begin: 0.05, duration: 400.ms),
                  const SizedBox(height: 28),

                  // 내 평점 + 배지 (순차 등장 - 250ms)
                  _TrainerRatingBadgeSection(
                        trainerId: authState.trainerModel?.id ?? '',
                      )
                      .animate()
                      .fadeIn(delay: 250.ms, duration: 400.ms)
                      .slideY(begin: 0.05, duration: 400.ms),
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
                      .fadeIn(delay: 300.ms, duration: 400.ms)
                      .slideY(begin: 0.05, duration: 400.ms),
                  const SizedBox(height: 28),

                  // AI 인사이트 (순차 등장 - 400ms)
                  _AiInsightSection()
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 400.ms)
                      .slideY(begin: 0.05, duration: 400.ms),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sliver 앱바
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary,
                  AppTheme.primary.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'PAL',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.settings_outlined,
              color: Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
          ),
          onPressed: () => context.go('/trainer/settings'),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  /// 환영 메시지 섹션
  Widget _buildWelcomeSection(BuildContext context, String name) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = '좋은 아침이에요';
    } else if (hour < 18) {
      greeting = '좋은 오후예요';
    } else {
      greeting = '좋은 저녁이에요';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
        const SizedBox(height: 4),
        Text(
          '$name님!',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideX(begin: -0.1),
      ],
    );
  }

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
    ).animate().fadeIn(duration: 400.ms);
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
        return _buildErrorCard(context, '로그인이 필요합니다', ref);
      }
      // 트레이너 정보 로딩 중
      debugPrint('[TodaySchedule] 트레이너 정보 로딩 중...');
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
          '일정을 불러올 수 없습니다',
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
                '오늘 예정된 일정이 없습니다',
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
                    size: 14,
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

  /// 프리미엄 화이트 카드 (흰색 배경 + 쉐도우 + 그레이 보더)
  Widget _buildPremiumCard(BuildContext context, {required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2A4A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3B5E) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
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
        context.go('/trainer/members/$memberId');
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
      error: (error, _) => _buildErrorCard(context, '데이터를 불러올 수 없습니다'),
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
                      '종료 임박 회원이 없습니다',
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
          onTap: () => context.go('/trainer/members/${mwu.member.id}'),
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
        color: isDark ? const Color(0xFF1E2A4A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3B5E) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
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
    final trainer = ref.watch(currentTrainerProvider);
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

        // Pro 플랜 체크 - 모든 기능 무료 개방
        if (false) ...[
          _buildUpgradeCard(context),
        ] else if (generationState.isLoading) ...[
          // 로딩 상태
          _buildInsightShimmer(),
        ] else if (aiInsights.isEmpty) ...[
          // 빈 상태 (AI 인사이트 없음)
          _buildEmptyState(context, trainerId),
          const SizedBox(height: 16),
          // 로컬 인사이트 폴백 (Free tier일 때도 보이도록)
          ..._buildLocalInsights(stats, endingSoon),
        ] else ...[
          // AI 인사이트 카드들
          for (int i = 0; i < aiInsights.length; i++) ...[
            _buildAiInsightCard(context, aiInsights[i], i),
            if (i < aiInsights.length - 1) const SizedBox(height: 16),
          ],
          // 더보기 버튼
          const SizedBox(height: 16),
          _buildSeeMoreButton(context, unreadCountAsync),
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
          message = '$newSaved개의 새 인사이트가 생성되었습니다';
          bgColor = AppTheme.secondary;
        } else if (totalGenerated > 0 && skipped > 0) {
          message = '새 인사이트 없음 (이미 생성된 $skipped개 제외)';
          bgColor = AppTheme.tertiary;
        } else {
          message = '분석할 데이터가 부족합니다. 회원 데이터를 추가해주세요.';
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

  /// 섹션 헤더 (타이틀 + 배지 + 새로고침 버튼)
  Widget _buildSectionHeader(
    BuildContext context, {
    required int unreadCount,
    required bool isLoading,
    required String? trainerId,
  }) {
    return Row(
      children: [
        // 타이틀
        const Text(
          'AI 인사이트',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(width: 8),
        // 읽지 않은 개수 배지
        if (unreadCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.error,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$unreadCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const Spacer(),
        // 새로고침 버튼
        IconButton(
          onPressed: isLoading || trainerId == null
              ? null
              : () {
                  ref
                      .read(insightsGenerationProvider.notifier)
                      .generate(trainerId: trainerId);
                },
          icon: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh),
          tooltip: '인사이트 새로고침',
        ),
      ],
    ).animate().fadeIn(delay: 500.ms, duration: 300.ms);
  }

  /// Pro 업그레이드 카드
  Widget _buildUpgradeCard(BuildContext context) {
    return GlassCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppTheme.primary.withValues(alpha: 0.3),
          AppTheme.secondary.withValues(alpha: 0.2),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.secondary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.workspace_premium,
              color: AppTheme.secondary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pro 플랜에서 AI 인사이트 사용',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'AI가 회원 데이터를 분석하여 맞춤 인사이트를 제공합니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/trainer/settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Pro 업그레이드',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms, duration: 500.ms).slideY(begin: 0.1);
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
            '새로운 인사이트가 없습니다',
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

  /// AI 인사이트 카드 (InsightCard 사용)
  Widget _buildAiInsightCard(
    BuildContext context,
    InsightModel insight,
    int index,
  ) {
    final insightsService = ref.read(insightsServiceProvider);

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
          child: GradientGlassCard(
            gradientColors: [
              insight.priorityColor.withValues(alpha: 0.8),
              insight.priorityColor.withValues(alpha: 0.6),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        insight.typeIcon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  insight.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'AI',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (!insight.isRead)
                                Container(
                                  margin: const EdgeInsets.only(left: 6),
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          // 회원 이름 표시
                          if (insight.memberName != null &&
                              insight.memberName!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              insight.memberName!,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  insight.message,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                // 이탈 위험도 게이지 차트 (churnRisk 타입일 때)
                if (insight.type == InsightType.churnRisk &&
                    insight.data != null)
                  _buildChurnGaugeSection(insight.data!),
                // 운동 볼륨 바 차트 (workoutVolume 타입일 때)
                if (insight.type == InsightType.workoutVolume &&
                    insight.data != null)
                  _buildVolumeBarSection(insight.data!),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      insight.isRead ? '확인하기' : '새 알림',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 600 + (100 * index)),
          duration: 500.ms,
        )
        .slideY(begin: 0.1);
  }

  /// 이탈 위험도 게이지 차트 섹션 빌드
  Widget _buildChurnGaugeSection(Map<String, dynamic> data) {
    // 데이터에서 필요한 필드 추출
    final churnScore = (data['churnScore'] as num?)?.toInt() ?? 0;
    final riskLevel = (data['riskLevel'] as String?) ?? 'LOW';
    final breakdown = (data['breakdown'] as Map<String, dynamic>?) ?? {};

    // 데이터가 유효하지 않으면 빈 위젯 반환
    if (churnScore == 0 && breakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ChurnGaugeChartCompact(
            churnScore: churnScore,
            riskLevel: riskLevel,
            size: 100,
          ),
        ),
      ],
    );
  }

  /// 운동 볼륨 바 차트 섹션 빌드
  Widget _buildVolumeBarSection(Map<String, dynamic> data) {
    // 데이터에서 필요한 필드 추출
    final weeklyVolumes =
        (data['weeklyVolumes'] as List<dynamic>?)
            ?.map((e) => (e as num).toInt())
            .toList() ??
        [];
    final fourWeekAverage = (data['fourWeekAverage'] as num?)?.toDouble() ?? 0;
    final volumeTrend = (data['volumeTrend'] as String?) ?? 'normal';
    final weeklyChanges =
        (data['weeklyChanges'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        [];

    // 데이터가 유효하지 않으면 빈 위젯 반환
    if (weeklyVolumes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: VolumeBarChart(
            weeklyVolumes: weeklyVolumes,
            fourWeekAverage: fourWeekAverage,
            volumeTrend: volumeTrend,
            weeklyChanges: weeklyChanges,
          ),
        ),
      ],
    );
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
            description: '$urgentCount명의 회원이 2회 이하로 남았습니다. 연장 상담이 필요합니다.',
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
            description: '회원들의 평균 진행률이 $avgProgress%입니다. 훌륭합니다!',
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
            description: '회원들의 평균 진행률이 $avgProgress%입니다. 동기부여가 필요할 수 있습니다.',
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
          title: '첫 회원을 등록하세요',
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
          title: '모든 것이 순조롭습니다',
          description: '${stats.activeMembers}명의 회원이 열심히 운동 중입니다.',
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
    return GradientGlassCard(
          gradientColors: insight.gradientColors,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(insight.icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      insight.title,
                      style: const TextStyle(
                        color: Colors.white,
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
                  color: Colors.white.withValues(alpha: 0.9),
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
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    insight.actionLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 700 + (100 * index)),
          duration: 500.ms,
        )
        .slideY(begin: 0.1);
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
            Icon(Icons.chevron_right, size: 20, color: AppTheme.primary),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 800.ms, duration: 300.ms);
  }

  Widget _buildInsightShimmer() {
    return Column(
      children: List.generate(
        2,
        (index) => Padding(
          padding: EdgeInsets.only(top: index > 0 ? 16 : 0),
          child: GlassCard(
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
          color: isDark ? const Color(0xFF1E2A4A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF2E3B5E) : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
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

/// 트레이너 평점 + 배지 카드 섹션
class _TrainerRatingBadgeSection extends ConsumerWidget {
  final String trainerId;

  const _TrainerRatingBadgeSection({required this.trainerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (trainerId.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ratingAsync = ref.watch(trainerRatingProvider(trainerId));
    final badgesAsync = ref.watch(trainerBadgesProvider(trainerId));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2A4A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3B5E) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Text(
                '내 평점',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push('/trainer/badges'),
                child: Text(
                  '배지 관리 →',
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF2563EB),
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
                  Icon(
                    Icons.star_rounded,
                    color: const Color(0xFFF59E0B),
                    size: 28,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    overall > 0 ? overall.toStringAsFixed(1) : '-',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
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

          const SizedBox(height: 16),

          // 보유 배지
          badgesAsync.when(
            data: (badges) {
              final activeBadges = badges?.activeBadges ?? [];
              if (activeBadges.isEmpty) {
                return Text(
                  '아직 획득한 배지가 없습니다',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                  ),
                );
              }
              // 최대 4개까지 표시
              final displayBadges = activeBadges.take(4).toList();
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: displayBadges
                    .map(
                      (badge) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2E3B5E)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${badge.icon} ${badge.name}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
            loading: () => const SizedBox(height: 24),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
