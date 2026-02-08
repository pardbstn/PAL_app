import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_pal_app/core/theme/app_tokens.dart';

/// 이미지 캐싱 래퍼 위젯
/// - 로딩: shimmer placeholder
/// - 에러: 기본 플레이스홀더 아이콘
/// - 성공: 페이드인 300ms
class PalCachedImage extends StatelessWidget {
  const PalCachedImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIcon = Icons.image_outlined,
  });

  /// 이미지 URL
  final String? imageUrl;

  /// 너비
  final double? width;

  /// 높이
  final double? height;

  /// 이미지 맞춤 방식
  final BoxFit fit;

  /// 테두리 둥글기
  final BorderRadius? borderRadius;

  /// 플레이스홀더 아이콘
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // URL이 없으면 플레이스홀더 표시
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder(isDark);
    }

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 300),
      placeholder: (context, url) => _buildShimmer(isDark),
      errorWidget: (context, url, error) => _buildPlaceholder(isDark),
    );

    // borderRadius 적용
    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  /// 쉬머 로딩 플레이스홀더
  Widget _buildShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.gray800 : AppColors.gray200,
      highlightColor: isDark ? AppColors.gray700 : AppColors.gray100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? AppColors.gray800 : AppColors.gray200,
          borderRadius: borderRadius,
        ),
      ),
    );
  }

  /// 에러/빈 플레이스홀더
  Widget _buildPlaceholder(bool isDark) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.gray800 : AppColors.gray100,
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Icon(
          placeholderIcon,
          size: AppIconSize.lg,
          color: isDark ? AppColors.gray600 : AppColors.gray400,
        ),
      ),
    );
  }
}
