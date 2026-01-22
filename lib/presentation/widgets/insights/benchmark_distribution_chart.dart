import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
// fl_chart와 flutter_animate를 사용한 벤치마크 분포 차트

/// 벤치마크 분포 차트 카테고리 데이터
class BenchmarkCategory {
  /// 카테고리명 (예: '출석률', '체지방 감량', '종합 순위')
  final String category;

  /// 실제 값
  final double value;

  /// 백분위 (1-100, 낮을수록 상위)
  final int percentile;

  /// 벤치마크 평균값
  final double benchmark;

  const BenchmarkCategory({
    required this.category,
    required this.value,
    required this.percentile,
    required this.benchmark,
  });

  /// Map에서 생성
  factory BenchmarkCategory.fromMap(Map<String, dynamic> map) {
    return BenchmarkCategory(
      category: map['category'] as String,
      value: (map['value'] as num).toDouble(),
      percentile: map['percentile'] as int,
      benchmark: (map['benchmark'] as num).toDouble(),
    );
  }
}

/// 벤치마크 분포 차트 위젯
/// 회원의 위치를 다른 회원들과 비교하여 시각화
class BenchmarkDistributionChart extends StatefulWidget {
  /// 종합 백분위 (1-100, 낮을수록 상위)
  final int overallPercentile;

  /// 카테고리별 데이터
  final List<BenchmarkCategory> categories;

  /// 목표 타입: 'diet' (다이어트), 'bulk' (벌크업), 'fitness' (체력 향상)
  final String goal;

  const BenchmarkDistributionChart({
    super.key,
    required this.overallPercentile,
    required this.categories,
    required this.goal,
  });

  /// Map 리스트로부터 생성하는 팩토리 생성자
  factory BenchmarkDistributionChart.fromMaps({
    Key? key,
    required int overallPercentile,
    required List<Map<String, dynamic>> categories,
    required String goal,
  }) {
    return BenchmarkDistributionChart(
      key: key,
      overallPercentile: overallPercentile,
      categories: categories.map((m) => BenchmarkCategory.fromMap(m)).toList(),
      goal: goal,
    );
  }

  @override
  State<BenchmarkDistributionChart> createState() =>
      _BenchmarkDistributionChartState();
}

