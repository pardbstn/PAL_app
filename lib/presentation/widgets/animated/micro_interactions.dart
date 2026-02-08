import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// 탭 피드백 위젯 - 탭할 때 살짝 작아짐
class TapFeedback extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;

  const TapFeedback({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.97,
  });

  @override
  State<TapFeedback> createState() => _TapFeedbackState();
}

class _TapFeedbackState extends State<TapFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// 호버 효과 위젯 (웹용)
class HoverEffect extends StatefulWidget {
  final Widget child;
  final double scale;
  final Duration duration;
  final VoidCallback? onTap;

  const HoverEffect({
    super.key,
    required this.child,
    this.scale = 1.01,
    this.duration = const Duration(milliseconds: 200),
    this.onTap,
  });

  @override
  State<HoverEffect> createState() => _HoverEffectState();
}

class _HoverEffectState extends State<HoverEffect> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? widget.scale : 1.0,
          duration: widget.duration,
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: widget.duration,
            decoration: BoxDecoration(
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// 숫자 카운트업 애니메이션
class AnimatedCounter extends StatelessWidget {
  final int value;
  final Duration duration;
  final TextStyle? style;
  final String? prefix;
  final String? suffix;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 800),
    this.style,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        return Text(
          '${prefix ?? ''}$animatedValue${suffix ?? ''}',
          style: style,
        );
      },
    );
  }
}

/// 소수점 숫자 카운트업 애니메이션
class AnimatedDoubleCounter extends StatelessWidget {
  final double value;
  final Duration duration;
  final TextStyle? style;
  final String? prefix;
  final String? suffix;
  final int decimalPlaces;

  const AnimatedDoubleCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 800),
    this.style,
    this.prefix,
    this.suffix,
    this.decimalPlaces = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        return Text(
          '${prefix ?? ''}${animatedValue.toStringAsFixed(decimalPlaces)}${suffix ?? ''}',
          style: style,
        );
      },
    );
  }
}

/// 애니메이션 프로그레스 바
class AnimatedProgressBar extends StatelessWidget {
  final double progress;
  final Color? backgroundColor;
  final Color? progressColor;
  final double height;
  final Duration duration;
  final BorderRadius? borderRadius;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    this.backgroundColor,
    this.progressColor,
    this.height = 8,
    this.duration = const Duration(milliseconds: 600),
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(height / 2);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: effectiveBorderRadius,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedContainer(
                duration: duration,
                curve: Curves.easeOutCubic,
                width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  color: progressColor ?? theme.colorScheme.primary,
                  borderRadius: effectiveBorderRadius,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 로딩 점 애니메이션
class LoadingDots extends StatefulWidget {
  final Color? color;
  final double size;

  const LoadingDots({
    super.key,
    this.color,
    this.size = 8,
  });

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final animValue = ((_controller.value + delay) % 1.0);
            final yOffset =
                -8 * (animValue < 0.5 ? animValue * 2 : (1 - animValue) * 2);

            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.size / 4),
              child: Transform.translate(
                offset: Offset(0, yOffset),
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// 쉬머 효과 래퍼 (로딩 시 반짝임)
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    final theme = Theme.of(context);
    final baseColor =
        widget.baseColor ?? theme.colorScheme.surfaceContainerHighest;
    final highlightColor =
        widget.highlightColor ?? theme.colorScheme.surfaceContainerLow;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}

// ============================================================================
// 프리미엄 마이크로 인터렉션
// ============================================================================

/// 프리미엄 탭 피드백 - 스프링 애니메이션 + 그림자 변화 + 햅틱
class PremiumTapFeedback extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleFactor;
  final bool enableHaptic;
  final bool enableShadow;
  final Duration duration;

  const PremiumTapFeedback({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleFactor = 0.97,
    this.enableHaptic = true,
    this.enableShadow = true,
    this.duration = const Duration(milliseconds: 150),
  });

  @override
  State<PremiumTapFeedback> createState() => _PremiumTapFeedbackState();
}

class _PremiumTapFeedbackState extends State<PremiumTapFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // 스프링 커브 사용
    final springCurve = Curves.easeOutCubic;

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: springCurve,
    ));

    _shadowAnimation = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
    if (widget.enableHaptic) {
      HapticFeedback.selectionClick();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap?.call();
    if (widget.enableHaptic) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  void _handleLongPress() {
    if (widget.enableHaptic) {
      HapticFeedback.mediumImpact();
    }
    widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onLongPress: widget.onLongPress != null ? _handleLongPress : null,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: widget.enableShadow
                  ? Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.08 * _shadowAnimation.value,
                            ),
                            blurRadius: 6 * _shadowAnimation.value,
                            offset: Offset(0, 3 * _shadowAnimation.value),
                          ),
                        ],
                      ),
                      child: child,
                    )
                  : child,
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

