import 'package:flutter/material.dart';

enum ErrorType {
  network,
  server,
  auth,
  permission,
  notFound,
  generic,
}

class ErrorState extends StatelessWidget {
  final ErrorType type;
  final String? customTitle;
  final String? customMessage;
  final String? retryLabel;
  final VoidCallback? onRetry;
  final Object? error;

  const ErrorState({
    super.key,
    this.type = ErrorType.generic,
    this.customTitle,
    this.customMessage,
    this.retryLabel,
    this.onRetry,
    this.error,
  });

  factory ErrorState.fromError(Object error, {VoidCallback? onRetry}) {
    return ErrorState(
      type: _getErrorType(error),
      error: error,
      onRetry: onRetry,
    );
  }

  static ErrorType _getErrorType(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('socketexception') || message.contains('network') || message.contains('connection')) {
      return ErrorType.network;
    }
    if (message.contains('permission') || message.contains('denied')) {
      return ErrorType.permission;
    }
    if (message.contains('not found') || message.contains('404')) {
      return ErrorType.notFound;
    }
    if (message.contains('unauthorized') || message.contains('unauthenticated')) {
      return ErrorType.auth;
    }
    if (message.contains('server') || message.contains('500')) {
      return ErrorType.server;
    }
    return ErrorType.generic;
  }

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(type);
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 아이콘
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                config.icon,
                size: 50,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            // 타이틀
            Text(
              customTitle ?? config.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // 메시지
            Text(
              customMessage ?? _getUserFriendlyMessage(error) ?? config.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            // 디버그 모드에서 실제 오류 메시지 표시
            if (error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  error.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontFamily: 'monospace',
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            // 재시도 버튼
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel ?? '다시 시도'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String? _getUserFriendlyMessage(Object? error) {
    if (error == null) return null;
    final message = error.toString();

    // Firebase 에러 변환
    if (message.contains('permission-denied')) {
      return '접근 권한이 없어요.';
    }
    if (message.contains('unavailable')) {
      return '서버에 연결할 수 없어요.';
    }
    if (message.contains('not-found')) {
      return '요청한 데이터를 찾을 수 없어요.';
    }
    if (message.contains('unauthenticated')) {
      return '로그인이 필요해요';
    }

    // 네트워크 에러
    if (message.toLowerCase().contains('socketexception')) {
      return '인터넷 연결을 확인해주세요.';
    }

    return null;
  }

  _ErrorStateConfig _getConfig(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return _ErrorStateConfig(
          icon: Icons.wifi_off,
          title: '네트워크 오류',
          message: '인터넷 연결을 확인해주세요.',
        );
      case ErrorType.server:
        return _ErrorStateConfig(
          icon: Icons.cloud_off,
          title: '서버 오류',
          message: '잠시 문제가 생겼어요. 다시 시도해주세요.',
        );
      case ErrorType.auth:
        return _ErrorStateConfig(
          icon: Icons.lock_outline,
          title: '인증 오류',
          message: '로그인이 필요하거나 세션이 만료됐어요',
        );
      case ErrorType.permission:
        return _ErrorStateConfig(
          icon: Icons.block,
          title: '권한 오류',
          message: '이 작업을 수행할 권한이 없어요.',
        );
      case ErrorType.notFound:
        return _ErrorStateConfig(
          icon: Icons.search_off,
          title: '찾을 수 없음',
          message: '요청한 데이터를 찾을 수 없어요.',
        );
      case ErrorType.generic:
        return _ErrorStateConfig(
          icon: Icons.error_outline,
          title: '오류 발생',
          message: '잠시 문제가 생겼어요. 다시 시도해주세요.',
        );
    }
  }
}

class _ErrorStateConfig {
  final IconData icon;
  final String title;
  final String message;

  _ErrorStateConfig({
    required this.icon,
    required this.title,
    required this.message,
  });
}
