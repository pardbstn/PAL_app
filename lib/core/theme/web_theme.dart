import 'package:flutter/material.dart';
import 'package:flutter_pal_app/core/theme/app_tokens.dart';

/// 웹 전용 디자인 시스템
/// 프리미엄 느낌의 그림자, 애니메이션, 호버 효과 제공
class WebTheme {
  WebTheme._();

  // ============================================
  // 사이즈 상수
  // ============================================

  /// 사이드바 펼침 너비
  static const double sidebarWidth = 280.0;

  /// 사이드바 접힘 너비
  static const double sidebarCollapsedWidth = 72.0;

  /// 컨텐츠 최대 너비
  static const double contentMaxWidth = 1400.0;

  /// 카드 모서리 둥글기
  static const double cardBorderRadius = 16.0;

  /// 헤더 높이
  static const double headerHeight = 64.0;

  // ============================================
  // 트랜지션 설정
  // ============================================

  /// 기본 트랜지션 지속 시간
  static const Duration transitionDuration = Duration(milliseconds: 200);

  /// 사이드바 애니메이션 지속 시간
  static const Duration sidebarAnimationDuration = Duration(milliseconds: 300);

  /// 기본 트랜지션 커브
  static const Curve transitionCurve = Curves.easeInOut;

  // ============================================
  // 색상 - 라이트 모드
  // ============================================

  /// 사이드바 배경 (라이트)
  static const Color sidebarBgLight = Color(0xFFFFFFFF);

  /// 컨텐츠 영역 배경 (라이트)
  static const Color contentBgLight = Color(0xFFF4F4F4);

  /// 카드 배경 (라이트)
  static const Color cardBgLight = Color(0xFFFFFFFF);

  // ============================================
  // 색상 - 다크 모드
  // ============================================

  /// 사이드바 배경 (다크)
  static const Color sidebarBgDark = Color(0xFF0E0E0E);

  /// 컨텐츠 영역 배경 (다크)
  static const Color contentBgDark = Color(0xFF1A1A1A);

  /// 카드 배경 (다크)
  static const Color cardBgDark = Color(0xFF2A2A2A);

  // ============================================
  // 그림자 - 프리미엄 다층 그림자
  // ============================================

  /// 카드 기본 그림자 (미묘하고 깊이감 있는 다층 그림자)
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.01),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  /// 카드 호버 그림자 (더 진하고 떠오르는 느낌)
  static List<BoxShadow> get cardShadowHover => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
      ];

  /// 사이드바 그림자
  static List<BoxShadow> get sidebarShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 20,
          offset: const Offset(4, 0),
        ),
      ];

  // ============================================
  // 그라데이션
  // ============================================

  /// 프라이머리 그라데이션 (파랑 -> 초록)
  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [Color(0xFF0064FF), Color(0xFF00C471)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// 서브틀 그라데이션 (배경용)
  static LinearGradient get subtleGradient => LinearGradient(
        colors: [
          const Color(0xFF0064FF).withValues(alpha: 0.05),
          const Color(0xFF00C471).withValues(alpha: 0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // ============================================
  // 데코레이션 헬퍼
  // ============================================

  /// 카드 데코레이션 (다크모드 자동 대응)
  /// 통일된 카드 스타일: borderRadius 16, border 1px, boxShadow blur 8
  static BoxDecoration cardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? cardBgDark : cardBgLight,
      borderRadius: BorderRadius.circular(cardBorderRadius),
      border: Border.all(
        color: isDark ? AppColors.darkBorder : AppColors.gray100,
        width: 1,
      ),
      boxShadow: AppShadows.sm,
    );
  }

  /// 사이드바 데코레이션 (다크모드 자동 대응)
  static BoxDecoration sidebarDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? sidebarBgDark : sidebarBgLight,
      boxShadow: sidebarShadow,
    );
  }

  /// 컨텐츠 영역 배경색 (다크모드 자동 대응)
  static Color contentBgColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? contentBgDark : contentBgLight;
  }

  // ============================================
  // 호버 카드 위젯
  // ============================================

  /// 호버 가능한 카드 래퍼 (호버시 살짝 확대 + 그림자 강조)
  static Widget hoverCard({
    required BuildContext context,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
  }) {
    return _HoverCard(
      onTap: onTap,
      padding: padding,
      child: child,
    );
  }
}

/// 호버 효과가 있는 카드 위젯
/// 마우스 호버시 살짝 확대되고 그림자가 강조됨
class _HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const _HoverCard({
    required this.child,
    this.onTap,
    this.padding,
  });

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: WebTheme.transitionDuration,
          curve: WebTheme.transitionCurve,
          transform: _isHovered
              ? Matrix4.diagonal3Values(1.02, 1.02, 1.0)
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: isDark ? WebTheme.cardBgDark : WebTheme.cardBgLight,
            borderRadius: BorderRadius.circular(WebTheme.cardBorderRadius),
            boxShadow:
                _isHovered ? WebTheme.cardShadowHover : WebTheme.cardShadow,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