/// 프리미엄 호버 효과 - 그림자 + 스케일 + 글로우
class PremiumHoverEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double hoverScale;
  final Color? glowColor;
  final double glowIntensity;
  final bool enableElevation;

  const PremiumHoverEffect({
    super.key,
    required this.child,
    this.onTap,
    this.hoverScale = 1.01,
    this.glowColor,
    this.glowIntensity = 0.15,
    this.enableElevation = true,
  });

  @override
  State<PremiumHoverEffect> createState() => _PremiumHoverEffectState();
}

class _PremiumHoverEffectState extends State<PremiumHoverEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.hoverScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHoverEnter(PointerEnterEvent event) {
    _controller.forward();
  }

  void _handleHoverExit(PointerExitEvent event) {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveGlowColor = widget.glowColor ?? theme.colorScheme.primary;

    return MouseRegion(
      onEnter: _handleHoverEnter,
      onExit: _handleHoverExit,
      child: GestureDetector(
        onTap: widget.onTap,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: widget.enableElevation
                        ? [
                            // 그림자
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: 0.08 * _elevationAnimation.value,
                              ),
                              blurRadius: 12 * _elevationAnimation.value,
                              offset: Offset(0, 6 * _elevationAnimation.value),
                            ),
                            // 글로우 효과
                            BoxShadow(
                              color: effectiveGlowColor.withValues(
                                alpha: widget.glowIntensity *
                                    _elevationAnimation.value,
                              ),
                              blurRadius: 10 * _elevationAnimation.value,
                              spreadRadius: 1 * _elevationAnimation.value,
                            ),
                          ]
                        : null,
                  ),
                  child: child,
                ),
              );
            },
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// 버튼 프레스 효과 - InkWell 개선
class PremiumInkEffect extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Color? splashColor;
  final Color? highlightColor;
  final bool enableRipple;

  const PremiumInkEffect({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.splashColor,
    this.highlightColor,
    this.enableRipple = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(16);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: effectiveBorderRadius,
        splashColor: enableRipple
            ? (splashColor ??
                theme.colorScheme.primary.withValues(alpha: 0.08))
            : Colors.transparent,
        highlightColor: highlightColor ??
            theme.colorScheme.primary.withValues(alpha: 0.04),
        splashFactory: enableRipple ? InkRipple.splashFactory : NoSplash.splashFactory,
        child: Ink(
          child: child,
        ),
      ),
    );
  }
}

