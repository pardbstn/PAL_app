# PAL Design System Guide v1.0

**Progress, Analyze, Level-up**

"기록하고, 분석하고, 성장하다."

| 항목 | 내용 |
|------|------|
| **작성일** | 2026.02.07 |
| **버전** | v1.0 |
| **플랫폼** | Flutter (Android/iOS) + Flutter Web → React/Next.js 전환 예정 |
| **대상** | 트레이너 앱, 회원 앱, 트레이너 웹 |

---

## 1. 디자인 철학 및 방향

### Design Vision: "Energetic Intelligence"

PAL은 **활기찬 프로페셔널리즘(Energetic Professionalism)** 스타일을 채택합니다.

- 피트니스의 역동성과 AI의 지적인 신뢰감을 결합
- 복잡한 운동/체성분 데이터를 직관적이고 동기부여가 되는 시각적 경험으로 승화
- 트레이너에게는 전문적인 업무 도구, 회원에게는 친근하고 동기부여되는 인터페이스 제공

### 핵심 디자인 원칙

| 원칙 | 설명 |
|------|------|
| **Effortless Clarity** | 복잡한 데이터를 한 눈에 이해할 수 있는 깔끔한 구조. 트레이너가 수업 사이 30초 만에 핵심 정보 확인 가능 |
| **Motivational Design** | 진행률, 변화 추이, 예측 데이터를 시각적으로 표현하여 회원에게 성취감 제공 |
| **Role-Adaptive UI** | 트레이너와 회원의 역할에 따라 동일 데이터를 다른 관점으로 제공. 하나의 디자인 시스템, 두 가지 경험 |
| **Premium but Approachable** | 고급스러운 비주얼이지만 헬스장 현장에서 바로 쓸 수 있는 실용적 접근성 |

### 1.1 타겟 환경 및 플랫폼 전략

| 환경 | 지원 범위 | 비고 |
|------|----------|------|
| **Android** | Android 8.0+ (API 26+) | 주력 타겟 (국내 PT 트레이너 주 사용) |
| **iOS** | iOS 14.0+ | Apple 디바이스 사용자 |
| **트레이너 웹** | Chrome/Edge 최신 2개 버전 | 대시보드, 커리큘럼 관리 등 전체 기능 |
| **해상도 (앱)** | 360px ~ 428px 기준 | 반응형 대응 (flutter_screenutil) |
| **해상도 (웹)** | 1280px 이상 | 사이드 네비게이션 + 메인 콘텐츠 |

---

## 2. 디자인 시스템

### 2.1 컬러 팔레트

#### Primary Colors

```
/* Primary - Sapphire Blue (신뢰/전문성/AI) */
--pal-primary-50:  #EFF6FF;
--pal-primary-100: #DBEAFE;
--pal-primary-200: #BFDBFE;
--pal-primary-300: #93C5FD;
--pal-primary-400: #60A5FA;
--pal-primary-500: #3B82F6;
--pal-primary-600: #2563EB;  /* 메인 Primary */
--pal-primary-700: #1D4ED8;
--pal-primary-800: #1E40AF;
--pal-primary-900: #1E3A8A;
```

#### Semantic Colors

| 용도 | 색상 코드 | 사용처 |
|------|----------|--------|
| **Primary** | `#2563EB` | 버튼, CTA, 강조, 링크, AI 관련 요소 |
| **Success** | `#10B981` | 증가 지표, 목표 달성, 긍정적 변화 (체중 감량 성공 등) |
| **Warning** | `#F59E0B` | 주의 알림, 이탈 위험, 출석률 저하 |
| **Error** | `#EF4444` | 오류, 감소 지표, 부정적 변화 |
| **AI Accent** | `#8B5CF6` | AI 인사이트, 예측 데이터, AI 생성 커리큘럼 표시 |
| **Background** | `#F9FAFB` | Light Mode 배경 |
| **Surface** | `#FFFFFF` | 카드, 패널 배경 |
| **Text Primary** | `#1F2937` | 본문 텍스트 |
| **Text Secondary** | `#6B7280` | 부가 텍스트, 힌트, 캡션 |
| **Border** | `#E5E7EB` | 구분선, 카드 테두리 |

