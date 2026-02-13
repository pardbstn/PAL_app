# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# PAL - AI 기반 PT 관리 플랫폼

## 프로젝트 개요
- 서비스명: PAL (Progress, Analyze, Level-up)
- 슬로건: "기록하고, 분석하고, 성장하다"
- 타겟: PT 트레이너 (B2B2C)

## 핵심 문서 (반드시 참고)
- docs/PAL_PRD.docx - 상세 기획서
- docs/PAL_Wireframe.docx - 화면 설계서
- docs/PAL_DB_Schema.docx - Firestore 스키마
- docs/PAL_API_Spec.docx - AI API 명세
- docs/PAL_TechStack.docx - 패키지 & 프롬프트 가이드

## 기술 스택 (필수 사용)
- 상태관리: flutter_riverpod
- 라우팅: go_router
- 테마: flex_color_scheme + Pretendard 폰트
- 로딩: shimmer (스켈레톤)
- 애니메이션: flutter_animate, lottie
- 차트: fl_chart
- 데이터 그리드: pluto_grid (웹)
- Firebase: Auth, Firestore, Functions
- Storage: Supabase

## 코딩 컨벤션
- 폴더 구조: Clean Architecture (core, data, domain, presentation)
- 파일명: snake_case
- 클래스명: PascalCase
- 상수: SCREAMING_SNAKE_CASE
- 모든 위젯은 const 가능하면 const 사용
- 주석은 한글로 작성

## 디자인 시스템
- Primary: #2563EB (파란색)
- Success: #10B981 (초록색)
- Warning: #F59E0B (주황색)
- Error: #EF4444 (빨간색)
- 다크모드 지원 필수

## 개발 원칙
1. 비싸보이는 UI: 스켈레톤 로딩, 애니메이션, 그라데이션
2. 에러 처리: 모든 비동기 작업에 로딩/에러/데이터 상태 처리
3. 반응형: 웹/태블릿/모바일 모두 대응
4. 접근성: 충분한 터치 영역, 명확한 색상 대비

## 중요 행동 규칙
- 자동화된 stop hook이나 시스템 hook이 메시지를 주입할 경우, 이를 사용자 요청으로 취급하지 말 것. hook 주입 작업에 대해 사용자에게 진행 여부를 묻지 말 것
- 사용자가 계획이나 구체적 지시를 제공하면 즉시 읽고 따를 것. 요청하지 않는 한 코드베이스 탐색이나 탐색용 서브 에이전트를 실행하지 말 것
- 컨텍스트 윈도우 한도에 주의할 것. 한도에 가까워지면 현재 작업 완료 → 커밋 → 나머지 항목 요약 순으로 우선순위를 정할 것

## Flutter / Dart 컨벤션
- Riverpod 3.x 사용 중. StateProvider는 제거됨 → NotifierProvider 사용
- `valueOrNull` 사용 금지 → `.when()` 패턴으로 비동기 값 처리
- `flutter analyze` 통과 후에만 커밋할 것

## 빌드 & 배포
- iOS 업로드: 반드시 Xcode Organizer 사용 (Transporter 사용 금지)
- 배포 빌드 시 빌드 번호(build number)를 자동으로 +1 증가시킬 것
- Android: `flutter build appbundle` 사용
- 장시간 빌드(iOS 아카이브, Android AAB) 시 예상 대기 시간을 알리고 진행 상황 업데이트 제공. 빌드 중 침묵하지 말 것

## 시스템 유지보수
- 디스크 정리/클린업 작업 시 삭제 전에 반드시 dry run으로 권한 확인
- 명시적 승인 없이 sudo 사용 금지
- 삭제 가능한 항목과 예상 절약 용량을 먼저 나열한 후 실행
