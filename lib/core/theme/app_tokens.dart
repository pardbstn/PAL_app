import 'package:flutter/material.dart';

/// PAL 앱 디자인 토큰 (Toss-inspired Design System)
/// 일관된 디자인 시스템을 위한 상수 정의

/// 간격(Spacing) 토큰 - 4px 기반 스케일
abstract class AppSpacing {
  /// space-1 (4px) - 아이콘-텍스트 간격, 뱃지 내부
  static const double xs = 4;

  /// space-2 (8px) - 인라인 요소 간격
  static const double sm = 8;

  /// space-3 (12px) - 컴팩트 패딩 (칩, 태그)
  static const double compact = 12;

  /// space-4 (16px) - 기본 패딩 (버튼, 입력 필드)
  static const double md = 16;

  /// space-5 (20px) - 카드 내부 패딩
  static const double lg = 20;

  /// space-6 (24px) - 섹션 간 간격
  static const double xl = 24;

  /// space-8 (32px) - 페이지 내 대구간 간격
  static const double xxl = 32;

  /// space-10 (40px) - 페이지 상단 여백
  static const double xxxl = 40;

  /// 화면 패딩 (20px)
  static const double screenPadding = 20;

  /// 섹션 간격 (24px)
  static const double sectionGap = 24;

  /// 카드 내부 패딩 (20px)
  static const double cardContentPadding = 20;
}

/// 모서리 둥글기(Radius) 토큰
abstract class AppRadius {
  /// 작은 둥글기 (8px) - 뱃지, 태그, 작은 칩
  static const double sm = 8;

  /// 중간 둥글기 (16px) - 버튼, 입력 필드, 작은 카드
  static const double md = 16;

  /// 큰 둥글기 (20px) - 메인 카드, 패널
  static const double lg = 20;

  /// 아주 큰 둥글기 (24px) - 바텀시트, 큰 모달
  static const double xl = 24;

  /// 완전한 둥글기 (9999px) - 아바타, 원형 버튼
  static const double full = 9999;

  /// BorderRadius 헬퍼
  static BorderRadius get smBorderRadius => BorderRadius.circular(sm);
  static BorderRadius get mdBorderRadius => BorderRadius.circular(md);
  static BorderRadius get lgBorderRadius => BorderRadius.circular(lg);
  static BorderRadius get xlBorderRadius => BorderRadius.circular(xl);
  static BorderRadius get fullBorderRadius => BorderRadius.circular(full);
}

/// 그림자(Shadow) 토큰 - Floating Shadow Style
/// 반응형 깊이: 오프셋 없이 블러만으로 "떠있는" 느낌 구현
abstract class AppShadows {
  /// 작은 그림자 - 미세한 구분이 필요한 요소 (subtle float)
  static List<BoxShadow> get sm => [
        const BoxShadow(
          color: Color(0x0A000000),
          blurRadius: 12,
          offset: Offset(0, 0),
        ),
      ];

  /// 중간 그림자 - 카드, 드롭다운 등 (standard float)
  static List<BoxShadow> get md => [
        const BoxShadow(
          color: Color(0x10000000),
          blurRadius: 24,
          offset: Offset(0, 0),
        ),
      ];

  /// 큰 그림자 - 모달, 플로팅 버튼 등 (elevated float)
  static List<BoxShadow> get lg => [
        const BoxShadow(
          color: Color(0x14000000),
          blurRadius: 32,
          offset: Offset(0, 2),
        ),
      ];

  /// Primary 강조 그림자
  static List<BoxShadow> get accent => [
        const BoxShadow(
          color: Color(0x200064FF),
          blurRadius: 20,
          offset: Offset(0, 0),
        ),
      ];

  /// AI 강조 그림자
  static List<BoxShadow> get ai => [
        const BoxShadow(
          color: Color(0x408B5CF6),
          blurRadius: 14,
          offset: Offset(0, 4),
        ),
      ];

  /// 네비게이션 바 그림자 (테두리로 대체)
  static List<BoxShadow> get navBar => [];
}

/// 애니메이션 지속 시간(Duration) 토큰
abstract class AppDurations {
  /// 마이크로 인터랙션 (150ms) - 버튼 탭, 토글, 체크박스
  static const Duration fast = Duration(milliseconds: 150);

  /// 화면 전환 (300ms) - 페이지 이동, 모달 열기
  static const Duration normal = Duration(milliseconds: 300);

  /// 데이터 진입 (400ms) - 차트 렌더링, 숫자 카운트업
  static const Duration slow = Duration(milliseconds: 400);

  /// 스켈레톤 Shimmer (2000ms)
  static const Duration shimmer = Duration(milliseconds: 2000);

  /// 성과 축하 (800ms) - 목표 달성 시 confetti/pulse
  static const Duration celebration = Duration(milliseconds: 800);
}

/// 아이콘 크기(Icon Size) 토큰
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
abstract class AppTextStyle {
  /// Display (28px) - 대시보드 메인 수치
  static const double display = 28;

