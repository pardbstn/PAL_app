import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';

/// 근육 그룹 밸런스 도넛 차트
/// 상체, 하체, 코어, 유산소 운동 비율을 시각화
class MuscleBalanceDonut extends StatefulWidget {
  /// 근육 그룹별 운동 비율 (%)
  /// Keys: 'upper' (상체), 'lower' (하체), 'core' (코어), 'cardio' (유산소)
  final Map<String, int> muscleGroupBalance;

  /// 불균형 여부
  final bool isImbalanced;

  /// 불균형 유형 (예: '상체 과다', '하체 부족')
  final String? imbalanceType;

  const MuscleBalanceDonut({
    super.key,
    required this.muscleGroupBalance,
    this.isImbalanced = false,
    this.imbalanceType,
  });

  @override
  State<MuscleBalanceDonut> createState() => _MuscleBalanceDonutState();
}

class _MuscleBalanceDonutState extends State<MuscleBalanceDonut> {
  int touchedIndex = -1;

  // 색상 정의
  static const Color upperColor = Color(0xFF0064FF); // Blue - 상체
  static const Color lowerColor = Color(0xFF00C471); // Green - 하체
  static const Color coreColor = Color(0xFFFF8A00); // Orange - 코어
  static const Color cardioColor = Color(0xFF8B5CF6); // Purple - 유산소

  // 근육 그룹 정보
  static const Map<String, _MuscleGroupInfo> _muscleGroups = {
    'upper': _MuscleGroupInfo(
      label: '상체',
      color: upperColor,
      icon: Icons.fitness_center,
    ),
    'lower': _MuscleGroupInfo(
      label: '하체',
      color: lowerColor,
      icon: Icons.directions_walk,
    ),
    'core': _MuscleGroupInfo(
      label: '코어',
      color: coreColor,
      icon: Icons.self_improvement,
    ),
    'cardio': _MuscleGroupInfo(
      label: '유산소',
      color: cardioColor,
      icon: Icons.directions_run,
    ),
  };

  /// 가장 높은 비율의 근육 그룹 찾기
  String get _dominantGroup {
    if (widget.muscleGroupBalance.isEmpty) return '';

    String dominant = '';
    int maxValue = 0;

    widget.muscleGroupBalance.forEach((key, value) {
      if (value > maxValue) {
        maxValue = value;
        dominant = key;
      }
    });

    return dominant;
  }

  /// 균형 상태 텍스트
  String get _centerText {
    if (widget.isImbalanced && widget.imbalanceType != null) {
      return widget.imbalanceType!;
    }

    // 균형 판단: 모든 값의 차이가 15% 이내면 균형
    final values = widget.muscleGroupBalance.values.toList();
    if (values.isEmpty) return '';

    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final minVal = values.reduce((a, b) => a < b ? a : b);

    if (maxVal - minVal <= 15) {
      return '균형';
    }

    // 우세 그룹 표시
    final dominantInfo = _muscleGroups[_dominantGroup];
    return dominantInfo?.label ?? '';
  }

