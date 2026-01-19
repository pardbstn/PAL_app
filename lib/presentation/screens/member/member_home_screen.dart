import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/data/models/member_model.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/providers/body_records_provider.dart';
import 'package:flutter_pal_app/presentation/providers/curriculums_provider.dart';
import '../../../presentation/widgets/states/states.dart';
import '../../../core/utils/animation_utils.dart';
import '../../widgets/animated/animated_widgets.dart';

/// 프리미엄 회원 홈 화면
class MemberHomeScreen extends ConsumerWidget {
  const MemberHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final member = ref.watch(currentMemberProvider);
    final user = ref.watch(currentUserModelProvider);

    // member가 null일 경우: 로딩 중이거나 회원 프로필이 없는 경우
    if (member == null) {
      // 인증되지 않았거나 로딩 중이면 스켈레톤 표시
      if (!authState.isAuthenticated) {
        return Scaffold(
          appBar: _buildAppBar(context),
          body: _buildLoadingSkeleton(context),
        );
      }
      // 인증되었지만 회원 프로필이 없는 경우
      return Scaffold(
        appBar: _buildAppBar(context),
        body: _buildNoMemberProfile(context, user?.name ?? '회원님', user?.memberCode),
      );
    }

    final memberId = member.id;
    final weightChangeAsync = ref.watch(weightChangeProvider(memberId));
    final nextCurriculumAsync = ref.watch(nextCurriculumProvider(memberId));
    final weightHistoryAsync = ref.watch(weightHistoryProvider(memberId));

    return Scaffold(
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: () async {
          // 데이터 새로고침
          ref.invalidate(weightChangeProvider(memberId));
          ref.invalidate(nextCurriculumProvider(memberId));
          ref.invalidate(weightHistoryProvider(memberId));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 상단 인사말 섹션 (index 0)
              _GreetingSection(userName: user?.name ?? '회원님')
                  .animateListItem(0),
              const SizedBox(height: 24),

              // 2. PT 진행 현황 카드 (index 1)
              _PtProgressCard(
                completed: member.ptInfo.completedSessions,
                total: member.ptInfo.totalSessions,
                progressRate: member.progressRate,
              ).animateListItem(1),
              const SizedBox(height: 16),

              // 3. 다음 수업 카드 (index 2)
              nextCurriculumAsync.when(
                loading: () => _buildNextClassSkeleton(context),
                error: (error, _) => _NextClassCard(curriculum: null, error: error.toString())
                    .animateListItem(2),
                data: (curriculum) => _NextClassCard(curriculum: curriculum)
                    .animateListItem(2),
              ),
              const SizedBox(height: 16),

              // 4. 체중 변화 미니 차트 (index 3)
              weightChangeAsync.when(
                loading: () => _buildWeightChartSkeleton(context),
                error: (error, _) => _WeightChangeCard(
                  weightChange: null,
                  weightHistory: const [],
                  error: error.toString(),
                ).animateListItem(3),
                data: (weightChange) => weightHistoryAsync.when(
                  loading: () => _buildWeightChartSkeleton(context),
                  error: (error, _) => _WeightChangeCard(
                    weightChange: weightChange,
                    weightHistory: const [],
                    error: error.toString(),
                  ).animateListItem(3),
                  data: (history) => _WeightChangeCard(
                    weightChange: weightChange,
                    weightHistory: history,
                  ).animateListItem(3),
                ),
              ),
              const SizedBox(height: 24),

              // 5. 빠른 액션 버튼들 (index 4)
              _QuickActionsSection()
                  .animateListItem(4),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('PAL'),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // TODO: 알림 화면으로 이동
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => context.go('/member/settings'),
        ),
      ],
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 인사말 스켈레톤
            Container(
              height: 32,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 20,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 24),
            // PT 진행 카드 스켈레톤
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 16),
            // 다음 수업 카드 스켈레톤
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 16),
            // 체중 차트 스켈레톤
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextClassSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildWeightChartSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// 회원 프로필이 없을 때 표시할 UI
  Widget _buildNoMemberProfile(BuildContext context, String userName, String? memberCode) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final displayTag = memberCode != null ? '$userName#$memberCode' : userName;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                size: 48,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '안녕하세요, $userName님!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '아직 트레이너와 연결되지 않았습니다.\n아래 회원 코드를 트레이너에게 알려주세요.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white60 : Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            // 회원 코드 표시
            if (memberCode != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary.withValues(alpha: 0.1),
                      AppTheme.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '내 회원 코드',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      displayTag,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppTheme.primary,
                    size: 28,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '회원 등록 방법',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. 위의 회원 코드를 트레이너에게 알려주세요\n2. 트레이너가 회원으로 등록하면\n3. 이 화면이 자동으로 업데이트됩니다',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white54 : Colors.black45,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }
}

