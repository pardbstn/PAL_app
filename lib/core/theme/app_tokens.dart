import 'package:flutter/material.dart';

/// PAL 앱 디자인 토큰
/// 일관된 디자인 시스템을 위한 상수 정의

/// 간격(Spacing) 토큰
/// 레이아웃 및 컴포넌트 간 일관된 간격 유지
abstract class AppSpacing {
  /// 아주 작은 간격 (4px)
  static const double xs = 4;

  /// 작은 간격 (8px)
  static const double sm = 8;

  /// 중간 간격 (16px)
  static const double md = 16;

  /// 큰 간격 (24px)
  static const double lg = 24;

  /// 아주 큰 간격 (32px)
  static const double xl = 32;

  /// 가장 큰 간격 (48px)
  static const double xxl = 48;
}

/// 모서리 둥글기(Radius) 토큰
/// 버튼, 카드, 입력 필드 등에 사용
abstract class AppRadius {
  /// 작은 둥글기 (8px)
  static const double sm = 8;

  /// 중간 둥글기 (12px)
  static const double md = 12;

  /// 큰 둥글기 (16px)
  static const double lg = 16;

  /// 아주 큰 둥글기 (24px)
  static const double xl = 24;

  /// 완전한 둥글기 (999px) - 원형 버튼, 칩 등에 사용
  static const double full = 999;

  /// BorderRadius 헬퍼
  static BorderRadius get smBorderRadius => BorderRadius.circular(sm);
  static BorderRadius get mdBorderRadius => BorderRadius.circular(md);
  static BorderRadius get lgBorderRadius => BorderRadius.circular(lg);
  static BorderRadius get xlBorderRadius => BorderRadius.circular(xl);
  static BorderRadius get fullBorderRadius => BorderRadius.circular(full);
}

/// 그림자(Shadow) 토큰
/// 카드, 모달, 버튼 등의 elevation 효과
abstract class AppShadows {
  /// 작은 그림자 - 미세한 구분이 필요한 요소
  static List<BoxShadow> get sm => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  /// 중간 그림자 - 카드, 드롭다운 등
  static List<BoxShadow> get md => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  /// 큰 그림자 - 모달, 플로팅 버튼 등
  static List<BoxShadow> get lg => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];
}

/// 애니메이션 지속 시간(Duration) 토큰
/// 일관된 애니메이션 타이밍 제공
abstract class AppDurations {
  /// 빠른 애니메이션 (150ms) - 호버, 포커스 효과
  static const Duration fast = Duration(milliseconds: 150);

  /// 일반 애니메이션 (300ms) - 상태 전환, 페이드
  static const Duration normal = Duration(milliseconds: 300);

  /// 느린 애니메이션 (500ms) - 페이지 전환, 복잡한 애니메이션
  static const Duration slow = Duration(milliseconds: 500);
}
