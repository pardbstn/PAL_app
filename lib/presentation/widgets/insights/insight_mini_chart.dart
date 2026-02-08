import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';

/// 인사이트 미니 차트 위젯
/// graphType에 따라 적절한 차트를 렌더링
class InsightMiniChart extends StatelessWidget {
  /// 차트 타입: 'line', 'bar', 'donut', 'progress'
  final String graphType;

  /// 차트 데이터
  /// - line: [{value: 75.5, isPrediction: false}, ...]
  /// - bar: [{label: '월', value: 3}, ...]
  /// - donut: [{name: '단백질', value: 75, color: Colors.red}, ...]
  /// - progress: [{value: 92, max: 100}]
  final List<Map<String, dynamic>> data;

  /// 차트 높이
  final double height;

  /// 차트 너비
  final double width;

  /// 기본 색상 (지정하지 않으면 AppTheme.primary 사용)
  final Color? primaryColor;

  const InsightMiniChart({
    super.key,
    required this.graphType,
    required this.data,
    this.height = 60,
    this.width = 120,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = primaryColor ?? AppTheme.primary;

    return SizedBox(
      height: height,
      width: width,
      child: _buildChart(context, color),
    );
  }

  Widget _buildChart(BuildContext context, Color color) {
    // 빈 데이터 처리
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    switch (graphType) {
      case 'line':
        return _buildLineChart(color);
      case 'bar':
        return _buildBarChart(color);
      case 'donut':
        return _buildDonutChart(context);
      case 'progress':
        return _buildProgressBar(context, color);
      default:
        return const SizedBox.shrink();
    }
  }

  /// 라인 차트 (트렌드 표시용)
  /// data format: [{value: 75.5, isPrediction: false}, {value: 74.2, isPrediction: true}]
  Widget _buildLineChart(Color color) {
    if (data.isEmpty) return const SizedBox.shrink();

    // 실제 데이터와 예측 데이터 분리
    final List<FlSpot> actualSpots = [];
    final List<FlSpot> predictionSpots = [];

    for (int i = 0; i < data.length; i++) {
      final point = data[i];
      final value = (point['value'] as num?)?.toDouble() ?? 0.0;
      final isPrediction = point['isPrediction'] as bool? ?? false;

      if (isPrediction) {
        // 예측 데이터는 마지막 실제 데이터 포인트부터 시작
        if (predictionSpots.isEmpty && actualSpots.isNotEmpty) {
          predictionSpots.add(actualSpots.last);
        }
        predictionSpots.add(FlSpot(i.toDouble(), value));
      } else {
        actualSpots.add(FlSpot(i.toDouble(), value));
      }
    }

    // 값 범위 계산 (패딩 포함)
    final allValues = data.map((d) => (d['value'] as num?)?.toDouble() ?? 0.0).toList();
    final minValue = allValues.reduce((a, b) => a < b ? a : b);
    final maxValue = allValues.reduce((a, b) => a > b ? a : b);
    final valueRange = maxValue - minValue;
    final padding = valueRange * 0.1;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: minValue - padding,
        maxY: maxValue + padding,
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          // 실제 데이터 라인 (실선)
          if (actualSpots.isNotEmpty)
            LineChartBarData(
              spots: actualSpots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: color,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: color,
                    strokeWidth: 1,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: color.withValues(alpha: 0.1),
              ),
            ),
          // 예측 데이터 라인 (점선)
          if (predictionSpots.isNotEmpty)
            LineChartBarData(
              spots: predictionSpots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: color.withValues(alpha: 0.5),
              barWidth: 2,
              isStrokeCapRound: true,
              dashArray: [5, 3], // 점선 스타일
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: color.withValues(alpha: 0.5),
                    strokeWidth: 1,
                    strokeColor: Colors.white,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  /// 바 차트 (요일별, 주간 등 표시용)
  /// data format: [{label: '월', value: 3}, {label: '화', value: 2}, ...]
  Widget _buildBarChart(Color color) {
    if (data.isEmpty) return const SizedBox.shrink();

    final maxValue = data
        .map((d) => (d['value'] as num?)?.toDouble() ?? 0.0)
        .reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(enabled: false),
        maxY: maxValue * 1.2, // 상단 여백
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final value = (item['value'] as num?)?.toDouble() ?? 0.0;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value,
                color: color,
                width: width / (data.length * 2), // 막대 너비 자동 조절
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// 도넛 차트 (영양소 비율 등 표시용)
  /// data format: [{name: '단백질', value: 75, color: Colors.red}, ...]
  Widget _buildDonutChart(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    // 기본 색상 팔레트 (색상이 지정되지 않은 경우)
    final defaultColors = [
      AppTheme.primary,
      AppTheme.secondary,
      AppTheme.tertiary,
      AppTheme.error,
      const Color(0xFF8B5CF6), // purple
      const Color(0xFF06B6D4), // cyan
    ];

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: height * 0.22, // 도넛 구멍 크기
        pieTouchData: PieTouchData(enabled: false),
        sections: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final value = (item['value'] as num?)?.toDouble() ?? 0.0;

          // 색상 결정 (지정된 색상 또는 기본 팔레트)
          Color sectionColor;
          if (item['color'] != null) {
            sectionColor = item['color'] as Color;
          } else {
            sectionColor = defaultColors[index % defaultColors.length];
          }

          return PieChartSectionData(
            value: value,
            color: sectionColor,
            radius: height * 0.25,
            title: '',
            showTitle: false,
          );
        }).toList(),
      ),
    );
  }

  /// 프로그레스 바 (달성률 표시용)
  /// data format: [{value: 92, max: 100}]
  Widget _buildProgressBar(BuildContext context, Color color) {
    if (data.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final item = data.first;
    final value = (item['value'] as num?)?.toDouble() ?? 0.0;
    final maxValue = (item['max'] as num?)?.toDouble() ?? 100.0;
    final percentage = maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;
    final percentageText = '${(percentage * 100).toInt()}%';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 퍼센트 텍스트
        Text(
          percentageText,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        // 프로그레스 바
        Container(
          height: 8,
          width: width,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
