import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:flutter_pal_app/core/theme/app_tokens.dart';
import 'package:flutter_pal_app/data/models/member_model.dart';
import 'package:flutter_pal_app/presentation/providers/members_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/member_card.dart';
import 'package:flutter_pal_app/presentation/widgets/add_member_dialog.dart';
import '../../../presentation/widgets/states/states.dart';
import 'package:flutter_pal_app/presentation/widgets/common/card_animations.dart';
import 'package:flutter_pal_app/presentation/widgets/common/mesh_gradient_background.dart';

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
      backgroundColor: Colors.transparent,
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
      body: MeshGradientBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
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
        ),
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
            const Icon(Icons.check, size: 18, color: AppColors.primary)
          else
            const SizedBox(width: AppSpacing.md),
          const SizedBox(width: AppSpacing.sm),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildSearchAndStats() {
    final statsAsync = ref.watch(memberStatsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
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
          const SizedBox(height: AppSpacing.sm),

          // 통계 칩
          statsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (stats) => Row(
              children: [
                _buildStatChip(
                  '전체 ${stats.totalMembers}명',
                  AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildStatChip(
                  '진행중 ${stats.activeMembers}명',
                  AppColors.secondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildStatChip(
                  '완료 ${stats.completedMembers}명',
                  AppColors.gray500,
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.fullBorderRadius,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: AppTextStyle.bodySmall,
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
          baseColor: isDark ? AppColors.gray700 : AppColors.gray300,
          highlightColor: isDark ? AppColors.gray600 : AppColors.gray100,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: AppRadius.lgBorderRadius,
                  border: Border.all(
                    color: isDark ? AppColors.gray700 : AppColors.gray200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
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
                    const SizedBox(width: AppSpacing.md),
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
                          const SizedBox(height: AppSpacing.sm),
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
                        borderRadius: AppRadius.smBorderRadius,
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

  /// 회원 목록 (staggered fadeIn + slideY 애니메이션 적용) - MemberWithUser 사용
  Widget _buildMemberListWithUser(List<MemberWithUser> membersWithUser) {
    final searchQuery = ref.watch(memberSearchQueryProvider);
    final sortOption = ref.watch(memberSortOptionProvider);

    return AnimatedListWrapper(
      child: ListView.builder(
        // 검색/정렬 변경 시 애니메이션 재실행을 위한 키
        key: ValueKey('$searchQuery-${sortOption.name}'),
        padding: EdgeInsets.zero,
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
              onTap: () => context.push('/trainer/members/${mwu.member.id}'),
              onEdit: () => _showEditMemberDialog(mwu.member),
              onDelete: () => _deleteMember(mwu.member),
            ),
          )
              .animate(delay: Duration(milliseconds: index * 50))
              .fadeIn(duration: const Duration(milliseconds: 300))
              .slideY(
                begin: 0.1,
                end: 0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
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
        content: Text('${member.goalLabel} 목표의 회원 정보를 수정할게요'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 수정 화면으로 이동
              context.push('/trainer/members/${member.id}');
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
            content: Text('회원이 삭제됐어요'),
            backgroundColor: AppColors.secondary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('삭제 실패: $e'),
            backgroundColor: AppColors.error,
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
