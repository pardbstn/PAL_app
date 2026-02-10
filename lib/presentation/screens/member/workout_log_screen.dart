import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/core/theme/app_tokens.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/providers/workout_log_provider.dart';
import 'package:flutter_pal_app/data/models/workout_log_model.dart';
import 'package:flutter_pal_app/presentation/widgets/common/app_card.dart';

/// 운동 기록 화면 (개인 모드용)
class WorkoutLogScreen extends ConsumerStatefulWidget {
  const WorkoutLogScreen({super.key});

  @override
  ConsumerState<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends ConsumerState<WorkoutLogScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userId = ref.watch(authProvider).userId ?? '';

    // Early check for empty userId
    if (userId.isEmpty) {
      return Scaffold(
        backgroundColor:
            isDark ? AppColors.appBackgroundDark : AppColors.appBackground,
        appBar: AppBar(
          title: const Text('운동 기록'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off_outlined,
                size: 80,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                '로그인이 필요해요',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.appBackgroundDark : AppColors.appBackground,
      appBar: AppBar(
        title: const Text('운동 기록'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '오늘'),
            Tab(text: '이번 주'),
            Tab(text: '이번 달'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TodayTab(userId: userId),
          _WeekTab(userId: userId),
          _MonthTab(userId: userId),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: AppNavGlass.fabBottomPadding),
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/member/add-workout'),
          icon: const Icon(Icons.add),
          label: const Text('운동 추가'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        )
            .animate()
            .scale(duration: 300.ms, curve: Curves.easeOutBack)
            .fadeIn(duration: 200.ms),
      ),
    );
  }
}

/// 오늘 탭
class _TodayTab extends ConsumerWidget {
  final String userId;

  const _TodayTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final todayWorkoutAsync = ref.watch(todayWorkoutProvider(userId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(todayWorkoutProvider(userId));
        // Wait a bit for the provider to refresh
        await Future.delayed(const Duration(milliseconds: 300));
      },
      child: todayWorkoutAsync.when(
        loading: () => _buildLoadingState(context, theme),
        error: (error, stack) => _buildErrorState(context, theme, error, () {
          ref.invalidate(todayWorkoutProvider(userId));
        }),
        data: (workouts) {
          if (workouts.isEmpty) {
            return _buildEmptyState(context, theme);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: workouts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final workout = workouts[index];
              return _WorkoutLogCard(workout: workout)
                  .animate()
                  .fadeIn(duration: 200.ms, delay: (index * 50).ms)
                  .slideY(begin: 0.02, end: 0);
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
          )
              .animate()
              .fadeIn(duration: 200.ms),
          const SizedBox(height: 16),
          Text(
            '운동 기록을 불러오는 중...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
              .animate()
              .fadeIn(duration: 200.ms, delay: 100.ms),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ThemeData theme,
    Object error,
    VoidCallback onRetry,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 60,
              color: AppColors.error,
            ),
          )
              .animate()
              .scale(duration: 300.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          Text(
            '오류가 발생했어요',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          )
              .animate()
              .fadeIn(duration: 200.ms, delay: 200.ms)
              .slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 60),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fitness_center_outlined,
                  size: 64,
                  color: AppColors.secondary,
                ),
              )
                  .animate()
                  .scale(duration: 400.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              Text(
                '아직 운동 기록이 없어요',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 100.ms)
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(height: 12),
              Text(
                '운동 추가 버튼을 눌러\n기록을 시작해보세요',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 200.ms)
                  .slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ],
    );
  }
}

/// 이번 주 탭
class _WeekTab extends ConsumerWidget {
  final String userId;

  const _WeekTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final weeklyAsync = ref.watch(weeklyWorkoutSummaryProvider(userId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(weeklyWorkoutSummaryProvider(userId));
        await Future.delayed(const Duration(milliseconds: 300));
      },
      child: weeklyAsync.when(
        loading: () => _buildLoadingState(context, theme),
        error: (error, stack) => _buildErrorState(context, theme, error, () {
          ref.invalidate(weeklyWorkoutSummaryProvider(userId));
        }),
        data: (summary) {
          if (summary.logs.isEmpty) {
            return _buildEmptyState(context, theme, '이번 주 운동 기록이 없어요');
          }

          // 날짜별로 그룹화
          final logsByDate = <String, List<WorkoutLogModel>>{};
          for (final log in summary.logs) {
            final dateKey =
                '${log.workoutDate.year}-${log.workoutDate.month.toString().padLeft(2, '0')}-${log.workoutDate.day.toString().padLeft(2, '0')}';
            logsByDate.putIfAbsent(dateKey, () => []).add(log);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: logsByDate.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                // 주간 요약 카드
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.gray100,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _SummaryItem(
                        icon: Icons.calendar_today,
                        label: '운동일',
                        value: '${summary.workoutDays}일',
                        color: AppTheme.primary,
                      ),
                      _SummaryItem(
                        icon: Icons.timer,
                        label: '총 시간',
                        value: '${summary.totalDurationMinutes}분',
                        color: AppTheme.secondary,
                      ),
                      _SummaryItem(
                        icon: Icons.fitness_center,
                        label: '운동 수',
                        value: '${summary.totalExercises}개',
                        color: AppTheme.tertiary,
                      ),
                    ],
                  ),
                );
              }

              // 날짜별 운동 목록
              final dateIndex = index - 1;
              final dateKey = logsByDate.keys.elementAt(dateIndex);
              final logs = logsByDate[dateKey]!;
              final date = logs.first.workoutDate;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (dateIndex > 0) const SizedBox(height: 16),
                  Text(
                    _formatDate(date),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...logs.map((log) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _WorkoutLogCard(workout: log),
                      )),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final diff = targetDate.difference(today).inDays;

