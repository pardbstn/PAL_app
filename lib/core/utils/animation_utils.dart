import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 공통 애니메이션 설정
abstract class AppAnimations {
  /// 페이드 인
  static List<Effect> fadeIn({
    Duration duration = const Duration(milliseconds: 200),
    Duration delay = Duration.zero,
  }) =>
      [
        FadeEffect(duration: duration, delay: delay),
      ];

  /// 슬라이드 업 + 페이드
  static List<Effect> slideUp({
    Duration duration = const Duration(milliseconds: 250),
    Duration delay = Duration.zero,
    double beginOffset = 2,
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
    Duration duration = const Duration(milliseconds: 250),
    Duration delay = Duration.zero,
    double beginOffset = -2,
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
    Duration duration = const Duration(milliseconds: 200),
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
          duration: const Duration(milliseconds: 200),
          delay: staggerDelay(index),
        ),
        MoveEffect(
          duration: const Duration(milliseconds: 200),
          delay: staggerDelay(index),
          begin: const Offset(0, 2),
          end: Offset.zero,
          curve: Curves.easeInOutCubic,
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

  // ========================================
  // 프리미엄 애니메이션 효과
  // ========================================

  /// 프리미엄 등장 효과 (페이드 + 슬라이드 + 블러 체이닝)
  ///
  /// 가장 고급스러운 등장 효과. 요소가 흐릿하게 나타나며
  /// 부드럽게 위로 올라오면서 선명해집니다.
  ///
  /// 사용처: 대시보드 카드, 중요 콘텐츠, 프로필 섹션
  static List<Effect> premiumEntrance({
    Duration duration = const Duration(milliseconds: 200),
    Duration delay = Duration.zero,
    double slideOffset = 2,
    double blurAmount = 4,
  }) =>
      [
        // 블러에서 선명하게
        BlurEffect(
          duration: duration,
          delay: delay,
          begin: Offset(blurAmount, blurAmount),
          end: Offset.zero,
          curve: Curves.easeOutCubic,
        ),
        // 페이드 인
        FadeEffect(
          duration: duration,
          delay: delay,
          begin: 0,
          end: 1,
          curve: Curves.easeOut,
        ),
        // 아래에서 위로 슬라이드
        MoveEffect(
          duration: duration,
          delay: delay,
          begin: Offset(0, slideOffset),
          end: Offset.zero,
          curve: Curves.easeOutCubic,
        ),
      ];

  /// 프리미엄 카드 등장 (스태거 + 블러)
  ///
  /// 카드 리스트에 사용하는 고급 스태거 효과.
  /// 각 카드가 순차적으로 흐릿함에서 선명하게 나타납니다.
  ///
  /// 사용처: 대시보드 카드 그리드, 회원 목록
  static List<Effect> premiumCardEntrance(int index) {
    final stagger = staggerDelay(index, maxDelay: 8);
    return [
      BlurEffect(
        duration: const Duration(milliseconds: 200),
        delay: stagger,
        begin: const Offset(3, 3),
        end: Offset.zero,
        curve: Curves.easeOutCubic,
      ),
      FadeEffect(
        duration: const Duration(milliseconds: 200),
        delay: stagger,
        begin: 0,
        end: 1,
        curve: Curves.easeOut,
      ),
      MoveEffect(
        duration: const Duration(milliseconds: 200),
        delay: stagger,
        begin: const Offset(0, 2),
        end: Offset.zero,
        curve: Curves.easeOutCubic,
      ),
      ScaleEffect(
        duration: const Duration(milliseconds: 200),
        delay: stagger,
        begin: const Offset(0.98, 0.98),
        end: const Offset(1, 1),
        curve: Curves.easeOutCubic,
      ),
    ];
  }

  /// 섹션 등장 (더 드라마틱한 효과)
  ///
  /// 화면 전체 섹션이 등장할 때 사용.
  /// 더 큰 이동 거리와 긴 지속 시간으로 존재감을 드러냅니다.
  ///
  /// 사용처: 대시보드 섹션, 통계 영역, 차트 컨테이너
  static List<Effect> sectionEntrance({
    Duration delay = Duration.zero,
  }) =>
      [
        FadeEffect(
          duration: const Duration(milliseconds: 200),
          delay: delay,
          begin: 0,
          end: 1,
          curve: Curves.easeOut,
        ),
        MoveEffect(
          duration: const Duration(milliseconds: 200),
          delay: delay,
          begin: const Offset(0, 2),
          end: Offset.zero,
          curve: Curves.easeOutCubic,
        ),
        BlurEffect(
          duration: const Duration(milliseconds: 200),
          delay: delay,
          begin: const Offset(4, 4),
          end: Offset.zero,
          curve: Curves.easeOutCubic,
        ),
      ];

  /// 리스트 아이템 등장 (개선된 스태거)
  ///
  /// 긴 리스트에 최적화된 스태거 효과.
  /// maxStagger를 넘는 인덱스는 지연이 증가하지 않아 성능 최적화.
  ///
  /// 사용처: 운동 기록 목록, 회원 목록, PT 세션 리스트
  static List<Effect> listItemEntrance(int index, {int maxStagger = 8}) {
    final stagger = staggerDelay(index, maxDelay: maxStagger);
    return [
      FadeEffect(
        duration: const Duration(milliseconds: 200),
        delay: stagger,
        begin: 0,
        end: 1,
        curve: Curves.easeOut,
      ),
      MoveEffect(
        duration: const Duration(milliseconds: 200),
        delay: stagger,
        begin: const Offset(0, 2),
        end: Offset.zero,
        curve: Curves.easeOutCubic,
      ),
      // 미묘한 스케일 효과 추가
      ScaleEffect(
        duration: const Duration(milliseconds: 200),
        delay: stagger,
        begin: const Offset(0.99, 0.99),
        end: const Offset(1, 1),
        curve: Curves.easeOutCubic,
      ),
    ];
  }

  /// 프로필 등장 (스케일 + 페이드 + 블러)
  ///
  /// 프로필 이미지나 아바타에 최적화된 등장 효과.
  /// 중앙에서 확대되며 나타나는 임팩트 있는 애니메이션.
  ///
  /// 사용처: 프로필 사진, 트레이너/회원 아바타, 로고
  static List<Effect> profileEntrance() => [
        BlurEffect(
          duration: const Duration(milliseconds: 200),
          begin: const Offset(4, 4),
          end: Offset.zero,
          curve: Curves.easeOutCubic,
        ),
        FadeEffect(
          duration: const Duration(milliseconds: 200),
          begin: 0,
          end: 1,
          curve: Curves.easeOut,
        ),
        ScaleEffect(
          duration: const Duration(milliseconds: 200),
          begin: const Offset(0.92, 0.92),
          end: const Offset(1, 1),
          curve: Curves.easeOutCubic,
        ),
      ];

  /// 버튼 강조 (펄스 + 글로우 느낌)
  ///
  /// 사용자의 주목을 끌어야 하는 중요한 액션 버튼에 사용.
  /// 부드럽게 커졌다 작아지며 시선을 끕니다.
  ///
  /// 사용처: CTA 버튼, 저장 버튼, 중요한 액션
  static List<Effect> buttonAttention() => [
        ScaleEffect(
          duration: const Duration(milliseconds: 200),
          begin: const Offset(1, 1),
          end: const Offset(1.04, 1.04),
          curve: Curves.easeInOut,
        ),
        ScaleEffect(
          duration: const Duration(milliseconds: 200),
          delay: const Duration(milliseconds: 200),
          begin: const Offset(1.04, 1.04),
          end: const Offset(1, 1),
          curve: Curves.easeInOut,
        ),
        // 투명도 변화로 글로우 느낌
        FadeEffect(
          duration: const Duration(milliseconds: 200),
          begin: 1,
          end: 0.85,
          curve: Curves.easeInOut,
        ),
        FadeEffect(
          duration: const Duration(milliseconds: 200),
          delay: const Duration(milliseconds: 200),
          begin: 0.85,
          end: 1,
          curve: Curves.easeInOut,
        ),
      ];

  /// 에러 상태 (개선된 흔들기)
  ///
  /// 기존 shake보다 더 부드럽고 자연스러운 에러 피드백.
  /// 좌우로 흔들리며 사용자에게 문제를 알립니다.
  ///
  /// 사용처: 폼 검증 실패, 로그인 오류, 입력 오류
  static List<Effect> errorShake() => [
        ShakeEffect(
          duration: const Duration(milliseconds: 350),
          hz: 5,
          offset: const Offset(6, 0),
          curve: Curves.easeInOut,
        ),
        // 살짝 빨간 빛이 도는 효과 (TintEffect 대신 간단한 방법)
        FadeEffect(
          duration: const Duration(milliseconds: 250),
          begin: 1,
          end: 0.9,
          curve: Curves.easeOut,
        ),
        FadeEffect(
          duration: const Duration(milliseconds: 250),
          delay: const Duration(milliseconds: 250),
          begin: 0.9,
          end: 1,
          curve: Curves.easeIn,
        ),
      ];

  /// 성공 상태 (바운스)
  ///
  /// 성공적인 액션 완료 시 즐거운 피드백.
  /// 통통 튀는 듯한 애니메이션으로 긍정적인 느낌 전달.
  ///
  /// 사용처: 저장 완료, PT 기록 저장, 회원 추가 성공
  static List<Effect> successBounce() => [
        ScaleEffect(
          duration: const Duration(milliseconds: 150),
          begin: const Offset(1, 1),
          end: const Offset(1.08, 1.08),
          curve: Curves.easeOut,
        ),
        ScaleEffect(
          duration: const Duration(milliseconds: 200),
          delay: const Duration(milliseconds: 150),
          begin: const Offset(1.08, 1.08),
          end: const Offset(1, 1),
          curve: Curves.easeOutCubic,
        ),
      ];

  /// 로딩 펄스 (무한 반복용)
  ///
  /// 스켈레톤 로더나 진행 중인 작업 표시에 사용.
  /// 부드럽게 깜빡이며 로딩 상태임을 알립니다.
  ///
  /// 사용처: 스켈레톤 UI, 로딩 인디케이터, 새로고침 중
  ///
  /// 예시:
  /// ```dart
  /// Container().animate(
  ///   onComplete: (controller) => controller.repeat(),
  /// ).then(effects: AppAnimations.loadingPulse())
  /// ```
  static List<Effect> loadingPulse() => [
        FadeEffect(
          duration: const Duration(milliseconds: 600),
          begin: 0.5,
          end: 1.0,
          curve: Curves.easeInOut,
        ),
        FadeEffect(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 600),
          begin: 1.0,
          end: 0.5,
          curve: Curves.easeInOut,
        ),
      ];
}

/// Widget 확장 - 쉬운 애니메이션 적용
///
/// RepaintBoundary로 자동 래핑하여 Impeller 렌더링 최적화.
/// 각 애니메이션은 독립적인 레이어로 분리되어 성능 향상.
extension AnimateWidgetExtensions on Widget {
  /// 스태거 리스트 아이템 애니메이션
  Widget animateListItem(int index) {
    return RepaintBoundary(
      child: animate(effects: AppAnimations.cardEntrance(index)),
    );
  }

