import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

/// PAL 앱 테마 설정
/// Primary: #2563EB (파란색)
/// Success/Secondary: #10B981 (초록색)
/// Warning/Tertiary: #F59E0B (주황색)
/// Error: #EF4444 (빨간색)
class AppTheme {
  AppTheme._();

  // 디자인 시스템 컬러
  static const Color primary = Color(0xFF2563EB);
  static const Color secondary = Color(0xFF10B981);
  static const Color tertiary = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Pretendard 폰트 패밀리
  static const String fontFamily = 'Pretendard';

  // 라이트 테마
  static ThemeData get light => FlexThemeData.light(
        colors: const FlexSchemeColor(
          primary: primary,
          primaryContainer: Color(0xFFDBEAFE),
          secondary: secondary,
          secondaryContainer: Color(0xFFD1FAE5),
          tertiary: tertiary,
          tertiaryContainer: Color(0xFFFEF3C7),
          error: error,
          errorContainer: Color(0xFFFEE2E2),
        ),
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 7,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 10,
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
          inputDecoratorBorderType: FlexInputBorderType.outline,
          inputDecoratorRadius: 12,
          cardRadius: 16,
          dialogRadius: 20,
          appBarScrolledUnderElevation: 1,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        fontFamily: fontFamily,
      );

  // 다크 테마
  static ThemeData get dark => FlexThemeData.dark(
        colors: const FlexSchemeColor(
          primary: Color(0xFF60A5FA), // 다크모드용 밝은 파란색
          primaryContainer: Color(0xFF1E40AF),
          secondary: Color(0xFF34D399), // 다크모드용 밝은 초록색
          secondaryContainer: Color(0xFF065F46),
          tertiary: Color(0xFFFBBF24), // 다크모드용 밝은 주황색
          tertiaryContainer: Color(0xFF92400E),
          error: Color(0xFFF87171), // 다크모드용 밝은 빨간색
          errorContainer: Color(0xFF991B1B),
        ),
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 13,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
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
          inputDecoratorBorderType: FlexInputBorderType.outline,
          inputDecoratorRadius: 12,
          cardRadius: 16,
          dialogRadius: 20,
          appBarScrolledUnderElevation: 3,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        fontFamily: fontFamily,
      );
}