    if (diff == 0) return '오늘';
    if (diff == -1) return '어제';
    if (diff == -2) return '그저께';

    return '${date.month}월 ${date.day}일 (${_getWeekdayName(date.weekday)})';
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[weekday - 1];
  }

  Widget _buildLoadingState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
          )
              .animate()
              .fadeIn(duration: 200.ms),
          const SizedBox(height: 16),
          Text(
            '주간 운동 기록을 불러오는 중...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
              .animate()
              .fadeIn(duration: 200.ms, delay: 100.ms),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ThemeData theme,
    Object error,
    VoidCallback onRetry,
  ) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 60),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 60,
                  color: AppColors.error,
                ),
              )
                  .animate()
                  .scale(duration: 300.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              Text(
                '오류가 발생했어요',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              )
                  .animate()
                  .fadeIn(duration: 200.ms, delay: 200.ms)
                  .slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, String message) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 60),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fitness_center_outlined,
                  size: 64,
                  color: AppColors.secondary,
                ),
              )
                  .animate()
                  .scale(duration: 400.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              Text(
                message,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 100.ms)
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(height: 12),
              Text(
                '운동 추가 버튼을 눌러\n기록을 시작해보세요',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 200.ms)
                  .slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ],
    );
  }
}

/// 이번 달 탭
class _MonthTab extends ConsumerWidget {
  final String userId;

  const _MonthTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final monthlyAsync = ref.watch(
      monthlyWorkoutHistoryProvider(
        MonthlyWorkoutParams(
          userId: userId,
          year: now.year,
          month: now.month,
        ),
      ),
    );

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(
          monthlyWorkoutHistoryProvider(
            MonthlyWorkoutParams(
              userId: userId,
              year: now.year,
              month: now.month,
            ),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 300));
      },
      child: monthlyAsync.when(
        loading: () => _buildLoadingState(context, theme),
        error: (error, stack) => _buildErrorState(context, theme, error, () {
          ref.invalidate(
            monthlyWorkoutHistoryProvider(
              MonthlyWorkoutParams(
                userId: userId,
                year: now.year,
                month: now.month,
              ),
            ),
          );
        }),
        data: (logs) {
          if (logs.isEmpty) {
            return _buildEmptyState(context, theme, '이번 달 운동 기록이 없어요');
          }

        // 날짜별로 그룹화
        final logsByDate = <String, List<WorkoutLogModel>>{};
        for (final log in logs) {
          final dateKey =
              '${log.workoutDate.year}-${log.workoutDate.month.toString().padLeft(2, '0')}-${log.workoutDate.day.toString().padLeft(2, '0')}';
          logsByDate.putIfAbsent(dateKey, () => []).add(log);
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: logsByDate.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final dateKey = logsByDate.keys.elementAt(index);
            final dateLogs = logsByDate[dateKey]!;
            final date = dateLogs.first.workoutDate;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${date.month}월 ${date.day}일 (${_getWeekdayName(date.weekday)})',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                ...dateLogs.map((log) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _WorkoutLogCard(workout: log),
                    )),
              ],
            );
          },
        );
        },
      ),
    );
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[weekday - 1];
  }

  Widget _buildLoadingState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
          )
              .animate()
              .fadeIn(duration: 200.ms),
          const SizedBox(height: 16),
          Text(
            '월간 운동 기록을 불러오는 중...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
              .animate()
              .fadeIn(duration: 200.ms, delay: 100.ms),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ThemeData theme,
    Object error,
    VoidCallback onRetry,
  ) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 60),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 60,
                  color: AppColors.error,
                ),
              )
                  .animate()
                  .scale(duration: 300.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              Text(
                '오류가 발생했어요',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              )
                  .animate()
                  .fadeIn(duration: 200.ms, delay: 200.ms)
                  .slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, String message) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 60),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fitness_center_outlined,
                  size: 64,
                  color: AppColors.secondary,
                ),
              )
                  .animate()
                  .scale(duration: 400.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              Text(
                message,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 100.ms)
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(height: 12),
              Text(
                '운동 추가 버튼을 눌러\n기록을 시작해보세요',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 200.ms)
                  .slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ],
    );
  }
}

/// 운동 기록 카드
class _WorkoutLogCard extends StatelessWidget {
  final WorkoutLogModel workout;

  const _WorkoutLogCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: AppTheme.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${workout.exercises.length}개 운동',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (workout.durationMinutes > 0)
                      Text(
                        '${workout.durationMinutes}분',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...workout.exercises.take(3).map((exercise) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        exercise.name,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '${exercise.sets}세트 × ${exercise.reps}회',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (exercise.weight > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${exercise.weight}kg',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              )),
          if (workout.exercises.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '외 ${workout.exercises.length - 3}개 운동',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          // 오운완 사진
          if (workout.imageUrl != null && workout.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _showFullImage(context, workout.imageUrl!),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      workout.imageUrl!,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.fullscreen, size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text('원본 보기', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (workout.memo.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                workout.memo,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 요약 아이템
class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// 전체 화면 이미지 뷰어
  void _showFullImage(BuildContext ctx, String imageUrl) {
    Navigator.of(ctx, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(6),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                ),
              ),
            ),
            title: const Text('오운완 사진', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          body: Center(
            child: InteractiveViewer(
              maxScale: 5.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                      color: Colors.white,
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
}