/// 카드 인터렉션 - 기울기 + 반사 효과 (웹/데스크톱)
class InteractiveCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool enableTilt;
  final bool enableReflection;
  final double maxTiltAngle;

  const InteractiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.enableTilt = true,
    this.enableReflection = true,
    this.maxTiltAngle = 10.0,
  });

  @override
  State<InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset _mousePosition = Offset.zero;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHoverEnter(PointerEnterEvent event) {
    setState(() => _isHovered = true);
    _controller.forward();
  }

  void _handleHoverExit(PointerExitEvent event) {
    setState(() {
      _isHovered = false;
      _mousePosition = Offset.zero;
    });
    _controller.reverse();
  }

  void _handleHoverMove(PointerHoverEvent event, Size size) {
    if (!widget.enableTilt) return;

    setState(() {
      // 카드 중심을 기준으로 -1 ~ 1 범위로 정규화
      _mousePosition = Offset(
        (event.localPosition.dx / size.width - 0.5) * 2,
        (event.localPosition.dy / size.height - 0.5) * 2,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        // 기울기 각도 계산 (라디안)
        final tiltX = widget.enableTilt
            ? _mousePosition.dy * widget.maxTiltAngle * math.pi / 180
            : 0.0;
        final tiltY = widget.enableTilt
            ? -_mousePosition.dx * widget.maxTiltAngle * math.pi / 180
            : 0.0;

        return MouseRegion(
          onEnter: _handleHoverEnter,
          onExit: _handleHoverExit,
          onHover: (event) => _handleHoverMove(event, size),
          child: GestureDetector(
            onTap: widget.onTap,
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // 원근감
                      ..rotateX(tiltX * _controller.value)
                      ..rotateY(tiltY * _controller.value),
                    child: Stack(
                      children: [
                        child!,
                        // 반사 효과 (그라데이션 오버레이)
                        if (widget.enableReflection && _isHovered)
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    center: Alignment(
                                      _mousePosition.dx,
                                      _mousePosition.dy,
                                    ),
                                    radius: 1.0,
                                    colors: [
                                      Colors.white.withValues(
                                        alpha: 0.2 * _controller.value,
                                      ),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 스위치/토글 피드백
class ToggleFeedback extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget child;

  const ToggleFeedback({
    super.key,
    required this.value,
    required this.onChanged,
    required this.child,
  });

  @override
  State<ToggleFeedback> createState() => _ToggleFeedbackState();
}

class _ToggleFeedbackState extends State<ToggleFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: widget.value ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(ToggleFeedback oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _controller.forward();
        HapticFeedback.mediumImpact();
      } else {
        _controller.reverse();
        HapticFeedback.lightImpact();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (0.05 * math.sin(_controller.value * math.pi)),
              child: child,
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

/// 슬라이드 삭제 피드백
class SwipeDeleteFeedback extends StatefulWidget {
  final Widget child;
  final VoidCallback onDelete;
  final Color deleteColor;

  const SwipeDeleteFeedback({
    super.key,
    required this.child,
    required this.onDelete,
    this.deleteColor = const Color(0xFFF04452),
  });

  @override
  State<SwipeDeleteFeedback> createState() => _SwipeDeleteFeedbackState();
}

class _SwipeDeleteFeedbackState extends State<SwipeDeleteFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragExtent = 0.0;
  final double _deleteThreshold = 100.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _controller.stop();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent = (_dragExtent + details.primaryDelta!).clamp(
        -_deleteThreshold * 1.5,
        0.0,
      );
    });

    // 삭제 임계값 도달 시 햅틱
    if (_dragExtent.abs() >= _deleteThreshold) {
      HapticFeedback.mediumImpact();
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_dragExtent.abs() >= _deleteThreshold) {
      // 삭제 실행
      _controller.forward().then((_) {
        HapticFeedback.heavyImpact();
        widget.onDelete();
      });
    } else {
      // 원위치
      setState(() => _dragExtent = 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_dragExtent.abs() / _deleteThreshold).clamp(0.0, 1.0);

    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: Stack(
        children: [
          // 배경 (삭제 표시)
          Positioned.fill(
            child: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              color: widget.deleteColor.withValues(alpha: progress),
              child: Icon(
                Icons.delete_outline,
                color: Colors.white.withValues(alpha: progress),
                size: 24,
              ),
            ),
          ),
          // 슬라이드 되는 콘텐츠
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final slideOffset = _dragExtent * (1.0 - _controller.value);
              return Transform.translate(
                offset: Offset(slideOffset, 0),
                child: child,
              );
            },
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

/// 롱프레스 메뉴 피드백
class LongPressFeedback extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Duration longPressDuration;

  const LongPressFeedback({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.longPressDuration = const Duration(milliseconds: 500),
  });

  @override
  State<LongPressFeedback> createState() => _LongPressFeedbackState();
}

class _LongPressFeedbackState extends State<LongPressFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.longPressDuration,
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          HapticFeedback.heavyImpact();
          widget.onLongPress?.call();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    if (widget.onLongPress != null) {
      _controller.forward();
      HapticFeedback.selectionClick();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    if (_controller.value < 1.0) {
      widget.onTap?.call();
    }
    _controller.reset();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: RepaintBoundary(
        child: Stack(
          children: [
            // 롱프레스 진행 표시 (원형 프로그레스)
            if (widget.onLongPress != null)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    if (!_isPressed) return const SizedBox.shrink();

                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.3 + (0.7 * _controller.value),
                          ),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    );
                  },
                ),
              ),
            // 자식 위젯
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isPressed ? 0.98 : 1.0,
                  child: child,
                );
              },
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}
