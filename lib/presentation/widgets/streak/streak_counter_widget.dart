import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/streak_model.dart';
import 'streak_calendar_widget.dart';

/// 현재 스트릭 수를 보여주는 컴팩트 위젯
/// 체중/식단 스트릭 타입에 따라 다른 스타일 제공
class StreakCounterWidget extends ConsumerStatefulWidget {
  final StreakModel? streak;
  final StreakType type;
  final bool showLabel;
  final bool compact;
  final VoidCallback? onTap;

  const StreakCounterWidget({
    super.key,
    required this.streak,
    required this.type,
    this.showLabel = true,
    this.compact = false,
    this.onTap,
  });

  @override
  ConsumerState<StreakCounterWidget> createState() =>
      _StreakCounterWidgetState();
}

class _StreakCounterWidgetState extends ConsumerState<StreakCounterWidget> {
  int _previousValue = 0;

  int get _currentStreak {
    if (widget.streak == null) return 0;
    return widget.type == StreakType.weight
        ? widget.streak!.weightStreak
        : widget.streak!.dietStreak;
  }

  @override
  void didUpdateWidget(StreakCounterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldStreak = oldWidget.streak;
    final oldValue = oldStreak == null
        ? 0
        : (widget.type == StreakType.weight
            ? oldStreak.weightStreak
            : oldStreak.dietStreak);
    if (oldValue != _currentStreak) {
      _previousValue = oldValue;
    }
  }

  void _showCalendarDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.type.label} 기록 캘린더',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              StreakCalendarWidget(
                streak: widget.streak,
                type: widget.type,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 타입별 색상
    final streakColor = widget.type == StreakType.weight
        ? const Color(0xFF2563EB) // Primary 파란색
        : const Color(0xFF10B981); // Success 초록색

    final backgroundColor = streakColor.withValues(alpha: 0.1);

    if (widget.compact) {
      return _buildCompactWidget(theme, streakColor, backgroundColor);
    }

    return _buildFullWidget(theme, colorScheme, streakColor, backgroundColor);
  }

  Widget _buildCompactWidget(
    ThemeData theme,
    Color streakColor,
    Color backgroundColor,
  ) {
    return GestureDetector(
      onTap: widget.onTap ?? _showCalendarDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: streakColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAnimatedCounter(
              theme.textTheme.bodyMedium!.copyWith(
                color: streakColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '일연속',
              style: theme.textTheme.bodySmall?.copyWith(
                color: streakColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullWidget(
    ThemeData theme,
    ColorScheme colorScheme,
    Color streakColor,
    Color backgroundColor,
  ) {
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap ?? _showCalendarDialog,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF2E3B5E) : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: streakColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    widget.type == StreakType.weight
                        ? Icons.monitor_weight_outlined
                        : Icons.restaurant_outlined,
                    color: streakColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.showLabel)
                        Text(
                          widget.type.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildAnimatedCounter(
                            theme.textTheme.titleMedium!.copyWith(
                              color: streakColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '일연속',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: streakColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
            // 항상 진행바 표시 (크기 통일)
            const SizedBox(height: 12),
            _buildProgressIndicator(streakColor),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _buildAnimatedCounter(TextStyle style) {
    // 값이 변경될 때 애니메이션
    if (_previousValue != _currentStreak && _currentStreak > _previousValue) {
      return TweenAnimationBuilder<int>(
        tween: IntTween(begin: _previousValue, end: _currentStreak),
        duration: const Duration(milliseconds: 500),
        builder: (context, value, child) {
          return Text(
            '$value',
            style: style,
          );
        },
      ).animate().scale(
            begin: const Offset(1.2, 1.2),
            end: const Offset(1, 1),
            duration: 300.ms,
            curve: Curves.easeOutBack,
          );
    }

    return Text(
      '$_currentStreak',
      style: style,
    );
  }

  Widget _buildProgressIndicator(Color streakColor) {
    // 다음 마일스톤 계산 (7, 14, 30, 60, 100)
    final milestones = [7, 14, 30, 60, 100];
    int nextMilestone = milestones.firstWhere(
      (m) => m > _currentStreak,
      orElse: () => 100,
    );

    int previousMilestone = 0;
    for (final m in milestones) {
      if (m < _currentStreak) {
        previousMilestone = m;
      } else {
        break;
      }
    }

    final progress =
        (_currentStreak - previousMilestone) / (nextMilestone - previousMilestone);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '다음 목표: $nextMilestone일',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: streakColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: streakColor.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(streakColor),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