#### Dark Mode 컬러 토큰

```
/* Dark Mode */
--pal-dark-bg-primary:    #0F172A;
--pal-dark-bg-secondary:  #1E293B;
--pal-dark-bg-surface:    #334155;
--pal-dark-text-primary:  #F1F5F9;
--pal-dark-text-secondary:#94A3B8;
--pal-dark-border:        #475569;
--pal-dark-accent:        #60A5FA;  /* Primary를 밝게 조정 */
--pal-dark-ai-accent:     #A78BFA;  /* AI Accent 밝게 조정 */
```

| 용도 | Light | Dark | 대비 비율 |
|------|-------|------|----------|
| **배경** | #F9FAFB | #0F172A | - |
| **본문 텍스트** | #1F2937 | #F1F5F9 | 15.8:1 / 14.2:1 |
| **보조 텍스트** | #6B7280 | #94A3B8 | 4.6:1 / 5.2:1 |
| **카드 배경** | #FFFFFF | #1E293B | - |
| **Primary 텍스트** | #2563EB | #60A5FA | 4.7:1 / 6.3:1 |

#### 역할별 컬러 적용

| 요소 | 트레이너 앱/웹 | 회원 앱 |
|------|---------------|---------|
| **네비게이션 강조** | Primary Blue (#2563EB) | Primary Blue (#2563EB) |
| **AI 기능 표시** | AI Purple (#8B5CF6) | AI Purple (#8B5CF6) |
| **성과 긍정 지표** | Success Green (#10B981) | Success Green (#10B981) |
| **CTA 버튼** | Primary Blue | Primary Blue + Gradient |
| **인사이트 카드 배경** | AI Purple 10% opacity | AI Purple 10% opacity |

---

### 2.2 타이포그래피

#### Font Selection

```dart
// Flutter 설정
// 한글: Pretendard (가독성 + 현대적)
// 영문/숫자: Inter (데이터 표시에 최적)
// 코드/수치: JetBrains Mono (인바디 데이터, AI 로그)

ThemeData(
  fontFamily: 'Pretendard',
  // Inter는 숫자/영문 표시에 부분 적용
)
```

```css
/* Web (React/Next.js 전환 시) */
@import url('https://cdn.jsdelivr.net/gh/orioncactus/pretendard/dist/web/static/pretendard.css');
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');

:root {
  --font-primary: 'Pretendard', -apple-system, sans-serif;
  --font-data: 'Inter', 'Pretendard', sans-serif;
  --font-code: 'JetBrains Mono', monospace;
}
```

#### Type Scale

| Level | Size | Weight | Usage | Line Height |
|-------|------|--------|-------|-------------|
| **Display** | 28px | 700 | 대시보드 메인 수치 (체중, 매출 등) | 1.2 |
| **H1** | 24px | 700 | 페이지 제목 | 1.3 |
| **H2** | 20px | 600 | 섹션 헤더, 카드 제목 | 1.3 |
| **H3** | 18px | 600 | 서브 섹션, 리스트 타이틀 | 1.4 |
| **Body** | 16px | 400 | 기본 본문 | 1.5 |
| **Body Small** | 14px | 400 | 보조 텍스트, 입력 힌트 | 1.5 |
| **Caption** | 12px | 500 | 레이블, 차트 축, 뱃지 텍스트 | 1.4 |
| **Data** | 16-28px | 600 | 숫자 데이터 (Inter 폰트 적용) | 1.2 |

---

### 2.3 그림자 및 애니메이션

```dart
// Flutter Shadow Tokens
class PalShadows {
  static const sm = [BoxShadow(color: Color(0x0F1F2937), blurRadius: 3, offset: Offset(0, 1))];
  static const md = [BoxShadow(color: Color(0x0D1F2937), blurRadius: 6, offset: Offset(0, 4))];
  static const lg = [BoxShadow(color: Color(0x0A1F2937), blurRadius: 15, offset: Offset(0, 10))];
  static const accent = [BoxShadow(color: Color(0x402563EB), blurRadius: 14, offset: Offset(0, 4))];
  static const ai = [BoxShadow(color: Color(0x408B5CF6), blurRadius: 14, offset: Offset(0, 4))];
}
```

```css
/* Web CSS Tokens */
:root {
  --shadow-sm: 0 1px 3px rgba(31, 41, 55, 0.06);
  --shadow-md: 0 4px 6px rgba(31, 41, 55, 0.05);
  --shadow-lg: 0 10px 15px rgba(31, 41, 55, 0.04);
  --shadow-accent: 0 4px 14px rgba(37, 99, 235, 0.25);
  --shadow-ai: 0 4px 14px rgba(139, 92, 246, 0.25);

  /* Timing Functions */
  --ease-out-expo: cubic-bezier(0.16, 1, 0.3, 1);
  --ease-out-quart: cubic-bezier(0.25, 1, 0.5, 1);

  /* Duration */
  --duration-fast: 150ms;
  --duration-normal: 250ms;
  --duration-slow: 400ms;
}
```

#### 애니메이션 가이드

| 유형 | Duration | Easing | 사용처 |
|------|----------|--------|--------|
| **마이크로 인터랙션** | 150ms | ease-out | 버튼 탭, 토글, 체크박스 |
| **화면 전환** | 300ms | ease-out-expo | 페이지 이동, 모달 열기 |
| **데이터 진입** | 400-600ms | ease-out-quart | 차트 렌더링, 숫자 카운트업 |
| **스켈레톤 Shimmer** | 2000ms | linear, infinite | 데이터 로딩 중 |
| **성과 축하** | 800ms | spring | 목표 달성 시 confetti/pulse |

---

### 2.4 Spacing Scale

4px 기반 스케일을 사용합니다. Flutter의 기본 단위와 호환됩니다.

| Token | Value | Flutter | 용도 |
|-------|-------|---------|------|
| **space-1** | 4px | 4.0 | 아이콘-텍스트 간격, 뱃지 내부 |
| **space-2** | 8px | 8.0 | 인라인 요소 간격 |
| **space-3** | 12px | 12.0 | 컴팩트 패딩 (칩, 태그) |
| **space-4** | 16px | 16.0 | 기본 패딩 (버튼, 입력 필드) |
| **space-5** | 20px | 20.0 | 카드 내부 패딩 |
| **space-6** | 24px | 24.0 | 섹션 간 간격 |
| **space-8** | 32px | 32.0 | 페이지 내 대구간 간격 |
| **space-10** | 40px | 40.0 | 페이지 상단 여백 |

### 2.5 Border Radius

| Token | Value | 용도 |
|-------|-------|------|
| **radius-sm** | 6px | 뱃지, 태그, 작은 칩 |
| **radius-md** | 12px | 버튼, 입력 필드, 작은 카드 |
| **radius-lg** | 16px | 메인 카드, 패널 |
| **radius-xl** | 24px | 바텀시트, 큰 모달 |
| **radius-full** | 9999px | 아바타, 원형 버튼 |

---

## 3. 핵심 컴포넌트 디자인

### 3.1 네비게이션

#### 트레이너 앱 - Bottom Navigation

```
┌───────────────────────────────────────┐
│                                       │
│         [메인 콘텐츠 영역]             │
│                                       │
├───────────────────────────────────────┤
│  🏠 홈    👥 회원   📝 기록   💬 메시지 │
└───────────────────────────────────────┘
```

- 활성 탭: Primary Blue 아이콘 + Bold 레이블
- 비활성 탭: Gray-400 아이콘 + Regular 레이블
- 배경: Surface White, 상단 1px border

#### 회원 앱 - Bottom Navigation

```
┌───────────────────────────────────────┐
│                                       │
│         [메인 콘텐츠 영역]             │
│                                       │
├───────────────────────────────────────┤
│  🏠 홈   📊 내 기록  🍽️ 식단  💬 메시지 │
└───────────────────────────────────────┘
```

#### 트레이너 웹 - Side Navigation

```
┌──────────┬────────────────────────────────────────────┐
│          │                                            │
│ 🏋️ PAL   │  [메인 콘텐츠 영역]                         │
│          │                                            │
│ 📊 대시보드│                                            │
│ 👥 회원관리│                                            │
│ 📋 커리큘럼│                                            │
│ 💬 메시지  │                                            │
│ ⚙️ 설정   │                                            │
│          │                                            │
└──────────┴────────────────────────────────────────────┘
```

- 사이드바 너비: 240px (접힘 시 64px, 아이콘만)
- 배경: White / Dark Mode: #1E293B
- 활성 메뉴: Primary-50 배경 + Primary-600 텍스트 + 좌측 4px accent bar
- 호버: Primary-50 배경

---

### 3.2 카드 컴포넌트

#### PalCard (기본 카드)

```
┌─────────────────────────────────┐
│  ┌─┐                           │
│  │👤│ 김민수                     │
│  └─┘ D+45 · 다이어트            │
│                                 │
│  체중  ──────────── 72.3kg      │
│  체지방 ─────────── 18.2%       │
│  골격근 ─────────── 33.1kg      │
│                                 │
│  📈 체중 -2.1kg (지난 달 대비)   │
│                                 │
└─────────────────────────────────┘
```

- 배경: Surface White
- 테두리: 1px solid Border (#E5E7EB)
- Border Radius: 16px
- 패딩: 20px
- 그림자: shadow-sm → 호버 시 shadow-md
- 증감 표시: ▲ Success Green / ▼ Error Red

#### PalInsightCard (AI 인사이트 카드)

```
┌─────────────────────────────────┐
│ ✨ AI 인사이트                    │  ← AI Purple 배경 10%
│                                 │
│ 김민수 회원은 최근 2주간 체중    │
│ 감량 속도가 둔화되었습니다.      │
│ 식단 기록 빈도가 60% 감소했으며, │
│ 단백질 섭취량 조절을 권장합니다.  │
│                                 │
│ [상세 보기 →]                    │
└─────────────────────────────────┘
```

- 배경: AI Purple (#8B5CF6) 10% opacity
- 좌측 4px AI Purple accent bar
- ✨ 아이콘으로 AI 생성 콘텐츠 표시
- 그림자: shadow-ai

---

### 3.3 차트/그래프 스타일

#### 차트 라이브러리

- **Flutter:** fl_chart (주력), syncfusion_flutter_charts (고급 차트)
- **Web:** Recharts (React 전환 시), Tremor (대시보드 위젯)

#### 차트 컬러 시퀀스

| 순서 | 색상 | 용도 |
|------|------|------|
| 1 | `#2563EB` | Primary Blue — 체중, 주요 지표 |
| 2 | `#10B981` | Success Green — 골격근량, 달성률 |
| 3 | `#F59E0B` | Warning Amber — 체지방률, 주의 지표 |
| 4 | `#EF4444` | Error Red — 목표 이탈, 감소 지표 |
| 5 | `#8B5CF6` | AI Purple — AI 예측선, 트렌드 |
| 6 | `#6B7280` | Gray — 기준선, 이전 기간 데이터 |

#### 차트 스타일 규칙

- 라인 차트: strokeWidth 2.5px, 곡선(cubic), 포인트 4px circle
- 바 차트: borderRadius 6px (상단), barWidth 적절히 자동 조절
- 그리드: 점선 (dashArray: [3, 3]), Gray-200
- 툴팁: White 배경, shadow-lg, radius-md, 12px 패딩
- 범례: 차트 하단, Caption 사이즈, 색상 원형 인디케이터
- 애니메이션: 초기 로드 시 500ms ease-out, 데이터 업데이트 시 300ms
- AI 예측선: 대시 패턴 (dashArray: [5, 5]) + AI Purple

---

### 3.4 상태 UI 패턴

모든 데이터 의존 화면은 아래 5가지 상태를 반드시 처리합니다.

| 상태 | 시각적 처리 | 적용 화면 | 구현 방법 |
|------|-----------|----------|----------|
| **Loading** | Skeleton Placeholder + Shimmer | 전체 화면 | 콘텐츠 영역 형태를 모방한 회색 블록 + shimmer 패키지 |
| **Empty** | Lottie 일러스트 + 안내 메시지 + CTA | 회원 목록, 운동 기록, 식단 | 중앙 정렬 Lottie 애니메이션, "아직 등록된 회원이 없습니다" + [회원 등록하기] 버튼 |
| **Error** | 에러 아이콘 + 메시지 + 재시도 | API 실패, AI 분석 오류 | Error Red 톤 아이콘, 구체적 메시지, [다시 시도] 버튼 |
| **Permission** | 잠금 아이콘 + 업그레이드 안내 | Free 티어 기능 제한 | Warning 톤, "Pro 플랜에서 사용 가능합니다" + [업그레이드] 버튼 |
| **Success** | 체크 아이콘 + 확인 토스트 | 저장 완료, AI 분석 완료 | Success Green 토스트, 3초 후 자동 닫힘 |

#### 에러 상태 패턴

| 에러 유형 | 표시 메시지 | 사용자 액션 |
|----------|-----------|-----------|
| **AI 분석 실패** | "AI 분석 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요." | [다시 분석하기] 버튼 |
| **네트워크 오류** | "인터넷 연결을 확인해 주세요." | [다시 시도] 버튼 (자동 재시도 3회) |
| **이미지 인식 실패** | "식단 사진을 인식할 수 없습니다. 다른 각도에서 촬영해 주세요." | [다시 촬영] + 수동 입력 안내 |
| **데이터 없음** | "분석할 데이터가 부족합니다. 최소 2주간의 기록이 필요합니다." | 진행률 바 표시 (현재/필요 데이터량) |

#### 스켈레톤 상세 (Flutter)

```dart
// 회원 카드 스켈레톤
class MemberCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 24, backgroundColor: Colors.grey),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 100, height: 16, color: Colors.grey),
                SizedBox(height: 8),
                Container(width: 160, height: 12, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 3.5 폼 컨트롤 전략

| 컴포넌트 | Flutter 구현 | 용도 |
|----------|-------------|------|
| **텍스트 입력** | TextField + InputDecoration | 회원 정보 입력, 운동 기록 |
| **숫자 입력** | TextField (keyboardType: number) + 단위 suffix | 체중, 세트, 횟수, 중량 |
| **날짜 선택** | showDatePicker / CupertinoDatePicker | 수업일, 목표 기한 |
| **드롭다운** | DropdownButtonFormField | 운동 부위, 목표 유형 선택 |
| **멀티 선택** | FilterChip / ChoiceChip (Wrap) | 운동 종목 태그 선택 |
| **이미지 업로드** | ImagePicker + 미리보기 | 식단 사진, 인바디 스캔 |
| **슬라이더** | Slider / RangeSlider | 목표 체중 범위, 난이도 조절 |
| **서명 패드** | signature_pad 패키지 | PT 계약 전자서명 |

#### 입력 필드 스타일

```dart
InputDecoration(
  filled: true,
  fillColor: Color(0xFFF9FAFB),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: Color(0xFFE5E7EB)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: Color(0xFF2563EB), width: 2),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: Color(0xFFEF4444)),
  ),
  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
)
```

---

## 4. 역할별 UI 가이드

### 4.1 트레이너 앱 (빠른 입력 중심)

**설계 원칙:** 수업 사이 짧은 시간에 핵심 작업을 완료할 수 있는 간결한 UI

- 홈 대시보드: 오늘 수업 회원 리스트, 주간 요약
- 회원 카드: 탭 한 번으로 운동 기록 입력 진입
- 퀵 액션 FAB: + 버튼 → 운동 기록 / 체성분 기록 / 메모 빠른 접근

### 4.2 회원 앱 (동기부여 중심)

**설계 원칙:** 자신의 변화를 시각적으로 확인하며 꾸준한 기록 습관을 형성

- 홈: 오늘 수업 정보 + AI 동기부여 메시지
- 내 기록: 체중/체성분 변화 그래프 (기간 선택 가능)
- 식단: 사진 촬영 → AI 자동 분석 결과 즉시 표시
- 프로그레스 링: 주간/월간 목표 달성률 시각화

### 4.3 트레이너 웹 (대시보드 중심)

**설계 원칙:** 넓은 화면을 활용한 데이터 분석과 커리큘럼 관리

- 대시보드: 전체 회원 현황, 이탈 위험 회원, 이번 주 스케줄
- 회원 상세: 전체 데이터 타임라인, AI 인사이트 패널
- 커리큘럼 편집: 드래그앤드롭 운동 배치, AI 자동 생성 + 수동 편집
- 매출 관리: 월별 매출 차트, 재등록률 추이

---

## 5. 데이터 시각화 디자인 가이드

### 5.1 주요 차트 유형별 사용처

| 차트 유형 | 사용처 | 스타일 |
|----------|--------|--------|
| **선 그래프 (Line)** | 체중 변화 추이, 매출 추이 | 곡선, 그라데이션 fill, AI 예측선 대시 |
| **막대 그래프 (Bar)** | 주간 운동량, 영양소 비교 | radius-sm 상단, 호버 시 툴팁 |
| **도넛 차트 (Doughnut)** | 영양소 비율 (탄단지), 운동 부위 분포 | 중앙에 총량 표시, 호버 시 세그먼트 확대 |
| **방사형 차트 (Radar)** | 체력 밸런스, 5대 운동 능력치 | 반투명 fill, 기준선 표시 |
| **게이지 (Gauge)** | 목표 달성률, BMI 범위 | 원형 프로그레스, 색상 구간 (위험-주의-정상-우수) |
| **진행률 바 (Progress)** | 오늘 칼로리, 주간 출석률 | 라운드, 그라데이션 fill |

### 5.2 숫자 데이터 표시 규칙

| 데이터 유형 | 포맷 | 예시 |
|-----------|------|------|
| **체중** | 소수점 1자리 + kg | 72.3kg |
| **체지방률** | 소수점 1자리 + % | 18.2% |
| **칼로리** | 천 단위 콤마 + kcal | 1,850kcal |
| **금액** | 천 단위 콤마 + 원 | 990,000원 |
| **증감** | ▲/▼ + 수치 + 색상 | ▼ 2.1kg (Success Green) |
| **퍼센트 변화** | +/- 기호 + 소수점 1자리 | +3.2% |
| **날짜** | YYYY.MM.DD (목록) / M월 D일 (본문) | 2026.02.07 / 2월 7일 |
| **기간** | D+N / N주차 | D+45 / 6주차 |

---

## 6. 반응형 레이아웃 전략

### 6.1 앱 (Flutter)

| Breakpoint | 대응 방법 |
|-----------|----------|
| **소형 (< 360px)** | 최소 지원, 핵심 요소만 표시 |
| **표준 (360-414px)** | 기본 레이아웃 |
| **대형 (> 414px)** | 카드 그리드 2열, 여백 확대 |
| **태블릿 (> 600px)** | 2-panel 레이아웃 (회원 목록 + 상세) |

flutter_screenutil을 사용하여 비율 기반 반응형 처리:

```dart
// 기준 디자인: 390 x 844 (iPhone 14 기준)
ScreenUtil.init(context, designSize: Size(390, 844));

// 사용 예시
Container(
  width: 343.w,   // 너비 비율 대응
  padding: EdgeInsets.all(16.r),  // 패딩 비율 대응
  child: Text('회원 목록', style: TextStyle(fontSize: 20.sp)),
)
```

### 6.2 웹 (트레이너 대시보드)

| Breakpoint | 너비 | 레이아웃 |
|-----------|------|---------|
| **Desktop (기본)** | ≥ 1280px | 사이드바(240px) + 메인(flex-1) |
| **Tablet** | 768-1279px | 사이드바 접힘(64px) + 메인 확장 |
| **Mobile** | < 768px | "PAL 앱을 이용해 주세요" 안내 + 앱 다운로드 링크 |

---

## 7. 접근성 (A11y) 가이드라인

| 항목 | 요구사항 | 구현 방법 |
|------|---------|----------|
| **색상 대비** | WCAG AA 준수 (4.5:1 이상) | 모든 텍스트에 충분한 대비 |
| **터치 타겟** | 최소 48x48dp | 모든 탭 가능 요소에 최소 크기 보장 |
| **스크린 리더** | Semantics 위젯 활용 | 차트에 텍스트 대체 설명, 이미지에 label |
| **모션 감소** | 시스템 설정 존중 | MediaQuery.disableAnimations 확인 |
| **색맹 대응** | 색상만으로 정보 전달 금지 | 증감에 ▲/▼ 아이콘 병행, 패턴 구분 |

```dart
// 모션 감소 설정 확인
final reduceMotion = MediaQuery.of(context).disableAnimations;

// 차트 접근성
Semantics(
  label: '체중 변화 그래프. 지난 달 대비 2.1kg 감소, 현재 72.3kg',
  child: WeightChart(data: weightData),
)
```

---

## 8. 아이콘 및 일러스트레이션

### 8.1 아이콘

- **기본 아이콘:** Material Icons (Flutter 내장)
- **보충 아이콘:** Lucide Icons (flutter_lucide 패키지) — 모던하고 일관된 스타일
- **AI 기능 표시:** ✨ (Sparkles) 아이콘을 AI 생성 콘텐츠에 일관적으로 사용
- **피트니스 전용:** 커스텀 SVG 아이콘 (운동 부위, 운동 종목)

### 8.2 일러스트레이션

- **빈 상태:** Lottie 애니메이션 (LottieFiles 무료 에셋)
  - 회원 없음: 빈 의자 + 운동 기구
  - 기록 없음: 빈 노트패드
  - 분석 중: 돌아가는 차트/그래프
- **성과 축하:** Confetti / Trophy Lottie 애니메이션
- **온보딩:** 3-4스텝 일러스트 (트레이너/회원 역할 선택, 핵심 기능 소개)

---

## 9. Flutter 테마 설정 예시

```dart
// lib/core/theme/pal_theme.dart
import 'package:flutter/material.dart';

class PalTheme {
  // Colors
  static const primary = Color(0xFF2563EB);
  static const primaryLight = Color(0xFFEFF6FF);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const aiAccent = Color(0xFF8B5CF6);
  static const background = Color(0xFFF9FAFB);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Pretendard',
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: success,
        error: error,
        surface: surface,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: Color(0xFF9CA3AF),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Pretendard',
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: Color(0xFF60A5FA),
        secondary: success,
        error: error,
        surface: Color(0xFF1E293B),
        onPrimary: Color(0xFF0F172A),
        onSurface: Color(0xFFF1F5F9),
      ),
      scaffoldBackgroundColor: Color(0xFF0F172A),
      cardTheme: CardTheme(
        color: Color(0xFF1E293B),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Color(0xFF475569)),
        ),
      ),
    );
  }
}
```

---

## 10. 웹 Tailwind CSS 설정 (React/Next.js 전환 시)

```typescript
// tailwind.config.ts
import type { Config } from 'tailwindcss';

