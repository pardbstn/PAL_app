import 'package:flutter/material.dart';

/// 에러 다이얼로그
///
/// 사용자에게 에러를 알리고 선택적으로 재시도 기능을 제공합니다.
///
/// 사용 예시:
/// ```dart
/// ErrorDialog.show(
///   context: context,
///   title: '네트워크 오류',
///   message: '인터넷 연결을 확인해주세요',
///   onRetry: () => _loadData(),
/// );
/// ```
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? details;
  final VoidCallback? onRetry;
  final String confirmText;
  final String? retryText;
  final IconData icon;
  final Color? iconColor;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.details,
    this.onRetry,
    this.confirmText = '확인',
    this.retryText,
    this.icon = Icons.error_outline_rounded,
    this.iconColor,
  });

  /// 에러 다이얼로그 표시
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String? details,
    VoidCallback? onRetry,
    String confirmText = '확인',
    String? retryText,
    IconData icon = Icons.error_outline_rounded,
    Color? iconColor,
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        details: details,
        onRetry: onRetry,
        confirmText: confirmText,
        retryText: retryText,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  /// 네트워크 에러 다이얼로그
  static Future<bool?> showNetworkError({
    required BuildContext context,
    VoidCallback? onRetry,
    String message = '인터넷 연결을 확인해주세요',
  }) {
    return show(
      context: context,
      title: '네트워크 오류',
      message: message,
      icon: Icons.wifi_off_rounded,
      onRetry: onRetry,
      retryText: '다시 시도',
    );
  }

  /// 서버 에러 다이얼로그
  static Future<bool?> showServerError({
    required BuildContext context,
    VoidCallback? onRetry,
    String message = '서버와 통신 중 문제가 생겼어요',
  }) {
    return show(
      context: context,
      title: '서버 오류',
      message: message,
      icon: Icons.cloud_off_rounded,
      onRetry: onRetry,
      retryText: '다시 시도',
    );
  }

  /// 인증 에러 다이얼로그
  static Future<bool?> showAuthError({
    required BuildContext context,
    String message = '로그인이 필요해요',
    VoidCallback? onConfirm,
  }) {
    return show(
      context: context,
      title: '인증 오류',
      message: message,
      icon: Icons.lock_outline_rounded,
      confirmText: '로그인',
    );
  }

  /// 일반 에러 다이얼로그
  static Future<bool?> showGenericError({
    required BuildContext context,
    String? message,
    VoidCallback? onRetry,
  }) {
    return show(
      context: context,
      title: '오류',
      message: message ?? '잠시 문제가 생겼어요',
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveIconColor = iconColor ?? colorScheme.error;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 아이콘
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: effectiveIconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: effectiveIconColor,
            ),
          ),
          const SizedBox(height: 16),

          // 제목
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // 메시지
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          // 상세 정보 (있는 경우)
          if (details != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                details!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      actions: [
        // 재시도 버튼 (있는 경우)
        if (onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              onRetry!();
            },
            child: Text(retryText ?? '다시 시도'),
          ),

        // 확인 버튼
        FilledButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(confirmText),
        ),
      ],
    );
  }
}
