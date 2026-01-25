import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:flutter_pal_app/core/constants/firestore_constants.dart';
import 'package:flutter_pal_app/core/theme/web_theme.dart';
import 'package:flutter_pal_app/data/models/member_model.dart';
import 'package:flutter_pal_app/data/models/user_model.dart';
import 'package:flutter_pal_app/data/models/inbody_record_model.dart';
import 'package:flutter_pal_app/presentation/providers/members_provider.dart';
import 'package:flutter_pal_app/presentation/providers/inbody_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/web/web_widgets.dart';

// ============================================================================
// 회원 상세 조회용 Provider (로컬 정의)
// ============================================================================

/// 회원 상세 조회용 Provider
/// MemberModel과 UserModel을 결합하여 반환
final memberDetailProvider =
    FutureProvider.family.autoDispose<MemberWithUser?, String>(
        (ref, memberId) async {
  final member = await ref.watch(memberByIdFutureProvider(memberId).future);
  if (member == null) return null;
  final userDoc = await FirebaseFirestore.instance
      .collection(FirestoreCollections.users)
      .doc(member.userId)
      .get();
  final user = userDoc.exists
      ? UserModel.fromJson({...userDoc.data()!, 'uid': userDoc.id})
      : null;
  return MemberWithUser(member: member, user: user);
});

// ============================================================================
// 트레이너 회원 상세 웹 화면
// ============================================================================

/// 트레이너 회원 상세 웹 전용 화면
/// 프리미엄 SaaS 스타일의 2컬럼 레이아웃
/// - 왼쪽 사이드바 (고정): 프로필 카드, PT 정보, 연락처
/// - 메인 컨텐츠: 탭바 (기록 | 그래프 | 커리큘럼 | 인바디 | 채팅)
class TrainerMemberDetailWebScreen extends ConsumerStatefulWidget {
  const TrainerMemberDetailWebScreen({super.key});

  @override
  ConsumerState<TrainerMemberDetailWebScreen> createState() =>
      _TrainerMemberDetailWebScreenState();
}

