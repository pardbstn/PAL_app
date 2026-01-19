import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/core/theme/web_theme.dart';
import 'package:flutter_pal_app/data/models/member_model.dart';
import 'package:flutter_pal_app/presentation/providers/members_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/add_member_dialog.dart';

/// 회원 필터 상태
enum MemberFilterTab { all, active, completed }

/// 회원 필터 Notifier
class MemberFilterTabNotifier extends Notifier<MemberFilterTab> {
  @override
  MemberFilterTab build() => MemberFilterTab.all;

  void setTab(MemberFilterTab tab) => state = tab;
}

/// 회원 필터 Provider
final memberFilterTabProvider =
    NotifierProvider<MemberFilterTabNotifier, MemberFilterTab>(
        () => MemberFilterTabNotifier());

/// 선택된 회원 ID 목록 Notifier
class SelectedMemberIdsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void add(String id) => state = {...state, id};

  void remove(String id) {
    final newState = Set<String>.from(state);
    newState.remove(id);
    state = newState;
  }

  void clear() => state = {};

  void setAll(Set<String> ids) => state = ids;
}

/// 선택된 회원 ID 목록 Provider
final selectedMemberIdsProvider =
    NotifierProvider<SelectedMemberIdsNotifier, Set<String>>(
        () => SelectedMemberIdsNotifier());

/// 트레이너 웹 회원 관리 화면
/// PlutoGrid 기반 프리미엄 SaaS 스타일 테이블 UI
class TrainerMembersWebScreen extends ConsumerStatefulWidget {
  const TrainerMembersWebScreen({super.key});

  @override
  ConsumerState<TrainerMembersWebScreen> createState() => _TrainerMembersWebScreenState();
}

class _TrainerMembersWebScreenState extends ConsumerState<TrainerMembersWebScreen> {
  final TextEditingController _searchController = TextEditingController();