const config: Config = {
  darkMode: 'class',
  content: ['./src/**/*.{js,ts,jsx,tsx,mdx}'],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Pretendard', '-apple-system', 'sans-serif'],
        data: ['Inter', 'Pretendard', 'sans-serif'],
        code: ['JetBrains Mono', 'monospace'],
      },
      colors: {
        pal: {
          primary: {
            50: '#EFF6FF', 100: '#DBEAFE', 200: '#BFDBFE',
            300: '#93C5FD', 400: '#60A5FA', 500: '#3B82F6',
            600: '#2563EB', 700: '#1D4ED8', 800: '#1E40AF',
            900: '#1E3A8A',
          },
          success: '#10B981',
          warning: '#F59E0B',
          error: '#EF4444',
          ai: '#8B5CF6',
        },
      },
      borderRadius: {
        'card': '16px',
      },
      boxShadow: {
        'accent': '0 4px 14px rgba(37, 99, 235, 0.25)',
        'ai': '0 4px 14px rgba(139, 92, 246, 0.25)',
      },
      animation: {
        'fade-in-up': 'fadeInUp 0.3s ease-out',
        'shimmer': 'shimmer 2s linear infinite',
        'count-up': 'countUp 0.6s ease-out',
      },
    },
  },
  plugins: [
    require('@tailwindcss/typography'),
    require('tailwindcss-animate'),
  ],
};

