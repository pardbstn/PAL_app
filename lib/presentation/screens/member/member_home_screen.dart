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
import 'package:flutter_pal_app/presentation/providers/insight_provider.dart';
import 'package:flutter_pal_app/presentation/providers/schedule_provider.dart';
import 'package:flutter_pal_app/presentation/providers/curriculums_provider.dart';
import 'package:flutter_pal_app/data/models/schedule_model.dart';
import 'package:flutter_pal_app/data/models/curriculum_model.dart';
import 'package:flutter_pal_app/presentation/widgets/insights/member_insight_card.dart';
import 'package:flutter_pal_app/presentation/widgets/member/reregistration_banner.dart';
import '../../../presentation/widgets/states/states.dart';
import '../../../core/utils/animation_utils.dart';
import '../../widgets/animated/animated_widgets.dart';
import 'package:flutter_pal_app/presentation/widgets/common/app_card.dart';
import 'package:flutter_pal_app/presentation/widgets/common/card_animations.dart';
import 'package:flutter_pal_app/presentation/widgets/common/glass_container.dart';
import 'package:flutter_pal_app/presentation/providers/trainer_rating_provider.dart';
import '../../../core/theme/app_tokens.dart';
import 'package:flutter_pal_app/presentation/widgets/add_body_record_sheet.dart';
import 'package:flutter_pal_app/presentation/widgets/trainer_transfer/transfer_pending_banner.dart';

/// 프리미엄 회원 홈 화면
class MemberHomeScreen extends ConsumerWidget {
  const MemberHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final member = ref.watch(currentMemberProvider);
    final user = ref.watch(currentUserModelProvider);
    final isPersonal = authState.userRole == UserRole.personal;

    // member가 null일 경우: 로딩 중이거나 회원 프로필이 없는 경우
    if (member == null) {
      // 인증되지 않았거나 로딩 중이면 스켈레톤 표시
      if (!authState.isAuthenticated) {
        return Scaffold(body: _buildLoadingSkeleton(context));
      }
      // 인증되었지만 회원 프로필이 없는 경우
      return Scaffold(
        body: _buildNoMemberProfile(
          context,
          user?.name ?? (isPersonal ? '사용자' : '회원님'),
          user?.memberCode,
        ),
      );
    }