class _TrainerMemberDetailWebScreenState
    extends ConsumerState<TrainerMemberDetailWebScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _memoController = TextEditingController();
  bool _isMemoEditing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memberId = GoRouterState.of(context).pathParameters['id'];

    if (memberId == null || memberId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('회원 ID가 없습니다.')),
      );
    }

    final memberDetailAsync = ref.watch(memberDetailProvider(memberId));

    return Scaffold(
      backgroundColor: WebTheme.contentBgColor(context),
      body: memberDetailAsync.when(
        loading: () => _buildLoadingSkeleton(context),
        error: (error, _) => _buildErrorState(context, error, memberId),
        data: (memberWithUser) {
          if (memberWithUser == null) {
            return _buildNotFoundState(context);
          }

          if (_memoController.text.isEmpty && memberWithUser.member.memo != null) {
            _memoController.text = memberWithUser.member.memo!;
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final layoutType = getLayoutType(constraints.maxWidth);
              final isNarrow = layoutType == LayoutType.mobile || layoutType == LayoutType.tablet;

              if (isNarrow) {
                return _buildNarrowLayout(context, memberWithUser);
              }
              return _buildWideLayout(context, memberWithUser);
            },
          );
        },
      ),
    );
  }

  // 넓은 화면 레이아웃 (데스크탑)
  Widget _buildWideLayout(BuildContext context, MemberWithUser memberWithUser) {
    return Column(
      children: [
        _buildHeader(context, memberWithUser),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 왼쪽 사이드바 (고정 360px)
              SizedBox(
                width: 360,
                child: _buildSidebar(context, memberWithUser),
              ),
              // 메인 컨텐츠
              Expanded(
                child: _buildMainContent(context, memberWithUser),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 좁은 화면 레이아웃 (모바일/태블릿)
  Widget _buildNarrowLayout(BuildContext context, MemberWithUser memberWithUser) {
    return Column(
      children: [
        _buildHeader(context, memberWithUser),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 프로필 요약
                _buildCompactProfile(context, memberWithUser),
                // 탭 컨텐츠
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: _buildMainContent(context, memberWithUser),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 컴팩트 프로필 (좁은 화면용)
  Widget _buildCompactProfile(BuildContext context, MemberWithUser memberWithUser) {
    final member = memberWithUser.member;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: WebTheme.cardDecoration(context),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: WebTheme.primaryGradient,
            ),
            child: Center(
              child: Text(
                memberWithUser.name.isNotEmpty ? memberWithUser.name[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  memberWithUser.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${member.ptInfo.completedSessions}/${member.ptInfo.totalSessions}회 진행',
                  style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getGoalColor(member.goal).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              member.goalLabel,
              style: TextStyle(color: _getGoalColor(member.goal), fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // 상단 헤더
  // ============================================================================

  Widget _buildHeader(BuildContext context, MemberWithUser memberWithUser) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: WebTheme.headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? WebTheme.cardBgDark : WebTheme.cardBgLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: '뒤로',
          ),
          const SizedBox(width: 16),
          Text(
            memberWithUser.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('회원 수정 기능 준비 중')),
              );
            },
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('수정'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.primary),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () => _showDeleteDialog(context, memberWithUser),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('삭제'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(color: colorScheme.error),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0);
  }

  // ============================================================================
  // 왼쪽 사이드바
  // ============================================================================

  Widget _buildSidebar(BuildContext context, MemberWithUser memberWithUser) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildProfileCard(context, memberWithUser)
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .slideX(begin: -0.1, end: 0),
          const SizedBox(height: 20),
          _buildPtInfoCard(context, memberWithUser)
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideX(begin: -0.1, end: 0),
          const SizedBox(height: 20),
          _buildContactCard(context, memberWithUser)
              .animate()
              .fadeIn(duration: 400.ms, delay: 300.ms)
              .slideX(begin: -0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, MemberWithUser memberWithUser) {
    final colorScheme = Theme.of(context).colorScheme;
    final member = memberWithUser.member;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: WebTheme.cardDecoration(context),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: WebTheme.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: memberWithUser.profileImageUrl != null
                ? ClipOval(
                    child: Image.network(
                      memberWithUser.profileImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, e, s) => _buildAvatarPlaceholder(context, memberWithUser.name),
                    ),
                  )
                : _buildAvatarPlaceholder(context, memberWithUser.name),
          ),
          const SizedBox(height: 16),
          Text(
            memberWithUser.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getGoalColor(member.goal).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _getGoalColor(member.goal).withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getGoalIcon(member.goal), size: 16, color: _getGoalColor(member.goal)),
                const SizedBox(width: 6),
                Text(
                  member.goalLabel,
                  style: TextStyle(color: _getGoalColor(member.goal), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '경험: ',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
              ),
              ...List.generate(3, (index) {
                final filledStars = switch (member.experience) {
                  ExperienceLevel.beginner => 1,
                  ExperienceLevel.intermediate => 2,
                  ExperienceLevel.advanced => 3,
                };
                return Icon(
                  index < filledStars ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 20,
                  color: index < filledStars ? Colors.amber : colorScheme.onSurface.withValues(alpha: 0.3),
                );
              }),
              const SizedBox(width: 4),
              Text(
                '(${member.experienceLabel})',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder(BuildContext context, String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildPtInfoCard(BuildContext context, MemberWithUser memberWithUser) {
    final colorScheme = Theme.of(context).colorScheme;
    final member = memberWithUser.member;
    final ptInfo = member.ptInfo;
    final progress = member.progressRate;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: WebTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fitness_center_rounded, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'PT 진행 현황',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${ptInfo.completedSessions}/${ptInfo.totalSessions} 회차',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.primary,
                    ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 16, color: colorScheme.onSurface.withValues(alpha: 0.5)),
              const SizedBox(width: 8),
              Text(
                '시작일: ${DateFormat('yyyy.MM.dd').format(ptInfo.startDate)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
              ),
            ],
          ),
          if (member.targetWeight != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.flag_rounded, size: 16, color: colorScheme.onSurface.withValues(alpha: 0.5)),
                const SizedBox(width: 8),
                Text(
                  '목표 체중: ${member.targetWeight}kg',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, MemberWithUser memberWithUser) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: WebTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.contact_phone_rounded, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                '연락처',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContactRow(context, icon: Icons.email_outlined, label: '이메일', value: memberWithUser.email ?? '-'),
          const SizedBox(height: 12),
          _buildContactRow(context, icon: Icons.phone_outlined, label: '전화번호', value: memberWithUser.phone ?? '-'),
        ],
      ),
    );
  }

  Widget _buildContactRow(BuildContext context, {required IconData icon, required String label, required String value}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // 메인 컨텐츠 (탭) - 5개 탭: 기록 | 그래프 | 커리큘럼 | 인바디 | 채팅
  // ============================================================================

  Widget _buildMainContent(BuildContext context, MemberWithUser memberWithUser) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(24),
      decoration: WebTheme.cardDecoration(context),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2))),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.5),
              indicatorColor: colorScheme.primary,
              indicatorWeight: 3,
              isScrollable: true,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              tabs: const [
                Tab(icon: Icon(Icons.history_rounded, size: 20), text: '기록'),
                Tab(icon: Icon(Icons.show_chart_rounded, size: 20), text: '그래프'),
                Tab(icon: Icon(Icons.list_alt_rounded, size: 20), text: '커리큘럼'),
                Tab(icon: Icon(Icons.monitor_weight_outlined, size: 20), text: '인바디'),
                Tab(icon: Icon(Icons.chat_bubble_outline, size: 20), text: '채팅'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRecordsTab(context, memberWithUser),
                _buildGraphTab(context, memberWithUser),
                _buildCurriculumTab(context, memberWithUser),
                _buildInbodyTab(context, memberWithUser),
                _buildChatTab(context, memberWithUser),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms).slideX(begin: 0.1, end: 0);
  }

  // 기록 탭 - 운동 기록 및 메모
  Widget _buildRecordsTab(BuildContext context, MemberWithUser memberWithUser) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('트레이너 메모', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              if (!_isMemoEditing)
                TextButton.icon(
                  onPressed: () => setState(() => _isMemoEditing = true),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('편집'),
                )
              else
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        _memoController.text = memberWithUser.member.memo ?? '';
                        setState(() => _isMemoEditing = false);
                      },
                      child: const Text('취소'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () async {
                        await ref.read(membersNotifierProvider.notifier).updateMemo(
                              memberWithUser.member.id,
                              _memoController.text,
                            );
                        setState(() => _isMemoEditing = false);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('메모가 저장되었습니다')));
                      },
                      child: const Text('저장'),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isMemoEditing ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.2),
                  width: _isMemoEditing ? 2 : 1,
                ),
              ),
              child: _isMemoEditing
                  ? TextField(
                      controller: _memoController,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '회원에 대한 메모를 입력하세요...\n(부상 이력, 주의사항, 특이사항 등)',
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  : SingleChildScrollView(
                      child: Text(
                        memberWithUser.member.memo?.isNotEmpty == true
                            ? memberWithUser.member.memo!
                            : '등록된 메모가 없습니다.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: memberWithUser.member.memo?.isNotEmpty == true
                                  ? null
                                  : colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  // 그래프 탭 - AI 예측선 포함
  Widget _buildGraphTab(BuildContext context, MemberWithUser memberWithUser) {
    final colorScheme = Theme.of(context).colorScheme;

    // 실제 데이터 (더미)
    final weightData = [
      const FlSpot(0, 75),
      const FlSpot(1, 74.5),
      const FlSpot(2, 74.2),
      const FlSpot(3, 73.8),
      const FlSpot(4, 73.5),
      const FlSpot(5, 73.0),
      const FlSpot(6, 72.5),
      const FlSpot(7, 72.2),
    ];

    // AI 예측 데이터 (점선으로 표시)
    final weightPrediction = [
      const FlSpot(7, 72.2),
      const FlSpot(8, 71.8),
      const FlSpot(9, 71.5),
      const FlSpot(10, 71.2),
      const FlSpot(11, 70.8),
    ];

    final muscleData = [
      const FlSpot(0, 32),
      const FlSpot(1, 32.2),
      const FlSpot(2, 32.5),
      const FlSpot(3, 32.8),
      const FlSpot(4, 33.0),
      const FlSpot(5, 33.3),
      const FlSpot(6, 33.5),
      const FlSpot(7, 33.8),
    ];

    final musclePrediction = [
      const FlSpot(7, 33.8),
      const FlSpot(8, 34.0),
      const FlSpot(9, 34.2),
      const FlSpot(10, 34.5),
      const FlSpot(11, 34.7),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 범례
          Row(
            children: [
              _buildLegendItem('실제 데이터', colorScheme.primary, false),
              const SizedBox(width: 24),
              _buildLegendItem('AI 예측', const Color(0xFF8B5CF6), true),
            ],
          ),
          const SizedBox(height: 24),

          // 체중 변화 차트
          Text('체중 변화', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            '최근 8주간 체중 변화 + AI 예측 (4주)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: colorScheme.outline.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}kg',
                        style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 11),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final weekNum = value.toInt() + 1;
                        final isPrediction = value >= 8;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '$weekNum주${isPrediction ? '*' : ''}',
                            style: TextStyle(
                              color: isPrediction
                                  ? const Color(0xFF8B5CF6).withValues(alpha: 0.7)
                                  : colorScheme.onSurface.withValues(alpha: 0.5),
                              fontSize: 11,
                              fontStyle: isPrediction ? FontStyle.italic : FontStyle.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // 실제 데이터
                  LineChartBarData(
                    spots: weightData,
                    isCurved: true,
                    color: colorScheme.primary,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: colorScheme.primary,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [colorScheme.primary.withValues(alpha: 0.3), colorScheme.primary.withValues(alpha: 0.0)],
                      ),
                    ),
                  ),
                  // AI 예측 (점선)
                  LineChartBarData(
                    spots: weightPrediction,
                    isCurved: true,
                    color: const Color(0xFF8B5CF6),
                    barWidth: 2,
                    dashArray: [8, 4],
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 3,
                        color: const Color(0xFF8B5CF6),
                        strokeWidth: 1,
                        strokeColor: Colors.white,
                      ),
                    ),
                  ),
                ],
                minY: 69,
                maxY: 76,
                minX: 0,
                maxX: 11,
              ),
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

          const SizedBox(height: 40),

          // 근육량 변화 차트
          Text('근육량 변화', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            '최근 8주간 근육량 변화 + AI 예측 (4주)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 0.5,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: colorScheme.outline.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toStringAsFixed(1)}kg',
                        style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 11),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final weekNum = value.toInt() + 1;
                        final isPrediction = value >= 8;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '$weekNum주${isPrediction ? '*' : ''}',
                            style: TextStyle(
                              color: isPrediction
                                  ? const Color(0xFF8B5CF6).withValues(alpha: 0.7)
                                  : colorScheme.onSurface.withValues(alpha: 0.5),
                              fontSize: 11,
                              fontStyle: isPrediction ? FontStyle.italic : FontStyle.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // 실제 데이터
                  LineChartBarData(
                    spots: muscleData,
                    isCurved: true,
                    color: const Color(0xFF10B981),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: const Color(0xFF10B981),
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF10B981).withValues(alpha: 0.3),
                          const Color(0xFF10B981).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                  // AI 예측 (점선)
                  LineChartBarData(
                    spots: musclePrediction,
                    isCurved: true,
                    color: const Color(0xFF8B5CF6),
                    barWidth: 2,
                    dashArray: [8, 4],
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 3,
                        color: const Color(0xFF8B5CF6),
                        strokeWidth: 1,
                        strokeColor: Colors.white,
                      ),
                    ),
                  ),
                ],
                minY: 31,
                maxY: 36,
                minX: 0,
                maxX: 11,
              ),
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

          const SizedBox(height: 16),
          Text(
            '* AI 예측은 현재 진행 추세를 기반으로 한 예측입니다.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDashed) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 3,
          decoration: BoxDecoration(
            color: isDashed ? Colors.transparent : color,
            border: isDashed ? Border.all(color: color, width: 1) : null,
          ),
          child: isDashed
              ? Row(
                  children: [
                    Container(width: 6, height: 3, color: color),
                    const SizedBox(width: 4),
                    Container(width: 6, height: 3, color: color),
                    const SizedBox(width: 4),
                    Container(width: 6, height: 3, color: color),
                  ],
                )
              : null,
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // 커리큘럼 탭
  Widget _buildCurriculumTab(BuildContext context, MemberWithUser memberWithUser) {
    final colorScheme = Theme.of(context).colorScheme;
    final member = memberWithUser.member;

    final sessions = List.generate(member.ptInfo.completedSessions, (index) {
      final sessionDate = member.ptInfo.startDate.add(Duration(days: index * 3));
      return {
        'session': index + 1,
        'date': sessionDate,
        'focus': ['상체', '하체', '코어', '전신'][index % 4],
        'exercises': ['벤치프레스', '스쿼트', '플랭크', '데드리프트'][index % 4],
        'completed': true,
      };
    });

    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center_rounded, size: 64, color: colorScheme.onSurface.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(
              '아직 진행한 세션이 없습니다',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        final isCompleted = session['completed'] as bool;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? colorScheme.primary.withValues(alpha: 0.1)
                      : colorScheme.outline.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${session['session']}',
                    style: TextStyle(
                      color: isCompleted ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${session['focus']} 운동',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session['exercises'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('MM.dd').format(session['date'] as DateTime),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '완료',
                      style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms, delay: (50 * index).ms).slideX(begin: 0.05, end: 0);
      },
    );
  }

  // 인바디 탭
  Widget _buildInbodyTab(BuildContext context, MemberWithUser memberWithUser) {
    final colorScheme = Theme.of(context).colorScheme;
    final memberId = memberWithUser.member.id;
    final historyAsync = ref.watch(inbodyHistoryProvider(memberId));

    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('오류가 발생했습니다: $e'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref.invalidate(inbodyHistoryProvider(memberId)),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
      data: (inbodyRecords) {
        if (inbodyRecords.isEmpty) {
          return _buildEmptyInbodyState(context, memberId);
        }
        return _buildInbodyContent(context, memberId, inbodyRecords, colorScheme);
      },
    );
  }

  Widget _buildEmptyInbodyState(BuildContext context, String memberId) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assessment_outlined, size: 64, color: colorScheme.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            '인바디 기록이 없습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '회원이 인바디 측정을 완료하면 여기에 표시됩니다',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  Widget _buildInbodyContent(
    BuildContext context,
    String memberId,
    List<InbodyRecordModel> inbodyRecords,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '인바디 측정 기록',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),

          // 인바디 카드 목록
          ...inbodyRecords.asMap().entries.map((entry) {
            final index = entry.key;
            final record = entry.value;
            final prevRecord = index < inbodyRecords.length - 1 ? inbodyRecords[index + 1] : null;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('yyyy년 MM월 dd일').format(record.measuredAt),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: [
                          if (index == 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '최신',
                                style: TextStyle(color: colorScheme.primary, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                          IconButton(
                            icon: Icon(Icons.delete_outline, size: 18, color: colorScheme.error),
                            onPressed: () => _deleteInbodyRecord(context, memberId, record),
                            tooltip: '삭제',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      _buildInbodyMetric(context, '체중', '${record.weight.toStringAsFixed(1)}kg', prevRecord != null ? record.weight - prevRecord.weight : null, false),
                      _buildInbodyMetric(context, '골격근', '${record.skeletalMuscleMass.toStringAsFixed(1)}kg', prevRecord != null ? record.skeletalMuscleMass - prevRecord.skeletalMuscleMass : null, true),
                      _buildInbodyMetric(context, '체지방', '${record.bodyFatPercent.toStringAsFixed(1)}%', prevRecord != null ? record.bodyFatPercent - prevRecord.bodyFatPercent : null, false),
                      if (record.bmi != null)
                        _buildInbodyMetric(context, 'BMI', record.bmi!.toStringAsFixed(1), prevRecord?.bmi != null ? record.bmi! - prevRecord!.bmi! : null, false),
                      if (record.inbodyScore != null)
                        _buildInbodyMetric(context, '점수', '${record.inbodyScore}점', prevRecord?.inbodyScore != null ? (record.inbodyScore! - prevRecord!.inbodyScore!).toDouble() : null, true),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms, delay: (100 * index).ms).slideY(begin: 0.1, end: 0);
          }),
        ],
      ),
    );
  }

  Future<void> _deleteInbodyRecord(BuildContext context, String memberId, InbodyRecordModel record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기록 삭제'),
        content: const Text('이 인바디 기록을 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('삭제')),
        ],
      ),
    );
    if (confirmed == true) {
      final notifier = ref.read(inbodyNotifierProvider.notifier);
      final success = await notifier.deleteRecord(memberId, record.id);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('기록이 삭제되었습니다'), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  Widget _buildInbodyMetric(BuildContext context, String label, String value, double? change, bool increaseIsGood) {
    final colorScheme = Theme.of(context).colorScheme;

    Color? changeColor;
    IconData? changeIcon;
    if (change != null && change != 0) {
      final isPositiveChange = change > 0;
      final isGood = increaseIsGood ? isPositiveChange : !isPositiveChange;
      changeColor = isGood ? const Color(0xFF10B981) : const Color(0xFFEF4444);
      changeIcon = isPositiveChange ? Icons.arrow_upward : Icons.arrow_downward;
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (change != null && change != 0) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(changeIcon, size: 12, color: changeColor),
                  const SizedBox(width: 2),
                  Text(
                    '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}',
                    style: TextStyle(fontSize: 11, color: changeColor, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 채팅 탭
  Widget _buildChatTab(BuildContext context, MemberWithUser memberWithUser) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_bubble_outline, size: 48, color: colorScheme.primary),
          ),
          const SizedBox(height: 24),
          Text(
            '${memberWithUser.name}님과 대화하기',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            '채팅방으로 이동하여 회원과 대화할 수 있습니다.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              // TODO: Navigate to chat room
              context.go('/trainer/messages');
            },
            icon: const Icon(Icons.chat),
            label: const Text('채팅방 이동'),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  // ============================================================================
  // 다이얼로그 및 유틸리티
  // ============================================================================

  Future<void> _showDeleteDialog(BuildContext context, MemberWithUser memberWithUser) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원 삭제'),
        content: Text('${memberWithUser.name} 회원을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('취소')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(membersNotifierProvider.notifier).deleteMember(memberWithUser.member.id);
      if (!context.mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('회원이 삭제되었습니다')));
    }
  }

  Color _getGoalColor(FitnessGoal goal) {
    return switch (goal) {
      FitnessGoal.diet => const Color(0xFF10B981),
      FitnessGoal.bulk => const Color(0xFFF59E0B),
      FitnessGoal.fitness => const Color(0xFF2563EB),
      FitnessGoal.rehab => const Color(0xFFEF4444),
    };
  }

  IconData _getGoalIcon(FitnessGoal goal) {
    return switch (goal) {
      FitnessGoal.diet => Icons.trending_down_rounded,
      FitnessGoal.bulk => Icons.trending_up_rounded,
      FitnessGoal.fitness => Icons.favorite_rounded,
      FitnessGoal.rehab => Icons.healing_rounded,
    };
  }

  // ============================================================================
  // 로딩/에러/없음 상태
  // ============================================================================

  Widget _buildLoadingSkeleton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(height: WebTheme.headerHeight, color: isDark ? WebTheme.cardBgDark : WebTheme.cardBgLight),
        Expanded(
          child: Row(
            children: [
              Container(
                width: 360,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: List.generate(
                    3,
                    (index) => Container(
                      height: 150,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat())
                        .shimmer(duration: 1500.ms, color: colorScheme.surface),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(duration: 1500.ms, color: colorScheme.surfaceContainerHighest),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, Object error, String memberId) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 64, color: colorScheme.error),
          const SizedBox(height: 16),
          Text('회원 정보를 불러올 수 없습니다', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back), label: const Text('돌아가기')),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => ref.refresh(memberDetailProvider(memberId)),
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_outlined, size: 64, color: colorScheme.onSurface.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('회원을 찾을 수 없습니다', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 24),
          OutlinedButton.icon(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back), label: const Text('돌아가기')),
        ],
      ),
    );
  }
}
