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

/// 아이콘 크기(Icon Size) 토큰
/// 일관된 아이콘 크기 제공
abstract class AppIconSize {
  /// 아주 작은 아이콘 (16px) - 인라인 표시
  static const double xs = 16;

  /// 작은 아이콘 (20px) - 버튼 내부, 리스트 아이템
  static const double sm = 20;

  /// 중간 아이콘 (24px) - 기본 크기
  static const double md = 24;

  /// 큰 아이콘 (32px) - 강조 표시
  static const double lg = 32;

  /// 아주 큰 아이콘 (48px) - 빈 상태, 히어로
  static const double xl = 48;

  /// 가장 큰 아이콘 (64px) - 온보딩, 대형 표시
  static const double xxl = 64;
}

/// 컨테이너 너비(Container Width) 토큰
/// 반응형 레이아웃을 위한 최대 너비
abstract class AppContainerWidth {
  /// 좁은 컨테이너 (480px) - 폼, 다이얼로그
  static const double narrow = 480;

  /// 중간 컨테이너 (720px) - 상세 페이지
  static const double medium = 720;

  /// 넓은 컨테이너 (1024px) - 리스트 페이지
  static const double wide = 1024;

  /// 최대 컨테이너 (1280px) - 대시보드
  static const double max = 1280;
}

/// 텍스트 스타일 프리셋
/// TextTheme과 함께 사용하는 폰트 크기 및 줄 간격
abstract class AppTextStyle {
  /// 대형 타이틀 (28px) - 페이지 헤딩
  static const double titleLarge = 28;

  /// 중형 타이틀 (22px) - 섹션 헤딩
  static const double titleMedium = 22;

  /// 소형 타이틀 (18px) - 카드 헤딩
  static const double titleSmall = 18;

  /// 대형 본문 (16px) - 강조 텍스트
  static const double bodyLarge = 16;

  /// 중형 본문 (14px) - 기본 텍스트
  static const double bodyMedium = 14;

  /// 소형 본문 (12px) - 보조 텍스트
  static const double bodySmall = 12;

  /// 캡션 (11px) - 라벨, 힌트
  static const double caption = 11;

  /// 줄 간격 비율
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;
}

/// 색상 토큰 (디자인 시스템 표준 색상)
/// Theme 색상과 별도로 직접 사용할 수 있는 상수
abstract class AppColors {
  // Primary 계열
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1D4ED8);

  // Secondary (Success) 계열
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryDark = Color(0xFF059669);

  // Tertiary (Warning) 계열
  static const Color tertiary = Color(0xFFF59E0B);
  static const Color tertiaryLight = Color(0xFFFBBF24);
  static const Color tertiaryDark = Color(0xFFD97706);

  // Error 계열
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);

  // Neutral (Gray) 계열 - Light Mode
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // Dark Mode 전용
  static const Color darkSurface = Color(0xFF1E2A4A);
  static const Color darkBackground = Color(0xFF1A2140);
  static const Color darkBorder = Color(0xFF2E3B5E);
}
