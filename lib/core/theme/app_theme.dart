import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

/// PAL 앱 테마 설정 (Toss-inspired Design System)
/// Primary: #0064FF (Toss Blue - 신뢰/전문성)
/// Success/Secondary: #00C471 (Toss Green - 성장/긍정)
/// Warning/Tertiary: #FF8A00 (Toss Orange - 주의 알림)
/// Error: #F04452 (Toss Red - 오류/경고)
/// AI Accent: #8B5CF6 (Purple - AI 인사이트)
class AppTheme {
  AppTheme._();

  // 토스 스타일 디자인 컬러
  static const Color primary = Color(0xFF0064FF);
  static const Color secondary = Color(0xFF00C471);
  static const Color tertiary = Color(0xFFFF8A00);
  static const Color error = Color(0xFFF04452);
  static const Color aiAccent = Color(0xFF8B5CF6);

  // Pretendard 폰트 패밀리
  static const String fontFamily = 'Pretendard';

  // 라이트 테마
  static ThemeData get light => FlexThemeData.light(
        colors: const FlexSchemeColor(
          primary: primary,
          primaryContainer: Color(0xFFE8F0FE),
          secondary: secondary,
          secondaryContainer: Color(0xFFE5F9EF),
          tertiary: tertiary,
          tertiaryContainer: Color(0xFFFFF3E0),
          error: error,
          errorContainer: Color(0xFFFFEDEF),
        ),
        surfaceMode: FlexSurfaceMode.level,
        blendLevel: 0,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 0,
          blendOnColors: false,
          useMaterial3Typography: true,
          useM2StyleDividerInM3: true,
          alignedDropdown: true,
          useInputDecoratorThemeInDialogs: true,
          fabUseShape: true,
          interactionEffects: true,
          bottomNavigationBarElevation: 0,
          bottomNavigationBarOpacity: 1,
          navigationBarOpacity: 1,
          navigationBarMutedUnselectedIcon: true,
          navigationBarMutedUnselectedLabel: true,
          navigationRailOpacity: 1,
          navigationRailMutedUnselectedIcon: true,
          navigationRailMutedUnselectedLabel: true,
          inputDecoratorBorderType: FlexInputBorderType.underline,
          inputDecoratorRadius: 16,
          cardRadius: 20,
          dialogRadius: 24,
          appBarScrolledUnderElevation: 0,
          // 버튼 스타일 (Toss Design)
          elevatedButtonRadius: 16,
          elevatedButtonElevation: 0,
          filledButtonRadius: 16,
          outlinedButtonRadius: 16,
          textButtonRadius: 16,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        fontFamily: fontFamily,
      );

  // 다크 테마
  static ThemeData get dark {
    final base = FlexThemeData.dark(
        colors: const FlexSchemeColor(
          primary: Color(0xFF4D9AFF), // 다크모드용 밝은 파란색
          primaryContainer: Color(0xFF1A3A6B),
          secondary: Color(0xFF33D68A), // 다크모드용 밝은 초록색
          secondaryContainer: Color(0xFF0A3D25),
          tertiary: Color(0xFFFFB74D), // 다크모드용 밝은 주황색
          tertiaryContainer: Color(0xFF5C3300),
          error: Color(0xFFFF6B6B), // 다크모드용 밝은 빨간색
          errorContainer: Color(0xFF4D1515),
        ),
        surfaceMode: FlexSurfaceMode.level,
        blendLevel: 0,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 0,
          blendOnColors: false,
          useMaterial3Typography: true,
          useM2StyleDividerInM3: true,
          alignedDropdown: true,
          useInputDecoratorThemeInDialogs: true,
          fabUseShape: true,
          interactionEffects: true,
          bottomNavigationBarElevation: 0,
          bottomNavigationBarOpacity: 1,
          navigationBarOpacity: 1,
          navigationBarMutedUnselectedIcon: true,
          navigationBarMutedUnselectedLabel: true,
          navigationRailOpacity: 1,
          navigationRailMutedUnselectedIcon: true,
          navigationRailMutedUnselectedLabel: true,
          inputDecoratorBorderType: FlexInputBorderType.underline,
          inputDecoratorRadius: 16,
          cardRadius: 20,
          dialogRadius: 24,
          appBarScrolledUnderElevation: 0,
          // 버튼 스타일 (Toss Design)
          elevatedButtonRadius: 16,
          elevatedButtonElevation: 0,
          filledButtonRadius: 16,
          outlinedButtonRadius: 16,
          textButtonRadius: 16,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        fontFamily: fontFamily,
      );
    // 다크모드 입력 필드 텍스트 가시성 개선
    return base.copyWith(
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        hintStyle: const TextStyle(color: Color(0xFF8E8E93)),
        labelStyle: const TextStyle(color: Color(0xFFBDBDBD)),
      ),
    );
  }
}