/// 상단 인사말 섹션
class _GreetingSection extends StatelessWidget {
  final String userName;

  const _GreetingSection({required this.userName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final greeting = _getTimeBasedGreeting();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '안녕하세요, $userName님!',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          greeting,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
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

/// PT 진행 현황 카드 - 프리미엄 애니메이션 적용
class _PtProgressCard extends StatefulWidget {
  final int completed;
  final int total;
  final double progressRate;

  const _PtProgressCard({
    required this.completed,
    required this.total,
    required this.progressRate,
  });

  @override
  State<_PtProgressCard> createState() => _PtProgressCardState();
}

class _PtProgressCardState extends State<_PtProgressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.progressRate,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));
    // 위젯이 빌드된 후 애니메이션 시작
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _progressController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _PtProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progressRate != widget.progressRate) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progressRate,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ));
      _progressController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final remaining = widget.total - widget.completed;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E40AF),
                  const Color(0xFF3B82F6),
                ]
              : [
                  AppTheme.primary,
                  const Color(0xFF60A5FA),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: PT 상세 페이지로 이동
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    // 원형 프로그레스 - 애니메이션 적용
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: CircularProgressIndicator(
                                  value: _progressAnimation.value,
                                  strokeWidth: 8,
                                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              // 퍼센트 카운트업 애니메이션
                              AnimatedCounter(
                                value: (_progressAnimation.value * 100).toInt(),
                                duration: const Duration(milliseconds: 1200),
                                suffix: '%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    // 텍스트 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PT 진행 현황',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 회차 카운트업 애니메이션
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              AnimatedCounter(
                                value: widget.completed,
                                duration: const Duration(milliseconds: 1000),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                ' / ${widget.total} 회차 완료',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // 남은 회차 카운트업
                          Row(
                            children: [
                              const Text(
                                '남은 회차: ',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              AnimatedCounter(
                                value: remaining,
                                duration: const Duration(milliseconds: 800),
                                suffix: '회',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.white70,
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 하단 프로그레스 바 추가
                AnimatedProgressBar(
                  progress: widget.progressRate,
                  height: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  progressColor: Colors.white,
                  duration: const Duration(milliseconds: 1200),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 다음 수업 카드
class _NextClassCard extends StatelessWidget {
  final dynamic curriculum; // CurriculumModel?
  final String? error;

  const _NextClassCard({
    this.curriculum,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 에러 상태
    if (error != null) {
      return _buildErrorCard(context, error!);
    }

    // 예정된 수업 없음
    if (curriculum == null) {
      return _buildEmptyCard(context);
    }

    final scheduledDate = curriculum.scheduledDate;
    final formattedDate = scheduledDate != null
        ? _formatDate(scheduledDate)
        : '날짜 미정';
    final formattedTime = scheduledDate != null
        ? _formatTime(scheduledDate)
        : '';

    return Card(
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // TODO: 수업 상세 페이지로 이동
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.calendar_today_outlined,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '다음 수업',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // 회차 카운트업 애니메이션 적용
                        Row(
                          children: [
                            AnimatedCounter(
                              value: curriculum.sessionNumber,
                              duration: const Duration(milliseconds: 800),
                              suffix: '회차',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                ' - ${curriculum.title}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formattedTime.isNotEmpty ? '$formattedDate $formattedTime' : formattedDate,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const EmptyState(
        type: EmptyStateType.sessions,
        customMessage: '트레이너에게 문의해보세요',
        iconSize: 80,
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ErrorState.fromError(
        error,
        onRetry: null,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final diff = targetDate.difference(today).inDays;

    if (diff == 0) return '오늘';
    if (diff == 1) return '내일';
    if (diff == 2) return '모레';

    return '${date.month}월 ${date.day}일';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute;
    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    if (minute == 0) {
      return '$period $displayHour시';
    }
    return '$period $displayHour시 $minute분';
  }
}

/// 체중 변화 미니 차트 카드
class _WeightChangeCard extends StatelessWidget {
  final WeightChange? weightChange;
  final List<WeightHistoryData> weightHistory;
  final String? error;

  const _WeightChangeCard({
    this.weightChange,
    required this.weightHistory,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 에러 상태
    if (error != null) {
      return _buildErrorCard(context, error!);
    }

    // 데이터 없음
    if (weightChange == null || weightHistory.length < 2) {
      return _buildEmptyCard(context);
    }

    final isLoss = weightChange!.isLoss;
    final changeColor = isLoss ? AppTheme.secondary : AppTheme.error;
    final changeSign = isLoss ? '' : '+';

    return Card(
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: changeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isLoss ? Icons.trending_down : Icons.trending_up,
                        color: changeColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '체중 변화',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // 체중 변화량 카운트업 애니메이션
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: changeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AnimatedDoubleCounter(
                    value: weightChange!.change.abs(),
                    duration: const Duration(milliseconds: 1000),
                    prefix: changeSign,
                    suffix: 'kg',
                    decimalPlaces: 1,
                    style: TextStyle(
                      color: changeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 시작/현재 체중 카운트업 애니메이션
            Row(
              children: [
                Text(
                  '시작: ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                AnimatedDoubleCounter(
                  value: weightChange!.startWeight,
                  duration: const Duration(milliseconds: 1000),
                  suffix: 'kg',
                  decimalPlaces: 1,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '  ->  현재: ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                AnimatedDoubleCounter(
                  value: weightChange!.currentWeight,
                  duration: const Duration(milliseconds: 1000),
                  suffix: 'kg',
                  decimalPlaces: 1,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 80,
              child: _buildMiniChart(context, changeColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniChart(BuildContext context, Color lineColor) {
    if (weightHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final spots = <FlSpot>[];

    for (var i = 0; i < weightHistory.length; i++) {
      spots.add(FlSpot(i.toDouble(), weightHistory[i].weight));
    }

    // 최소/최대 체중 계산 (차트 범위 설정용)
    final weights = weightHistory.map((e) => e.weight).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final padding = (maxWeight - minWeight) * 0.2;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (weightHistory.length - 1).toDouble(),
        minY: minWeight - padding - 1,
        maxY: maxWeight + padding + 1,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => theme.colorScheme.surfaceContainerHighest,
            tooltipBorderRadius: BorderRadius.circular(8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)}kg',
                  TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: lineColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                // 첫 번째와 마지막 점만 표시
                if (index == 0 || index == spots.length - 1) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: lineColor,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                }
                return FlDotCirclePainter(
                  radius: 0,
                  color: Colors.transparent,
                  strokeWidth: 0,
                  strokeColor: Colors.transparent,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  lineColor.withValues(alpha: 0.3),
                  lineColor.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const EmptyState(
        type: EmptyStateType.bodyRecords,
        customTitle: '체중 기록이 부족합니다',
        customMessage: '2개 이상의 기록이 필요해요',
        iconSize: 80,
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ErrorState.fromError(
        error,
        onRetry: null,
      ),
    );
  }
}

/// 빠른 액션 버튼 섹션
class _QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 액션',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.camera_alt_outlined,
                label: '식단 기록',
                color: AppTheme.tertiary,
                onTap: () {
                  context.go('/member/diet');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.bar_chart_outlined,
                label: '내 기록',
                color: AppTheme.primary,
                onTap: () {
                  context.go('/member/records');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 빠른 액션 버튼 위젯
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
