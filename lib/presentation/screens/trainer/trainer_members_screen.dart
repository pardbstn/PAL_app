import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/data/models/member_model.dart';
import 'package:flutter_pal_app/presentation/providers/members_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/member_card.dart';
import 'package:flutter_pal_app/presentation/widgets/add_member_dialog.dart';
import '../../../presentation/widgets/states/states.dart';
import 'package:flutter_pal_app/presentation/widgets/common/card_animations.dart';

/// 트레이너 회원 목록 화면
class TrainerMembersScreen extends ConsumerStatefulWidget {
  const TrainerMembersScreen({super.key});

  @override
  ConsumerState<TrainerMembersScreen> createState() =>
      _TrainerMembersScreenState();
}

class _TrainerMembersScreenState extends ConsumerState<TrainerMembersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final membersWithUserAsync = ref.watch(sortedMembersWithUserProvider);
    final searchQuery = ref.watch(memberSearchQueryProvider);
    final sortOption = ref.watch(memberSortOptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('회원 관리'),
        actions: [
          // 정렬 버튼
          PopupMenuButton<MemberSortOption>(
            icon: const Icon(Icons.sort),
            tooltip: '정렬',
            onSelected: (option) {
              ref.read(memberSortOptionProvider.notifier).setSortOption(option);
            },
            itemBuilder: (context) => [
              _buildSortMenuItem(
                MemberSortOption.remainingSessionsDesc,
                '남은 회차 많은 순',
                sortOption,
              ),
              _buildSortMenuItem(
                MemberSortOption.remainingSessionsAsc,
                '남은 회차 적은 순',
                sortOption,
              ),
              _buildSortMenuItem(
                MemberSortOption.progressDesc,
                '진행률 높은 순',
                sortOption,
              ),
              _buildSortMenuItem(
                MemberSortOption.progressAsc,
                '진행률 낮은 순',
                sortOption,
              ),
            ],
          ),
          // 회원 추가 버튼
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            tooltip: '회원 등록',
            onPressed: () => _showAddMemberDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 검색바 + 통계
          _buildSearchAndStats(),

          // 회원 목록
          Expanded(
            child: membersWithUserAsync.when(
              loading: () => _buildShimmerList(),
              error: (error, stack) => _buildErrorView(error),
              data: (membersWithUser) {
                // 검색 필터 적용
                final filteredMembers =
                    _filterBySearchWithUser(membersWithUser, searchQuery);

                if (filteredMembers.isEmpty) {
                  return _buildEmptyView(searchQuery.isNotEmpty);
                }

                return _buildMemberListWithUser(filteredMembers);
              },
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<MemberSortOption> _buildSortMenuItem(
    MemberSortOption option,
    String label,
    MemberSortOption currentOption,
  ) {
    return PopupMenuItem(
      value: option,
      child: Row(
        children: [
          if (option == currentOption)
            const Icon(Icons.check, size: 18, color: AppTheme.primary)
          else
            const SizedBox(width: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildSearchAndStats() {
    final statsAsync = ref.watch(memberStatsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 검색바
          SearchBar(
            controller: _searchController,
            hintText: '회원 이름으로 검색...',
            leading: const Icon(Icons.search),
            trailing: [
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(memberSearchQueryProvider.notifier).clear();
                  },
                ),
            ],
            onChanged: (value) {
              ref.read(memberSearchQueryProvider.notifier).setQuery(value);
            },
          ),
          const SizedBox(height: 12),

          // 통계 칩
          statsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (stats) => Row(
              children: [
                _buildStatChip(
                  '전체 ${stats.totalMembers}명',
                  AppTheme.primary,
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  '진행중 ${stats.activeMembers}명',
                  AppTheme.secondary,
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  '완료 ${stats.completedMembers}명',
                  Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  /// 검색어로 필터링 (MemberWithUser 사용)
  List<MemberWithUser> _filterBySearchWithUser(
      List<MemberWithUser> members, String query) {
    if (query.isEmpty) return members;

    final lowerQuery = query.toLowerCase();
    return members.where((mwu) {
      // 이름으로 검색
      final nameMatch = mwu.name.toLowerCase().contains(lowerQuery);
      // 목표로 검색
      final goalMatch = mwu.member.goalLabel.toLowerCase().contains(lowerQuery);
      // 메모로 검색
      final memoMatch =
          mwu.member.memo?.toLowerCase().contains(lowerQuery) ?? false;
      // 이메일로 검색
      final emailMatch =
          mwu.email?.toLowerCase().contains(lowerQuery) ?? false;

      return nameMatch || goalMatch || memoMatch || emailMatch;
    }).toList();
  }

  /// Shimmer 로딩 스켈레톤
  Widget _buildShimmerList() {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Shimmer.fromColors(
          baseColor: isDark ? const Color(0xFF424242) : const Color(0xFFE0E0E0),
          highlightColor: isDark ? const Color(0xFF616161) : const Color(0xFFF5F5F5),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2937) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // 아바타
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 텍스트
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 16,
                            width: 120,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 12,
                            width: 180,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    // 회차 표시
                    Container(
                      width: 60,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// 에러 뷰
  Widget _buildErrorView(Object error) {
    return ErrorState.fromError(
      error,
      onRetry: () => ref.invalidate(membersProvider),
    );
  }

  /// 빈 상태 뷰
  Widget _buildEmptyView(bool isSearching) {
    if (isSearching) {
      return const EmptyState(type: EmptyStateType.search);
    }
    return EmptyState(
      type: EmptyStateType.members,
      onAction: () => _showAddMemberDialog(context),
    );
  }

  /// 회원 목록 (flutter_staggered_animations 적용) - MemberWithUser 사용
  Widget _buildMemberListWithUser(List<MemberWithUser> membersWithUser) {
    final searchQuery = ref.watch(memberSearchQueryProvider);
    final sortOption = ref.watch(memberSortOptionProvider);

    return AnimatedListWrapper(
      child: ListView.builder(
        // 검색/정렬 변경 시 애니메이션 재실행을 위한 키
        key: ValueKey('$searchQuery-${sortOption.name}'),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: membersWithUser.length,
        itemBuilder: (context, index) {
          final mwu = membersWithUser[index];
          return AnimatedListWrapper.item(
            index: index,
            child: MemberCard(
              member: mwu.member,
              memberName: mwu.name,
              profileImageUrl: mwu.profileImageUrl,
              lastWorkoutDate: null, // TODO: 마지막 운동일 연동
              onTap: () => context.go('/trainer/members/${mwu.member.id}'),
              onEdit: () => _showEditMemberDialog(mwu.member),
              onDelete: () => _deleteMember(mwu.member),
            ),
          );
        },
      ),
    );
  }

  /// 회원 수정 다이얼로그
  void _showEditMemberDialog(MemberModel member) {
    // TODO: 회원 수정 화면 또는 다이얼로그 구현
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원 수정'),
        content: Text('${member.goalLabel} 목표의 회원 정보를 수정합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 수정 화면으로 이동
              context.go('/trainer/members/${member.id}');
            },
            child: const Text('상세보기'),
          ),
        ],
      ),
    );
  }

  /// 회원 삭제
  Future<void> _deleteMember(MemberModel member) async {
    try {
      await ref.read(membersNotifierProvider.notifier).deleteMember(member.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('회원이 삭제되었습니다.'),
            backgroundColor: AppTheme.secondary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('삭제 실패: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _showAddMemberDialog(BuildContext context) async {
    final result = await AddMemberDialog.show(context);
    if (result == true) {
      // 회원 목록 새로고침
      ref.invalidate(membersProvider);
    }
  }
}