  // 페이지네이션 상태
  int _currentPage = 1;
  static const int _itemsPerPage = 10;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(sortedMembersWithUserProvider);
    final searchQuery = ref.watch(memberSearchQueryProvider);
    final filterTab = ref.watch(memberFilterTabProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: WebTheme.contentBgColor(context),
      child: Column(
        children: [
          // 상단 툴바
          _buildToolbar(context, isDark),

          // 필터 탭
          _buildFilterTabs(context, filterTab, isDark),

          // 테이블 영역
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: membersAsync.when(
                loading: () => _buildLoadingSkeleton(isDark),
                error: (error, stack) => _buildErrorView(error, isDark),
                data: (membersWithUser) {
                  // 검색 필터 적용
                  var filtered = _filterBySearch(membersWithUser, searchQuery);
                  // 상태 필터 적용
                  filtered = _filterByTab(filtered, filterTab);

                  if (filtered.isEmpty) {
                    return _buildEmptyView(searchQuery.isNotEmpty, isDark);
                  }

                  return _buildMembersTable(context, filtered, isDark);
                },
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  /// 상단 툴바 빌드
  Widget _buildToolbar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? WebTheme.cardBgDark : WebTheme.cardBgLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          // 타이틀
          const Text(
            '회원 관리',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 32),

          // 검색바
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  ref.read(memberSearchQueryProvider.notifier).setQuery(value);
                },
                decoration: InputDecoration(
                  hintText: '이름, 이메일, 목표로 검색...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(memberSearchQueryProvider.notifier).clear();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.withValues(alpha: 0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // 회원 추가 버튼
          FilledButton.icon(
            onPressed: () => _showAddMemberDialog(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('회원 추가'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 300.ms);
  }

  /// 필터 탭 빌드
  Widget _buildFilterTabs(BuildContext context, MemberFilterTab currentTab, bool isDark) {
    final statsAsync = ref.watch(memberStatsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? WebTheme.cardBgDark : WebTheme.cardBgLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          statsAsync.when(
            data: (stats) => Row(
              children: [
                _buildFilterTabButton(
                  context,
                  MemberFilterTab.all,
                  '전체',
                  stats.totalMembers,
                  currentTab,
                  isDark,
                ),
                const SizedBox(width: 8),
                _buildFilterTabButton(
                  context,
                  MemberFilterTab.active,
                  '진행중',
                  stats.activeMembers,
                  currentTab,
                  isDark,
                ),
                const SizedBox(width: 8),
                _buildFilterTabButton(
                  context,
                  MemberFilterTab.completed,
                  '완료',
                  stats.completedMembers,
                  currentTab,
                  isDark,
                ),
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const Spacer(),
          // 선택된 회원 수 표시
          Consumer(
            builder: (context, ref, _) {
              final selectedIds = ref.watch(selectedMemberIdsProvider);
              if (selectedIds.isEmpty) return const SizedBox.shrink();

              return Row(
                children: [
                  Text(
                    '${selectedIds.length}명 선택됨',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: () {
                      ref.read(selectedMemberIdsProvider.notifier).clear();
                    },
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('선택 해제'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms, duration: 300.ms);
  }

  /// 필터 탭 버튼 빌드
  Widget _buildFilterTabButton(
    BuildContext context,
    MemberFilterTab tab,
    String label,
    int count,
    MemberFilterTab currentTab,
    bool isDark,
  ) {
    final isSelected = tab == currentTab;

    return InkWell(
      onTap: () {
        ref.read(memberFilterTabProvider.notifier).setTab(tab);
        _currentPage = 1;
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : (isDark ? Colors.white24 : Colors.grey.withValues(alpha: 0.3)),
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppTheme.primary : null,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary
                    : (isDark ? Colors.white12 : Colors.grey.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.grey[700]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// PlutoGrid 테이블 빌드
  Widget _buildMembersTable(BuildContext context, List<MemberWithUser> members, bool isDark) {
    final selectedIds = ref.watch(selectedMemberIdsProvider);

    // 페이지네이션 계산
    final totalPages = (members.length / _itemsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, members.length);
    final pagedMembers = members.sublist(startIndex, endIndex);

    // 컬럼 정의
    final columns = _buildColumns(context, members, selectedIds, isDark);

    // 행 데이터 생성
    final rows = pagedMembers.map((mwu) => _buildRow(mwu, selectedIds, isDark)).toList();

    return Container(
      decoration: WebTheme.cardDecoration(context),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // 테이블
          Expanded(
            child: PlutoGrid(
              columns: columns,
              rows: rows,
              onRowDoubleTap: (PlutoGridOnRowDoubleTapEvent event) {
                final memberId = event.row.cells['id']?.value as String?;
                if (memberId != null) {
                  context.push('/trainer/member/$memberId');
                }
              },
              configuration: PlutoGridConfiguration(
                style: PlutoGridStyleConfig(
                  gridBackgroundColor: isDark ? WebTheme.cardBgDark : WebTheme.cardBgLight,
                  rowColor: isDark ? WebTheme.cardBgDark : WebTheme.cardBgLight,
                  activatedColor: AppTheme.primary.withValues(alpha: 0.1),
                  activatedBorderColor: AppTheme.primary,
                  cellColorInEditState: isDark ? WebTheme.cardBgDark : Colors.white,
                  cellColorInReadOnlyState: isDark ? WebTheme.cardBgDark : Colors.grey[50]!,
                  borderColor: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.15),
                  gridBorderColor: Colors.transparent,
                  columnTextStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                    fontSize: 13,
                  ),
                  cellTextStyle: TextStyle(
                    color: isDark ? Colors.white : Colors.grey[800],
                    fontSize: 14,
                  ),
                  iconColor: isDark ? Colors.white70 : Colors.grey[600]!,
                  menuBackgroundColor: isDark ? WebTheme.cardBgDark : Colors.white,
                  rowHeight: 60,
                  columnHeight: 48,
                ),
                columnSize: const PlutoGridColumnSizeConfig(
                  autoSizeMode: PlutoAutoSizeMode.scale,
                ),
                scrollbar: const PlutoGridScrollbarConfig(
                  isAlwaysShown: false,
                  scrollbarThickness: 8,
                  scrollbarThicknessWhileDragging: 10,
                ),
              ),
            ),
          ),

          // 페이지네이션
          _buildPagination(context, totalPages, members.length, isDark),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  /// PlutoGrid 컬럼 정의
  List<PlutoColumn> _buildColumns(
    BuildContext context,
    List<MemberWithUser> allMembers,
    Set<String> selectedIds,
    bool isDark,
  ) {
    return [
      // 체크박스 컬럼
      PlutoColumn(
        title: '',
        field: 'checkbox',
        type: PlutoColumnType.text(),
        width: 50,
        minWidth: 50,
        enableSorting: false,
        enableFilterMenuItem: false,
        enableContextMenu: false,
        frozen: PlutoColumnFrozen.start,
        renderer: (rendererContext) {
          final memberId = rendererContext.row.cells['id']?.value as String?;
          final isSelected = memberId != null && selectedIds.contains(memberId);

          return Center(
            child: Checkbox(
              value: isSelected,
              onChanged: (value) {
                if (value == true && memberId != null) {
                  ref.read(selectedMemberIdsProvider.notifier).add(memberId);
                } else if (memberId != null) {
                  ref.read(selectedMemberIdsProvider.notifier).remove(memberId);
                }
              },
              activeColor: AppTheme.primary,
            ),
          );
        },
      ),

      // 프로필 컬럼 (frozen)
      PlutoColumn(
        title: '회원',
        field: 'profile',
        type: PlutoColumnType.text(),
        width: 180,
        minWidth: 150,
        frozen: PlutoColumnFrozen.start,
        enableFilterMenuItem: false,
        renderer: (rendererContext) {
          final name = rendererContext.row.cells['name']?.value as String? ?? '회원';
          final imageUrl = rendererContext.row.cells['imageUrl']?.value as String?;

          return _ProfileCell(name: name, imageUrl: imageUrl, isDark: isDark);
        },
      ),

      // 이메일 컬럼
      PlutoColumn(
        title: '이메일',
        field: 'email',
        type: PlutoColumnType.text(),
        width: 200,
        minWidth: 150,
        renderer: (rendererContext) {
          final email = rendererContext.cell.value as String? ?? '-';
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              email,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),

      // 목표 컬럼
      PlutoColumn(
        title: '목표',
        field: 'goal',
        type: PlutoColumnType.text(),
        width: 120,
        minWidth: 100,
        renderer: (rendererContext) {
          final goal = rendererContext.cell.value as String? ?? '';
          return Center(child: _GoalBadge(goal: goal, isDark: isDark));
        },
      ),

      // 경력 컬럼
      PlutoColumn(
        title: '경력',
        field: 'experience',
        type: PlutoColumnType.text(),
        width: 100,
        minWidth: 80,
        renderer: (rendererContext) {
          final experience = rendererContext.cell.value as String? ?? '';
          return Center(child: _ExperienceBadge(experience: experience, isDark: isDark));
        },
      ),

      // PT 진행률 컬럼
      PlutoColumn(
        title: 'PT 진행률',
        field: 'progress',
        type: PlutoColumnType.number(),
        width: 150,
        minWidth: 120,
        renderer: (rendererContext) {
          final progress = (rendererContext.row.cells['progressRate']?.value as double?) ?? 0.0;
          final completed = rendererContext.row.cells['completedSessions']?.value as int? ?? 0;
          final total = rendererContext.row.cells['totalSessions']?.value as int? ?? 0;

          return _ProgressCell(
            progress: progress,
            completed: completed,
            total: total,
            isDark: isDark,
          );
        },
      ),

      // 남은 회차 컬럼
      PlutoColumn(
        title: '남은 회차',
        field: 'remaining',
        type: PlutoColumnType.number(),
        width: 100,
        minWidth: 80,
        renderer: (rendererContext) {
          final remaining = rendererContext.cell.value as int? ?? 0;
          return Center(child: _RemainingCell(remaining: remaining, isDark: isDark));
        },
      ),

      // 상태 컬럼
      PlutoColumn(
        title: '상태',
        field: 'status',
        type: PlutoColumnType.text(),
        width: 90,
        minWidth: 80,
        renderer: (rendererContext) {
          final status = rendererContext.cell.value as String? ?? '';
          return Center(child: _StatusBadge(status: status, isDark: isDark));
        },
      ),

      // 액션 컬럼
      PlutoColumn(
        title: '',
        field: 'action',
        type: PlutoColumnType.text(),
        width: 60,
        minWidth: 50,
        enableSorting: false,
        enableFilterMenuItem: false,
        enableContextMenu: false,
        renderer: (rendererContext) {
          final memberId = rendererContext.row.cells['id']?.value as String?;
          final memberName = rendererContext.row.cells['name']?.value as String? ?? '회원';

          return Center(
            child: PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                size: 18,
                color: isDark ? Colors.white54 : Colors.grey[600],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onSelected: (value) {
                if (memberId == null) return;

                switch (value) {
                  case 'detail':
                    context.push('/trainer/member/$memberId');
                    break;
                  case 'edit':
                    _showEditDialog(context, memberId, memberName);
                    break;
                  case 'delete':
                    _showDeleteConfirmDialog(context, memberId, memberName);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'detail',
                  child: Row(
                    children: [
                      Icon(Icons.visibility_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('상세 보기'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('수정'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18, color: AppTheme.error),
                      const SizedBox(width: 8),
                      Text('삭제', style: TextStyle(color: AppTheme.error)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),

      // 숨김 필드들 (데이터 저장용)
      PlutoColumn(
        title: '',
        field: 'id',
        type: PlutoColumnType.text(),
        hide: true,
      ),
      PlutoColumn(
        title: '',
        field: 'name',
        type: PlutoColumnType.text(),
        hide: true,
      ),
      PlutoColumn(
        title: '',
        field: 'imageUrl',
        type: PlutoColumnType.text(),
        hide: true,
      ),
      PlutoColumn(
        title: '',
        field: 'progressRate',
        type: PlutoColumnType.number(),
        hide: true,
      ),
      PlutoColumn(
        title: '',
        field: 'completedSessions',
        type: PlutoColumnType.number(),
        hide: true,
      ),
      PlutoColumn(
        title: '',
        field: 'totalSessions',
        type: PlutoColumnType.number(),
        hide: true,
      ),
    ];
  }

  /// PlutoGrid 행 데이터 생성
  PlutoRow _buildRow(MemberWithUser mwu, Set<String> selectedIds, bool isDark) {
    final member = mwu.member;
    final isActive = member.remainingSessions > 0;

    return PlutoRow(
      cells: {
        'checkbox': PlutoCell(value: ''),
        'profile': PlutoCell(value: mwu.name),
        'email': PlutoCell(value: mwu.email ?? '-'),
        'goal': PlutoCell(value: member.goalLabel),
        'experience': PlutoCell(value: member.experienceLabel),
        'progress': PlutoCell(value: (member.progressRate * 100).round()),
        'remaining': PlutoCell(value: member.remainingSessions),
        'status': PlutoCell(value: isActive ? '진행중' : '완료'),
        'action': PlutoCell(value: ''),
        'id': PlutoCell(value: member.id),
        'name': PlutoCell(value: mwu.name),
        'imageUrl': PlutoCell(value: mwu.profileImageUrl ?? ''),
        'progressRate': PlutoCell(value: member.progressRate),
        'completedSessions': PlutoCell(value: member.ptInfo.completedSessions),
        'totalSessions': PlutoCell(value: member.ptInfo.totalSessions),
      },
    );
  }

  /// 페이지네이션 빌드
  Widget _buildPagination(BuildContext context, int totalPages, int totalItems, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            '전체 $totalItems명',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey[600],
              fontSize: 13,
            ),
          ),
          const Spacer(),
          // 이전 페이지 버튼
          IconButton(
            onPressed: _currentPage > 1
                ? () => setState(() => _currentPage--)
                : null,
            icon: const Icon(Icons.chevron_left),
            iconSize: 20,
            splashRadius: 20,
          ),
          // 페이지 번호들
          ...List.generate(
            totalPages.clamp(0, 5),
            (index) {
              final page = _calculatePageNumber(index, totalPages);
              final isCurrentPage = page == _currentPage;

              return InkWell(
                onTap: () => setState(() => _currentPage = page),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isCurrentPage ? AppTheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '$page',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isCurrentPage ? FontWeight.w600 : FontWeight.normal,
                        color: isCurrentPage
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.grey[700]),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // 다음 페이지 버튼
          IconButton(
            onPressed: _currentPage < totalPages
                ? () => setState(() => _currentPage++)
                : null,
            icon: const Icon(Icons.chevron_right),
            iconSize: 20,
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  /// 페이지 번호 계산 (현재 페이지 중심으로 표시)
  int _calculatePageNumber(int index, int totalPages) {
    if (totalPages <= 5) return index + 1;

    if (_currentPage <= 3) return index + 1;
    if (_currentPage >= totalPages - 2) return totalPages - 4 + index;
    return _currentPage - 2 + index;
  }

  /// 로딩 스켈레톤 빌드
  Widget _buildLoadingSkeleton(bool isDark) {
    return Container(
      decoration: WebTheme.cardDecoration(context),
      child: Column(
        children: [
          // 테이블 헤더 스켈레톤
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          // 테이블 행 스켈레톤
          Expanded(
            child: ListView.builder(
              itemCount: 8,
              itemBuilder: (context, index) {
                return Container(
                  height: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.03)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 1500.ms, color: isDark ? Colors.white10 : Colors.white);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 에러 뷰 빌드
  Widget _buildErrorView(Object error, bool isDark) {
    return Container(
      decoration: WebTheme.cardDecoration(context),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: AppTheme.error,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '회원 목록을 불러오지 못했습니다',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                ref.invalidate(membersProvider);
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  /// 빈 상태 뷰 빌드
  Widget _buildEmptyView(bool isSearching, bool isDark) {
    return Container(
      decoration: WebTheme.cardDecoration(context),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearching ? Icons.search_off : Icons.people_outline,
                size: 64,
                color: isDark ? Colors.white38 : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isSearching ? '검색 결과가 없습니다' : '아직 등록된 회원이 없습니다',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching ? '다른 검색어를 입력해보세요' : '첫 번째 회원을 등록해보세요!',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.grey[600],
              ),
            ),
            if (!isSearching) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _showAddMemberDialog(context),
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('회원 등록하기'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 검색 필터 적용
  List<MemberWithUser> _filterBySearch(List<MemberWithUser> members, String query) {
    if (query.isEmpty) return members;

    final lowerQuery = query.toLowerCase();
    return members.where((mwu) {
      final nameMatch = mwu.name.toLowerCase().contains(lowerQuery);
      final goalMatch = mwu.member.goalLabel.toLowerCase().contains(lowerQuery);
      final memoMatch = mwu.member.memo?.toLowerCase().contains(lowerQuery) ?? false;
      final emailMatch = mwu.email?.toLowerCase().contains(lowerQuery) ?? false;

      return nameMatch || goalMatch || memoMatch || emailMatch;
    }).toList();
  }

  /// 탭 필터 적용
  List<MemberWithUser> _filterByTab(List<MemberWithUser> members, MemberFilterTab tab) {
    switch (tab) {
      case MemberFilterTab.all:
        return members;
      case MemberFilterTab.active:
        return members.where((m) => m.member.remainingSessions > 0).toList();
      case MemberFilterTab.completed:
        return members.where((m) => m.member.remainingSessions <= 0).toList();
    }
  }

  /// 회원 추가 다이얼로그
  Future<void> _showAddMemberDialog(BuildContext context) async {
    final result = await AddMemberDialog.show(context);
    if (result == true) {
      ref.invalidate(membersProvider);
    }
  }

  /// 회원 수정 다이얼로그
  void _showEditDialog(BuildContext context, String memberId, String memberName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('$memberName 회원 수정'),
        content: const Text('회원 상세 페이지에서 수정하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/trainer/member/$memberId');
            },
            child: const Text('상세 보기'),
          ),
        ],
      ),
    );
  }

  /// 회원 삭제 확인 다이얼로그
  void _showDeleteConfirmDialog(BuildContext context, String memberId, String memberName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('회원 삭제'),
        content: Text('$memberName 회원을 정말 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(membersNotifierProvider.notifier).deleteMember(memberId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('회원이 삭제되었습니다.'),
                      backgroundColor: AppTheme.secondary,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('삭제 실패: $e'),
                      backgroundColor: AppTheme.error,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}

/// 프로필 셀 위젯
class _ProfileCell extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final bool isDark;

  const _ProfileCell({
    required this.name,
    this.imageUrl,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
            backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                ? NetworkImage(imageUrl!)
                : null,
            child: imageUrl == null || imageUrl!.isEmpty
                ? Text(
                    name.isNotEmpty ? name[0] : '?',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// 목표 배지 위젯
class _GoalBadge extends StatelessWidget {
  final String goal;
  final bool isDark;

  const _GoalBadge({required this.goal, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final (emoji, color) = _getGoalStyle(goal);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            goal,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color) _getGoalStyle(String goal) {
    switch (goal) {
      case '다이어트':
        return ('🔥', const Color(0xFFEF4444));
      case '벌크업':
        return ('💪', const Color(0xFF2563EB));
      case '체력 향상':
        return ('🏃', const Color(0xFF10B981));
      case '재활':
        return ('🩹', const Color(0xFFF59E0B));
      default:
        return ('🎯', Colors.grey);
    }
  }
}

/// 경력 배지 위젯
class _ExperienceBadge extends StatelessWidget {
  final String experience;
  final bool isDark;

  const _ExperienceBadge({required this.experience, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final stars = _getStars(experience);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Icon(
          index < stars ? Icons.star : Icons.star_border,
          size: 14,
          color: index < stars
              ? const Color(0xFFF59E0B)
              : (isDark ? Colors.white24 : Colors.grey[300]),
        );
      }),
    );
  }

  int _getStars(String experience) {
    switch (experience) {
      case '초급':
        return 1;
      case '중급':
        return 2;
      case '고급':
        return 3;
      default:
        return 0;
    }
  }
}

/// 진행률 셀 위젯
class _ProgressCell extends StatelessWidget {
  final double progress;
  final int completed;
  final int total;
  final bool isDark;

  const _ProgressCell({
    required this.progress,
    required this.completed,
    required this.total,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: isDark ? Colors.white12 : Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0
                      ? AppTheme.secondary
                      : AppTheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$completed/$total',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

/// 남은 회차 셀 위젯
class _RemainingCell extends StatelessWidget {
  final int remaining;
  final bool isDark;

  const _RemainingCell({required this.remaining, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isLow = remaining > 0 && remaining <= 5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isLow
            ? AppTheme.error.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLow) ...[
            Icon(
              Icons.warning_amber,
              size: 14,
              color: AppTheme.error,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            '$remaining회',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isLow ? AppTheme.error : (isDark ? Colors.white : Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
}

/// 상태 배지 위젯
class _StatusBadge extends StatelessWidget {
  final String status;
  final bool isDark;

  const _StatusBadge({required this.status, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isActive = status == '진행중';
    final color = isActive ? AppTheme.secondary : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