  /// 페이드 인 애니메이션
  Widget animateFadeIn({Duration? delay}) {
    return RepaintBoundary(
      child: animate(
          effects: AppAnimations.fadeIn(delay: delay ?? Duration.zero)),
    );
  }

  /// 슬라이드 업 애니메이션
  Widget animateSlideUp({Duration? delay}) {
    return RepaintBoundary(
      child: animate(
          effects: AppAnimations.slideUp(delay: delay ?? Duration.zero)),
    );
  }

  /// 슬라이드 다운 애니메이션
  Widget animateSlideDown({Duration? delay}) {
    return RepaintBoundary(
      child: animate(
          effects: AppAnimations.slideDown(delay: delay ?? Duration.zero)),
    );
  }

  /// 스케일 인 애니메이션
  Widget animateScaleIn({Duration? delay}) {
    return RepaintBoundary(
      child: animate(
          effects: AppAnimations.scaleIn(delay: delay ?? Duration.zero)),
    );
  }

  // ========================================
  // 프리미엄 애니메이션 확장 메서드
  // ========================================

  /// 프리미엄 등장 효과 적용
  ///
  /// 가장 고급스러운 등장 애니메이션. 블러 + 페이드 + 슬라이드 조합.
  ///
  /// 사용 예시:
  /// ```dart
  /// Container(
  ///   child: Text('Premium Content'),
  /// ).animatePremiumEntrance(delay: Duration(milliseconds: 100))
  /// ```
  Widget animatePremiumEntrance({Duration? delay}) {
    return RepaintBoundary(
      child: animate(
        effects: AppAnimations.premiumEntrance(
          delay: delay ?? Duration.zero,
        ),
      ),
    );
  }

