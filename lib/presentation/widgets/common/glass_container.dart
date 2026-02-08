import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_pal_app/core/theme/app_tokens.dart';

/// 글래스모피즘 컨테이너
/// BackdropFilter + 반투명 배경 + 미세한 보더
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.blurSigma = 10,
    this.padding,
    this.borderRadius,
    this.color,
  });

  /// 자식 위젯
  final Widget child;

  /// 블러 강도 (기본값: 10)
  final double blurSigma;

  /// 내부 패딩
  final EdgeInsets? padding;

  /// 테두리 둥글기
  final BorderRadius? borderRadius;

  /// 배경 색상 (null이면 테마에 따라 자동 설정)
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(AppRadius.lg);

    // 다크모드: 검은색 반투명, 라이트모드: 흰색 반투명
    final effectiveColor = color ??
        (isDark
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.7));

    return ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: effectiveColor,
            borderRadius: effectiveBorderRadius,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
