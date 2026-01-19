import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';

/// 목표 달성률 원형 인디케이터
class GoalProgressIndicator extends StatelessWidget {
  final double currentValue;
  final double targetValue;
  final double startValue;
  final String label;
  final String unit;
  final bool isDecreaseGoal; // 감량 목표 (true) vs 증량 목표 (false)

  const GoalProgressIndicator({
    super.key,
    required this.currentValue,
    required this.targetValue,
    required this.startValue,
    required this.label,
    this.unit = 'kg',
    this.isDecreaseGoal = true,
  });

  double get progress {
    if (isDecreaseGoal) {
      // 감량: 시작값에서 목표값까지 얼마나 감량했는지
      final totalToLose = startValue - targetValue;
      final actualLost = startValue - currentValue;
      if (totalToLose <= 0) return 0;
      return (actualLost / totalToLose).clamp(0.0, 1.0);
    } else {
      // 증량: 시작값에서 목표값까지 얼마나 증량했는지
      final totalToGain = targetValue - startValue;
      final actualGained = currentValue - startValue;
      if (totalToGain <= 0) return 0;
      return (actualGained / totalToGain).clamp(0.0, 1.0);
    }
  }

  double get remaining {
    if (isDecreaseGoal) {
      return currentValue - targetValue;
    } else {
      return targetValue - currentValue;
    }
  }

  Color get progressColor {
    if (progress >= 1.0) return AppTheme.secondary;
    if (progress >= 0.7) return AppTheme.primary;
    if (progress >= 0.4) return AppTheme.tertiary;
    return AppTheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).toInt();

    return Column(
      children: [
        CircularPercentIndicator(
          radius: 80,
          lineWidth: 12,
          percent: progress,
          animation: true,
          animationDuration: 1200,
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: progressColor,
          backgroundColor: Colors.grey[200]!,
          center: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percent%',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
              Text(
                '달성',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // 상세 정보
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildInfoRow(
                '시작',
                '${startValue.toStringAsFixed(1)}$unit',
                Colors.grey[600]!,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                '현재',
                '${currentValue.toStringAsFixed(1)}$unit',
                AppTheme.primary,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                '목표',
                '${targetValue.toStringAsFixed(1)}$unit',
                AppTheme.secondary,
              ),
              const Divider(height: 24),
              _buildInfoRow(
                isDecreaseGoal ? '남은 감량' : '남은 증량',
                '${remaining.abs().toStringAsFixed(1)}$unit',
                remaining <= 0 ? AppTheme.secondary : AppTheme.tertiary,
                isBold: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

/// 여러 목표를 한 번에 보여주는 요약 카드
class GoalSummaryCard extends StatelessWidget {
  final String title;
  final double percent;
  final String current;
  final String target;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const GoalSummaryCard({
    super.key,
    required this.title,
    required this.percent,
    required this.current,
    required this.target,
    required this.color,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  '${(percent * 100).toInt()}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent.clamp(0.0, 1.0),
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '현재: $current',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '목표: $target',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
