import 'package:flutter/material.dart';

/// 웹 반응형 레이아웃 브레이크포인트
class WebBreakpoints {
  WebBreakpoints._();

  /// 모바일: < 600px
  static const double mobile = 600;

  /// 태블릿: 600px - 900px
  static const double tablet = 900;

  /// 데스크탑: 900px - 1200px
  static const double desktop = 1200;

  /// 와이드 데스크탑: >= 1200px
  static const double wideDesktop = 1200;
}

/// 반응형 레이아웃 타입
enum LayoutType { mobile, tablet, desktop, wideDesktop }

/// 현재 레이아웃 타입 결정
LayoutType getLayoutType(double width) {
  if (width < WebBreakpoints.mobile) return LayoutType.mobile;
  if (width < WebBreakpoints.tablet) return LayoutType.tablet;
  if (width < WebBreakpoints.desktop) return LayoutType.desktop;
  return LayoutType.wideDesktop;
}

/// 반응형 그리드 컬럼 수 결정
int getGridColumnCount(double width) {
  if (width < WebBreakpoints.mobile) return 1;
  if (width < WebBreakpoints.tablet) return 2;
  if (width < WebBreakpoints.desktop) return 3;
  return 4;
}

/// 반응형 레이아웃 빌더 위젯
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.wideDesktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? wideDesktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= WebBreakpoints.wideDesktop) {
          return wideDesktop ?? desktop ?? tablet ?? mobile;
        }
        if (width >= WebBreakpoints.desktop) {
          return desktop ?? tablet ?? mobile;
        }
        if (width >= WebBreakpoints.tablet) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}

/// 반응형 그리드 위젯
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.wideDesktopColumns = 4,
    this.childAspectRatio,
    this.mainAxisExtent,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final int wideDesktopColumns;
  final double? childAspectRatio;
  final double? mainAxisExtent;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final layoutType = getLayoutType(width);

        final columns = switch (layoutType) {
          LayoutType.mobile => mobileColumns,
          LayoutType.tablet => tabletColumns,
          LayoutType.desktop => desktopColumns,
          LayoutType.wideDesktop => wideDesktopColumns,
        };

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: childAspectRatio ?? 1.0,
            mainAxisExtent: mainAxisExtent,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

/// 반응형 Row/Column 위젯 - 좁으면 Column, 넓으면 Row
class ResponsiveRowColumn extends StatelessWidget {
  const ResponsiveRowColumn({
    super.key,
    required this.children,
    this.breakpoint = WebBreakpoints.tablet,
    this.rowMainAxisAlignment = MainAxisAlignment.start,
    this.rowCrossAxisAlignment = CrossAxisAlignment.start,
    this.columnMainAxisAlignment = MainAxisAlignment.start,
    this.columnCrossAxisAlignment = CrossAxisAlignment.stretch,
    this.rowSpacing = 16,
    this.columnSpacing = 16,
  });

  final List<Widget> children;
  final double breakpoint;
  final MainAxisAlignment rowMainAxisAlignment;
  final CrossAxisAlignment rowCrossAxisAlignment;
  final MainAxisAlignment columnMainAxisAlignment;
  final CrossAxisAlignment columnCrossAxisAlignment;
  final double rowSpacing;
  final double columnSpacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= breakpoint) {
          return Row(
            mainAxisAlignment: rowMainAxisAlignment,
            crossAxisAlignment: rowCrossAxisAlignment,
            children: _insertSpacing(children, rowSpacing, isRow: true),
          );
        }
        return Column(
          mainAxisAlignment: columnMainAxisAlignment,
          crossAxisAlignment: columnCrossAxisAlignment,
          children: _insertSpacing(children, columnSpacing, isRow: false),
        );
      },
    );
  }

  List<Widget> _insertSpacing(List<Widget> widgets, double spacing, {required bool isRow}) {
    if (widgets.isEmpty) return widgets;

    final result = <Widget>[];
    for (var i = 0; i < widgets.length; i++) {
      result.add(widgets[i]);
      if (i < widgets.length - 1) {
        result.add(isRow ? SizedBox(width: spacing) : SizedBox(height: spacing));
      }
    }
    return result;
  }
}

/// 반응형 패딩 위젯
class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobilePadding = const EdgeInsets.all(16),
    this.tabletPadding = const EdgeInsets.all(24),
    this.desktopPadding = const EdgeInsets.all(32),
    this.wideDesktopPadding = const EdgeInsets.all(48),
  });

  final Widget child;
  final EdgeInsets mobilePadding;
  final EdgeInsets tabletPadding;
  final EdgeInsets desktopPadding;
  final EdgeInsets wideDesktopPadding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layoutType = getLayoutType(constraints.maxWidth);

        final padding = switch (layoutType) {
          LayoutType.mobile => mobilePadding,
          LayoutType.tablet => tabletPadding,
          LayoutType.desktop => desktopPadding,
          LayoutType.wideDesktop => wideDesktopPadding,
        };

        return Padding(padding: padding, child: child);
      },
    );
  }
}

/// 레이아웃 타입에 따른 값 반환 헬퍼
T responsiveValue<T>(
  BuildContext context, {
  required T mobile,
  T? tablet,
  T? desktop,
  T? wideDesktop,
}) {
  final width = MediaQuery.of(context).size.width;
  final layoutType = getLayoutType(width);

  return switch (layoutType) {
    LayoutType.mobile => mobile,
    LayoutType.tablet => tablet ?? mobile,
    LayoutType.desktop => desktop ?? tablet ?? mobile,
    LayoutType.wideDesktop => wideDesktop ?? desktop ?? tablet ?? mobile,
  };
}