    final memberId = member.id;
    final weightChangeAsync = ref.watch(weightChangeProvider(memberId));
    final nextPtScheduleAsync = ref.watch(
      nextMemberPtScheduleProvider(memberId),
    );
    final weightHistoryAsync = ref.watch(weightHistoryProvider(memberId));
    final memberInsightsAsync = ref.watch(
      memberInsightsStreamProvider(memberId),
    );
    final nextCurriculumAsync = ref.watch(nextCurriculumProvider(memberId));

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? null : Colors.transparent,
      body: Container(
        decoration: isDarkMode
            ? null
            : BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0055FF), // deep electric blue
                    Color(0xFF4D8BFF), // medium blue
                    Color(0xFFE0F0FF), // soft sky blue
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
                    Color(0x26FFFFFF), // white at 15% opacity
                    Colors.transparent,
                  ],
                  stops: [0.0, 1.0],
                ),
              ),
        child: RefreshIndicator(
          onRefresh: () async {
            // 데이터 새로고침
            ref.invalidate(weightChangeProvider(memberId));
            ref.invalidate(nextMemberPtScheduleProvider(memberId));
            ref.invalidate(weightHistoryProvider(memberId));
          },
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // 1. 블루 브랜딩 히어로 헤더
                _BlueBrandingHeader(
                  userName: user?.name ?? (isPersonal ? '사용자' : '회원님'),
                  onNotification: () => context.push(
                    '/notifications?userId=${authState.userId ?? ''}',
                  ),
                  onSettings: () => context.push('/member/settings'),
                ).animateListItem(0),
                const SizedBox(height: 16),

                // 트레이너 전환 요청 배너 - PT 모드만
                if (!isPersonal) ...[TransferPendingBanner(memberId: memberId)],

                // 재등록 배너 (80% 이상 완료 시) - PT 모드만
                if (!isPersonal) ...[
                  ReregistrationBanner(memberId: memberId),
                  const SizedBox(height: 16),
                ],

                // 개인 모드: 오늘 운동 요약 카드 (TODO: 구현 필요)
                // if (isPersonal)
                //   _TodayWorkoutSummaryCard(userId: authState.userId!)
                //       .animateListItem(1),

                // PT 모드: PT 진행 현황 카드
                if (!isPersonal) ...[
                  _PtProgressCard(
                    completed: member.ptInfo.completedSessions,
                    total: member.ptInfo.totalSessions,
                    progressRate: member.progressRate,
                  ).animateListItem(1),
                  const SizedBox(height: 16),
                ],

                // PT 모드만: 다음 수업 카드
                if (!isPersonal) ...[
                  nextPtScheduleAsync.when(
                    loading: () => _buildNextClassSkeleton(context),
                    error: (error, _) => _NextClassCard(
                      schedule: null,
                      error: error.toString(),
                    ).animateListItem(2),
                    data: (schedule) =>
                        _NextClassCard(schedule: schedule).animateListItem(2),
                  ),
                  const SizedBox(height: 16),
                ],

                // PT 모드만: 다음 진행할 커리큘럼 카드
                if (!isPersonal)
                  nextCurriculumAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (curriculum) => curriculum != null
                        ? Column(
                            children: [
                              _NextCurriculumCard(
                                curriculum: curriculum,
                              ).animateListItem(2),
                              const SizedBox(height: 16),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),

                // 4. 체중 변화 미니 차트 (index 3)
                weightChangeAsync.when(
                  loading: () => _buildWeightChartSkeleton(context),
                  error: (error, _) => _WeightChangeCard(
                    weightChange: null,
                    weightHistory: const [],
                    error: error.toString(),
                    onAddRecord: () =>
                        AddBodyRecordSheet.show(context, memberId),
                  ).animateListItem(3),
                  data: (weightChange) => weightHistoryAsync.when(
                    loading: () => _buildWeightChartSkeleton(context),
                    error: (error, _) => _WeightChangeCard(
                      weightChange: weightChange,
                      weightHistory: const [],
                      error: error.toString(),
                      onAddRecord: () =>
                          AddBodyRecordSheet.show(context, memberId),
                    ).animateListItem(3),
                    data: (history) => _WeightChangeCard(
                      weightChange: weightChange,
                      weightHistory: history,
                      onAddRecord: () =>
                          AddBodyRecordSheet.show(context, memberId),
                    ).animateListItem(3),
                  ),
                ),
                const SizedBox(height: 16),

                // 5. AI 인사이트 카드 (index 4)
                memberInsightsAsync.when(
                  loading: () => _buildInsightSkeleton(context),
                  error: (e, s) => _EmptyInsightSection(
                    memberId: memberId,
                  ).animateListItem(4),
                  data: (insights) => insights.isEmpty
                      ? _EmptyInsightSection(
                          memberId: memberId,
                        ).animateListItem(4)
                      : _InsightCardsSection(
                          insights: insights,
                          memberId: memberId,
                        ).animateListItem(4),
                ),
                const SizedBox(height: 24),

                // 6. 빠른 액션 버튼들 (index 5)
                _QuickActionsSection(
                  trainerId: member.trainerId,
                  memberId: memberId,
                  isPersonal: isPersonal,
                ).animateListItem(5),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      ),
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
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 20,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 24),
            // PT 진행 카드 스켈레톤
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 16),
            // 다음 수업 카드 스켈레톤
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 16),
            // 체중 차트 스켈레톤
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
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
          color: Colors.white.withValues(alpha: 0.5),
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
          color: Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildInsightSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// 회원 프로필이 없을 때 표시할 UI
  Widget _buildNoMemberProfile(
    BuildContext context,
    String userName,
    String? memberCode,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final displayTag = memberCode != null ? '$userName#$memberCode' : userName;

    return SafeArea(
          child: Column(
            children: [
              // 상단 설정 버튼
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () => context.push('/member/settings'),
                      tooltip: '설정',
                    ),
                  ],
                ),
              ),
              // 메인 콘텐츠
              Expanded(
                child: Center(
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
                          '아직 트레이너와 연결되지 않았어요.\n아래 회원 코드를 트레이너에게 알려주세요',
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.gray100,
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
                              children: [
                                Text(
                                  '내 회원 코드',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  displayTag,
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
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
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.grey.shade100,
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
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black45,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 200.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }
}

/// 브랜딩 히어로 헤더 - 화이트 카드 스타일
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
            color: isDark
                ? AppColors.gray400
                : Colors.white,
          ),
          onPressed: onNotification,
        ),
        IconButton(
          icon: Icon(
            Icons.settings_rounded,
            color: isDark
                ? AppColors.gray400
                : Colors.white,
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
    _progressAnimation = Tween<double>(begin: 0, end: widget.progressRate)
        .animate(
          CurvedAnimation(
            parent: _progressController,
            curve: Curves.easeOutCubic,
          ),
        );
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
      _progressAnimation =
          Tween<double>(
            begin: _progressAnimation.value,
            end: widget.progressRate,
          ).animate(
            CurvedAnimation(
              parent: _progressController,
              curve: Curves.easeOutCubic,
            ),
          );
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
    final remaining = widget.total - widget.completed;

    return GlassContainer(
      blurSigma: 20,
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      color: Colors.white.withValues(alpha: 0.25),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: PT 상세 페이지로 이동
          },
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              Row(
                children: [
                  // 원형 프로그레스 - 애니메이션 적용 + 글로우 효과
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0055FF).withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: SizedBox(
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
                                  backgroundColor: const Color(0xFF0055FF)
                                      .withValues(alpha: 0.15),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Color(0xFF0055FF),
                                      ),
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              // 퍼센트 카운트업 애니메이션
                              AnimatedCounter(
                                value: (_progressAnimation.value * 100).toInt(),
                                duration: const Duration(milliseconds: 1200),
                                suffix: '%',
                                style: const TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // 텍스트 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PT 진행 현황',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
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
                                color: Color(0xFFFFFFFF),
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              ' / ${widget.total} 회차 완료',
                              style: const TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // 남은 회차 카운트업
                        Row(
                          children: [
                            Text(
                              '남은 회차: ',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 14,
                              ),
                            ),
                            AnimatedCounter(
                              value: remaining,
                              duration: const Duration(milliseconds: 800),
                              suffix: '회',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 하단 프로그레스 바 추가
              AnimatedProgressBar(
                progress: widget.progressRate,
                height: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                progressColor: const Color(0xFF4D9AFF),
                duration: const Duration(milliseconds: 1200),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 다음 수업 카드 (캘린더 PT 일정 기반)
class _NextClassCard extends StatelessWidget {
  final ScheduleModel? schedule;
  final String? error;

  const _NextClassCard({this.schedule, this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 에러 상태
    if (error != null) {
      return _buildErrorCard(context, error!);
    }

    // 예정된 수업 없음
    if (schedule == null) {
      return _buildEmptyCard(context);
    }

    final scheduledDate = schedule!.scheduledAt;
    final formattedDate = _formatDate(scheduledDate);
    final formattedTime = _formatTime(scheduledDate);
    final duration = schedule!.duration;

    // D-Day 계산
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduleDay = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
    );
    final daysUntil = scheduleDay.difference(today).inDays;

    String dDayText;
    if (daysUntil == 0) {
      dDayText = '오늘';
    } else if (daysUntil == 1) {
      dDayText = '내일';
    } else {
      dDayText = 'D-$daysUntil';
    }

    return GlassContainer(
      blurSigma: 15,
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // 캘린더 화면으로 이동
            context.go('/member/calendar');
          },
          borderRadius: BorderRadius.circular(24),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.fitness_center,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '다음 PT 수업',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (daysUntil == 0
                                    ? AppTheme.secondary
                                    : theme.colorScheme.primary)
                                .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        dDayText,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: daysUntil == 0
                              ? AppTheme.secondary
                              : theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 수업 정보
                if (schedule!.memberName != null &&
                    schedule!.memberName!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      schedule!.memberName!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
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
                        '$formattedDate $formattedTime ($duration분)',
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
    return GlassContainer(
      blurSigma: 15,
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const EmptyState(
            type: EmptyStateType.sessions,
            customMessage: '트레이너에게 문의해보세요',
            iconSize: 48,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.go('/member/calendar'),
            child: const Text('일정 보러 가기'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    return GlassContainer(
      blurSigma: 15,
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(16),
      child: ErrorState.fromError(error, onRetry: null),
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
  final VoidCallback? onAddRecord;

  const _WeightChangeCard({
    this.weightChange,
    required this.weightHistory,
    this.error,
    this.onAddRecord,
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

    return GlassContainer(
      blurSigma: 15,
      borderRadius: BorderRadius.circular(24),
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
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: changeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                      child: Icon(
                        isLoss ? Icons.trending_down : Icons.trending_up,
                        color: changeColor,
                        size: 24,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: changeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
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
            SizedBox(height: 80, child: _buildMiniChart(context, changeColor)),
          ],
        ),
    );
  }

  Widget _buildMiniChart(BuildContext context, Color lineColor) {
    if (weightHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    // 날짜 오름차순 정렬 (왼쪽=과거, 오른쪽=최신)
    final sortedHistory = List<WeightHistoryData>.from(weightHistory)
      ..sort((a, b) => a.date.compareTo(b.date));

    final theme = Theme.of(context);
    final spots = <FlSpot>[];

    for (var i = 0; i < sortedHistory.length; i++) {
      spots.add(FlSpot(i.toDouble(), sortedHistory[i].weight));
    }

    // 최소/최대 체중 계산 (차트 범위 설정용)
    final weights = sortedHistory.map((e) => e.weight).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final padding = (maxWeight - minWeight) * 0.2;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (sortedHistory.length - 1).toDouble(),
        minY: minWeight - padding - 1,
        maxY: maxWeight + padding + 1,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) =>
                theme.colorScheme.surfaceContainerHighest,
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
            curveSmoothness: 0.4,
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
    return GlassContainer(
      blurSigma: 15,
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(16),
      child: EmptyState(
        type: EmptyStateType.bodyRecords,
        customTitle: '체중 기록이 부족합니다',
        customMessage: '2개 이상의 기록이 필요해요',
        iconSize: 80,
        onAction: onAddRecord,
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    return GlassContainer(
      blurSigma: 15,
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(16),
      child: ErrorState.fromError(error, onRetry: null),
    );
  }
}

/// 빠른 액션 버튼 섹션
class _QuickActionsSection extends ConsumerWidget {
  final String trainerId;
  final String memberId;
  final bool isPersonal;

  const _QuickActionsSection({
    required this.trainerId,
    required this.memberId,
    required this.isPersonal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 트레이너 평점 조회
    final trainerRatingAsync = trainerId.isNotEmpty
        ? ref.watch(trainerRatingProvider(trainerId))
        : null;

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
        const SizedBox(height: 12),
        // 트레이너 평점 표시 카드 (PT 모드만) - 탭하면 상세 보기
        if (!isPersonal && trainerId.isNotEmpty && trainerRatingAsync != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => context.push('/member/trainer-rating/$trainerId'),
              child: GlassContainer(
                blurSigma: 10,
                borderRadius: BorderRadius.circular(16),
                padding: const EdgeInsets.all(16),
                child: trainerRatingAsync.when(
                data: (rating) {
                  final overall = rating?.overall ?? 0.0;
                  final reviewCount = rating?.reviewCount ?? 0;
                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8A00).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFF8A00),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '내 트레이너 평점',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                ...List.generate(5, (index) {
                                  final starValue = index + 1;
                                  if (overall >= starValue) {
                                    return const Icon(
                                      Icons.star_rounded,
                                      color: Color(0xFFFF8A00),
                                      size: 18,
                                    );
                                  } else if (overall >= starValue - 0.5) {
                                    return const Icon(
                                      Icons.star_half_rounded,
                                      color: Color(0xFFFF8A00),
                                      size: 18,
                                    );
                                  } else {
                                    return Icon(
                                      Icons.star_outline_rounded,
                                      color: Colors.grey.shade300,
                                      size: 18,
                                    );
                                  }
                                }),
                                const SizedBox(width: 8),
                                Text(
                                  overall > 0
                                      ? overall.toStringAsFixed(1)
                                      : '-',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFFF8A00),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '($reviewCount개 리뷰)',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.3,
                        ),
                        size: 20,
                      ),
                    ],
                  );
                },
                loading: () => Shimmer.fromColors(
                  baseColor: isDark
                      ? Colors.grey.shade800
                      : Colors.grey.shade300,
                  highlightColor: isDark
                      ? Colors.grey.shade700
                      : Colors.grey.shade100,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
              ),
            ),
          ),
        if (!isPersonal)
          _QuickActionButton(
            icon: Icons.star_outline_rounded,
            label: '트레이너 평가하기',
            color: const Color(0xFFFF8A00),
            onTap: () {
              if (trainerId.isEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('연동된 트레이너 없음'),
                    content: const Text(
                      '현재 연동된 트레이너가 없어요.\n트레이너와 연동 후 평가할 수 있어요',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('확인'),
                      ),
                    ],
                  ),
                );
                return;
              }
              context.push(
                '/member/review-trainer/$trainerId?memberId=$memberId',
              );
            },
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
    return GlassContainer(
      blurSigma: 10,
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
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
      ),
    );
  }
}

/// 빈 인사이트 섹션 (인사이트 생성 유도)
class _EmptyInsightSection extends ConsumerWidget {
  final String memberId;

  const _EmptyInsightSection({required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final generationState = ref.watch(memberInsightsGenerationProvider);
    final authState = ref.watch(authProvider);
    final isPersonal = authState.userRole == UserRole.personal;

    // 생성 완료 시 즉시 인사이트 카드 표시
    if (generationState.insights != null &&
        generationState.insights!.isNotEmpty) {
      return _InsightCardsSection(
        insights: generationState.insights!,
        memberId: memberId,
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'AI 인사이트',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Icon(
            Icons.insights,
            size: 48,
            color: AppTheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            isPersonal
                ? '기록을 쌓으면 AI가 맞춤 인사이트를 제공해요'
                : 'AI가 분석한 맞춤 인사이트를 확인해보세요',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
          if (isPersonal) ...[
            const SizedBox(height: 8),
            Text(
              '혼자서도 잘하고 있어요! 💪',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: generationState.isGenerating
                  ? null
                  : () => ref
                        .read(memberInsightsGenerationProvider.notifier)
                        .generate(memberId),
              icon: generationState.isGenerating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome, size: 18),
              label: Text(
                generationState.isGenerating ? '분석 중...' : '인사이트 생성하기',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          // 에러 메시지 표시
          if (generationState.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              generationState.errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// AI 인사이트 카드 섹션
class _InsightCardsSection extends ConsumerWidget {
  final List<MemberInsight> insights;
  final String memberId;

  const _InsightCardsSection({required this.insights, required this.memberId});

  /// 중복 제거 및 필터링된 인사이트 목록 반환
  List<MemberInsight> _getFilteredInsights() {
    final seen = <String>{};
    final filtered = <MemberInsight>[];
    for (final insight in insights) {
      // 같은 제목의 인사이트는 최신 것만 표시
      if (seen.contains(insight.title)) {
        continue;
      }
      seen.add(insight.title);
      // 만료된 인사이트 제외
      if (insight.expiresAt != null &&
          insight.expiresAt!.isBefore(DateTime.now())) {
        continue;
      }
      filtered.add(insight);
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final generationState = ref.watch(memberInsightsGenerationProvider);
    final authState = ref.watch(authProvider);
    final isPersonal = authState.userRole == UserRole.personal;
    final filteredInsights = _getFilteredInsights();

    if (filteredInsights.isEmpty) {
      return _EmptyInsightSection(memberId: memberId);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 20,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI 인사이트',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isPersonal)
                        Text(
                          '꾸준한 기록이 최고의 트레이너에요',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              // 새로고침 버튼
              IconButton(
                icon: generationState.isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh, size: 20),
                onPressed: generationState.isGenerating
                    ? null
                    : () => _refreshInsights(ref),
                tooltip: '인사이트 새로고침',
              ),
            ],
          ),
        ),
        SizedBox(
          height: 240,
          child: AnimatedListWrapper(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filteredInsights.length > 5
                  ? 5
                  : filteredInsights.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final insight = filteredInsights[index];
                return AnimatedListWrapper.item(
                  index: index,
                  horizontalOffset: 50.0,
                  verticalOffset: 0.0,
                  child: MemberInsightCard(
                    insight: insight,
                    onRead: () {
                      // 자세히 보기 시 자동 읽음 처리
                      if (!insight.isRead) {
                        ref
                            .read(memberInsightsServiceProvider)
                            .markAsRead(insight.id);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// 인사이트 새로고침
  void _refreshInsights(WidgetRef ref) {
    ref.read(memberInsightsGenerationProvider.notifier).generate(memberId);
  }
}

/// 다음 진행할 커리큘럼 카드
class _NextCurriculumCard extends StatelessWidget {
  final CurriculumModel curriculum;

  const _NextCurriculumCard({required this.curriculum});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassContainer(
      blurSigma: 15,
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 (체중 변화 카드와 동일한 레이아웃)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '다음 진행할 운동',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${curriculum.sessionNumber}회차 · ${curriculum.exercises.length}개',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 커리큘럼 제목
            Text(
              curriculum.title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // 운동 목록 미리보기 (최대 3개)
            ...curriculum.exercises.take(3).map((exercise) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        exercise.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ),
                    Text(
                      '${exercise.sets}세트 × ${exercise.reps}회',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }),

            // 더 많은 운동이 있을 경우
            if (curriculum.exercises.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '외 ${curriculum.exercises.length - 3}개 운동',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
    );
  }
}
