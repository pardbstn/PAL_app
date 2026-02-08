import 'package:flutter/material.dart';

/// 재시도 위젯
///
/// 에러 발생 시 표시되는 위젯으로 아이콘, 메시지, 재시도 버튼을 포함합니다.
///
/// 사용 예시:
/// ```dart
/// RetryWidget(
///   message: '데이터를 불러올 수 없습니다',
///   onRetry: () => _loadData(),
/// );
/// ```
class RetryWidget extends StatelessWidget {
  final String? title;
  final String message;
  final String? description;
  final VoidCallback? onRetry;
  final String retryText;
  final IconData icon;
  final Color? iconColor;
  final double iconSize;
  final bool compact;
  final Widget? customAction;

  const RetryWidget({
    super.key,
    this.title,
    required this.message,
    this.description,
    this.onRetry,
    this.retryText = '다시 시도',
    this.icon = Icons.error_outline_rounded,
    this.iconColor,
    this.iconSize = 64,
    this.compact = false,
    this.customAction,
  });

  /// 네트워크 에러 위젯
  factory RetryWidget.network({
    Key? key,
    String message = '인터넷 연결을 확인해주세요',
    String? description,
    VoidCallback? onRetry,
    bool compact = false,
  }) {
    return RetryWidget(
      key: key,
      title: '네트워크 오류',
      message: message,
      description: description,
      onRetry: onRetry,
      icon: Icons.wifi_off_rounded,
      compact: compact,
    );
  }

  /// 서버 에러 위젯
  factory RetryWidget.server({
    Key? key,
    String message = '서버와 통신 중 문제가 생겼어요',
    String? description,
    VoidCallback? onRetry,
    bool compact = false,
  }) {
    return RetryWidget(
      key: key,
      title: '서버 오류',
      message: message,
      description: description,
      onRetry: onRetry,
      icon: Icons.cloud_off_rounded,
      compact: compact,
    );
  }

  /// 데이터 로드 실패 위젯
  factory RetryWidget.loadFailed({
    Key? key,
    String message = '데이터를 불러올 수 없어요',
    String? description,
    VoidCallback? onRetry,
    bool compact = false,
  }) {
    return RetryWidget(
      key: key,
      title: '로드 실패',
      message: message,
      description: description,
      onRetry: onRetry,
      icon: Icons.sync_problem_rounded,
      compact: compact,
    );
  }

  /// 권한 없음 위젯
  factory RetryWidget.unauthorized({
    Key? key,
    String message = '접근 권한이 없어요',
    String? description,
    Widget? customAction,
    bool compact = false,
  }) {
    return RetryWidget(
      key: key,
      title: '접근 제한',
      message: message,
      description: description,
      icon: Icons.lock_outline_rounded,
      customAction: customAction,
      compact: compact,
    );
  }

  /// 타임아웃 위젯
  factory RetryWidget.timeout({
    Key? key,
    String message = '요청 시간이 초과됐어요',
    String? description,
    VoidCallback? onRetry,
    bool compact = false,
  }) {
    return RetryWidget(
      key: key,
      title: '시간 초과',
      message: message,
      description: description,
      onRetry: onRetry,
      icon: Icons.timer_off_rounded,
      compact: compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompact(context);
    }
    return _buildFull(context);
  }

  Widget _buildFull(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveIconColor = iconColor ?? colorScheme.error;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: effectiveIconColor,
              ),
            ),
            const SizedBox(height: 24),

            // 제목 (있는 경우)
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],

            // 메시지
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            // 설명 (있는 경우)
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),

            // 액션 버튼
            if (customAction != null)
              customAction!
            else if (onRetry != null)
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(retryText),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompact(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveIconColor = iconColor ?? colorScheme.error;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 아이콘
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: effectiveIconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24,
              color: effectiveIconColor,
            ),
          ),
          const SizedBox(width: 12),

          // 메시지
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // 재시도 버튼
          if (customAction != null)
            customAction!
          else if (onRetry != null)
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              tooltip: retryText,
            ),
        ],
      ),
    );
  }
}

/// 인라인 에러 위젯 (작은 공간용)
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final Color? color;

  const InlineErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveColor = color ?? colorScheme.error;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.error_outline_rounded,
          size: 16,
          color: effectiveColor,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: effectiveColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (onRetry != null) ...[
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRetry,
            child: Icon(
              Icons.refresh_rounded,
              size: 16,
              color: colorScheme.primary,
            ),
          ),
        ],
      ],
    );
  }
}
