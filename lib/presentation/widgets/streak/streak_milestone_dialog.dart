import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart' show ShareParams, SharePlus;

import '../../../data/models/badge_model.dart';
import '../../../data/models/streak_model.dart';

/// 마일스톤 달성 시 표시되는 축하 다이얼로그
class StreakMilestoneDialog extends StatefulWidget {
  final int milestone;
  final StreakType streakType;
  final BadgeModel? newBadge;
  final bool isNewRecord;
  final VoidCallback? onClose;

  const StreakMilestoneDialog({
    super.key,
    required this.milestone,
    required this.streakType,
    this.newBadge,
    this.isNewRecord = false,
    this.onClose,
  });

  /// 마일스톤 다이얼로그 표시
  static Future<void> show(
    BuildContext context, {
    required int milestone,
    required StreakType streakType,
    BadgeModel? newBadge,
    bool isNewRecord = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StreakMilestoneDialog(
        milestone: milestone,
        streakType: streakType,
        newBadge: newBadge,
        isNewRecord: isNewRecord,
      ),
    );
  }

  @override
  State<StreakMilestoneDialog> createState() => _StreakMilestoneDialogState();
}

class _StreakMilestoneDialogState extends State<StreakMilestoneDialog>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _badgeController;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 타입별 색상
    final primaryColor = widget.streakType == StreakType.weight
        ? const Color(0xFF2563EB)
        : const Color(0xFF10B981);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 컨페티 효과
            ..._buildConfetti(primaryColor),

            // 메인 콘텐츠
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 불꽃 & 배지 아이콘
                  _buildMainIcon(primaryColor),
                  const SizedBox(height: 20),

                  // 축하 메시지
                  Text(
                    '🎉 축하합니다! 🎉',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 400.ms)
                      .scale(begin: const Offset(0.8, 0.8)),

                  const SizedBox(height: 12),

                  // 마일스톤 정보
                  _buildMilestoneInfo(theme, primaryColor),

                  const SizedBox(height: 16),

                  // 신기록 표시
                  if (widget.isNewRecord) _buildNewRecordBadge(theme),

                  // 배지 획득 정보
                  if (widget.newBadge != null) ...[
                    const SizedBox(height: 16),
                    _buildBadgeInfo(theme, colorScheme, primaryColor),
                  ],

                  const SizedBox(height: 24),

                  // 버튼들
                  _buildButtons(context, theme, primaryColor),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          curve: Curves.easeOutBack,
        );
  }

  List<Widget> _buildConfetti(Color primaryColor) {
    final colors = [
      primaryColor,
      const Color(0xFFFF6B35),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFFEC4899),
    ];

    return List.generate(20, (index) {
      final color = colors[index % colors.length];
      final left = (index * 17.0) % 300;
      final delay = (index * 100) % 1000;

      return Positioned(
        left: left,
        top: -20,
        child: AnimatedBuilder(
          animation: _confettiController,
          builder: (context, child) {
            final progress = (_confettiController.value + delay / 1000) % 1;
            return Transform.translate(
              offset: Offset(
                (index % 2 == 0 ? 1 : -1) * 20 * progress,
                400 * progress,
              ),
              child: Transform.rotate(
                angle: progress * 6.28,
                child: Opacity(
                  opacity: (1 - progress).clamp(0.0, 1.0),
                  child: child,
                ),
              ),
            );
          },
          child: Container(
            width: 8 + (index % 3) * 4.0,
            height: 8 + (index % 3) * 4.0,
            decoration: BoxDecoration(
              color: color,
              shape: index % 2 == 0 ? BoxShape.circle : BoxShape.rectangle,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildMainIcon(Color primaryColor) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 글로우 효과
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                primaryColor.withValues(alpha: 0.3),
                primaryColor.withValues(alpha: 0.0),
              ],
            ),
          ),
        )
            .animate(
              onPlay: (controller) => controller.repeat(reverse: true),
            )
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.1, 1.1),
              duration: 1500.ms,
            ),

        // 메인 아이콘
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor,
                primaryColor.withValues(alpha: 0.7),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🔥',
                  style: TextStyle(fontSize: 32),
                ),
                Text(
                  '${widget.milestone}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              curve: Curves.elasticOut,
              duration: 800.ms,
            ),

        // 스파클 효과
        ..._buildSparkles(primaryColor),
      ],
    );
  }

  List<Widget> _buildSparkles(Color primaryColor) {
    return List.generate(8, (index) {
      const radius = 55.0;
      final x = radius * (index % 2 == 0 ? 1.2 : 1.0);

      return Positioned(
        child: Transform.translate(
          offset: Offset(
            x * (index < 4 ? 1 : -1) * (index % 2 == 0 ? 0.7 : 1),
            x * (index < 2 || index > 5 ? -1 : 1) * (index % 2 == 0 ? 1 : 0.7),
          ),
          child: const Text(
            '✨',
            style: TextStyle(fontSize: 16),
          )
              .animate(
                onPlay: (controller) => controller.repeat(reverse: true),
                delay: (index * 100).ms,
              )
              .fadeIn()
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1.2, 1.2),
                duration: 600.ms,
              ),
        ),
      );
    });
  }

  Widget _buildMilestoneInfo(ThemeData theme, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            '${widget.streakType.label} 기록',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: '${widget.milestone}일',
                  style: TextStyle(color: primaryColor),
                ),
                TextSpan(
                  text: ' 연속 달성!',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildNewRecordBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFFF6B35)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.emoji_events,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            '신기록 달성!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 700.ms, duration: 400.ms)
        .shimmer(duration: 1500.ms, delay: 1000.ms);
  }

  Widget _buildBadgeInfo(
    ThemeData theme,
    ColorScheme colorScheme,
    Color primaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '🏆',
                  style: TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '새 배지 획득!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFF59E0B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.newBadge!.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.newBadge!.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 900.ms, duration: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildButtons(
    BuildContext context,
    ThemeData theme,
    Color primaryColor,
  ) {
    return Row(
      children: [
        // 공유 버튼
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _shareAchievement(),
            icon: const Icon(Icons.share, size: 18),
            label: const Text('공유하기'),
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              side: BorderSide(color: primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // 확인 버튼
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onClose?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              '확인',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 1100.ms, duration: 400.ms);
  }

  void _shareAchievement() {
    final typeLabel = widget.streakType.label;
    final message = widget.newBadge != null
        ? '🎉 PAL에서 $typeLabel ${widget.milestone}일 연속 기록 달성! 🏆 "${widget.newBadge!.name}" 배지도 획득했어요!'
        : '🔥 PAL에서 $typeLabel ${widget.milestone}일 연속 기록 달성! 꾸준히 기록하고 있어요!';

    SharePlus.instance.share(ShareParams(text: message));
  }
}
