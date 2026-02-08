import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/core/theme/app_tokens.dart';
import 'package:flutter_pal_app/data/models/member_model.dart';

/// 회원 카드 위젯
/// 스와이프 액션(수정/삭제) 지원
class MemberCard extends StatelessWidget {
  final MemberModel member;
  final String? memberName;
  final String? profileImageUrl;
  final DateTime? lastWorkoutDate;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MemberCard({
    super.key,
    required this.member,
    this.memberName,
    this.profileImageUrl,
    this.lastWorkoutDate,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isWarning =
        member.remainingSessions <= 5 && member.remainingSessions > 0;
    final isCompleted = member.remainingSessions <= 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(member.id),
        // 왼쪽 스와이프 → 수정
        startActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (_) => onEdit?.call(),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: '수정',
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
            ),
          ],
        ),
        // 오른쪽 스와이프 → 삭제
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (_) => _showDeleteConfirmation(context),
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: '삭제',
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(16),
              ),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: onTap,
          child: _MemberCardContent(
            member: member,
            memberName: memberName,
            profileImageUrl: profileImageUrl,
            lastWorkoutDate: lastWorkoutDate,
            isWarning: isWarning,
            isCompleted: isCompleted,
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원 삭제'),
        content: Text(
          '${memberName ?? '회원'}님을 삭제할까요?\n이 작업은 되돌릴 수 없어요',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}

/// 카드 내부 컨텐츠
class _MemberCardContent extends StatelessWidget {
  final MemberModel member;
  final String? memberName;
  final String? profileImageUrl;
  final DateTime? lastWorkoutDate;
  final bool isWarning;
  final bool isCompleted;

  const _MemberCardContent({
    required this.member,
    this.memberName,
    this.profileImageUrl,
    this.lastWorkoutDate,
    required this.isWarning,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final progressPercent = (member.progressRate * 100).toInt();
    final displayName = memberName ?? '회원 ${member.id.substring(0, 4)}';

    return Opacity(
      // 완료 상태일 때 전체 카드를 회색빛으로 처리
      opacity: isCompleted ? 0.7 : 1.0,
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: isWarning
            ? Border.all(
                color: AppTheme.tertiary.withValues(alpha: 0.3), width: 1.5)
            : isCompleted
                ? Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.gray100)
                : Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.gray100),
        boxShadow: AppShadows.md,
      ),
      child: Row(
        children: [
          // 프로필 아바타
          _buildAvatar(displayName),
          const SizedBox(width: 16),

          // 회원 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이름 + 상태 아이콘
                _buildNameRow(displayName, colorScheme),
                const SizedBox(height: 4),

                // 목표 배지 + 진행률
                _buildGoalAndProgress(progressPercent, colorScheme),
                const SizedBox(height: 8),

                // 진행률 바
                _buildProgressBar(colorScheme),
                const SizedBox(height: 6),

                // 마지막 운동일
                _buildLastWorkoutDate(colorScheme),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // 남은 회차
          _buildRemainingBadge(),
        ],
      ),
    ),
    );
  }

  Widget _buildAvatar(String name) {
    final goalColor = _getGoalColor(member.goal);
    final initials = _getInitials(name);

    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: goalColor.withValues(alpha: 0.5),
            width: 3,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            profileImageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _buildInitialsAvatar(initials, goalColor),
          ),
        ),
      );
    }

    return _buildInitialsAvatar(initials, goalColor);
  }

  Widget _buildInitialsAvatar(String initials, Color color) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  Widget _buildNameRow(String name, ColorScheme colorScheme) {
    return Row(
      children: [
        Flexible(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        if (isWarning)
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppTheme.tertiary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppTheme.tertiary,
              size: 16,
            ),
          ),
        if (isCompleted)
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppTheme.secondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppTheme.secondary,
              size: 16,
            ),
          ),
      ],
    );
  }

  Widget _buildGoalAndProgress(int progressPercent, ColorScheme colorScheme) {
    return Row(
      children: [
        _buildGoalBadge(member.goal),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${member.ptInfo.completedSessions}/${member.ptInfo.totalSessions}회 ($progressPercent%)',
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalBadge(FitnessGoal goal) {
    final color = _getGoalColor(goal);
    final icon = _getGoalIcon(goal);
    final label = _getGoalLabel(goal);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(ColorScheme colorScheme) {
    final color = isCompleted
        ? AppTheme.secondary
        : isWarning
            ? AppTheme.tertiary
            : AppTheme.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: member.progressRate,
        backgroundColor: colorScheme.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation<Color>(color),
        minHeight: 6,
      ),
    );
  }

  Widget _buildLastWorkoutDate(ColorScheme colorScheme) {
    if (lastWorkoutDate == null) {
      return Row(
        children: [
          Icon(Icons.schedule, size: 12, color: colorScheme.outline),
          const SizedBox(width: 4),
          Text(
            '운동 기록 없음',
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.outline,
            ),
          ),
        ],
      );
    }

    final now = DateTime.now();
    final diff = now.difference(lastWorkoutDate!);
    String dateText;
    Color dateColor;

    if (diff.inDays == 0) {
      dateText = '오늘 운동';
      dateColor = AppTheme.secondary;
    } else if (diff.inDays == 1) {
      dateText = '어제 운동';
      dateColor = AppTheme.primary;
    } else if (diff.inDays < 7) {
      dateText = '${diff.inDays}일 전 운동';
      dateColor = colorScheme.onSurfaceVariant;
    } else if (diff.inDays < 14) {
      dateText = '1주 전 운동';
      dateColor = AppTheme.tertiary;
    } else {
      dateText = '${(diff.inDays / 7).floor()}주 전 운동';
      dateColor = AppTheme.error;
    }

    return Row(
      children: [
        Icon(Icons.schedule, size: 12, color: dateColor),
        const SizedBox(width: 4),
        Text(
          dateText,
          style: TextStyle(
            fontSize: 11,
            color: dateColor,
            fontWeight: diff.inDays >= 7 ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildRemainingBadge() {
    final color = isCompleted
        ? AppTheme.secondary
        : isWarning
            ? AppTheme.error
            : AppTheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: isWarning
            ? Border.all(color: color.withValues(alpha: 0.3))
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCompleted)
            const Icon(
              Icons.emoji_events,
              color: AppTheme.secondary,
              size: 24,
            )
          else
            Text(
              '${member.remainingSessions}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          Text(
            isCompleted ? '완료' : '회 남음',
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getGoalColor(FitnessGoal goal) {
    return switch (goal) {
      FitnessGoal.diet => AppTheme.error,
      FitnessGoal.bulk => AppTheme.primary,
      FitnessGoal.fitness => AppTheme.secondary,
      FitnessGoal.rehab => AppTheme.tertiary,
    };
  }

  IconData _getGoalIcon(FitnessGoal goal) {
    return switch (goal) {
      FitnessGoal.diet => Icons.local_fire_department,
      FitnessGoal.bulk => Icons.fitness_center,
      FitnessGoal.fitness => Icons.directions_run,
      FitnessGoal.rehab => Icons.healing,
    };
  }

  String _getGoalLabel(FitnessGoal goal) {
    return switch (goal) {
      FitnessGoal.diet => '다이어트',
      FitnessGoal.bulk => '벌크업',
      FitnessGoal.fitness => '체력향상',
      FitnessGoal.rehab => '재활',
    };
  }
}

/// 컴팩트 버전 회원 카드 (대시보드 등에서 사용)
class MemberCardCompact extends StatelessWidget {
  final MemberModel member;
  final String? memberName;
  final String? profileImageUrl;
  final VoidCallback? onTap;

  const MemberCardCompact({
    super.key,
    required this.member,
    this.memberName,
    this.profileImageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWarning =
        member.remainingSessions <= 5 && member.remainingSessions > 0;
    final displayName = memberName ?? '회원';
    final goalColor = _getGoalColor(member.goal);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: isWarning
              ? Border.all(
                  color: AppTheme.tertiary.withValues(alpha: 0.3), width: 1.5)
              : Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.gray100),
          boxShadow: AppShadows.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아바타
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [goalColor, goalColor.withValues(alpha: 0.7)],
                ),
                shape: BoxShape.circle,
              ),
              child: profileImageUrl != null
                  ? ClipOval(
                      child: Image.network(
                        profileImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Center(
                          child: Text(
                            displayName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        displayName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            // 이름
            Text(
              displayName,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // 남은 회차
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isWarning
                    ? AppTheme.error.withValues(alpha: 0.1)
                    : goalColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${member.remainingSessions}회 남음',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isWarning ? AppTheme.error : goalColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getGoalColor(FitnessGoal goal) {
    return switch (goal) {
      FitnessGoal.diet => AppTheme.error,
      FitnessGoal.bulk => AppTheme.primary,
      FitnessGoal.fitness => AppTheme.secondary,
      FitnessGoal.rehab => AppTheme.tertiary,
    };
  }
}
