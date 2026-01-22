import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';

/// 이탈 위험도 게이지 차트 위젯
/// 회원의 이탈 위험 점수를 반원 게이지 형태로 시각화
/// 위험 수준별 색상 코딩 및 세부 요인 표시
class ChurnGaugeChart extends StatefulWidget {
  /// 이탈 위험 점수 (0-100)
  final int churnScore;

  /// 위험 수준: CRITICAL, HIGH, MEDIUM, LOW
  final String riskLevel;

  /// 요인별 점수 breakdown
  /// 예: {'attendanceDrop': {'score': 70, 'weighted': 21}, ...}
  final Map<String, Map<String, dynamic>> breakdown;

  /// 위험 요인 설명 목록
  /// 예: ['출석률 30% 하락', '2주 체중 정체']
  final List<String> riskFactors;

  /// 차트 크기 (반원 지름)
  final double size;

  /// 애니메이션 활성화 여부
  final bool animate;

  const ChurnGaugeChart({
    super.key,
    required this.churnScore,
    required this.riskLevel,
    required this.breakdown,
    required this.riskFactors,
    this.size = 200,
    this.animate = true,
  });

  @override
  State<ChurnGaugeChart> createState() => _ChurnGaugeChartState();
}

class _ChurnGaugeChartState extends State<ChurnGaugeChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scoreAnimation = Tween<double>(
      begin: 0,
      end: widget.churnScore.toDouble(),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    if (widget.animate) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ChurnGaugeChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.churnScore != widget.churnScore) {
      _scoreAnimation = Tween<double>(
        begin: _scoreAnimation.value,
        end: widget.churnScore.toDouble(),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 위험 수준에 따른 색상 반환
  Color _getRiskColor(String level) {
    switch (level.toUpperCase()) {
      case 'CRITICAL':
        return const Color(0xFFEF4444); // 빨강
      case 'HIGH':
        return const Color(0xFFF59E0B); // 주황
      case 'MEDIUM':
        return const Color(0xFFFBBF24); // 노랑
      case 'LOW':
        return const Color(0xFF10B981); // 초록
      default:
        return AppTheme.primary;
    }
  }

  /// 위험 수준 한글 레이블
  String _getRiskLevelLabel(String level) {
    switch (level.toUpperCase()) {
      case 'CRITICAL':
        return '매우 위험';
      case 'HIGH':
        return '위험';
      case 'MEDIUM':
        return '주의';
      case 'LOW':
        return '양호';
      default:
        return level;
    }
  }

  /// 요인 키의 한글 레이블
  String _getFactorLabel(String key) {
    switch (key) {
      case 'attendanceDrop':
        return '출석률 하락';
      case 'weightPlateau':
        return '체중 정체';
      case 'messageNoResponse':
        return '메시지 무응답';
      case 'remainingSessions':
        return '잔여 세션';
      case 'goalProgress':
        return '목표 진행';
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final riskColor = _getRiskColor(widget.riskLevel);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 반원 게이지 차트
        _buildGaugeChart(colorScheme, riskColor),

        const SizedBox(height: 16),

        // 위험 요인 칩
        if (widget.riskFactors.isNotEmpty) ...[
          _buildRiskFactorChips(colorScheme, riskColor),
          const SizedBox(height: 16),
        ],

        // 세부 요인 점수 breakdown
        if (widget.breakdown.isNotEmpty)
          _buildBreakdownSection(colorScheme),
      ],
    );
  }

  /// 반원 게이지 차트 빌드
  Widget _buildGaugeChart(ColorScheme colorScheme, Color riskColor) {
    return AnimatedBuilder(
      animation: _scoreAnimation,
      builder: (context, child) {
        final animatedScore = _scoreAnimation.value;

        return SizedBox(
          width: widget.size,
          height: widget.size * 0.6, // 반원 높이
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // 반원 게이지 (PieChart로 구현)
              SizedBox(
                width: widget.size,
                height: widget.size,
                child: PieChart(
                  PieChartData(
                    startDegreeOffset: 180, // 6시 방향에서 시작
                    sectionsSpace: 0,
                    centerSpaceRadius: widget.size * 0.3,
                    pieTouchData: PieTouchData(enabled: false),
                    sections: _buildGaugeSections(animatedScore, colorScheme),
                  ),
                ),
              ),

              // 중앙 점수 표시
              Positioned(
                bottom: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 점수
                    Text(
                      '${animatedScore.toInt()}',
                      style: TextStyle(
                        fontSize: widget.size * 0.2,
                        fontWeight: FontWeight.w700,
                        color: riskColor,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // 위험 수준 레이블
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: riskColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: riskColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getRiskLevelLabel(widget.riskLevel),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: riskColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ).animate().fadeIn(duration: 400.ms).scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: 600.ms,
          curve: Curves.easeOutBack,
        );
  }

  /// 게이지 섹션 빌드 (반원만 표시)
  List<PieChartSectionData> _buildGaugeSections(
    double score,
    ColorScheme colorScheme,
  ) {
    // 반원 = 180도이므로 전체 값을 180으로 설정
    // 점수 비율에 따라 채움 섹션과 빈 섹션 계산
    final fillValue = (score / 100) * 180;
    final emptyValue = 180 - fillValue;

    // 점수에 따른 색상 결정
    Color scoreColor;
    if (score >= 80) {
      scoreColor = const Color(0xFFEF4444); // CRITICAL
    } else if (score >= 60) {
      scoreColor = const Color(0xFFF59E0B); // HIGH
    } else if (score >= 40) {
      scoreColor = const Color(0xFFFBBF24); // MEDIUM
    } else {
      scoreColor = const Color(0xFF10B981); // LOW
    }

    return [
      // 채움 섹션 (점수 표시)
      PieChartSectionData(
        value: fillValue,
        color: scoreColor,
        radius: widget.size * 0.15,
        title: '',
        showTitle: false,
      ),
      // 빈 섹션 (배경)
      PieChartSectionData(
        value: emptyValue,
        color: colorScheme.surfaceContainerHighest,
        radius: widget.size * 0.15,
        title: '',
        showTitle: false,
      ),
      // 하단 반원 숨김 (투명)
      PieChartSectionData(
        value: 180,
        color: Colors.transparent,
        radius: widget.size * 0.15,
        title: '',
        showTitle: false,
      ),
    ];
  }

  /// 위험 요인 칩 빌드
  Widget _buildRiskFactorChips(ColorScheme colorScheme, Color riskColor) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: widget.riskFactors.map((factor) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: riskColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: riskColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 14,
                color: riskColor,
              ),
              const SizedBox(width: 4),
              Text(
                factor,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: riskColor,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    )
        .animate(delay: 200.ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0, duration: 400.ms);
  }

  /// 세부 요인 breakdown 섹션 빌드
  Widget _buildBreakdownSection(ColorScheme colorScheme) {
    final sortedEntries = widget.breakdown.entries.toList()
      ..sort((a, b) {
        final aWeighted = (a.value['weighted'] as num?)?.toDouble() ?? 0;
        final bWeighted = (b.value['weighted'] as num?)?.toDouble() ?? 0;
        return bWeighted.compareTo(aWeighted); // 내림차순 정렬
      });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '세부 요인 분석',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...sortedEntries.asMap().entries.map((entry) {
            final index = entry.key;
            final factorKey = entry.value.key;
            final factorData = entry.value.value;
            final score = (factorData['score'] as num?)?.toInt() ?? 0;
            final weighted = (factorData['weighted'] as num?)?.toInt() ?? 0;

            return _buildFactorRow(
              colorScheme,
              _getFactorLabel(factorKey),
              score,
              weighted,
              index,
            );
          }),
        ],
      ),
    )
        .animate(delay: 400.ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0, duration: 400.ms);
  }

  /// 개별 요인 행 빌드
  Widget _buildFactorRow(
    ColorScheme colorScheme,
    String label,
    int score,
    int weighted,
    int index,
  ) {
    // 점수에 따른 색상
    Color barColor;
    if (score >= 80) {
      barColor = const Color(0xFFEF4444);
    } else if (score >= 60) {
      barColor = const Color(0xFFF59E0B);
    } else if (score >= 40) {
      barColor = const Color(0xFFFBBF24);
    } else {
      barColor = const Color(0xFF10B981);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Row(
                children: [
                  Text(
                    '$score점',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: barColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '+$weighted',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.outline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          // 프로그레스 바
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: score / 100),
            duration: Duration(milliseconds: 800 + (index * 100)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Container(
                height: 6,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(3),
                      gradient: LinearGradient(
                        colors: [
                          barColor,
                          barColor.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 컴팩트 버전 이탈 위험도 게이지
/// 작은 공간에 간단히 표시할 때 사용
class ChurnGaugeChartCompact extends StatelessWidget {
  final int churnScore;
  final String riskLevel;
  final double size;

  const ChurnGaugeChartCompact({
    super.key,
    required this.churnScore,
    required this.riskLevel,
    this.size = 80,
  });

  Color _getRiskColor(String level) {
    switch (level.toUpperCase()) {
      case 'CRITICAL':
        return const Color(0xFFEF4444);
      case 'HIGH':
        return const Color(0xFFF59E0B);
      case 'MEDIUM':
        return const Color(0xFFFBBF24);
      case 'LOW':
        return const Color(0xFF10B981);
      default:
        return AppTheme.primary;
    }
  }

  String _getRiskLevelLabel(String level) {
    switch (level.toUpperCase()) {
      case 'CRITICAL':
        return '매우 위험';
      case 'HIGH':
        return '위험';
      case 'MEDIUM':
        return '주의';
      case 'LOW':
        return '양호';
      default:
        return level;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final riskColor = _getRiskColor(riskLevel);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 원형 프로그레스
          SizedBox(
            width: size,
            height: size,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: churnScore / 100),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return CustomPaint(
                  painter: _CircularGaugePainter(
                    progress: value,
                    progressColor: riskColor,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    strokeWidth: size * 0.1,
                  ),
                );
              },
            ),
          ),
          // 중앙 점수
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$churnScore',
                style: TextStyle(
                  fontSize: size * 0.25,
                  fontWeight: FontWeight.w700,
                  color: riskColor,
                  height: 1,
                ),
              ),
              Text(
                _getRiskLevelLabel(riskLevel),
                style: TextStyle(
                  fontSize: size * 0.1,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 원형 게이지 페인터 (컴팩트 버전용)
class _CircularGaugePainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  _CircularGaugePainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 배경 원
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // 프로그레스 아크
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // 12시 방향에서 시작
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
