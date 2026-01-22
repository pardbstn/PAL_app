import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';

/// 카드 애니메이션 유틸리티
///
/// 카드와 리스트 아이템에 일관된 등장 애니메이션을 적용하기 위한 유틸리티 클래스.
/// flutter_animate를 사용하여 fadeIn + slideY 효과를 제공합니다.
class CardAnimations {
  CardAnimations._();

  /// 기본 등장 애니메이션 duration
  static const Duration defaultDuration = Duration(milliseconds: 300);

  /// 리스트 아이템 stagger delay
  static const Duration staggerDelay = Duration(milliseconds: 50);

  /// 카드 등장 애니메이션 적용
  ///
  /// [child] 애니메이션을 적용할 위젯
  /// [index] 리스트에서의 인덱스 (stagger 효과용)
  /// [duration] 애니메이션 지속 시간
  /// [curve] 애니메이션 커브
  static Widget fadeSlideIn(
    Widget child, {
    int index = 0,
    Duration? duration,
    Curve curve = Curves.easeOut,
  }) {
    final effectiveDuration = duration ?? defaultDuration;
    return child
        .animate(delay: Duration(milliseconds: index * 50))
        .fadeIn(duration: effectiveDuration)
        .slideY(
          begin: 0.1,
          end: 0,
          duration: effectiveDuration,
          curve: curve,
        );
  }

  /// 좌측에서 슬라이드인 애니메이션
  ///
  /// [child] 애니메이션을 적용할 위젯
  /// [index] 리스트에서의 인덱스 (stagger 효과용)
  static Widget fadeSlideInFromLeft(Widget child, {int index = 0}) {
    return child
        .animate(delay: Duration(milliseconds: index * 50))
        .fadeIn(duration: defaultDuration)
        .slideX(
          begin: -0.1,
          end: 0,
          duration: defaultDuration,
          curve: Curves.easeOut,
        );
  }

  /// 우측에서 슬라이드인 애니메이션
  ///
  /// [child] 애니메이션을 적용할 위젯
  /// [index] 리스트에서의 인덱스 (stagger 효과용)
  static Widget fadeSlideInFromRight(Widget child, {int index = 0}) {
    return child
        .animate(delay: Duration(milliseconds: index * 50))
        .fadeIn(duration: defaultDuration)
        .slideX(
          begin: 0.1,
          end: 0,
          duration: defaultDuration,
          curve: Curves.easeOut,
        );
  }

  /// 스케일 업 애니메이션 (팝인 효과)
  ///
  /// [child] 애니메이션을 적용할 위젯
  /// [index] 리스트에서의 인덱스 (stagger 효과용)
  static Widget scaleIn(Widget child, {int index = 0}) {
    return child
        .animate(delay: Duration(milliseconds: index * 50))
        .fadeIn(duration: defaultDuration)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.0, 1.0),
          duration: defaultDuration,
          curve: Curves.easeOutBack,
        );
  }
}

/// flutter_staggered_animations를 활용한 리스트 래퍼
///
/// ListView나 GridView의 아이템들에 순차적인 등장 애니메이션을 적용합니다.
/// 사용 예:
/// ```dart
/// AnimatedListWrapper(
///   child: ListView.builder(
///     itemCount: items.length,
///     itemBuilder: (context, index) {
///       return AnimatedListWrapper.item(
///         index: index,
///         child: YourListItem(),
///       );
///     },
///   ),
/// )
/// ```
class AnimatedListWrapper extends StatelessWidget {
  const AnimatedListWrapper({
    super.key,
    required this.child,
  });

