import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';

/// 체성분 비율 파이 차트
/// 골격근량, 체지방량, 기타 비율 표시
class BodyCompositionPieChart extends StatefulWidget {
  final double muscleMass; // 골격근량 (kg)
  final double fatMass; // 체지방량 (kg)
  final double totalWeight; // 총 체중 (kg)

  const BodyCompositionPieChart({
    super.key,
    required this.muscleMass,
    required this.fatMass,
    required this.totalWeight,
  });

  @override
  State<BodyCompositionPieChart> createState() =>
      _BodyCompositionPieChartState();
}

class _BodyCompositionPieChartState extends State<BodyCompositionPieChart> {
  int touchedIndex = -1;

  double get otherMass =>
      widget.totalWeight - widget.muscleMass - widget.fatMass;

  double get musclePercent => (widget.muscleMass / widget.totalWeight) * 100;
  double get fatPercent => (widget.fatMass / widget.totalWeight) * 100;
  double get otherPercent => (otherMass / widget.totalWeight) * 100;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 파이 차트
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!
                            .touchedSectionIndex;
                      });
                    },
                  ),
                  sectionsSpace: 3,
                  centerSpaceRadius: 50,
                  sections: _buildSections(),
                ),
              ),
              // 중앙 텍스트
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.totalWeight.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'kg',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // 범례
        _buildLegend(),
      ],
    );
  }

  List<PieChartSectionData> _buildSections() {
    return [
      // 골격근량
      PieChartSectionData(
        color: AppTheme.primary,
        value: widget.muscleMass,
        title: touchedIndex == 0
            ? '${musclePercent.toStringAsFixed(1)}%'
            : '${widget.muscleMass.toStringAsFixed(1)}kg',
        radius: touchedIndex == 0 ? 65 : 55,
        titleStyle: TextStyle(
          fontSize: touchedIndex == 0 ? 14 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: touchedIndex == 0 ? _buildBadge('골격근') : null,
        badgePositionPercentageOffset: 1.3,
      ),
      // 체지방량
      PieChartSectionData(
        color: AppTheme.error,
        value: widget.fatMass,
        title: touchedIndex == 1
            ? '${fatPercent.toStringAsFixed(1)}%'
            : '${widget.fatMass.toStringAsFixed(1)}kg',
        radius: touchedIndex == 1 ? 65 : 55,
        titleStyle: TextStyle(
          fontSize: touchedIndex == 1 ? 14 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: touchedIndex == 1 ? _buildBadge('체지방') : null,
        badgePositionPercentageOffset: 1.3,
      ),
      // 기타 (수분, 뼈 등)
      PieChartSectionData(
        color: Colors.grey[400]!,
        value: otherMass > 0 ? otherMass : 0.1,
        title: touchedIndex == 2
            ? '${otherPercent.toStringAsFixed(1)}%'
            : '${otherMass.toStringAsFixed(1)}kg',
        radius: touchedIndex == 2 ? 65 : 55,
        titleStyle: TextStyle(
          fontSize: touchedIndex == 2 ? 14 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: touchedIndex == 2 ? _buildBadge('기타') : null,
        badgePositionPercentageOffset: 1.3,
      ),
    ];
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _legendItem(
          '골격근량',
          AppTheme.primary,
          '${widget.muscleMass.toStringAsFixed(1)}kg',
          '${musclePercent.toStringAsFixed(1)}%',
        ),
        _legendItem(
          '체지방량',
          AppTheme.error,
          '${widget.fatMass.toStringAsFixed(1)}kg',
          '${fatPercent.toStringAsFixed(1)}%',
        ),
        _legendItem(
          '기타',
          Colors.grey[400]!,
          '${otherMass.toStringAsFixed(1)}kg',
          '${otherPercent.toStringAsFixed(1)}%',
        ),
      ],
    );
  }

  Widget _legendItem(String label, Color color, String value, String percent) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(percent, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ],
    );
  }
}
