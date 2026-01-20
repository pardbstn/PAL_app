import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

enum LoadingStateType {
  general,
  aiAnalysis,
  saving,
  uploading,
  syncing,
}

class LoadingState extends StatelessWidget {
  final LoadingStateType type;
  final String? customMessage;
  final bool showProgress;
  final double? progress;

  const LoadingState({
    super.key,
    this.type = LoadingStateType.general,
    this.customMessage,
    this.showProgress = false,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(type);
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 로딩 애니메이션
            LoadingAnimationWidget.staggeredDotsWave(
              color: theme.colorScheme.primary,
              size: 50,
            ),
            const SizedBox(height: 24),
            // 메시지
            Text(
              customMessage ?? config.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            // 프로그레스 표시
            if (showProgress) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
              if (progress != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${(progress! * 100).toInt()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  _LoadingStateConfig _getConfig(LoadingStateType type) {
    switch (type) {
      case LoadingStateType.general:
        return _LoadingStateConfig(
          message: '로딩 중...',
        );
      case LoadingStateType.aiAnalysis:
        return _LoadingStateConfig(
          message: 'AI가 분석 중입니다...',
        );
      case LoadingStateType.saving:
        return _LoadingStateConfig(
          message: '저장 중...',
        );
      case LoadingStateType.uploading:
        return _LoadingStateConfig(
          message: '업로드 중...',
        );
      case LoadingStateType.syncing:
        return _LoadingStateConfig(
          message: '동기화 중...',
        );
    }
  }
}

class _LoadingStateConfig {
  final String message;

  _LoadingStateConfig({
    required this.message,
  });
}