  /// 래핑할 리스트 위젯
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: child,
    );
  }

  /// 리스트 아이템에 애니메이션 적용
  ///
  /// [index] 리스트에서의 인덱스
  /// [child] 애니메이션을 적용할 아이템 위젯
  /// [duration] 애니메이션 지속 시간
  /// [horizontalOffset] 수평 시작 오프셋 (좌측에서 등장 효과)
  /// [verticalOffset] 수직 시작 오프셋 (아래에서 등장 효과)
  static Widget item({
    required int index,
    required Widget child,
    Duration duration = const Duration(milliseconds: 375),
    double horizontalOffset = 0.0,
    double verticalOffset = 50.0,
  }) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: duration,
      child: SlideAnimation(
        horizontalOffset: horizontalOffset,
        verticalOffset: verticalOffset,
        child: FadeInAnimation(
          child: child,
        ),
      ),
    );
  }

  /// 그리드 아이템에 애니메이션 적용
  ///
  /// [index] 그리드에서의 인덱스
  /// [columnCount] 그리드의 열 개수
  /// [child] 애니메이션을 적용할 아이템 위젯
  /// [duration] 애니메이션 지속 시간
  static Widget gridItem({
    required int index,
    required int columnCount,
    required Widget child,
    Duration duration = const Duration(milliseconds: 375),
  }) {
    return AnimationConfiguration.staggeredGrid(
      position: index,
      columnCount: columnCount,
      duration: duration,
      child: ScaleAnimation(
        child: FadeInAnimation(
          child: child,
        ),
      ),
    );
  }
}

/// shimmer 활용한 카드 스켈레톤
///
/// 로딩 상태를 표시하기 위한 통일된 스켈레톤 위젯입니다.
/// 다크모드를 자동으로 지원합니다.
class CardSkeleton extends StatelessWidget {
  const CardSkeleton({
    super.key,
    this.height,
    this.width,
    this.borderRadius = 16.0,
    this.padding,
    this.child,
  });

  /// 스켈레톤 높이 (null이면 child에 맞춤)
  final double? height;

  /// 스켈레톤 너비 (null이면 부모에 맞춤)
  final double? width;

  /// 모서리 둥글기 (기본값: 16.0)
  final double borderRadius;

  /// 내부 패딩
  final EdgeInsets? padding;

  /// 내부에 표시할 커스텀 스켈레톤 콘텐츠
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF424242) : const Color(0xFFE0E0E0),
      highlightColor:
          isDark ? const Color(0xFF616161) : const Color(0xFFF5F5F5),
      child: Container(
        height: height,
        width: width,
        padding: padding,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: child,
      ),
    );
  }

  /// 리스트 아이템용 스켈레톤 생성
  ///
  /// 아바타 + 텍스트 라인 형태의 기본적인 리스트 아이템 스켈레톤
  factory CardSkeleton.listItem({
    Key? key,
    double height = 80,
  }) {
    return CardSkeleton(
      key: key,
      height: height,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 아바타 스켈레톤
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          // 텍스트 라인 스켈레톤
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 카드용 스켈레톤 생성
  ///
  /// 제목 + 콘텐츠 영역 형태의 카드 스켈레톤
  factory CardSkeleton.card({
    Key? key,
    double height = 150,
  }) {
    return CardSkeleton(
      key: key,
      height: height,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 스켈레톤
          Container(
            height: 20,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          // 콘텐츠 영역 스켈레톤
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 통계 카드용 스켈레톤 생성
  ///
  /// 아이콘 + 숫자 + 라벨 형태의 통계 카드 스켈레톤
  factory CardSkeleton.stat({
    Key? key,
    double height = 100,
  }) {
    return CardSkeleton(
      key: key,
      height: height,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아이콘 스켈레톤
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const Spacer(),
          // 숫자 스켈레톤
          Container(
            height: 24,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          // 라벨 스켈레톤
          Container(
            height: 14,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

/// 여러 개의 카드 스켈레톤을 표시하는 리스트
///
/// 로딩 상태에서 여러 개의 스켈레톤을 한번에 표시할 때 사용
class CardSkeletonList extends StatelessWidget {
  const CardSkeletonList({
    super.key,
    this.itemCount = 3,
    this.itemHeight = 80,
    this.separatorHeight = 12,
    this.padding,
    this.skeletonBuilder,
  });

  /// 표시할 스켈레톤 개수
  final int itemCount;

  /// 각 스켈레톤의 높이
  final double itemHeight;

  /// 스켈레톤 간 간격
  final double separatorHeight;

  /// 전체 리스트 패딩
  final EdgeInsets? padding;

  /// 커스텀 스켈레톤 빌더 (null이면 기본 CardSkeleton.listItem 사용)
  final Widget Function(int index)? skeletonBuilder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        children: List.generate(itemCount, (index) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < itemCount - 1 ? separatorHeight : 0,
            ),
            child: skeletonBuilder?.call(index) ??
                CardSkeleton.listItem(height: itemHeight),
          );
        }),
      ),
    );
  }
}
