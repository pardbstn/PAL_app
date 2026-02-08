import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_pal_app/core/theme/app_tokens.dart';

/// Lottie 래퍼 위젯 (에셋 또는 네트워크)
/// 에셋이 없을 경우 graceful fallback (아이콘 + 텍스트)
class PalLottie extends StatelessWidget {
  const PalLottie({
    super.key,
    this.assetPath,
    this.networkUrl,
    this.width,
    this.height,
    this.repeat = true,
    this.fit = BoxFit.contain,
    this.fallbackIcon = Icons.animation,
    this.fallbackText = '애니메이션',
  });

  /// 에셋 경로 (예: assets/animations/loading.json)
  final String? assetPath;

  /// 네트워크 URL
  final String? networkUrl;

  /// 너비
  final double? width;

  /// 높이
  final double? height;

  /// 반복 재생 여부
  final bool repeat;

  /// 맞춤 방식
  final BoxFit fit;

  /// Fallback 아이콘
  final IconData fallbackIcon;

  /// Fallback 텍스트
  final String fallbackText;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 에셋이 있으면 에셋 로딩
    if (assetPath != null && assetPath!.isNotEmpty) {
      return _buildAssetLottie(isDark);
    }

    // 네트워크 URL이 있으면 네트워크 로딩
    if (networkUrl != null && networkUrl!.isNotEmpty) {
      return _buildNetworkLottie(isDark);
    }

    // 둘 다 없으면 fallback 표시
    return _buildFallback(isDark);
  }

  /// 에셋 Lottie 빌드
  Widget _buildAssetLottie(bool isDark) {
    return LottieBuilder.asset(
      assetPath!,
      width: width,
      height: height,
      fit: fit,
      repeat: repeat,
      errorBuilder: (context, error, stackTrace) {
        return _buildFallback(isDark);
      },
    );
  }

  /// 네트워크 Lottie 빌드
  Widget _buildNetworkLottie(bool isDark) {
    return LottieBuilder.network(
      networkUrl!,
      width: width,
      height: height,
      fit: fit,
      repeat: repeat,
      errorBuilder: (context, error, stackTrace) {
        return _buildFallback(isDark);
      },
    );
  }

  /// Fallback 위젯 (아이콘 + 텍스트)
  Widget _buildFallback(bool isDark) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            fallbackIcon,
            size: AppIconSize.xl,
            color: isDark ? AppColors.gray600 : AppColors.gray400,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            fallbackText,
            style: TextStyle(
              fontSize: AppTextStyle.bodySmall,
              color: isDark ? AppColors.gray500 : AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }
}
