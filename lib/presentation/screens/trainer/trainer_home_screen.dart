import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/core/utils/animation_utils.dart';
import 'package:flutter_pal_app/data/models/member_model.dart';
import 'package:flutter_pal_app/data/models/schedule_model.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/providers/members_provider.dart';
import 'package:flutter_pal_app/presentation/providers/schedule_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/animated/animated_widgets.dart';
import 'package:flutter_pal_app/presentation/widgets/glass_card.dart';

/// 트레이너 홈 (대시보드) 화면
/// Glassmorphism 효과로 프리미엄 UI 제공
class TrainerHomeScreen extends ConsumerWidget {
  const TrainerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final displayName = authState.displayName ?? '트레이너님';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withValues(alpha: 0.1),
              colorScheme.surface,
              colorScheme.secondary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // 앱바
              _buildSliverAppBar(context),

              // 컨텐츠
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // 환영 메시지
                    _buildWelcomeSection(context, displayName),
                    const SizedBox(height: 28),

                    // 오늘 일정
                    _buildSectionHeader(context, '오늘 일정', Icons.calendar_today),
                    const SizedBox(height: 16),
                    _TodayScheduleSection(),
                    const SizedBox(height: 28),

                    // 회원 현황
                    _buildSectionHeader(context, '회원 현황', Icons.people_alt),
                    const SizedBox(height: 16),
                    _MemberStatsSection(),
                    const SizedBox(height: 28),

                    // PT 종료 임박
                    _buildSectionHeader(context, 'PT 종료 임박', Icons.warning_amber_rounded),
                    const SizedBox(height: 16),
                    _EndingSoonSection(),
                    const SizedBox(height: 28),

                    // AI 인사이트
                    _buildSectionHeader(context, 'AI 인사이트', Icons.auto_awesome),
                    const SizedBox(height: 16),
                    _AiInsightSection(),
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
                colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.8)],
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
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.settings_outlined,
              color: Theme.of(context).colorScheme.onSurface,
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
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
        ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
        const SizedBox(height: 4),
        Text(
          '$name님!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideX(begin: -0.1),
      ],
    );
  }

  /// 섹션 헤더
  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
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
        return _buildErrorCard(context, '일정을 불러올 수 없습니다', ref, trainerId: trainerId);
      },
      data: (schedules) {
        debugPrint('[TodaySchedule] 일정 로드 완료: ${schedules.length}개');
        // 예정된 일정만 필터링 (완료/취소된 일정 제외 + 시간 지난 일정 제외)
        final now = DateTime.now();
        final activeSchedules = schedules
            .where((s) => s.status == ScheduleStatus.scheduled)
            .where((s) => s.endTime.isAfter(now))  // 시간 지난 일정 제외
            .toList();
        debugPrint('[TodaySchedule] 활성 일정 수 (시간 필터 후): ${activeSchedules.length}개');

        if (activeSchedules.isEmpty) {
          return _buildEmptyScheduleCard(context);
        }

        return GlassCard(
          child: Column(
            children: [
              for (int i = 0; i < activeSchedules.length; i++) ...[
                _buildScheduleItem(context, activeSchedules[i], i),
                if (i < activeSchedules.length - 1)
                  Divider(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                    height: 24,
                  ),
              ],
            ],
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1);
      },
    );
  }

  Widget _buildEmptyScheduleCard(BuildContext context) {
    return GlassCard(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(
                Icons.event_available,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                '오늘 예정된 일정이 없습니다',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildScheduleItem(BuildContext context, ScheduleModel schedule, int index) {
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  : Icon(
                      Icons.event_note,
                      color: avatarColor,
                      size: 20,
                    ),
            ),
            const SizedBox(width: 12),
            // 제목 & 상태
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule.displayTitle,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isPt
                              ? AppTheme.primary.withValues(alpha: 0.1)
                              : AppTheme.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isPt ? 'PT' : '개인',
                          style: TextStyle(
                            color: isPt ? AppTheme.primary : AppTheme.secondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        schedule.status.label,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
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
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: 100 * index)).fadeIn().slideX(begin: 0.05);
  }

  Color _getAvatarColor(int index) {
    final colors = [Colors.blue, Colors.purple, Colors.orange, Colors.teal, Colors.pink];
    return colors[index % colors.length];
  }

  Widget _buildScheduleShimmer() {
    return GlassCard(
      child: Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Shimmer.fromColors(
            baseColor: isDark ? const Color(0xFF424242) : const Color(0xFFE0E0E0),
            highlightColor: isDark ? const Color(0xFF616161) : const Color(0xFFF5F5F5),
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
                      const CircleAvatar(radius: 20, backgroundColor: Colors.white),
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
          );
        },
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String message, WidgetRef ref, {String? trainerId}) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(color: Colors.grey[600]),
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
            child: _AnimatedStatCard(
              label: '전체 회원',
              value: stats.totalMembers,
              suffix: '명',
              icon: Icons.people,
              iconColor: AppTheme.primary,
              onTap: () => context.go('/trainer/members'),
            ).animateListItem(0),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _AnimatedStatCard(
              label: 'PT 진행중',
              value: stats.activeMembers,
              suffix: '명',
              icon: Icons.fitness_center,
              iconColor: AppTheme.secondary,
            ).animateListItem(1),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _AnimatedStatCard(
              label: 'PT 완료',
              value: stats.completedMembers,
              suffix: '명',
              icon: Icons.check_circle_outline,
              iconColor: Colors.grey,
            ).animateListItem(2),
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
            child: GlassCard(
              padding: const EdgeInsets.all(16),
              child: Builder(
                builder: (context) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return Shimmer.fromColors(
                    baseColor: isDark ? const Color(0xFF424242) : const Color(0xFFE0E0E0),
                    highlightColor: isDark ? const Color(0xFF616161) : const Color(0xFFF5F5F5),
                    child: Column(
                      children: [
                        const CircleAvatar(radius: 24, backgroundColor: Colors.white),
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
            child: GlassStatCard(
              label: '-',
              value: '-',
              icon: Icons.error_outline,
              iconColor: Colors.grey,
            ),
          ),
        ),
      ),
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
        if (members.isEmpty) {
          return GlassCard(
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
                        color: Colors.grey[600],
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1);
        }

        return GlassCard(
          child: Column(
            children: [
              for (int i = 0; i < members.length; i++) ...[
                _buildEndingSoonItem(context, members[i], i),
                if (i < members.length - 1)
                  Divider(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                    height: 24,
                  ),
              ],
            ],
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1);
      },
    );
  }

  Widget _buildEndingSoonItem(BuildContext context, MemberWithUser mwu, int index) {
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
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    ).animate(delay: Duration(milliseconds: 100 * index)).fadeIn().slideX(begin: 0.05);
  }

  Widget _buildEndingSoonShimmer() {
    return GlassCard(
      child: Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Shimmer.fromColors(
            baseColor: isDark ? const Color(0xFF424242) : const Color(0xFFE0E0E0),
            highlightColor: isDark ? const Color(0xFF616161) : const Color(0xFFF5F5F5),
            child: Column(
              children: List.generate(
                2,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 22, backgroundColor: Colors.white),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: 80, height: 14, color: Colors.white),
                            const SizedBox(height: 6),
                            Container(width: 100, height: 12, color: Colors.white),
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
          );
        },
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String message) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            message,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ),
    );
  }
}

