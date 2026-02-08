import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
  final String? lottieAsset; // Lottie 에셋 경로 (예: 'assets/lottie/empty.json')
  final bool useLottie; // Lottie 사용 여부 (기본값 false)

  const EmptyState({
    super.key,
    this.type = EmptyStateType.generic,
    this.customTitle,
    this.customMessage,
    this.actionLabel,
    this.onAction,
    this.customIcon,
    this.iconSize = 120,
    this.lottieAsset,
    this.useLottie = false,
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
            const SizedBox(height: 28),
            // 타이틀
            Text(
              customTitle ?? config.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
            const SizedBox(height: 10),
            // 메시지
            Text(
              customMessage ?? config.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 15,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 350.ms, duration: 300.ms),
            // 액션 버튼
            if (actionLabel != null || config.actionLabel != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onAction,
                icon: Icon(config.actionIcon ?? Icons.add),
                label: Text(actionLabel ?? config.actionLabel ?? ''),
              ).animate().fadeIn(delay: 500.ms, duration: 300.ms)
                  .slideY(begin: 0.1, end: 0, duration: 300.ms),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context, _EmptyStateConfig config) {
    final effectiveLottieAsset = lottieAsset ?? config.lottieAsset;

    // useLottie가 true이고 lottieAsset이 있으면 Lottie 사용
    if (useLottie && effectiveLottieAsset != null) {
      return Lottie.asset(
        effectiveLottieAsset,
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            _buildFallbackIcon(context, config),
      );
    }

    // 기존 아이콘 로직
    return _buildFallbackIcon(context, config);
  }

  Widget _buildFallbackIcon(BuildContext context, _EmptyStateConfig config) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 배경 글로우
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [
                        primaryColor.withValues(alpha: 0.15),
                        primaryColor.withValues(alpha: 0.03),
                        Colors.transparent,
                      ]
                    : [
                        primaryColor.withValues(alpha: 0.12),
                        primaryColor.withValues(alpha: 0.04),
                        Colors.transparent,
                      ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
          // 아이콘 컨테이너
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF374151),
                        const Color(0xFF1F2937),
                      ]
                    : [
                        primaryColor.withValues(alpha: 0.12),
                        primaryColor.withValues(alpha: 0.05),
                      ],
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : primaryColor.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: isDark ? 0.1 : 0.08),
                  blurRadius: 24,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Specular highlight
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 36,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: isDark ? 0.08 : 0.25),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Icon(
                    config.icon,
                    size: 36,
                    color: isDark
                        ? primaryColor.withValues(alpha: 0.7)
                        : primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(0.96, 0.96),
          end: const Offset(1.04, 1.04),
          duration: 2500.ms,
          curve: Curves.easeInOut,
        )
        .shimmer(
          delay: 500.ms,
          duration: 2500.ms,
          color: primaryColor.withValues(alpha: 0.08),
        );
  }

  _EmptyStateConfig _getConfig(EmptyStateType type) {
    switch (type) {
      case EmptyStateType.members:
        return _EmptyStateConfig(
          icon: Icons.people_outline,
          title: '아직 등록된 회원이 없어요',
          message: '새 회원을 등록해보세요',
          actionLabel: '회원 등록',
          actionIcon: Icons.person_add,
          lottieAsset: 'assets/lottie/empty_members.json',
        );
      case EmptyStateType.curriculums:
        return _EmptyStateConfig(
          icon: Icons.fitness_center,
          title: '아직 커리큘럼이 없어요',
          message: 'AI로 맞춤 커리큘럼을 생성해보세요',
          actionLabel: 'AI 커리큘럼 생성',
          actionIcon: Icons.auto_awesome,
          lottieAsset: 'assets/lottie/empty_curriculum.json',
        );
      case EmptyStateType.bodyRecords:
        return _EmptyStateConfig(
          icon: Icons.insert_chart_outlined,
          title: '아직 체성분 기록이 없어요',
          message: '체성분을 기록하면 변화 그래프를 볼 수 있어요',
          actionLabel: '기록 추가',
          actionIcon: Icons.add,
          lottieAsset: 'assets/lottie/empty_chart.json',
        );
      case EmptyStateType.dietRecords:
        return _EmptyStateConfig(
          icon: Icons.restaurant_outlined,
          title: '아직 식단 기록이 없어요',
          message: '오늘 먹은 음식을 기록해보세요',
          actionLabel: '식단 기록',
          actionIcon: Icons.add_a_photo,
          lottieAsset: 'assets/lottie/empty_diet.json',
        );
      case EmptyStateType.messages:
        return _EmptyStateConfig(
          icon: Icons.chat_bubble_outline,
          title: '아직 메시지가 없어요',
          message: '트레이너와 대화를 시작해보세요',
          actionLabel: '메시지 보내기',
          actionIcon: Icons.send,
          lottieAsset: 'assets/lottie/empty_chat.json',
        );
      case EmptyStateType.sessions:
        return _EmptyStateConfig(
          icon: Icons.event_available,
          title: '예정된 수업이 없어요',
          message: '이 날짜에는 수업이 없어요',
          actionLabel: null,
          actionIcon: null,
          lottieAsset: 'assets/lottie/empty_calendar.json',
        );
      case EmptyStateType.signatures:
        return _EmptyStateConfig(
          icon: Icons.draw_outlined,
          title: '서명 기록이 없어요',
          message: '수업 완료 시 서명 기록이 저장돼요',
          actionLabel: null,
          actionIcon: null,
          lottieAsset: 'assets/lottie/empty_signature.json',
        );
      case EmptyStateType.search:
        return _EmptyStateConfig(
          icon: Icons.search_off,
          title: '검색 결과가 없어요',
          message: '다른 검색어로 시도해보세요',
          actionLabel: null,
          actionIcon: null,
          lottieAsset: 'assets/lottie/search_empty.json',
        );
      case EmptyStateType.generic:
        return _EmptyStateConfig(
          icon: Icons.inbox_outlined,
          title: '아직 데이터가 없어요',
          message: '아직 데이터가 없어요',
          actionLabel: null,
          actionIcon: null,
          lottieAsset: 'assets/lottie/empty.json',
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
  final String? lottieAsset; // Lottie 에셋 경로 (optional)

  _EmptyStateConfig({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.actionIcon,
    this.lottieAsset,
  });
}