  /// 섹션 등장 애니메이션 적용
  ///
  /// 화면 전체 섹션이나 큰 컨테이너에 사용하는 드라마틱한 효과.
  ///
  /// 사용 예시:
  /// ```dart
  /// Card(
  ///   child: DashboardSection(),
  /// ).animateSectionEntrance(delay: Duration(milliseconds: 200))
  /// ```
  Widget animateSectionEntrance({Duration? delay}) {
    return RepaintBoundary(
      child: animate(
        effects: AppAnimations.sectionEntrance(
          delay: delay ?? Duration.zero,
        ),
      ),
    );
  }

  /// 프로필 등장 애니메이션 적용
  ///
  /// 프로필 사진이나 아바타에 최적화된 중앙 확대 효과.
  ///
  /// 사용 예시:
  /// ```dart
  /// CircleAvatar(
  ///   backgroundImage: NetworkImage(profileUrl),
  /// ).animateProfileEntrance()
  /// ```
  Widget animateProfileEntrance() {
    return RepaintBoundary(
      child: animate(effects: AppAnimations.profileEntrance()),
    );
  }

  /// 리스트 아이템 스태거 애니메이션 적용
  ///
  /// 개선된 스태거 효과로 긴 리스트에 최적화.
  ///
  /// 사용 예시:
  /// ```dart
  /// ListView.builder(
  ///   itemBuilder: (context, index) {
  ///     return ListTile(
  ///       title: Text('Item $index'),
  ///     ).animateListItemStagger(index);
  ///   },
  /// )
  /// ```
  Widget animateListItemStagger(int index, {int maxStagger = 8}) {
    return RepaintBoundary(
      child: animate(
        effects: AppAnimations.listItemEntrance(
          index,
          maxStagger: maxStagger,
        ),
      ),
    );
  }