export default config;
```

---

## 11. 공통 UI 컴포넌트 목록

| 컴포넌트 | 설명 | Flutter 위젯 | 사용 화면 |
|----------|------|-------------|----------|
| **PalButton** | Primary/Secondary/Outline/Ghost | ElevatedButton + variants | 전체 |
| **PalCard** | 기본 카드 컨테이너 | Container + BoxDecoration | 전체 |
| **PalInsightCard** | AI 인사이트 표시 카드 | Card + AI accent styling | 대시보드, 회원 상세 |
| **PalInput** | 텍스트/숫자 입력 필드 | TextField + InputDecoration | 기록 입력, 회원 등록 |
| **PalChart** | 선/막대/도넛/방사형 그래프 | fl_chart | 기록 화면, 대시보드 |
| **PalAvatar** | 프로필 이미지 (원형) | CircleAvatar + cached_network_image | 회원 카드, 메시지 |
| **PalBadge** | 상태/증감 표시 뱃지 | Container + Text + Color | 데이터 변화 표시 |
| **PalSkeleton** | 스켈레톤 로딩 | shimmer 패키지 | 데이터 로딩 시 |
| **PalEmptyState** | 빈 상태 일러스트 + CTA | Lottie + Text + Button | 데이터 없는 화면 |
| **PalToast** | 성공/에러 토스트 메시지 | SnackBar custom styling | 전체 |
| **PalProgressRing** | 원형 프로그레스 바 | CustomPainter / syncfusion | 목표 달성률 |
| **PalBottomSheet** | 바텀시트 (액션, 상세정보) | showModalBottomSheet | 빠른 입력, 필터 |

---

## 부록: 패키지 의존성 요약

| 영역 | 패키지 | 버전 | 용도 |
|------|--------|------|------|
| **테마** | flex_color_scheme | ^7.3.0 | 라이트/다크 테마 자동 생성 |
| **폰트** | google_fonts | ^6.1.0 | Pretendard, Inter 적용 |
| **반응형** | flutter_screenutil | ^5.9.0 | 다양한 화면 크기 대응 |
| **차트** | fl_chart | ^0.66.0 | 선/막대/도넛/방사형 |
| **애니메이션** | flutter_animate | ^4.3.0 | 선언적 애니메이션 체이닝 |
| **스켈레톤** | shimmer | ^3.0.0 | 로딩 스켈레톤 효과 |
| **Lottie** | lottie | ^3.0.0 | 빈 상태, 성공 모션 |
| **이미지** | cached_network_image | ^3.3.0 | 프로필/식단 이미지 캐싱 |
| **SVG** | flutter_svg | ^2.0.0 | 커스텀 아이콘, 일러스트 |
| **글래스모피즘** | glassmorphism | ^3.0.0 | 프리미엄 카드 디자인 |

---

*Last updated: 2026.02.07 | PAL Design System v1.0*
