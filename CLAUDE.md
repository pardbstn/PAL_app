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
