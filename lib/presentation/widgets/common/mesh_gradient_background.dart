import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';

/// 서브 화면용 메시 그라데이션 배경
/// 쿨 그레이 베이스 위에 블루 포인트 컬러가 희미하게 번지는 효과
///
/// 사용 예시:
/// ```dart
/// MeshGradientBackground(
///   scrollController: _scrollController,
///   child: ListView(...),
/// )
/// ```
class MeshGradientBackground extends StatefulWidget {
  /// 그라데이션 위에 표시될 자식 위젯
  final Widget child;

  /// 스크롤 시 패럴랙스 효과를 위한 컨트롤러 (선택 사항)
  final ScrollController? scrollController;

  /// 애니메이션 속도 배율 (기본값: 1.0, 느리게: 0.5, 빠르게: 2.0)
  final double animationSpeed;

  const MeshGradientBackground({
    super.key,
    required this.child,
    this.scrollController,
    this.animationSpeed = 1.0,
  });

  @override
  State<MeshGradientBackground> createState() => _MeshGradientBackgroundState();
}

class _MeshGradientBackgroundState extends State<MeshGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();

    // 10초 주기로 반복되는 느린 애니메이션
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (10000 / widget.animationSpeed).round()),
    )..repeat();

    // 스크롤 리스너 등록 (패럴랙스 효과)
    widget.scrollController?.addListener(_onScroll);
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = widget.scrollController?.offset ?? 0.0;
    });
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // 애니메이션되는 그라데이션 배경
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _MeshGradientPainter(
                  animationValue: _controller.value,
                  scrollOffset: _scrollOffset,
                  isDark: isDark,
                ),
              );
            },
          ),
        ),

        // 실제 콘텐츠
        widget.child,
      ],
    );
  }
}

/// 메시 그라데이션을 그리는 CustomPainter
class _MeshGradientPainter extends CustomPainter {
  final double animationValue;
  final double scrollOffset;
  final bool isDark;

  const _MeshGradientPainter({
    required this.animationValue,
    required this.scrollOffset,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 베이스 색상
    final baseColor = isDark ? const Color(0xFF0E0E0E) : const Color(0xFFF5F7FA);
    final blueColor = AppColors.primary; // #0064FF

    // 베이스 레이어 먼저 칠하기
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = baseColor,
    );

    // 패럴랙스 오프셋 (스크롤의 10%만 반영해서 미묘한 효과)
    final parallaxY = scrollOffset * 0.1;

    // 블루 그라데이션 포인트 4개 정의
    final gradients = [
      _GradientPoint(
        // 왼쪽 상단
        offsetX: 0.2,
        offsetY: 0.15,
        radius: 0.4,
        opacity: isDark ? 0.03 : 0.06,
        phaseX: 0.0,
        phaseY: 0.0,
      ),
      _GradientPoint(
        // 오른쪽 상단
        offsetX: 0.8,
        offsetY: 0.2,
        radius: 0.35,
        opacity: isDark ? 0.04 : 0.07,
        phaseX: math.pi * 0.5,
        phaseY: math.pi * 0.3,
      ),
      _GradientPoint(
        // 왼쪽 하단
        offsetX: 0.15,
        offsetY: 0.75,
        radius: 0.38,
        opacity: isDark ? 0.05 : 0.08,
        phaseX: math.pi,
        phaseY: math.pi * 0.7,
      ),
      _GradientPoint(
        // 오른쪽 하단
        offsetX: 0.85,
        offsetY: 0.8,
        radius: 0.42,
        opacity: isDark ? 0.035 : 0.065,
        phaseX: math.pi * 1.5,
        phaseY: math.pi * 1.2,
      ),
    ];

    // 각 그라데이션 포인트 그리기
    for (final gradient in gradients) {
      _drawGradientPoint(
        canvas,
        size,
        gradient,
        blueColor,
        parallaxY,
      );
    }
  }

  void _drawGradientPoint(
    Canvas canvas,
    Size size,
    _GradientPoint gradient,
    Color color,
    double parallaxY,
  ) {
    // sin/cos 곡선으로 부드러운 움직임 생성 (범위: -0.05 ~ 0.05)
    final animPhase = animationValue * 2 * math.pi;
    final moveX = math.sin(animPhase + gradient.phaseX) * 0.05;
    final moveY = math.cos(animPhase + gradient.phaseY) * 0.05;

    // 최종 위치 계산
    final centerX = size.width * (gradient.offsetX + moveX);
    final centerY = size.height * (gradient.offsetY + moveY) - parallaxY;

    // 반지름 계산
    final radius = size.width * gradient.radius;

    // 방사형 그라데이션 생성
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(gradient.opacity),
          color.withOpacity(gradient.opacity * 0.5),
          color.withOpacity(0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(
        Rect.fromCircle(
          center: Offset(centerX, centerY),
          radius: radius,
        ),
      );

    // 그라데이션 원 그리기
    canvas.drawCircle(
      Offset(centerX, centerY),
      radius,
      paint,
    );
  }

  @override
  bool shouldRepaint(_MeshGradientPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.scrollOffset != scrollOffset ||
        oldDelegate.isDark != isDark;
  }
}

/// 개별 그라데이션 포인트 정의
class _GradientPoint {
  /// X 위치 (0.0 ~ 1.0, 화면 비율)
  final double offsetX;

  /// Y 위치 (0.0 ~ 1.0, 화면 비율)
  final double offsetY;

  /// 반지름 (0.0 ~ 1.0, 화면 너비 비율)
  final double radius;

  /// 투명도 (0.0 ~ 1.0)
  final double opacity;

  /// X축 애니메이션 위상차 (라디안)
  final double phaseX;

  /// Y축 애니메이션 위상차 (라디안)
  final double phaseY;

  const _GradientPoint({
    required this.offsetX,
    required this.offsetY,
    required this.radius,
    required this.opacity,
    required this.phaseX,
    required this.phaseY,
  });
}
