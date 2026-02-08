import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_pal_app/core/theme/app_tokens.dart';

/// 글래스모픽 아이콘 컨테이너
///
/// 반투명 유리 질감 + 그라데이션 + Specular highlight
/// 식단 시간, 퀵액션 등 아이콘을 감싸는 고급 컨테이너
class GlassIcon extends StatelessWidget {
  const GlassIcon({
    super.key,
    required this.icon,
    this.size = 48,
    this.iconSize = 24,
    this.color,
    this.gradientColors,
    this.blurSigma = 8,
    this.iconColor,
  });

  /// 아이콘 데이터
  final IconData icon;

  /// 컨테이너 크기
  final double size;

  /// 아이콘 크기
  final double iconSize;

  /// 기본 색상 (그라데이션 자동 생성)
  final Color? color;

  /// 커스텀 그라데이션 색상 [시작, 끝]
  final List<Color>? gradientColors;

  /// 블러 강도
  final double blurSigma;

  /// 아이콘 색상 (null이면 white)
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = color ?? AppColors.primary;

    final effectiveGradient = gradientColors ??
        [
          baseColor.withValues(alpha: isDark ? 0.4 : 0.25),
          baseColor.withValues(alpha: isDark ? 0.2 : 0.12),
        ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.35),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.35),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: effectiveGradient,
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.4),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Specular highlight (상단 빛 반사)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: size * 0.45,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(size * 0.35),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: isDark ? 0.15 : 0.35),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // 아이콘
              Center(
                child: Icon(
                  icon,
                  size: iconSize,
                  color: iconColor ?? (isDark ? Colors.white : baseColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
