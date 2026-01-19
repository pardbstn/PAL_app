import 'package:flutter/material.dart';

/// 반응형 브레이크포인트 정의
/// - mobile: 768px 미만
/// - tablet: 768px ~ 1200px
/// - desktop: 1200px 이상
class Breakpoints {
  Breakpoints._();

  /// 모바일 최대 너비
  static const double mobile = 768;

  /// 태블릿 최대 너비
  static const double tablet = 1200;

  // desktop: 1200px 이상
}

/// 반응형 유틸리티 클래스
/// 화면 크기에 따른 디바이스 타입 판별 및 반응형 값 제공
class ResponsiveUtils {
  ResponsiveUtils._();

  /// 모바일 화면인지 확인 (768px 미만)
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < Breakpoints.mobile;

  /// 태블릿 화면인지 확인 (768px ~ 1200px)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= Breakpoints.mobile && width < Breakpoints.tablet;
  }

  /// 데스크톱 화면인지 확인 (1200px 이상)
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= Breakpoints.tablet;

  /// 웹 와이드 화면인지 확인 (768px 이상 - 태블릿 + 데스크톱)
  static bool isWebWide(BuildContext context) =>
      MediaQuery.of(context).size.width >= Breakpoints.mobile;

  /// 현재 디바이스 타입 반환
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < Breakpoints.mobile) return DeviceType.mobile;
    if (width < Breakpoints.tablet) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  /// 반응형 값 반환
  /// tablet이 null이면 desktop 값 사용
  static T responsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? desktop;
      case DeviceType.desktop:
        return desktop;
    }
  }

  /// 반응형 패딩 값 반환
  static EdgeInsets responsivePadding(BuildContext context) {
    return responsiveValue(
      context,
      mobile: const EdgeInsets.all(16),
      tablet: const EdgeInsets.all(24),
      desktop: const EdgeInsets.all(32),
    );
  }

  /// 반응형 수평 패딩 값 반환
  static EdgeInsets responsiveHorizontalPadding(BuildContext context) {
    return responsiveValue(
      context,
      mobile: const EdgeInsets.symmetric(horizontal: 16),
      tablet: const EdgeInsets.symmetric(horizontal: 24),
      desktop: const EdgeInsets.symmetric(horizontal: 32),
    );
  }

  /// 그리드 컬럼 수 반환
  static int gridColumnCount(BuildContext context) {
    return responsiveValue(
      context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
    );
  }
}

/// 디바이스 타입 열거형
enum DeviceType {
  /// 모바일 (768px 미만)
  mobile,

  /// 태블릿 (768px ~ 1200px)
  tablet,

  /// 데스크톱 (1200px 이상)
  desktop,
}

/// 반응형 빌더 위젯
/// LayoutBuilder를 사용하여 화면 크기에 따른 위젯 빌드
class ResponsiveBuilder extends StatelessWidget {
  /// 디바이스 타입에 따라 위젯을 빌드하는 함수
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = ResponsiveUtils.getDeviceType(context);
        return builder(context, deviceType);
      },
    );
  }
}

/// 웹/모바일 분기 위젯
/// 웹 와이드 화면(768px 이상)과 모바일 화면을 분기
class WebMobileSwitcher extends StatelessWidget {
  /// 웹 화면용 위젯 (768px 이상)
  final Widget webBuilder;

  /// 모바일 화면용 위젯 (768px 미만)
  final Widget mobileBuilder;

  const WebMobileSwitcher({
    super.key,
    required this.webBuilder,
    required this.mobileBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveUtils.isWebWide(context)) {
      return webBuilder;
    }
    return mobileBuilder;
  }
}

/// 반응형 그리드 뷰 래퍼
/// 화면 크기에 따라 컬럼 수가 자동 조절됨
class ResponsiveGridView extends StatelessWidget {
  /// 그리드 아이템 리스트
  final List<Widget> children;

  /// 아이템 간 간격
  final double spacing;

  /// 아이템 세로 간격 (null이면 spacing 사용)
  final double? runSpacing;

  /// 아이템 최소 너비
  final double minItemWidth;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing,
    this.minItemWidth = 300,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 최소 너비 기준으로 컬럼 수 계산
        final columnCount =
            (constraints.maxWidth / minItemWidth).floor().clamp(1, 4);
        final itemWidth =
            (constraints.maxWidth - (spacing * (columnCount - 1))) /
                columnCount;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing ?? spacing,
          children: children
              .map(
                (child) => SizedBox(
                  width: itemWidth,
                  child: child,
                ),
              )
              .toList(),
        );
      },
    );
  }
}