  /// 균형 상태 색상
  Color get _centerColor {
    if (widget.isImbalanced) {
      return AppTheme.error;
    }
    if (_centerText == '균형') {
      return AppTheme.secondary;
    }
    return _muscleGroups[_dominantGroup]?.color ?? AppTheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // 도넛 차트
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
                  centerSpaceRadius: 55,
                  sections: _buildSections(),
                ),
              ).animate().fadeIn(duration: 400.ms).scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: 500.ms,
                    curve: Curves.easeOutBack,
                  ),
              // 중앙 텍스트
              _buildCenterContent(colorScheme),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // 범례
        _buildLegend(colorScheme),
        // 불균형 경고
        if (widget.isImbalanced && widget.imbalanceType != null)
          _buildImbalanceWarning(colorScheme),
      ],
    );
  }

  /// 중앙 콘텐츠 (상태 표시)
  Widget _buildCenterContent(ColorScheme colorScheme) {
    final isBalanced = _centerText == '균형';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 상태 아이콘
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _centerColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isBalanced
                ? Icons.check_circle_outline
                : widget.isImbalanced
                    ? Icons.warning_amber_rounded
                    : _muscleGroups[_dominantGroup]?.icon ?? Icons.analytics,
            color: _centerColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        // 상태 텍스트
        Text(
          _centerText,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _centerColor,
          ),
        ),
      ],
    ).animate(delay: 300.ms).fadeIn(duration: 300.ms);
  }

  /// 파이 차트 섹션 생성
  List<PieChartSectionData> _buildSections() {
    final sections = <PieChartSectionData>[];
    final entries = widget.muscleGroupBalance.entries.toList();

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final groupInfo = _muscleGroups[entry.key];

      if (groupInfo == null) continue;

      final isTouched = touchedIndex == i;
      final value = entry.value.toDouble();
      final percentage = value.toStringAsFixed(0);

      // 불균형 영역 강조
      final isImbalancedSection = widget.isImbalanced &&
          widget.imbalanceType != null &&
          widget.imbalanceType!.contains(groupInfo.label);

      sections.add(
        PieChartSectionData(
          color: groupInfo.color,
          value: value,
          title: isTouched ? '${groupInfo.label}\n$percentage%' : '$percentage%',
          radius: isTouched
              ? 60
              : isImbalancedSection
                  ? 55
                  : 50,
          titleStyle: TextStyle(
            fontSize: isTouched ? 13 : 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 2,
              ),
            ],
          ),
          badgeWidget: isTouched ? _buildBadge(groupInfo) : null,
          badgePositionPercentageOffset: 1.2,
          // 불균형 영역에 테두리 추가
          borderSide: isImbalancedSection
              ? BorderSide(
                  color: AppTheme.error.withValues(alpha: 0.8),
                  width: 3,
                )
              : BorderSide.none,
        ),
      );
    }

    return sections;
  }

  /// 터치 시 표시되는 배지
  Widget _buildBadge(_MuscleGroupInfo info) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: info.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: info.color.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            info.icon,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            info.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 범례 위젯
  Widget _buildLegend(ColorScheme colorScheme) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: widget.muscleGroupBalance.entries.map((entry) {
        final groupInfo = _muscleGroups[entry.key];
        if (groupInfo == null) return const SizedBox.shrink();

        final isImbalancedSection = widget.isImbalanced &&
            widget.imbalanceType != null &&
            widget.imbalanceType!.contains(groupInfo.label);

        return _LegendItem(
          label: groupInfo.label,
          color: groupInfo.color,
          value: entry.value,
          icon: groupInfo.icon,
          isHighlighted: isImbalancedSection,
        );
      }).toList(),
    ).animate(delay: 200.ms).fadeIn(duration: 300.ms).slideY(
          begin: 0.2,
          end: 0,
          duration: 300.ms,
        );
  }

  /// 불균형 경고 위젯
  Widget _buildImbalanceWarning(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppTheme.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '${widget.imbalanceType} - 균형 잡힌 운동을 권장합니다',
              style: TextStyle(
                color: AppTheme.error,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: 400.ms).fadeIn(duration: 300.ms).shake(
          hz: 2,
          duration: 500.ms,
        );
  }
}

/// 범례 아이템 위젯
class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  final int value;
  final IconData icon;
  final bool isHighlighted;

  const _LegendItem({
    required this.label,
    required this.color,
    required this.value,
    required this.icon,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppTheme.error.withValues(alpha: 0.1)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: isHighlighted
            ? Border.all(color: AppTheme.error.withValues(alpha: 0.5))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 색상 인디케이터
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // 라벨
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 4),
          // 퍼센트
          Text(
            '$value%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? AppTheme.error : color,
            ),
          ),
        ],
      ),
    );
  }
}

/// 근육 그룹 정보 클래스
class _MuscleGroupInfo {
  final String label;
  final Color color;
  final IconData icon;

  const _MuscleGroupInfo({
    required this.label,
    required this.color,
    required this.icon,
  });
}
