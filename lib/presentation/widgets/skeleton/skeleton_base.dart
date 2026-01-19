import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// 다크모드 대응 Shimmer 컨테이너
class SkeletonContainer extends StatelessWidget {
  final Widget child;

  const SkeletonContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF424242) : const Color(0xFFE0E0E0),
      highlightColor: isDark ? const Color(0xFF616161) : const Color(0xFFF5F5F5),
      child: child,
    );
  }
}

/// 기본 스켈레톤 박스
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// 스켈레톤 원형 (아바타용)
class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// 스켈레톤 텍스트 라인
class SkeletonLine extends StatelessWidget {
  final double width;
  final double height;

  const SkeletonLine({
    super.key,
    this.width = double.infinity,
    this.height = 16,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(width: width, height: height, borderRadius: 4);
  }
}
