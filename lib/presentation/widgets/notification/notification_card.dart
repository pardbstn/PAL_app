import 'package:flutter/material.dart';

import 'package:flutter_pal_app/data/models/notification_model.dart';

/// 단일 알림 항목 카드
///
/// 알림 타입에 따른 아이콘, 제목, 본문, 시간을 표시합니다.
/// 읽지 않은 알림은 파란색 점으로 표시됩니다.
class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  // 디자인 시스템 색상
  static const Color _primaryColor = Color(0xFF2563EB);
  static const Color _successColor = Color(0xFF10B981);
  static const Color _warningColor = Color(0xFFF59E0B);
  static const Color _errorColor = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 통일된 카드 스타일 색상
    final backgroundColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final borderColor = isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);

    // 읽지 않은 알림 하이라이트 배경색
    final cardColor = notification.isRead
        ? backgroundColor
        : (isDark
            ? _primaryColor.withValues(alpha: 0.15)
            : _primaryColor.withValues(alpha: 0.06));

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 알림 타입 아이콘
                _NotificationIcon(type: notification.type),
                const SizedBox(width: 12),
                // 알림 내용
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목 + 읽지 않음 표시
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: notification.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // 읽지 않음 인디케이터
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 8),
                              decoration: const BoxDecoration(
                                color: _primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // 본문
                      Text(
                        notification.body,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // 시간
                      Text(
                        notification.timeAgo,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                // 화살표 아이콘
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: theme.colorScheme.outline,
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

/// 알림 타입별 아이콘 위젯
class _NotificationIcon extends StatelessWidget {
  final NotificationType type;

  const _NotificationIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final config = _getIconConfig(type);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        config.icon,
        color: config.color,
        size: 22,
      ),
    );
  }

  _IconConfig _getIconConfig(NotificationType type) {
    switch (type) {
      case NotificationType.reregistration:
        return _IconConfig(
          icon: Icons.autorenew,
          color: NotificationCard._warningColor,
        );
      case NotificationType.sessionReminder:
        return _IconConfig(
          icon: Icons.event_available,
          color: NotificationCard._primaryColor,
        );
      case NotificationType.streakReminder:
        return _IconConfig(
          icon: Icons.local_fire_department,
          color: NotificationCard._errorColor,
        );
      case NotificationType.reviewRequest:
        return _IconConfig(
          icon: Icons.rate_review_outlined,
          color: NotificationCard._successColor,
        );
      case NotificationType.trainerRequest:
        return _IconConfig(
          icon: Icons.person_add_alt_1,
          color: NotificationCard._primaryColor,
        );
      case NotificationType.badgeEarned:
        return _IconConfig(
          icon: Icons.workspace_premium,
          color: NotificationCard._successColor,
        );
      case NotificationType.badgeAtRisk:
        return _IconConfig(
          icon: Icons.warning_amber_rounded,
          color: NotificationCard._warningColor,
        );
      case NotificationType.badgeRevoked:
        return _IconConfig(
          icon: Icons.remove_circle_outline,
          color: NotificationCard._errorColor,
        );
      case NotificationType.general:
        return _IconConfig(
          icon: Icons.notifications_outlined,
          color: NotificationCard._primaryColor,
        );
    }
  }
}

/// 아이콘 설정
class _IconConfig {
  final IconData icon;
  final Color color;

  _IconConfig({
    required this.icon,
    required this.color,
  });
}
