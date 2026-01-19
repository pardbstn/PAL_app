import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

/// 아바타 크기 열거형
enum AppAvatarSize {
  xs(24),
  sm(32),
  md(40),
  lg(56),
  xl(80);

  const AppAvatarSize(this.dimension);
  final double dimension;
}

/// PAL 앱의 공통 아바타 위젯
///
/// 프로필 이미지 또는 이니셜을 원형으로 표시합니다.
/// 온라인 상태 표시 기능을 포함합니다.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = AppAvatarSize.md,
    this.backgroundColor,
    this.showOnlineIndicator = false,
    this.isOnline = false,
  });

  /// 프로필 이미지 URL (null이면 이니셜 표시)
  final String? imageUrl;

  /// 사용자 이름 (이니셜 생성 및 배경색 결정에 사용)
  final String? name;

  /// 아바타 크기
  final AppAvatarSize size;

  /// 배경색 (null이면 이름 기반으로 자동 생성)
  final Color? backgroundColor;

  /// 온라인 인디케이터 표시 여부
  final bool showOnlineIndicator;

  /// 온라인 상태
  final bool isOnline;

  /// 이름에서 이니셜 추출
  String _getInitials() {
    if (name == null || name!.trim().isEmpty) {
      return '';
    }

    final trimmedName = name!.trim();
    final parts = trimmedName.split(RegExp(r'\s+'));

    if (parts.length >= 2) {
      // 이름과 성의 첫 글자
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else {
      // 단일 단어면 첫 글자만
      return parts[0][0].toUpperCase();
    }
  }

  /// 이름 기반으로 일관된 배경색 생성
  Color _generateColorFromName(BuildContext context) {
    if (name == null || name!.trim().isEmpty) {
      return Colors.grey[300]!;
    }

    // 이름의 hashCode를 사용하여 일관된 색상 생성
    final hash = name!.hashCode.abs();

    // 파스텔톤의 색상 팔레트
    final colors = [
      const Color(0xFF5C6BC0), // 인디고
      const Color(0xFF26A69A), // 틸
      const Color(0xFF66BB6A), // 그린
      const Color(0xFFFFCA28), // 앰버
      const Color(0xFFFF7043), // 딥 오렌지
      const Color(0xFFEC407A), // 핑크
      const Color(0xFFAB47BC), // 퍼플
      const Color(0xFF42A5F5), // 블루
      const Color(0xFF78909C), // 블루 그레이
      const Color(0xFF8D6E63), // 브라운
    ];

    return colors[hash % colors.length];
  }

  /// 배경색에 따른 텍스트 색상 결정
  Color _getTextColor(Color bgColor) {
    // 밝기 계산 (YIQ 공식 사용)
    final r = (bgColor.r * 255).round();
    final g = (bgColor.g * 255).round();
    final b = (bgColor.b * 255).round();
    final brightness = (r * 299 + g * 587 + b * 114) / 1000;
    return brightness > 128 ? Colors.black87 : Colors.white;
  }

  /// 온라인 인디케이터 크기 (아바타 크기의 12%)
  double get _indicatorSize => size.dimension * 0.12;

  @override
  Widget build(BuildContext context) {
    final dimension = size.dimension;
    final effectiveBackgroundColor = backgroundColor ?? _generateColorFromName(context);

    return SizedBox(
      width: dimension,
      height: dimension,
      child: Stack(
        children: [
          // 메인 아바타
          ClipOval(
            child: _buildAvatarContent(effectiveBackgroundColor),
          ),
          // 온라인 인디케이터
          if (showOnlineIndicator)
            Positioned(
              right: 0,
              bottom: 0,
              child: _buildOnlineIndicator(),
            ),
        ],
      ),
    );
  }

  /// 아바타 내용 빌드 (이미지 또는 이니셜)
  Widget _buildAvatarContent(Color bgColor) {
    final dimension = size.dimension;

    // 이미지 URL이 있으면 CachedNetworkImage 사용
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        width: dimension,
        height: dimension,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildShimmerPlaceholder(),
        errorWidget: (context, url, error) => _buildInitialsAvatar(bgColor),
      );
    }

    // 이미지가 없으면 이니셜 아바타
    return _buildInitialsAvatar(bgColor);
  }

  /// Shimmer 로딩 플레이스홀더
  Widget _buildShimmerPlaceholder() {
    final dimension = size.dimension;

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: dimension,
        height: dimension,
        color: Colors.white,
      ),
    );
  }

  /// 이니셜 아바타
  Widget _buildInitialsAvatar(Color bgColor) {
    final dimension = size.dimension;
    final initials = _getInitials();
    final textColor = _getTextColor(bgColor);

    // 폰트 크기: 아바타 크기의 40%
    final fontSize = dimension * 0.4;

    return Container(
      width: dimension,
      height: dimension,
      color: bgColor,
      alignment: Alignment.center,
      child: initials.isNotEmpty
          ? Text(
              initials,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            )
          : Icon(
              Icons.person,
              size: fontSize,
              color: textColor,
            ),
    );
  }

  /// 온라인 상태 인디케이터
  Widget _buildOnlineIndicator() {
    final indicatorSize = _indicatorSize.clamp(6.0, 16.0);
    final borderWidth = (indicatorSize * 0.2).clamp(1.5, 3.0);

    return Container(
      width: indicatorSize,
      height: indicatorSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOnline ? const Color(0xFF10B981) : Colors.grey[400],
        border: Border.all(
          color: Colors.white,
          width: borderWidth,
        ),
      ),
    );
  }
}
