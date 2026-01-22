import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';

/// 주간 운동 볼륨 바 차트 위젯
/// 5주간의 운동 볼륨을 표시하고 트렌드를 시각화
class VolumeBarChart extends StatefulWidget {
  /// 주간 볼륨 리스트 (5개, index 0 = 이번 주)
  final List<int> weeklyVolumes;

  /// 4주 평균 볼륨
  final double fourWeekAverage;

  /// 볼륨 트렌드: 'overtraining', 'undertraining', 'imbalanced', 'normal'
  final String volumeTrend;

  /// 주간 변화율 (%) - 4개 값
  final List<double> weeklyChanges;

  const VolumeBarChart({
    super.key,
    required this.weeklyVolumes,
    required this.fourWeekAverage,
    required this.volumeTrend,
    this.weeklyChanges = const [],
  });

  @override
  State<VolumeBarChart> createState() => _VolumeBarChartState();
}

class _VolumeBarChartState extends State<VolumeBarChart> {
  int? touchedIndex;

  // 색상 상수
  static const Color _overtainingColor = Color(0xFFEF4444); // 빨간색
  static const Color _normalColor = Color(0xFF2563EB); // 파란색
  static const Color _undertrainingColor = Color(0xFFF59E0B); // 주황색

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 범례
        _buildLegend(colorScheme),
        const SizedBox(height: 16),
        // 차트
        SizedBox(
          height: 220,
          child: BarChart(
            _buildBarChartData(colorScheme),
            duration: const Duration(milliseconds: 300),
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 12),
        // 트렌드 인디케이터
        _buildTrendIndicator(colorScheme),
      ],
    );
  }

  /// 범례 빌드
  Widget _buildLegend(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem('과훈련', _overtainingColor),
        const SizedBox(width: 16),
        _legendItem('정상', _normalColor),
        const SizedBox(width: 16),
        _legendItem('저훈련', _undertrainingColor),
        const SizedBox(width: 16),
        _legendItem('4주 평균', colorScheme.outline, isDashed: true),
      ],
    );
  }

  Widget _legendItem(String label, Color color, {bool isDashed = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isDashed)
          CustomPaint(
            size: const Size(20, 3),
            painter: _DashedLinePainter(color: color),
          )
        else
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// 바 차트 데이터 빌드
  BarChartData _buildBarChartData(ColorScheme colorScheme) {
    if (widget.weeklyVolumes.isEmpty) return BarChartData();

    // 최대값 계산 (상단 여백 포함)
    final maxVolume = widget.weeklyVolumes.reduce((a, b) => a > b ? a : b);
    final maxY = (maxVolume * 1.2).toDouble();

    return BarChartData(
      maxY: maxY,
      minY: 0,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: _calculateInterval(maxVolume.toDouble()),
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
            reservedSize: 50,
            interval: _calculateInterval(maxVolume.toDouble()),
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  _formatVolume(value.toInt()),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= widget.weeklyVolumes.length) {
                return const SizedBox();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _getWeekLabel(index),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                    fontWeight: index == 0 ? FontWeight.bold : FontWeight.normal,
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
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => Colors.black87,
          tooltipBorderRadius: BorderRadius.circular(12),
          tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final volume = widget.weeklyVolumes[group.x];
            final changeText = groupIndex < widget.weeklyChanges.length
                ? ' (${widget.weeklyChanges[groupIndex] >= 0 ? '+' : ''}${widget.weeklyChanges[groupIndex].toStringAsFixed(1)}%)'
                : '';
            return BarTooltipItem(
              '${_formatVolume(volume)}$changeText',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              children: [
                TextSpan(
                  text: '\n${_getWeekLabel(group.x)}',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 11,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            );
          },
        ),
        touchCallback: (event, response) {
          setState(() {
            if (response?.spot != null && event is FlTapUpEvent) {
              touchedIndex = response!.spot!.touchedBarGroupIndex;
            } else if (event is FlTapCancelEvent || event is FlPanEndEvent) {
              touchedIndex = null;
            }
          });
        },
      ),
      barGroups: _buildBarGroups(),
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          HorizontalLine(
            y: widget.fourWeekAverage,
            color: colorScheme.outline,
            strokeWidth: 2,
            dashArray: [8, 4],
            label: HorizontalLineLabel(
              show: true,
              alignment: Alignment.topRight,
              padding: const EdgeInsets.only(right: 8, bottom: 4),
              style: TextStyle(
                color: colorScheme.outline,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              labelResolver: (line) => '평균 ${_formatVolume(line.y.toInt())}',
            ),
          ),
        ],
      ),
    );
  }

  /// 바 그룹 빌드
  List<BarChartGroupData> _buildBarGroups() {
    return widget.weeklyVolumes.asMap().entries.map((entry) {
      final index = entry.key;
      final volume = entry.value;
      final isTouched = touchedIndex == index;
      final barColor = _getBarColor(volume);

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: volume.toDouble(),
            color: barColor,
            width: isTouched ? 28 : 24,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: widget.weeklyVolumes.reduce((a, b) => a > b ? a : b) * 1.2,
              color: Colors.grey.withValues(alpha: 0.05),
            ),
          ),
        ],
        showingTooltipIndicators: isTouched ? [0] : [],
      );
    }).toList();
  }

  /// 볼륨에 따른 바 색상 결정
  Color _getBarColor(int volume) {
    final average = widget.fourWeekAverage;

    // 평균 대비 20% 이상이면 과훈련
    if (volume > average * 1.2) {
      return _overtainingColor;
    }
    // 평균 대비 80% 미만이면 저훈련
    if (volume < average * 0.8) {
      return _undertrainingColor;
    }
    // 그 외는 정상
    return _normalColor;
  }

  /// 트렌드 인디케이터 빌드
  Widget _buildTrendIndicator(ColorScheme colorScheme) {
    final trendData = _getTrendData();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: trendData.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: trendData.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            trendData.icon,
            color: trendData.color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trendData.title,
                  style: TextStyle(
                    color: trendData.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  trendData.description,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 300.ms);
  }

  /// 트렌드 데이터 가져오기
  _TrendData _getTrendData() {
    switch (widget.volumeTrend) {
      case 'overtraining':
        return _TrendData(
          icon: Icons.warning_amber_rounded,
          color: _overtainingColor,
          title: '과훈련 주의',
          description: '최근 운동 볼륨이 평균보다 높습니다. 충분한 휴식을 권장합니다.',
        );
      case 'undertraining':
        return _TrendData(
          icon: Icons.trending_down_rounded,
          color: _undertrainingColor,
          title: '저훈련 상태',
          description: '운동 볼륨이 평균보다 낮습니다. 점진적인 볼륨 증가를 고려해보세요.',
        );
      case 'imbalanced':
        return _TrendData(
          icon: Icons.balance_rounded,
          color: AppTheme.tertiary,
          title: '불균형 훈련',
          description: '주간 볼륨 변동이 큽니다. 일관된 훈련 패턴을 유지해보세요.',
        );
      default:
        return _TrendData(
          icon: Icons.check_circle_outline_rounded,
          color: AppTheme.secondary,
          title: '정상 훈련',
          description: '운동 볼륨이 적절하게 유지되고 있습니다.',
        );
    }
  }

  /// 주 라벨 가져오기
  String _getWeekLabel(int index) {
    if (index == 0) return '이번 주';
    return '$index주 전';
  }

  /// 볼륨 포맷팅 (kg 또는 톤)
  String _formatVolume(int volume) {
    if (volume >= 1000) {
      final tons = volume / 1000;
      return '${tons.toStringAsFixed(1)}톤';
    }
    return '${volume}kg';
  }

  /// Y축 간격 계산
  double _calculateInterval(double maxValue) {
    if (maxValue <= 10000) return 2000;
    if (maxValue <= 50000) return 10000;
    if (maxValue <= 100000) return 20000;
    return 50000;
  }
}

/// 트렌드 데이터 모델
class _TrendData {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  _TrendData({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });
}

/// 점선 그리기용 커스텀 페인터
class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter({required this.color});

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