/// AI 인사이트 섹션
class _AiInsightSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(memberStatsProvider);
    final endingSoonAsync = ref.watch(endingSoonMembersWithUserProvider);

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

    final List<_InsightItem> insights = [];

    // PT 종료 임박 인사이트
    if (endingSoon.isNotEmpty) {
      final urgentCount = endingSoon.where((m) => m.member.remainingSessions <= 2).length;
      if (urgentCount > 0) {
        insights.add(_InsightItem(
          icon: Icons.warning_amber_rounded,
          iconColor: AppTheme.error,
          title: 'PT 연장 필요',
          description: '$urgentCount명의 회원이 2회 이하로 남았습니다. 연장 상담이 필요합니다.',
          actionLabel: '확인하기',
          gradientColors: [AppTheme.error.withValues(alpha: 0.8), AppTheme.error.withValues(alpha: 0.6)],
        ));
      }
    }

    // 활성 회원 인사이트
    if (stats.activeMembers > 0) {
      final avgProgress = (stats.averageProgress * 100).round();
      if (avgProgress >= 70) {
        insights.add(_InsightItem(
          icon: Icons.emoji_events,
          iconColor: AppTheme.secondary,
          title: '우수한 진행률',
          description: '회원들의 평균 진행률이 $avgProgress%입니다. 훌륭합니다!',
          actionLabel: '상세보기',
          gradientColors: [AppTheme.secondary.withValues(alpha: 0.8), AppTheme.secondary.withValues(alpha: 0.6)],
        ));
      } else if (avgProgress < 50) {
        insights.add(_InsightItem(
          icon: Icons.trending_up,
          iconColor: AppTheme.primary,
          title: '진행률 향상 필요',
          description: '회원들의 평균 진행률이 $avgProgress%입니다. 동기부여가 필요할 수 있습니다.',
          actionLabel: '확인하기',
          gradientColors: [AppTheme.primary.withValues(alpha: 0.8), AppTheme.primary.withValues(alpha: 0.6)],
        ));
      }
    }

    // 신규 회원 인사이트
    if (stats.totalMembers == 0) {
      insights.add(_InsightItem(
        icon: Icons.person_add,
        iconColor: AppTheme.primary,
        title: '첫 회원을 등록하세요',
        description: 'PAL과 함께 회원 관리를 시작해보세요!',
        actionLabel: '회원 추가',
        gradientColors: [AppTheme.primary.withValues(alpha: 0.8), AppTheme.primary.withValues(alpha: 0.6)],
      ));
    }

    // 기본 인사이트 (아무것도 없을 때)
    if (insights.isEmpty) {
      insights.add(_InsightItem(
        icon: Icons.check_circle,
        iconColor: AppTheme.secondary,
        title: '모든 것이 순조롭습니다',
        description: '${stats.activeMembers}명의 회원이 열심히 운동 중입니다.',
        actionLabel: '확인하기',
        gradientColors: [AppTheme.secondary.withValues(alpha: 0.8), AppTheme.secondary.withValues(alpha: 0.6)],
      ));
    }

    return Column(
      children: [
        for (int i = 0; i < insights.length; i++) ...[
          _buildInsightCard(context, insights[i], i),
          if (i < insights.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildInsightCard(BuildContext context, _InsightItem insight, int index) {
    return GradientGlassCard(
      gradientColors: insight.gradientColors,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(insight.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
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
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 600 + (100 * index)), duration: 500.ms).slideY(begin: 0.1);
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
                  baseColor: isDark ? const Color(0xFF424242) : const Color(0xFFE0E0E0),
                  highlightColor: isDark ? const Color(0xFF616161) : const Color(0xFFF5F5F5),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 24, backgroundColor: Colors.white),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: 120, height: 16, color: Colors.white),
                            const SizedBox(height: 8),
                            Container(width: double.infinity, height: 12, color: Colors.white),
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

/// 인사이트 아이템 데이터 클래스
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
    final effectiveIconColor = iconColor ?? colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: effectiveIconColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            // 카운트업 애니메이션 적용
            AnimatedCounter(
              value: value,
              suffix: suffix,
              duration: const Duration(milliseconds: 1000),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
