import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 공통 애니메이션 설정
abstract class AppAnimations {
  /// 페이드 인
  static List<Effect> fadeIn({
    Duration duration = const Duration(milliseconds: 300),
    Duration delay = Duration.zero,
  }) =>
      [
        FadeEffect(duration: duration, delay: delay),
      ];

  /// 슬라이드 업 + 페이드
  static List<Effect> slideUp({
    Duration duration = const Duration(milliseconds: 400),
    Duration delay = Duration.zero,
    double beginOffset = 30,
  }) =>
      [
        FadeEffect(duration: duration, delay: delay),
        MoveEffect(
          duration: duration,
          delay: delay,
          begin: Offset(0, beginOffset),
          end: Offset.zero,
          curve: Curves.easeOutCubic,
        ),
      ];

  /// 슬라이드 다운 + 페이드
  static List<Effect> slideDown({
    Duration duration = const Duration(milliseconds: 400),
    Duration delay = Duration.zero,
    double beginOffset = -30,
  }) =>
      [
        FadeEffect(duration: duration, delay: delay),
        MoveEffect(
          duration: duration,
          delay: delay,
          begin: Offset(0, beginOffset),
          end: Offset.zero,
          curve: Curves.easeOutCubic,
        ),
      ];

  /// 스케일 인
  static List<Effect> scaleIn({
    Duration duration = const Duration(milliseconds: 300),
    Duration delay = Duration.zero,
    double begin = 0.95,
  }) =>
      [
        FadeEffect(duration: duration, delay: delay),
        ScaleEffect(
          duration: duration,
          delay: delay,
          begin: Offset(begin, begin),
          end: const Offset(1, 1),
          curve: Curves.easeOutCubic,
        ),
      ];

  /// 리스트 아이템 스태거 딜레이 계산
  static Duration staggerDelay(int index, {int maxDelay = 5}) {
    final effectiveIndex = index.clamp(0, maxDelay);
    return Duration(milliseconds: 50 * effectiveIndex);
  }

  /// 카드 등장 (스태거)
  static List<Effect> cardEntrance(int index) => [
        FadeEffect(
          duration: const Duration(milliseconds: 400),
          delay: staggerDelay(index),
        ),
        MoveEffect(
          duration: const Duration(milliseconds: 400),
          delay: staggerDelay(index),
          begin: const Offset(0, 20),
          end: Offset.zero,
          curve: Curves.easeOutCubic,
        ),
      ];

  /// 흔들기 (에러)
  static List<Effect> shake() => [
        ShakeEffect(
          duration: const Duration(milliseconds: 400),
          hz: 4,
          offset: const Offset(8, 0),
        ),
      ];

  /// 펄스 (주목)
  static List<Effect> pulse() => [
        ScaleEffect(
          duration: const Duration(milliseconds: 200),
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
        ),
        ScaleEffect(
          duration: const Duration(milliseconds: 200),
          delay: const Duration(milliseconds: 200),
          begin: const Offset(1.05, 1.05),
          end: const Offset(1, 1),
        ),
      ];
}

/// Widget 확장 - 쉬운 애니메이션 적용
extension AnimateWidgetExtensions on Widget {
  /// 스태거 리스트 아이템 애니메이션
  Widget animateListItem(int index) {
    return animate(effects: AppAnimations.cardEntrance(index));
  }

  /// 페이드 인 애니메이션
  Widget animateFadeIn({Duration? delay}) {
    return animate(
        effects: AppAnimations.fadeIn(delay: delay ?? Duration.zero));
  }

  /// 슬라이드 업 애니메이션
  Widget animateSlideUp({Duration? delay}) {
    return animate(
        effects: AppAnimations.slideUp(delay: delay ?? Duration.zero));
  }

  /// 슬라이드 다운 애니메이션
  Widget animateSlideDown({Duration? delay}) {
    return animate(
        effects: AppAnimations.slideDown(delay: delay ?? Duration.zero));
  }

  /// 스케일 인 애니메이션
  Widget animateScaleIn({Duration? delay}) {
    return animate(
        effects: AppAnimations.scaleIn(delay: delay ?? Duration.zero));
  }
}
