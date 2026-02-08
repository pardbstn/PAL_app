import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_pal_app/presentation/providers/insight_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/insights/insight_mini_chart.dart';
import 'package:flutter_pal_app/presentation/widgets/insights/benchmark_distribution_chart.dart';
import 'package:flutter_pal_app/presentation/widgets/insights/muscle_balance_donut.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/core/theme/app_tokens.dart';

/// 회원 인사이트 카드 (토스 스타일 디자인)
///
/// MemberInsight 데이터를 받아서 유형별로 다른 디자인 렌더:
/// - 체성분 변화: 라인 차트
/// - 목표 예측: 프로그레스 게이지
/// - 운동 성과: PR 달성 강조
/// - 식단 피드백: 도넛 차트
/// - 출석 습관: 바 차트
class MemberInsightCard extends StatelessWidget {
  final MemberInsight insight;
  final VoidCallback? onRead;

  const MemberInsightCard({
    super.key,
    required this.insight,
    this.onRead,
  });

  /// 인사이트 타입에 따른 네비게이션 경로 반환
  String? _getNavigationRoute() {
    switch (insight.type) {
      // 체성분 관련 - 기록 화면으로
      case 'weight':
      case 'body_change_report':
      case 'bodyPrediction':
      case 'bodyChangeReport':
      case 'weightProgress':
        return '/member/records';
      // 영양/식단 관련 - 식단 화면으로
      case 'nutrition':
      case 'nutrition_balance':
      case 'nutritionBalance':
        return '/member/diet';
      // 출석/일정 관련 - 캘린더 화면으로
      case 'attendance':
      case 'attendance_habit':
      case 'attendanceHabit':
      case 'attendanceAlert':
        return '/member/calendar';
      // 운동 관련 - 기록 화면으로
      case 'workout':
      case 'workout_achievement':
      case 'workoutAchievement':
      case 'workoutVolume':
        return '/member/records';
      // 목표 진행률 - 기록 화면으로
      case 'goal_progress':
      case 'goalProgress':
        return '/member/records';
      // 벤치마크 - 기록 화면으로
      case 'benchmark':
        return '/member/records';
      // 컨디션 패턴 - 기록 화면으로
      case 'conditionPattern':
        return '/member/records';
      default:
        return null;
    }
  }

  /// 인사이트 타입에 따른 배경 그라데이션 색상
  List<Color> _getGradientColors() {
    switch (insight.type) {
      case 'weight':
      case 'body_change_report':
        return [
          const Color(0xFF3B82F6),
          const Color(0xFF0064FF),
        ];
      case 'workout':
      case 'workout_achievement':
        return [
          const Color(0xFF00C471),
          const Color(0xFF059669),
        ];
      case 'nutrition':
      case 'nutrition_balance':
        return [
          const Color(0xFFFF8A00),
          const Color(0xFFD97706),
        ];
      case 'attendance':
      case 'attendance_habit':
        return [
          const Color(0xFF8B5CF6),
          const Color(0xFF7C3AED),
        ];
      case 'goal_progress':
        return [
          const Color(0xFF06B6D4),
          const Color(0xFF0891B2),
        ];
      default:
        return [
          AppTheme.primary,
          AppTheme.primary.withValues(alpha: 0.8),
        ];
    }
  }

  /// 타입별 이모지
  String _getEmoji() {
    switch (insight.type) {
      case 'weight':
      case 'body_change_report':
        return '📊';
      case 'workout':
      case 'workout_achievement':
        return '🎉';
      case 'nutrition':
      case 'nutrition_balance':
        return '🥗';
      case 'attendance':
      case 'attendance_habit':
        return '🔥';
      case 'goal_progress':
        return '🎯';
      case 'motivation':
        return '💪';
      default:
        return '💡';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final navigationRoute = _getNavigationRoute();
    final gradientColors = _getGradientColors();

    return GestureDetector(
      onTap: navigationRoute != null
          ? () {
              onRead?.call();
              context.push(navigationRoute);
            }
          : null,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors.map((c) => c.withValues(alpha: 0.1)).toList(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.gray100,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단: 타입 아이콘 + 우선순위 태그
            Row(
              children: [
                // 타입 아이콘 (원형 배경)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: insight.priorityColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _getEmoji(),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const Spacer(),
                // 우선순위 태그
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: insight.priorityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getPriorityLabel(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: insight.priorityColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 중간: 제목
            Text(
              insight.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // 메시지
            Flexible(
              child: Text(
                insight.message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // 하단: 미니 차트 (데이터가 있는 경우)
            if (insight.graphData != null && insight.graphType != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 60,
                child: _buildChart(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 우선순위 라벨
  String _getPriorityLabel() {
    switch (insight.priority) {
      case 'high':
        return '중요';
      case 'medium':
        return '일반';
      case 'low':
      default:
        return '참고';
    }
  }

  /// 그래프 타입과 인사이트 타입에 따른 차트 위젯 빌드
  Widget _buildChart() {
    // 벤치마크 타입이고 distribution 그래프인 경우
    if (insight.type == 'benchmark' && insight.graphType == 'distribution') {
      final data = insight.graphData!;
      final overallPercentile = data.isNotEmpty && data[0].containsKey('overallPercentile')
          ? (data[0]['overallPercentile'] as num).toInt()
          : 50;
      final goal = data.isNotEmpty && data[0].containsKey('goal')
          ? data[0]['goal'] as String
          : 'fitness';
      final categories = data.isNotEmpty && data[0].containsKey('categories')
          ? (data[0]['categories'] as List<dynamic>)
              .map((c) => c as Map<String, dynamic>)
              .toList()
          : <Map<String, dynamic>>[];

      return BenchmarkDistributionChart.fromMaps(
        overallPercentile: overallPercentile,
        categories: categories,
        goal: goal,
      );
    }

    // workout_volume 타입이고 donut 그래프인 경우
    if (insight.type == 'workoutVolume' && insight.graphType == 'donut') {
      final data = insight.graphData!;
      if (data.isNotEmpty && data[0].containsKey('muscleGroupBalance')) {
        final muscleBalance = data[0]['muscleGroupBalance'] as Map<String, dynamic>;
        final isImbalanced = data[0]['isImbalanced'] as bool? ?? false;
        final imbalanceType = data[0]['imbalanceType'] as String?;

        return MuscleBalanceDonut(
          muscleGroupBalance: muscleBalance.map(
            (key, value) => MapEntry(key, (value as num).toInt()),
          ),
          isImbalanced: isImbalanced,
          imbalanceType: imbalanceType,
        );
      }
    }

    // 기본 InsightMiniChart 사용
    return InsightMiniChart(
      graphType: insight.graphType!,
      data: insight.graphData!,
      primaryColor: insight.priorityColor,
      width: double.infinity,
      height: 80,
    );
  }
}
