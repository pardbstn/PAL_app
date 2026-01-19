import 'package:flutter/material.dart';

enum EmptyStateType {
  members,
  curriculums,
  bodyRecords,
  dietRecords,
  messages,
  sessions,
  signatures,
  search,
  generic,
}

class EmptyState extends StatelessWidget {
  final EmptyStateType type;
  final String? customTitle;
  final String? customMessage;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? customIcon;
  final double iconSize;

  const EmptyState({
    super.key,
    this.type = EmptyStateType.generic,
    this.customTitle,
    this.customMessage,
    this.actionLabel,
    this.onAction,
    this.customIcon,
    this.iconSize = 120,
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
          children: [
            // 아이콘 또는 Lottie
            customIcon ?? _buildIcon(context, config),
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
              customMessage ?? config.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            // 액션 버튼
            if (actionLabel != null || config.actionLabel != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onAction,
                icon: Icon(config.actionIcon ?? Icons.add),
                label: Text(actionLabel ?? config.actionLabel ?? ''),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context, _EmptyStateConfig config) {
    final theme = Theme.of(context);
    // Lottie 파일이 있으면 사용, 없으면 아이콘
    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Icon(
        config.icon,
        size: iconSize * 0.5,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  _EmptyStateConfig _getConfig(EmptyStateType type) {
    switch (type) {
      case EmptyStateType.members:
        return _EmptyStateConfig(
          icon: Icons.people_outline,
          title: '아직 등록된 회원이 없습니다',
          message: '새 회원을 등록해보세요',
          actionLabel: '회원 등록',
          actionIcon: Icons.person_add,
        );
      case EmptyStateType.curriculums:
        return _EmptyStateConfig(
          icon: Icons.fitness_center,
          title: '아직 커리큘럼이 없습니다',
          message: 'AI로 맞춤 커리큘럼을 생성해보세요',
          actionLabel: 'AI 커리큘럼 생성',
          actionIcon: Icons.auto_awesome,
        );
      case EmptyStateType.bodyRecords:
        return _EmptyStateConfig(
          icon: Icons.insert_chart_outlined,
          title: '아직 체성분 기록이 없습니다',
          message: '체성분을 기록하면 변화 그래프를 볼 수 있어요',
          actionLabel: '기록 추가',
          actionIcon: Icons.add,
        );
      case EmptyStateType.dietRecords:
        return _EmptyStateConfig(
          icon: Icons.restaurant_outlined,
          title: '아직 식단 기록이 없습니다',
          message: '오늘 먹은 음식을 기록해보세요',
          actionLabel: '식단 기록',
          actionIcon: Icons.add_a_photo,
        );
      case EmptyStateType.messages:
        return _EmptyStateConfig(
          icon: Icons.chat_bubble_outline,
          title: '아직 메시지가 없습니다',
          message: '트레이너와 대화를 시작해보세요',
          actionLabel: '메시지 보내기',
          actionIcon: Icons.send,
        );
      case EmptyStateType.sessions:
        return _EmptyStateConfig(
          icon: Icons.event_available,
          title: '예정된 수업이 없습니다',
          message: '이 날짜에는 수업이 없어요',
          actionLabel: null,
          actionIcon: null,
        );
      case EmptyStateType.signatures:
        return _EmptyStateConfig(
          icon: Icons.draw_outlined,
          title: '서명 기록이 없습니다',
          message: '수업 완료 시 서명 기록이 저장됩니다',
          actionLabel: null,
          actionIcon: null,
        );
      case EmptyStateType.search:
        return _EmptyStateConfig(
          icon: Icons.search_off,
          title: '검색 결과가 없습니다',
          message: '다른 검색어로 시도해보세요',
          actionLabel: null,
          actionIcon: null,
        );
      case EmptyStateType.generic:
        return _EmptyStateConfig(
          icon: Icons.inbox_outlined,
          title: '데이터가 없습니다',
          message: '아직 데이터가 없어요',
          actionLabel: null,
          actionIcon: null,
        );
    }
  }
}

class _EmptyStateConfig {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final IconData? actionIcon;

  _EmptyStateConfig({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.actionIcon,
  });
}