  /// 프리미엄 카드 스태거 애니메이션 적용
  ///
  /// 카드 그리드에 사용하는 고급 스태거 효과.
  ///
  /// 사용 예시:
  /// ```dart
  /// GridView.builder(
  ///   itemBuilder: (context, index) {
  ///     return DashboardCard().animatePremiumCard(index);
  ///   },
  /// )
  /// ```
  Widget animatePremiumCard(int index) {
    return RepaintBoundary(
      child: animate(effects: AppAnimations.premiumCardEntrance(index)),
    );
  }

  /// 버튼 강조 애니메이션 적용
  ///
  /// 중요한 액션 버튼에 주목을 끄는 펄스 효과.
  ///
  /// 사용 예시:
  /// ```dart
  /// ElevatedButton(
  ///   onPressed: () {},
  ///   child: Text('Save'),
  /// ).animateButtonAttention()
  /// ```
  Widget animateButtonAttention() {
    return RepaintBoundary(
      child: animate(effects: AppAnimations.buttonAttention()),
    );
  }

  /// 에러 상태 애니메이션 적용
  ///
  /// 입력 오류나 검증 실패 시 사용하는 흔들림 효과.
  ///
  /// 사용 예시:
  /// ```dart
  /// if (hasError) {
  ///   TextField().animateErrorShake();
  /// }
  /// ```
  Widget animateErrorShake() {
    return RepaintBoundary(
      child: animate(effects: AppAnimations.errorShake()),
    );
  }

  /// 성공 상태 애니메이션 적용
  ///
  /// 액션 완료 시 긍정적인 피드백을 주는 바운스 효과.
  ///
  /// 사용 예시:
  /// ```dart
  /// Icon(Icons.check_circle).animateSuccessBounce()
  /// ```
  Widget animateSuccessBounce() {
    return RepaintBoundary(
      child: animate(effects: AppAnimations.successBounce()),
    );
  }

  /// 로딩 펄스 애니메이션 적용 (무한 반복)
  ///
  /// 스켈레톤 로더나 로딩 인디케이터에 사용.
  ///
  /// 사용 예시:
  /// ```dart
  /// Container(
  ///   height: 200,
  ///   color: Colors.grey[300],
  /// ).animateLoadingPulse()
  /// ```
  Widget animateLoadingPulse() {
    return RepaintBoundary(
      child: animate(
        onComplete: (controller) => controller.repeat(),
        effects: AppAnimations.loadingPulse(),
      ),
    );
  }
}
