import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';

/// 체중 변화 라인 차트
/// 실제 데이터는 실선, 예측 데이터는 점선으로 표시
class WeightLineChart extends StatefulWidget {
  final List<WeightData> actualData;
  final List<WeightData> predictedData;
  final double? targetWeight;
  final String unit;

  const WeightLineChart({
    super.key,
    required this.actualData,
    this.predictedData = const [],
    this.targetWeight,
    this.unit = 'kg',
  });

  @override
  State<WeightLineChart> createState() => _WeightLineChartState();
}

class _WeightLineChartState extends State<WeightLineChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 범례
        _buildLegend(),
        const SizedBox(height: 16),
        // 차트
        SizedBox(
          height: 220,
          child: LineChart(
            _buildLineChartData(),
            duration: const Duration(milliseconds: 300),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem('실제 체중', AppTheme.primary, false),
        const SizedBox(width: 24),
        if (widget.predictedData.isNotEmpty)
          _legendItem('예측', AppTheme.secondary, true),
        if (widget.targetWeight != null) ...[
          const SizedBox(width: 24),
          _legendItem('목표', AppTheme.tertiary, true),
        ],
      ],
    );
  }

  Widget _legendItem(String label, Color color, bool isDashed) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: isDashed ? Colors.transparent : color,
            border: isDashed
                ? Border(
                    bottom: BorderSide(
                      color: color,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  )
                : null,
          ),
          child: isDashed
              ? CustomPaint(
                  painter: DashedLinePainter(color: color),
                )
              : null,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  LineChartData _buildLineChartData() {
    final allData = [...widget.actualData, ...widget.predictedData];
    if (allData.isEmpty) return LineChartData();

    final minY = allData.map((e) => e.weight).reduce((a, b) => a < b ? a : b) - 2;
    final maxY = allData.map((e) => e.weight).reduce((a, b) => a > b ? a : b) + 2;

    return LineChartData(
      minY: minY,
      maxY: maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 2,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withValues(alpha: 0.15),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 45,
            interval: 2,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}${widget.unit}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= allData.length) return const SizedBox();
              if (index % 2 != 0 && allData.length > 6) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  allData[index].label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => Colors.black87,
          tooltipBorderRadius: BorderRadius.circular(12),
          tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final isActual = spot.barIndex == 0;
              return LineTooltipItem(
                '${spot.y.toStringAsFixed(1)}${widget.unit}',
                TextStyle(
                  color: isActual ? AppTheme.primary : AppTheme.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: '\n${isActual ? "실제" : "예측"}',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 11,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),
      lineBarsData: [
        // 실제 데이터 (실선)
        LineChartBarData(
          spots: widget.actualData
              .asMap()
              .entries
              .map((e) => FlSpot(e.key.toDouble(), e.value.weight))
              .toList(),
          isCurved: true,
          curveSmoothness: 0.3,
          color: AppTheme.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 5,
                color: Colors.white,
                strokeWidth: 3,
                strokeColor: AppTheme.primary,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primary.withValues(alpha: 0.3),
                AppTheme.primary.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
        // 예측 데이터 (점선)
        if (widget.predictedData.isNotEmpty)
          LineChartBarData(
            spots: widget.predictedData
                .asMap()
                .entries
                .map((e) => FlSpot(
                      (widget.actualData.length + e.key).toDouble(),
                      e.value.weight,
                    ))
                .toList(),
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppTheme.secondary,
            barWidth: 3,
            isStrokeCapRound: true,
            dashArray: [8, 4],
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: Colors.white,
                  strokeWidth: 3,
                  strokeColor: AppTheme.secondary,
                );
              },
            ),
          ),
      ],
      extraLinesData: widget.targetWeight != null
          ? ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: widget.targetWeight!,
                  color: AppTheme.tertiary,
                  strokeWidth: 2,
                  dashArray: [8, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.only(right: 8, bottom: 4),
                    style: TextStyle(
                      color: AppTheme.tertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    labelResolver: (line) => '목표 ${line.y.toInt()}${widget.unit}',
                  ),
                ),
              ],
            )
          : null,
    );
  }
}

/// 체중 데이터 모델
class WeightData {
  final String label;
  final double weight;
  final DateTime? date;

  WeightData({
    required this.label,
    required this.weight,
    this.date,
  });
}

/// 점선 그리기용 커스텀 페인터
class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;

    const dashWidth = 4.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