  /// H1 (26px) - 페이지 제목
  static const double titleLarge = 26;

  /// H2 (21px) - 섹션 헤더, 카드 제목
  static const double titleMedium = 21;

  /// H3 (17px) - 서브 섹션, 리스트 타이틀
  static const double titleSmall = 17;

  /// Body (16px) - 기본 본문
  static const double bodyLarge = 16;

  /// Body Small (15px) - 보조 텍스트, 입력 힌트
  static const double bodyMedium = 15;

  /// Caption (13px) - 레이블, 차트 축, 뱃지 텍스트
  static const double bodySmall = 13;

  /// 캡션 (11px)
  static const double caption = 11;

  /// 줄 간격 비율
  static const double lineHeightTight = 1.3;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;
}

/// 색상 토큰 (Toss-inspired Design System)
abstract class AppColors {
  // Primary 계열 (Toss Blue)
  static const Color primary = Color(0xFF0064FF);
  static const Color primaryLight = Color(0xFF4D9AFF);
  static const Color primaryDark = Color(0xFF0050CC);
  static const Color primary50 = Color(0xFFE8F0FE);
  static const Color primary100 = Color(0xFFD0E1FD);
  static const Color primary200 = Color(0xFFA1C4FB);
  static const Color primary500 = Color(0xFF0064FF);

  // Secondary (Success) 계열 (Toss Green)
  static const Color secondary = Color(0xFF00C471);
  static const Color secondaryLight = Color(0xFF33D68A);
  static const Color secondaryDark = Color(0xFF009D5A);

  // Tertiary (Warning) 계열 (Toss Orange)
  static const Color tertiary = Color(0xFFFF8A00);
  static const Color tertiaryLight = Color(0xFFFFAB40);
  static const Color tertiaryDark = Color(0xFFE67A00);

  // Error 계열 (Toss Red)
  static const Color error = Color(0xFFF04452);
  static const Color errorLight = Color(0xFFFF6B6B);
  static const Color errorDark = Color(0xFFD63341);

  // AI Accent 계열
  static const Color aiAccent = Color(0xFF8B5CF6);
  static const Color aiAccentLight = Color(0xFFA78BFA);
  static const Color aiAccentDark = Color(0xFF7C3AED);

  // Neutral (Gray) 계열 - Light Mode
  static const Color gray50 = Color(0xFFF4F4F4);
  static const Color gray100 = Color(0xFFEBEBEB);
  static const Color gray200 = Color(0xFFD9D9D9);
  static const Color gray300 = Color(0xFFB0B0B0);
  static const Color gray400 = Color(0xFF8B8B8B);
  static const Color gray500 = Color(0xFF6B6B6B);
  static const Color gray600 = Color(0xFF4E4E4E);
  static const Color gray700 = Color(0xFF333333);
  static const Color gray800 = Color(0xFF1A1A1A);
  static const Color gray900 = Color(0xFF0E0E0E);

  // Dark Mode 전용
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkBackground = Color(0xFF0E0E0E);
  static const Color darkBorder = Color(0xFF2A2A2A);

  // 앱 배경색
  static const Color appBackground = Color(0xFFF4F4F4);
  static const Color appBackgroundDark = Color(0xFF0E0E0E);

  // 텍스트
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF8B8B8B);

  // 테두리
  static const Color border = Color(0xFFEBEBEB);
  static const Color borderDark = Color(0xFF2A2A2A);

  // 네비게이션 바
  static const Color navBarBackground = Color(0xFFFFFFFF);
  static const Color navBarBackgroundDark = Color(0xFF1A1A1A);
  static const Color navBarSelected = Color(0xFF0064FF);
  static const Color navBarSelectedDark = Color(0xFF4D9AFF);

  // 아이콘 배경용
  static const Color iconBackgroundLight = Color(0xFFF4F4F4);
  static const Color iconBackgroundDark = Color(0xFF2A2A2A);
}

/// Liquid Glass 네비게이터 토큰 (iOS 26 스타일)
abstract class AppNavGlass {
  /// 바 배경 블러 강도
  static const double barBlurSigma = 20.0;

  /// 바 높이 (라벨 포함)
  static const double height = 74.0;

  /// 플로팅 마진 (하단 10px - 화면 하단에 가깝게)
  static const EdgeInsets margin = EdgeInsets.fromLTRB(16, 0, 16, 10);

  /// 바 테두리 둥글기
  static const double borderRadius = 32.0;

  /// 활성 탭 색상 (Light - PAL Primary Blue)
  static const Color activeColor = Color(0xFF0064FF);

  /// 활성 탭 색상 (Dark)
  static const Color activeColorDark = Color(0xFF4D9AFF);

  /// Light 모드 배경
  static const double lightOpacity = 0.92;

  /// Dark 모드 배경
  static const double darkOpacity = 0.7;

  /// FAB 하단 패딩 (네비바 겹침 방지)
  static const double fabBottomPadding = 130.0;
}
