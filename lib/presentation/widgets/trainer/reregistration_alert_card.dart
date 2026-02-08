import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/models/reregistration_alert_model.dart';
import '../../providers/reregistration_provider.dart';

/// 재등록 대기 회원 알림 카드 - 트레이너 대시보드용
/// 재등록이 필요한 회원 정보와 진행률을 표시
class ReregistrationAlertCard extends ConsumerWidget {
  const ReregistrationAlertCard({
    super.key,
    required this.alert,
    required this.memberName,
    this.memberProfileUrl,
    this.onContact,
    this.onMarkComplete,
  });

  /// 재등록 알림 모델
  final ReregistrationAlertModel alert;

  /// 회원 이름
  final String memberName;

  /// 회원 프로필 이미지 URL
  final String? memberProfileUrl;

  /// 연락하기 버튼 콜백
  final VoidCallback? onContact;

  /// 완료 버튼 콜백
  final VoidCallback? onMarkComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.gray100,
          width: 1,
        ),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          // 헤더 영역
          _buildHeader(context, colorScheme, isDark),

          // 구분선
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),

          // 진행률 영역
          _buildProgressSection(context, colorScheme),

          // 알림 발송 상태 (있는 경우)
          if (alert.alertSentAt != null) _buildAlertSentInfo(context, colorScheme),

          // 액션 버튼 영역
          _buildActionButtons(context, colorScheme, ref),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme, bool isDark) {
    final progressPercent = (alert.progressRate * 100).toInt();
    final initials = _getInitials(memberName);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 프로필 아바타
          _buildAvatar(initials, colorScheme),
          const SizedBox(width: 12),

          // 회원 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        memberName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(colorScheme),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${alert.completedSessions}/${alert.totalSessions}회 완료 ($progressPercent%)',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // 남은 회차 뱃지
          _buildRemainingBadge(colorScheme),
        ],
      ),
    );
  }

  Widget _buildAvatar(String initials, ColorScheme colorScheme) {
    final avatarColor = alert.progressRate >= 0.9 ? AppTheme.error : AppTheme.tertiary;

    if (memberProfileUrl != null && memberProfileUrl!.isNotEmpty) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: avatarColor.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            memberProfileUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildInitialsAvatar(initials, avatarColor),
          ),
        ),
      );
    }

    return _buildInitialsAvatar(initials, avatarColor);
  }

  Widget _buildInitialsAvatar(String initials, Color color) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
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
            fontSize: 18,
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

  Widget _buildStatusBadge(ColorScheme colorScheme) {
    final Color badgeColor;
    final String badgeText;
    final IconData badgeIcon;

    if (alert.alertSentAt != null) {
      badgeColor = AppTheme.secondary;
      badgeText = '알림 발송됨';
      badgeIcon = Icons.check_circle_outline;
    } else if (alert.progressRate >= 0.9) {
      badgeColor = AppTheme.error;
      badgeText = '긴급';
      badgeIcon = Icons.priority_high;
    } else {
      badgeColor = AppTheme.tertiary;
      badgeText = '재등록 대기';
      badgeIcon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 12, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            badgeText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemainingBadge(ColorScheme colorScheme) {
    final remaining = alert.remainingSessions;
    final color = remaining <= 2 ? AppTheme.error : AppTheme.tertiary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$remaining',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            '회 남음',
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

  Widget _buildProgressSection(BuildContext context, ColorScheme colorScheme) {
    final progressColor = alert.progressRate >= 0.9
        ? AppTheme.error
        : alert.progressRate >= 0.8
            ? AppTheme.tertiary
            : AppTheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 진행률 라벨
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PT 진행률',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                alert.progressPercentage,
                style: TextStyle(
                  fontSize: 12,
                  color: progressColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 진행률 바
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                // 배경
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                // 진행률
                FractionallySizedBox(
                  widthFactor: alert.progressRate.clamp(0.0, 1.0),
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          progressColor,
                          progressColor.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                // 80% 마커
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.8 * 0.7, // 대략적인 위치
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    color: colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // 힌트 텍스트
          Text(
            '80% 이상 완료 시 재등록 알림 대상',
            style: TextStyle(
              fontSize: 10,
              color: colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertSentInfo(BuildContext context, ColorScheme colorScheme) {
    final dateFormat = DateFormat('M월 d일 HH:mm');
    final sentTimeText = dateFormat.format(alert.alertSentAt!);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_active_outlined,
            size: 16,
            color: AppTheme.secondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$sentTimeText에 알림 발송됨',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, ColorScheme colorScheme, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 연락하기 버튼
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onContact,
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text('연락하기'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 완료 버튼
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onMarkComplete,
              icon: const Icon(Icons.check, size: 18),
              label: const Text('완료'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 재등록 알림 리스트 위젯 - 트레이너 대시보드에서 여러 알림 표시
class ReregistrationAlertList extends ConsumerWidget {
  const ReregistrationAlertList({
    super.key,
    required this.trainerId,
    required this.getMemberName,
    this.getMemberProfileUrl,
    this.onContactMember,
    this.onMarkComplete,
    this.maxItems,
  });

  /// 트레이너 ID
  final String trainerId;

  /// 회원 ID로 이름 조회하는 함수
  final String Function(String memberId) getMemberName;

  /// 회원 ID로 프로필 URL 조회하는 함수 (선택)
  final String? Function(String memberId)? getMemberProfileUrl;

  /// 회원에게 연락하기 콜백
  final void Function(String memberId)? onContactMember;

  /// 완료 처리 콜백
  final void Function(String memberId)? onMarkComplete;

  /// 표시할 최대 항목 수 (null이면 전체 표시)
  final int? maxItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(reregistrationAlertsProvider(trainerId));

    return alertsAsync.when(
      data: (alerts) {
        if (alerts.isEmpty) {
          return _buildEmptyState(context);
        }

        final displayAlerts = maxItems != null
            ? alerts.take(maxItems!).toList()
            : alerts;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            _buildListHeader(context, alerts.length),
            const SizedBox(height: 12),
            // 알림 카드 목록
            ...displayAlerts.map((alert) => ReregistrationAlertCard(
                  alert: alert,
                  memberName: getMemberName(alert.memberId),
                  memberProfileUrl: getMemberProfileUrl?.call(alert.memberId),
                  onContact: () => onContactMember?.call(alert.memberId),
                  onMarkComplete: () => onMarkComplete?.call(alert.memberId),
                )),
            // 더보기 표시
            if (maxItems != null && alerts.length > maxItems!)
              _buildShowMoreButton(context, alerts.length - maxItems!),
          ],
        );
      },
      loading: () => _buildLoadingState(context),
      error: (error, _) => _buildErrorState(context, error),
    );
  }

  Widget _buildListHeader(BuildContext context, int count) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.tertiary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.notification_important_outlined,
            color: AppTheme.tertiary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '재등록 대기',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.tertiary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 48,
            color: AppTheme.secondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            '재등록 대기 회원이 없어요',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppTheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '데이터를 불러오는 중 문제가 생겼어요',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowMoreButton(BuildContext context, int remainingCount) {
    return TextButton(
      onPressed: () {
        // TODO: 전체 목록 페이지로 이동
      },
      child: Text(
        '+$remainingCount명 더보기',
        style: const TextStyle(
          color: AppTheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