class _BenchmarkDistributionChartState extends State<BenchmarkDistributionChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 백분위에 따른 색상 반환
  Color _getPercentileColor(int percentile) {
    if (percentile <= 20) {
      return const Color(0xFF10B981); // Green - 상위 20%
    } else if (percentile <= 40) {
      return const Color(0xFF2563EB); // Blue - 상위 40%
    } else if (percentile <= 60) {
      return const Color(0xFFFBBF24); // Yellow - 상위 60%
    } else if (percentile <= 80) {
      return const Color(0xFFF59E0B); // Orange - 상위 80%
    } else {
      return const Color(0xFFEF4444); // Red - 하위 20%
    }
  }

  /// 백분위에 따른 라벨 반환
  String _getPercentileLabel(int percentile) {
    if (percentile <= 10) {
      return '상위 $percentile%';
    } else if (percentile <= 20) {
      return '상위 $percentile%';
    } else if (percentile <= 50) {
      return '상위 $percentile%';
    } else {
      return '하위 ${100 - percentile}%';
    }
  }

  /// 목표 타입에 따른 라벨 반환
  String _getGoalLabel() {
    switch (widget.goal) {
      case 'diet':
        return '다이어트';
      case 'bulk':
        return '벌크업';
      case 'fitness':
        return '체력 향상';
      default:
        return '일반';
    }
  }

  /// 목표 타입에 따른 아이콘 반환
  IconData _getGoalIcon() {
    switch (widget.goal) {
      case 'diet':
        return Icons.local_fire_department;
      case 'bulk':
        return Icons.fitness_center;
      case 'fitness':
        return Icons.directions_run;
      default:
        return Icons.stars;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final overallColor = _getPercentileColor(widget.overallPercentile);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 종합 순위 헤더
            _buildOverallHeader(colorScheme, overallColor),
            const SizedBox(height: 24),

            // 카테고리별 바 차트
            ...widget.categories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildCategoryBar(category, colorScheme, index),
              );
            }),

            const SizedBox(height: 16),

            // 범례
            _buildLegend(colorScheme),
          ],
        );
      },
    );
  }

  /// 종합 순위 헤더
  Widget _buildOverallHeader(ColorScheme colorScheme, Color overallColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            overallColor.withValues(alpha: 0.15),
            overallColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: overallColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 목표 아이콘
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: overallColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getGoalIcon(),
              color: overallColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // 텍스트 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getGoalLabel(),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: overallColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getPercentileLabel(widget.overallPercentile),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '종합 순위',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // 백분위 원형 표시
          _buildPercentileCircle(widget.overallPercentile, overallColor),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: -0.1, end: 0, duration: 500.ms);
  }

  /// 백분위 원형 표시
  Widget _buildPercentileCircle(int percentile, Color color) {
    final displayPercentile = percentile <= 50 ? percentile : 100 - percentile;
    final prefix = percentile <= 50 ? '상위' : '하위';

    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 배경 원
          SizedBox(
            width: 70,
            height: 70,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 6,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.transparent),
            ),
          ),
          // 진행 원
          SizedBox(
            width: 70,
            height: 70,
            child: CircularProgressIndicator(
              value: (1 - percentile / 100) * _animation.value,
              strokeWidth: 6,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          // 중앙 텍스트
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                prefix,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$displayPercentile%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 카테고리별 수평 바 차트
  Widget _buildCategoryBar(
    BenchmarkCategory category,
    ColorScheme colorScheme,
    int index,
  ) {
    final color = _getPercentileColor(category.percentile);
    // 백분위가 낮을수록 좋으므로, 바의 너비는 (100 - percentile)로 계산
    final barProgress = (100 - category.percentile) / 100;
    // 벤치마크 위치 계산 (평균이 50%라고 가정)
    final benchmarkPosition = 0.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 카테고리 헤더
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category.category,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            Row(
              children: [
                Text(
                  _getPercentileLabel(category.percentile),
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatValue(category.value, category.category),
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 수평 바 차트
        SizedBox(
          height: 32,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final animatedProgress = barProgress * _animation.value;
              final benchmarkX = maxWidth * benchmarkPosition;

              return Stack(
                children: [
                  // 배경 바
                  Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  // 진행 바
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 24,
                    width: maxWidth * animatedProgress,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color,
                          color.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),

                  // 벤치마크 평균 라인
                  Positioned(
                    left: benchmarkX - 1,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        color: colorScheme.outline,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),

                  // 벤치마크 라벨
                  Positioned(
                    left: benchmarkX - 20,
                    bottom: -2,
                    child: Text(
                      '평균',
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.outline,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn(duration: 400.ms)
        .slideX(begin: -0.1, end: 0, duration: 400.ms);
  }

  /// 값 포맷팅
  String _formatValue(double value, String category) {
    if (category.contains('출석률') || category.contains('순위')) {
      return '${value.toStringAsFixed(0)}%';
    } else if (category.contains('체지방') || category.contains('근육')) {
      return '${value.toStringAsFixed(1)}kg';
    }
    return value.toStringAsFixed(1);
  }

  /// 범례
  Widget _buildLegend(ColorScheme colorScheme) {
    final legendItems = [
      ('상위 20%', const Color(0xFF10B981)),
      ('상위 40%', const Color(0xFF2563EB)),
      ('상위 60%', const Color(0xFFFBBF24)),
      ('하위 40%', const Color(0xFFF59E0B)),
      ('하위 20%', const Color(0xFFEF4444)),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '등급 기준',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: legendItems.map((item) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: item.$2,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.$1,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    )
        .animate(delay: 400.ms)
        .fadeIn(duration: 400.ms);
  }
}

/// fl_chart를 사용한 상세 분포 차트 (선택적 사용)
class BenchmarkDetailChart extends StatelessWidget {
  final List<BenchmarkCategory> categories;

  const BenchmarkDetailChart({
    super.key,
    required this.categories,
  });

  Color _getPercentileColor(int percentile) {
    if (percentile <= 20) {
      return const Color(0xFF10B981);
    } else if (percentile <= 40) {
      return const Color(0xFF2563EB);
    } else if (percentile <= 60) {
      return const Color(0xFFFBBF24);
    } else if (percentile <= 80) {
      return const Color(0xFFF59E0B);
    } else {
      return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          minY: 0,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => colorScheme.surfaceContainerHighest,
              tooltipBorderRadius: BorderRadius.circular(8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final category = categories[groupIndex];
                return BarTooltipItem(
                  '${category.category}\n',
                  TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  children: [
                    TextSpan(
                      text: '상위 ${category.percentile}%',
                      style: TextStyle(
                        color: _getPercentileColor(category.percentile),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= categories.length) {
                    return const SizedBox.shrink();
                  }
                  final category = categories[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      category.category,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 25,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${(100 - value).toInt()}%',
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.outline,
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: categories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final color = _getPercentileColor(category.percentile);
            // 백분위가 낮을수록 바가 높음 (상위일수록 좋음)
            final barValue = (100 - category.percentile).toDouble();

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: barValue,
                  color: color,
                  width: 40,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 100,
                    color: colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            );
          }).toList(),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              // 평균선 (50%)
              HorizontalLine(
                y: 50,
                color: colorScheme.outline,
                strokeWidth: 2,
                dashArray: [8, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  labelResolver: (line) => '평균',
                  style: TextStyle(
                    fontSize: 10,
                    color: colorScheme.outline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
