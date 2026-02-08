

# PAL Agent Teams 구현 전략 v3.0

**기반 문서**: PAL PRD v4.0 Final + 신규 요구사항 7건
**앱 상태**: Production (1.0.4+7) — 170+ 파일, 37 Cloud Functions
**작성일**: 2026-02-07

---

## 목차

0. [사전 준비](#0-사전-준비)
1. [신규 요구사항 정리](#1-신규-요구사항-정리)
2. [기능별 영향 범위 분석](#2-기능별-영향-범위-분석)
3. [CLAUDE.md 템플릿](#3-claudemd-템플릿)
4. [팀 구성 전략 (3단계)](#4-팀-구성-전략-3단계)
5. [Stage 1: Foundation 변경](#5-stage-1-foundation-변경)
6. [Stage 2: 메인 병렬 개발](#6-stage-2-메인-병렬-개발)
7. [Stage 3: AI 인사이트 고도화](#7-stage-3-ai-인사이트-고도화)
8. [운영 가이드](#8-운영-가이드)

---

## 0. 사전 준비

Agent Teams를 시작하기 전에 반드시 완료해야 할 환경 설정, 도구 확인, 프로젝트 상태 점검 항목입니다.

### 0.1 Claude Code 설치 및 버전 확인

```bash
# Claude Code 설치 (Node.js 18+ 필수)
npm install -g @anthropic-ai/claude-code

# 버전 확인 (Agent Teams 지원 버전인지 확인)
claude --version

# 최신 버전으로 업데이트
npm update -g @anthropic-ai/claude-code
```

### 0.2 Agent Teams 활성화

Agent Teams는 실험적 기능이므로 명시적으로 활성화해야 합니다.

```bash
# 방법 1: 환경 변수 (일회성)
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1

# 방법 2: 쉘 프로필에 영구 저장 (.zshrc 또는 .bashrc)
echo 'export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1' >> ~/.zshrc
source ~/.zshrc

# 방법 3: settings.json에 저장 (권장 — 영구 + 프로젝트별 관리)
# ~/.claude/settings.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### 0.3 터미널 환경 설정

```bash
# 디스플레이 모드 확인
# - in-process (기본): 모든 터미널에서 작동, Shift+Up/Down으로 Teammate 전환
# - tmux: 분할 패널 모드 (tmux 또는 iTerm2 필요)

# tmux 설치 확인 (분할 패널 원할 경우)
tmux -V

# settings.json에서 디스플레이 모드 설정
{
  "teammateMode": "in-process"    # 또는 "tmux" 또는 "auto"
}

# 또는 세션별 오버라이드
claude --teammate-mode in-process
```

**디스플레이 모드 비교:**

| 모드 | 장점 | 단점 | 요구사항 |
|------|------|------|---------|
| `in-process` (기본) | 아무 터미널에서 작동 | Teammate 전환에 키보드 조작 필요 | 없음 |
| `tmux` | 모든 Teammate 동시 확인 가능 | 설정 필요, VS Code 터미널 미지원 | tmux 또는 iTerm2 |
| `auto` | tmux 세션 안이면 자동 분할 | 예측 어려움 | 없음 |

**⚠️ 주의**: VS Code 내장 터미널, Windows Terminal, Ghostty에서는 split-pane 모드가 지원되지 않습니다.

### 0.4 PAL 프로젝트 상태 점검

Agent Teams 시작 전에 프로젝트가 깨끗한 상태인지 확인합니다.

```bash
# 1. Git 상태 확인 — 작업 전 반드시 clean 상태
cd ~/pal-project  # PAL 프로젝트 루트
git status
# → "nothing to commit, working tree clean" 확인

# 2. 현재 브랜치에서 feature 브랜치 생성 (권장)
git checkout -b feature/v2-major-update

# 3. Flutter 빌드 정상 확인
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
# → 에러 0개 확인

# 4. Cloud Functions 빌드 확인
cd functions/
npm install
npm run build
# → 에러 0개 확인
cd ..

# 5. Firebase Emulator 정상 작동 확인
firebase emulators:start
# → Auth, Firestore, Functions 에뮬레이터 정상 구동 확인
# → Ctrl+C로 종료

# 6. 기존 앱 실행 테스트 (최소 한 번)
flutter run -d chrome  # 웹으로 빠르게 확인
```

### 0.5 API 키 및 외부 서비스 확인

```bash
# Cloud Functions 환경 변수에 필요한 키 목록 확인
# functions/.env 또는 Firebase 환경 설정

✅ ANTHROPIC_API_KEY     # Claude API (인바디 OCR, 커리큘럼 생성, 인사이트)
✅ OPENAI_API_KEY        # GPT-4o Vision (식단 분석 — 기존)
✅ SUPABASE_URL          # Supabase Storage (이미지 업로드)
✅ SUPABASE_ANON_KEY     # Supabase 인증
✅ Firebase 프로젝트 설정 # google-services.json / GoogleService-Info.plist

# Claude API 크레딧 확인 (인바디 OCR 추가로 사용량 증가 예상)
# → https://console.anthropic.com 에서 잔여 크레딧 확인
# → Vision API 호출 1회당 약 $0.01~0.05 예상
```

### 0.6 테스트 계정 준비

PAL은 3가지 역할(트레이너/회원/개인모드)이 있으므로 각 역할별 테스트 계정이 필요합니다.

```
테스트 계정 목록:

1. 트레이너 계정
   - 이메일: trainer-test@pal.com (또는 카카오/구글 테스트 계정)
   - 역할: trainer
   - 테스트 데이터: 회원 3~5명 등록된 상태

2. 회원 계정 (기존 PT 진행 중)
   - 이메일: member-test@pal.com
   - 역할: member
   - trainerId: 위 트레이너에 연결된 상태
   - 테스트 데이터: 체성분 기록 5건+, 식단 기록 3건+

3. 회원 계정 (트레이너 전환 테스트용)
   - 이메일: member-transfer@pal.com
   - 역할: member
   - 다른 트레이너에 연결된 상태 → 전환 테스트용

4. 개인모드 계정 (신규 — Stage 1 이후 생성)
   - 이메일: personal-test@pal.com
   - 역할: personal
   - 트레이너 연결 없음

5. 두 번째 트레이너 계정 (전환 테스트용)
   - 이메일: trainer-test2@pal.com
   - 역할: trainer
   - 회원 전환 시 새 트레이너 역할
```

### 0.7 Firestore 테스트 데이터 시드

```bash
# Firebase Emulator에서 테스트 데이터 시드 스크립트 실행
# (없으면 Stage 1에서 생성)

node scripts/seed-test-data.js
# 또는 Firestore 콘솔에서 수동 생성

# 시드해야 할 컬렉션:
# - users (5개 — 위 계정들)
# - trainers (2개)
# - members (3개)
# - body_records (5~10개 — 체성분 변화 테스트)
# - diet_records (5개 — 식단 기록 테스트)
# - curriculums (3개 — 커리큘럼 보기 테스트)
# - insights (5개 — 인사이트 표시 테스트)
```

### 0.8 CLAUDE.md 파일 생성

**⚠️ 가장 중요한 사전 준비 단계입니다.**

모든 Teammate는 프로젝트 루트의 `CLAUDE.md`를 자동으로 로드합니다. 이 파일이 PAL 프로젝트의 규칙과 구조를 모든 Teammate에게 전달하는 유일한 방법입니다.

```bash
# 프로젝트 루트에 CLAUDE.md 생성
touch ~/pal-project/CLAUDE.md
```

**CLAUDE.md 내용은 [섹션 3](#3-claudemd-템플릿)에 전체 템플릿이 있습니다.**

### 0.9 사전 준비 체크리스트

```
□ Claude Code 최신 버전 설치됨
□ CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 설정됨
□ 터미널 디스플레이 모드 선택됨 (in-process 또는 tmux)
□ Git clean 상태 + feature 브랜치 생성됨
□ flutter pub get + build_runner 에러 없음
□ flutter analyze 에러 0개
□ functions/ npm run build 에러 없음
□ Firebase Emulator 정상 작동 확인됨
□ API 키 전부 설정됨 (Anthropic, OpenAI, Supabase, Firebase)
□ Claude API 크레딧 충분함
□ 테스트 계정 5개 준비됨 (trainer×2, member×2, personal×1)
□ Firestore 테스트 데이터 시드됨
□ CLAUDE.md 파일 생성됨 (섹션 3 템플릿 기반)
□ 인바디 결과지 테스트 이미지 2~3장 준비됨 (OCR 테스트용)
□ FCM 설정: Firebase Console에서 Cloud Messaging 활성화됨
□ iOS: APNs 인증 키(.p8) 또는 인증서 Firebase Console에 업로드됨
□ Android: google-services.json 최신 버전 확인됨
□ 실기기 2대 준비됨 (푸시 알림 테스트: Android 1대 + iOS 1대)
□ Lottie 에셋 다운로드됨 (LottieFiles.com에서 무료 에셋 5개+)
□ 사운드 에셋 준비됨 (성공음, 확인음, 경고음 — 무료 SFX 사이트)

모두 ✅ → Stage 1 시작!
```

---

## 1. 신규 요구사항 정리

| # | 기능 | 설명 | 복잡도 |
|---|------|------|--------|
| F1 | **개인모드** | PT 종료 회원 or 신규 사용자가 트레이너 없이 독립적으로 운동/식단 기록. 회원 화면과 동일하되 트레이너 관련 UI 숨김 | 🔴 높음 |
| F2 | **역할 선택 3분기** | 기존 2가지(트레이너/회원) → 3가지(트레이너/회원/개인모드). 온보딩 플로우 변경 | 🟡 중간 |
| F3 | **개인 운동 기록** | 회원+개인모드 사용자가 직접 운동 기록 (종목, 세트, 무게, 횟수, 운동 시간). 기존에는 커리큘럼 열람만 가능 | 🟡 중간 |
| F4 | **트레이너 전환 시스템** | 자동 끊김 → 선택적 전환. 회원이 수락/거절, 기존 트레이너에게 이동 알림, 데이터 삭제 선택권 | 🔴 높음 |
| F5 | **인바디 사진 OCR** | 인바디 결과지 사진 촬영 → AI가 체성분 수치 자동 추출(체중, 체지방률, 근육량, BMI 등) → 자동 기입 | 🟡 중간 |
| F6 | **AI 인사이트 고도화** | 트레이너/회원별 맞춤 인사이트. 현재 퀄리티 낮음 → 구체적이고 실행 가능한 인사이트로 개선 | 🟡 중간 |
| F7 | **데이터 삭제 권한** | 회원이 자신의 과거 트레이너 기록, PT 데이터를 선택적으로 삭제 가능 | 🟢 낮음 |
| F8 | **푸시 알림 시스템** | DM 메시지 필수 푸시. 앱 미실행 상태에서도 핸드폰 알림 수신. 알림 내용(메시지 미리보기) 표시. 앱 아이콘 배지(빨간 숫자) 표시. FCM + APNs 연동 | 🔴 높음 |
| F9 | **프리미엄 디자인 시스템** | 햅틱 피드백, 화면 전환 애니메이션, 마이크로 인터랙션, 스켈레톤 UI, 사운드 피드백, 히어로 위젯, 글래스모피즘 깊이감, Lottie/Rive 애니메이션, 부드러운 스크롤 물리 효과, 이미지 캐싱+페이드인 | 🔴 높음 |

---

## 2. 기능별 영향 범위 분석

### 2.1 파일 영향 매트릭스

```
                        core/   models/  repo/   providers/ trainer/ member/ personal/ functions/ widgets/
                        router  (Freezed)                    screens  screens screens   (CF)
F1 개인모드              ✏️      ✏️       ✏️      ✏️         -        📋      🆕        ✏️        -
F2 역할 선택 3분기       ✏️      ✏️       -       ✏️         -        -       -         -         -
F3 개인 운동 기록        -       🆕       🆕      🆕         -        ✏️      ✏️        -         -
F4 트레이너 전환         ✏️      ✏️       🆕      🆕         ✏️       ✏️      -         🆕        -
F5 인바디 OCR            -       ✏️       ✏️      ✏️         -        ✏️      ✏️        🆕        -
F6 AI 인사이트 고도화    -       ✏️       ✏️      ✏️         ✏️       ✏️      ✏️        ✏️        -
F7 데이터 삭제           -       -        🆕      🆕         -        ✏️      ✏️        🆕        -
F8 푸시 알림             ✏️      🆕       🆕      🆕         ✏️       ✏️      ✏️        🆕        -
F9 프리미엄 디자인       ✏️      -        -       -          ✏️       ✏️      ✏️        -         🆕✏️

✏️ = 수정  🆕 = 신규 생성  📋 = 기존 복사+수정  - = 무관
```

### 2.2 핵심 발견: Foundation 변경이 필수

F1(개인모드)과 F2(역할 3분기)는 **core/router, data/models, 인증 플로우**를 건드립니다. 이건 **모든 Teammate에게 영향**을 주므로 반드시 Agent Teams 시작 전에 단일 세션으로 먼저 처리해야 합니다.

### 2.3 신규 데이터 모델

```dart
// F3: 개인 운동 기록
@freezed
class WorkoutLogModel with _$WorkoutLogModel {
  factory WorkoutLogModel({
    required String id,
    required String userId,
    required DateTime workoutDate,
    required int durationMinutes,        // 총 운동 시간 (분)
    required List<WorkoutExercise> exercises,
    String? notes,
    required DateTime createdAt,
  }) = _WorkoutLogModel;
}

@freezed
class WorkoutExercise with _$WorkoutExercise {
  factory WorkoutExercise({
    required String name,              // 운동 종목
    required int sets,                 // 세트 수
    required int reps,                 // 횟수
    double? weight,                    // 무게 (kg)
    int? restSeconds,                  // 휴식 시간
    required int order,                // 순서
  }) = _WorkoutExercise;
}

// F4: 트레이너 전환 요청
@freezed
class TrainerTransferModel with _$TrainerTransferModel {
  factory TrainerTransferModel({
    required String id,
    required String memberId,
    required String fromTrainerId,     // 기존 트레이너
    required String toTrainerId,       // 새 트레이너
    required TransferStatus status,    // pending | accepted | rejected
    required bool memberApproved,      // 회원 수락 여부
    required bool dataTransferred,     // 데이터 이전 완료 여부
    DateTime? respondedAt,
    required DateTime createdAt,
  }) = _TrainerTransferModel;
}

// F5: 인바디 OCR 결과
@freezed
class InbodyOcrResult with _$InbodyOcrResult {
  factory InbodyOcrResult({
    required double weight,
    double? bodyFatPercent,
    double? muscleMass,
    double? bmi,
    double? bmr,
    double? bodyWater,
    double? visceralFat,
    required double confidence,        // OCR 신뢰도
    required String imageUrl,
    required DateTime measuredAt,
  }) = _InbodyOcrResult;
}
```

### 2.4 신규 Firestore 컬렉션

```
기존 18개 + 신규 2개:

workout_logs/              # F3: 개인 운동 기록
  {logId}/
trainer_transfers/         # F4: 트레이너 전환 요청
  {transferId}/
```

### 2.5 신규/수정 Cloud Functions

```
신규 (6개):
- analyzeInbodyImage       # F5: 인바디 사진 OCR (Claude Vision)
- initiateTrainerTransfer  # F4: 트레이너 전환 요청 생성
- respondTrainerTransfer   # F4: 전환 수락/거절 처리
- deleteUserTrainerData    # F7: 특정 트레이너 관련 데이터 삭제
- sendPushNotification     # F8: 범용 푸시 알림 전송 (FCM)
- onNewMessage             # F8: 메시지 생성 트리거 → 자동 푸시

수정 (3개):
- generateInsights         # F6: 인사이트 프롬프트 전면 개선
- generateMemberInsights   # F6: 회원별 인사이트 개선
- dailyInsightGenerator    # F6: 일간 인사이트 트리거 개선
```

### 2.6 신규 Riverpod 프로바이더

```
신규 (4개):
- workoutLogProvider       # F3: 개인 운동 기록 CRUD
- trainerTransferProvider  # F4: 트레이너 전환 상태 관리
- inbodyOcrProvider        # F5: 인바디 OCR 분석 상태
- pushNotificationProvider # F8: FCM 토큰 관리, 배지 카운트, 알림 설정

수정 (4개):
- authProvider             # F2: 역할 3분기 (personal 추가)
- insightProvider          # F6: 인사이트 타입/표시 로직 개선
- membersProvider          # F4: 트레이너 전환 시 회원 목록 갱신
- chatProvider             # F8: 메시지 발송 시 푸시 트리거 연동 + 읽음 처리 시 배지 감소
```

### 2.7 F8 푸시 알림 상세 설계

```dart
// 신규 모델
@freezed
class NotificationSettingsModel with _$NotificationSettingsModel {
  factory NotificationSettingsModel({
    required String userId,
    required String fcmToken,
    @Default(true) bool dmMessages,          // DM 메시지 알림
    @Default(true) bool ptReminders,         // PT 일정 리마인더
    @Default(true) bool aiInsights,          // AI 인사이트 알림
    @Default(true) bool trainerTransfer,     // 트레이너 전환 요청
    @Default(true) bool weeklyReport,        // 주간 리포트
    required DateTime updatedAt,
  }) = _NotificationSettingsModel;
}
```

**필요 패키지:**
```yaml
# pubspec.yaml 추가
firebase_messaging: ^15.0.0      # FCM 푸시 알림
flutter_local_notifications: ^17.0.0  # 포그라운드 알림 표시
flutter_app_badger: ^1.5.0       # 앱 아이콘 배지 숫자
```

**푸시 알림 시나리오:**

| 이벤트 | 알림 제목 | 알림 본문 | 배지 | 우선순위 |
|--------|----------|----------|------|---------|
| DM 메시지 | "김트레이너님" | "내일 10시에 뵐게요!" (메시지 미리보기) | +1 | HIGH |
| PT 일정 리마인더 | "PT 수업 1시간 전" | "오늘 14:00 김민수 회원과 PT" | +1 | HIGH |
| 트레이너 전환 요청 | "새 트레이너 요청" | "○○ 트레이너가 연결 요청을 보냈어요" | +1 | HIGH |
| AI 인사이트 | "새로운 인사이트" | "김민수님 이탈 위험 감지됨" | +1 | MEDIUM |
| 주간 리포트 | "주간 리포트 도착" | "이번 주 운동 3회, 체중 -0.3kg" | +1 | LOW |
| 읽음 처리 | - | - | -1 (감소) | - |

**FCM 아키텍처:**
```
메시지 전송 → Firestore messages/ 컬렉션 write
  → onNewMessage CF 트리거 (Firestore onCreate)
    → 수신자 FCM 토큰 조회
    → 알림 설정 확인 (dmMessages: true?)
    → FCM 전송 (title, body, data, badge)
      → Android: 알림 채널 (PAL Messages)
      → iOS: APNs + badge count
```

### 2.8 F9 프리미엄 디자인 시스템 상세

```
┌─────────────────────────────────────────────────────┐
│              PAL 프리미엄 디자인 시스템               │
├─────────────────────────────────────────────────────┤
│                                                     │
│  1. 햅틱 피드백 (HapticFeedback)                    │
│     - 버튼 클릭: lightImpact                        │
│     - 토글 전환: mediumImpact                       │
│     - 삭제/경고: heavyImpact                        │
│     - 성공 완료: HapticFeedback.vibrate()           │
│                                                     │
│  2. 화면 전환 애니메이션 (Page Transitions)          │
│     - 기본: SharedAxisTransition (수평)              │
│     - 모달: SlideTransition (아래→위)               │
│     - 탭 전환: FadeThrough (200ms)                  │
│     - go_router CustomTransitionPage 활용           │
│                                                     │
│  3. 마이크로 인터랙션                                │
│     - 버튼 누르기: scale 0.95 → 1.0 (100ms)        │
│     - 카드 탭: elevation 변화 + 미세한 scale         │
│     - 스위치: 색상 전환 + 위치 이동 (200ms)          │
│     - FAB: rotate + scale 애니메이션                 │
│                                                     │
│  4. 스켈레톤 UI (shimmer)                            │
│     - 모든 리스트/카드에 shimmer 스켈레톤 필수        │
│     - shimmer 색상: 다크모드 대응                    │
│     - 실제 데이터 구조와 동일한 형태                  │
│                                                     │
│  5. 사운드 피드백                                     │
│     - 운동 완료: 경쾌한 성공음                       │
│     - 기록 저장: 짧은 확인음                         │
│     - 에러: 부드러운 경고음                          │
│     - 구현: audioplayers 패키지 + assets/sounds/     │
│     - 설정에서 ON/OFF 가능                           │
│                                                     │
│  6. 히어로 위젯 (Hero Animation)                     │
│     - 프로필 이미지: 목록 → 상세 전환                │
│     - 인사이트 카드: 홈 → 상세 전환                  │
│     - 차트 미니 → 전체 화면 전환                     │
│     - Hero tag 네이밍: 'hero-{type}-{id}'           │
│                                                     │
│  7. 글래스모피즘 + 깊이감                            │
│     - BackdropFilter + blur(10) for 오버레이        │
│     - 배경: 반투명 white.withOpacity(0.7)           │
│     - 그림자: 연한 2단계 (ambient + directional)     │
│     - 다크모드: blur(15) + black.withOpacity(0.5)   │
│                                                     │
│  8. Lottie/Rive 애니메이션                           │
│     - 온보딩 슬라이드: Lottie 일러스트              │
│     - AI 분석 중: Rive 로딩 스피너                   │
│     - 목표 달성: Lottie 축하 애니메이션              │
│     - PR 달성: Rive 메달 애니메이션                  │
│     - 빈 상태: Lottie 일러스트                      │
│     - 패키지: lottie: ^3.0.0, rive: ^0.13.0        │
│     - 에셋: assets/animations/                      │
│                                                     │
│  9. 스크롤 + 캐싱                                    │
│     - BouncingScrollPhysics (iOS 스타일)            │
│     - CachedNetworkImage + fadeIn (300ms)           │
│     - SliverAppBar + 스크롤 연동 축소               │
│     - ListView.builder + AutomaticKeepAlive         │
│     - 패키지: cached_network_image: ^3.3.0          │
│                                                     │
│  10. 프리텐다드 타이포그래피                          │
│      - Display: 24pt Bold, letterSpacing: -0.5      │
│      - Title: 18pt SemiBold                         │
│      - Body: 15pt Regular, height: 1.5              │
│      - Caption: 12pt Regular, color: grey           │
│      - 숫자: Tabular Figures (고정폭 숫자)           │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**필요 패키지:**
```yaml
# pubspec.yaml 추가 (F9)
lottie: ^3.0.0                   # Lottie 애니메이션
rive: ^0.13.0                    # Rive 애니메이션
audioplayers: ^6.0.0             # 사운드 피드백
cached_network_image: ^3.3.0     # 이미지 캐싱 + 페이드인
flutter_animate: ^4.5.0          # 마이크로 인터랙션 (기존)
```

---

## 3. CLAUDE.md 템플릿

```markdown
# PAL - AI PT 관리 플랫폼

## 프로젝트 상태
Production 앱 (1.0.4+7), 스토어 배포 완료, 170+ 파일

## 기술 스택
- Flutter 3.10+ / Dart 3.10+ / Riverpod 3.1.0 / go_router 17.0.1
- Firebase Auth + Firestore + Cloud Functions (TypeScript)
- Supabase Storage / Claude API (Anthropic)
- flex_color_scheme 8.4.0 / Pretendard 폰트

## 디자인 (토스 스타일)
- Primary: #0064FF / Success: #00C471 / Error: #F04452 / Warning: #FF8A00
- 카드: borderRadius 20, 패딩 20, 최소 그림자
- 애니메이션: 200ms fadeIn, 0.02 slideY, 50ms stagger
- UX 라이팅: 토스 해요체 ("저장됐어요", "삭제할까요?")

## 프리미엄 디자인 필수 규칙
- 햅틱: 모든 버튼 HapticFeedback.lightImpact(), 토글 mediumImpact, 삭제 heavyImpact
- 전환: go_router CustomTransitionPage + SharedAxisTransition(수평), 모달은 SlideUp
- 마이크로: 버튼 press scale 0.95→1.0(100ms), 카드 탭 elevation 변화
- 스켈레톤: 모든 리스트/카드에 shimmer 필수 (다크모드 대응)
- 사운드: 운동완료=성공음, 기록저장=확인음, 에러=경고음 (설정에서 ON/OFF)
- 히어로: 프로필/인사이트/차트 전환 시 Hero(tag: 'hero-{type}-{id}')
- 글래스모피즘: BackdropFilter blur(10) + white.withOpacity(0.7), 다크 blur(15)
- Lottie/Rive: 온보딩=Lottie, AI분석중=Rive, 목표달성=Lottie 축하
- 스크롤: BouncingScrollPhysics, CachedNetworkImage fadeIn(300ms)
- 폰트: Pretendard (Display 24pt Bold, Title 18pt SemiBold, Body 15pt Regular)

## 푸시 알림 시스템
- FCM + flutter_local_notifications + flutter_app_badger
- DM 메시지 알림 필수 (앱 미실행 상태에서도 수신)
- 알림 내용에 메시지 미리보기 포함
- 앱 아이콘 배지(빨간 숫자) 표시
- 읽음 처리 시 배지 -1
- 알림 설정: DM/PT리마인더/AI인사이트/전환요청/주간리포트 개별 ON/OFF

## 사용자 역할 (3가지) ← 업데이트됨
- trainer: PT 트레이너
- member: PT 수강 회원 (트레이너 코드 연결)
- personal: 개인모드 (독립 사용자 - 신규가입 또는 PT 종료 회원)
  * 회원(member)과 동일한 UI를 공유하되, 트레이너 관련 기능 숨김
  * 개인 운동 기록, 식단 기록, 체성분 기록, AI 인사이트 사용 가능

## 개인모드(personal) UI 규칙
회원 화면을 재사용하되 다음 요소는 숨김:
- 트레이너 정보 카드, PT 진행 상황 카드
- 트레이너 채팅/메시지 탭
- 트레이너 평가 화면
- PT 캘린더 (개인 캘린더로 대체)
- 커리큘럼 뷰 (대신 개인 운동 기록 사용)
표시 여부는 `isPersonalMode` 플래그로 조건부 렌더링

## 프로젝트 구조
lib/
├── core/          # 라우터, 테마, 상수, 유틸 (⚠️ 수정 시 전체 영향)
├── data/
│   ├── models/    # 26개+ Freezed 모델 (⚠️ 수정 시 전체 영향)
│   ├── repositories/  # 24개+ Firestore CRUD
│   └── services/      # 7개 외부 서비스
├── presentation/
│   ├── screens/
│   │   ├── auth/      # 인증, 온보딩, 역할 선택
│   │   ├── trainer/   # 트레이너 전용 화면
│   │   ├── member/    # 회원 + 개인모드 공유 화면
│   │   ├── web/       # 웹 대시보드
│   │   └── common/    # 공통 (채팅, 알림)
│   ├── widgets/
│   └── providers/     # 27개+ Riverpod 프로바이더
functions/src/         # 41개+ Cloud Functions (TypeScript)

## ⚠️ 파일 충돌 방지
1. core/, data/models/ → 반드시 1명만
2. 같은 프로바이더 파일 동시 수정 금지
3. pubspec.yaml → Lead만 수정
4. 회원(member) 화면 수정 시 개인모드(personal) 영향 반드시 확인
```

---

## 4. 팀 구성 전략 (3단계)

전체 작업을 3개 Stage로 나눕니다. Stage 1은 단일 세션(팀 X), Stage 2~3은 Agent Teams입니다.

```
┌────────────────────────────────────────────────┐
│  Stage 1: Foundation 변경 (단일 세션) ← 선행 필수│
│  F1 개인모드 모델/라우터                         │
│  F2 역할 선택 3분기                              │
│  F3 WorkoutLog 모델 추가                         │
│  F4 TrainerTransfer 모델 추가                    │
│  F8 NotificationSettings 모델 + FCM 초기화       │
│  F9 디자인 유틸 + 패키지 + 에셋 디렉토리          │
│  + build_runner 실행                             │
│  소요: 2~3일                                     │
└─────────────────────┬──────────────────────────┘
                      │
┌─────────────────────▼──────────────────────────┐
│  Stage 2: 메인 병렬 개발 (Agent Teams 7명)      │
│  T1: 개인모드 + 운동기록 UI (member/personal)    │
│  T2: 트레이너 전환 시스템 (trainer + member)     │
│  T3: 인바디 OCR (member)                         │
│  T4: Cloud Functions (backend)                   │
│  T5: 프로바이더 + Repository (data layer)        │
│  T6: 푸시 알림 시스템 (FCM + 배지 + 설정)        │
│  T7: 프리미엄 디자인 시스템 (위젯 + 에셋)        │
│  소요: 4~6일                                     │
└─────────────────────┬──────────────────────────┘
                      │
┌─────────────────────▼──────────────────────────┐
│  Stage 3: AI 인사이트 고도화 (Agent Teams 3명)  │
│  T1: 트레이너 인사이트 (프롬프트 + UI)           │
│  T2: 회원/개인 인사이트 (프롬프트 + UI)          │
│  T3: CF 인사이트 엔진 개선 (backend)             │
│  소요: 2~3일                                     │
└────────────────────────────────────────────────┘
```

---

## 5. Stage 1: Foundation 변경 (단일 세션)

**⚠️ Agent Teams 사용하지 않음. 단일 Claude Code 세션으로 처리.**

### 처리 항목

```
1. UserRoleType enum 수정
   기존: trainer | member | self
   변경: trainer | member | personal
   파일: lib/data/models/user_model.dart

2. WorkoutLogModel + WorkoutExercise 신규 Freezed 모델 추가
   파일: lib/data/models/workout_log_model.dart

3. TrainerTransferModel 신규 Freezed 모델 추가
   파일: lib/data/models/trainer_transfer_model.dart

4. InbodyOcrResult 모델 추가 (또는 기존 InbodyModel 확장)
   파일: lib/data/models/inbody_ocr_result.dart

5. NotificationSettingsModel 신규 Freezed 모델 추가
   파일: lib/data/models/notification_settings_model.dart
   필드: userId, fcmToken, dmMessages, ptReminders, aiInsights,
         trainerTransfer, weeklyReport, updatedAt

6. go_router 라우팅 업데이트
   - /role-selection → 3가지 선택지
   - /personal/* 라우트 추가 (회원 라우트 미러링)
   - /member/workout-log 추가
   - /member/inbody-ocr 추가
   파일: lib/core/router/app_router.dart
   - 모든 라우트에 CustomTransitionPage 적용 (SharedAxisTransition)

7. pubspec.yaml 패키지 추가
   - firebase_messaging: ^15.0.0
   - flutter_local_notifications: ^17.0.0
   - flutter_app_badger: ^1.5.0
   - lottie: ^3.0.0
   - rive: ^0.13.0
   - audioplayers: ^6.0.0
   - cached_network_image: ^3.3.0

8. 프리미엄 디자인 유틸리티 생성
   - lib/core/utils/haptic_utils.dart (햅틱 피드백 래퍼)
   - lib/core/utils/sound_utils.dart (사운드 피드백 래퍼)
   - lib/core/utils/page_transitions.dart (커스텀 전환 애니메이션)
   - assets/sounds/ 디렉토리 생성 (success.mp3, confirm.mp3, warning.mp3)
   - assets/animations/ 디렉토리 생성 (Lottie/Rive 에셋)

9. FCM 초기화 코드 추가
   - main.dart에 Firebase Messaging 초기화
   - 포그라운드/백그라운드 메시지 핸들러 등록
   - iOS: APNs 권한 요청 코드
   - Android: 알림 채널 생성 (PAL Messages, PAL Reminders)

10. build_runner 실행
    dart run build_runner build --delete-conflicting-outputs

11. Git commit
```

### 프롬프트

```
PAL 앱에 다음 Foundation 변경을 해줘:

1. UserRoleType에 'personal' 추가 (기존 'self'를 'personal'로 변경)
2. 신규 Freezed 모델 4개 추가:
   - WorkoutLogModel (userId, workoutDate, durationMinutes, exercises[], notes)
   - WorkoutExercise (name, sets, reps, weight?, restSeconds?, order)
   - TrainerTransferModel (memberId, fromTrainerId, toTrainerId, status, memberApproved)
   - InbodyOcrResult (weight, bodyFatPercent?, muscleMass?, bmi?, confidence, imageUrl)
   - NotificationSettingsModel (userId, fcmToken, dmMessages, ptReminders, aiInsights, trainerTransfer, weeklyReport)
3. go_router에 라우트 추가:
   - /personal/* (member 라우트 미러링, Shell 네비 바텀탭 구조 동일)
   - /member/workout-log (개인 운동 기록)
   - /member/workout-log/add (운동 기록 추가)
   - /member/inbody-ocr (인바디 사진 OCR)
   - 모든 라우트에 CustomTransitionPage 적용 (SharedAxisTransition 수평)
4. 역할 선택 화면에 '개인 모드' 선택지 추가
5. pubspec.yaml에 패키지 추가:
   firebase_messaging, flutter_local_notifications, flutter_app_badger,
   lottie, rive, audioplayers, cached_network_image
6. 프리미엄 디자인 유틸리티 생성:
   - lib/core/utils/haptic_utils.dart (lightImpact/mediumImpact/heavyImpact 래퍼)
   - lib/core/utils/sound_utils.dart (playSuccess/playConfirm/playWarning)
   - lib/core/utils/page_transitions.dart (SharedAxisTransition/SlideUp/FadeThrough)
   - assets/sounds/ 디렉토리 + assets/animations/ 디렉토리 생성
7. main.dart에 FCM 초기화:
   - FirebaseMessaging.instance.requestPermission()
   - 포그라운드 메시지 핸들러 (flutter_local_notifications로 표시)
   - 백그라운드 메시지 핸들러 등록
   - Android 알림 채널 2개: 'pal_messages' (DM), 'pal_reminders' (PT 리마인더)
8. build_runner 실행

기존 코드 인터페이스는 최대한 유지하고, 새 모델/라우트/유틸만 추가해줘.
```

---

## 6. Stage 2: 메인 병렬 개발 (Agent Teams 7명)

### 환경 설정

```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

### 팀 생성 마스터 프롬프트

```
PAL 앱의 대규모 기능 추가를 위한 Agent Team을 만들어줘.
Foundation 변경(모델, 라우터, 패키지, FCM 초기화, 디자인 유틸)은 이미 완료됐어.

팀 구성 (7명):

1. "personal-mode" — 개인모드 + 운동 기록 UI 전담
   작업 범위: lib/presentation/screens/member/ (개인모드 공유 화면)
   
   작업 내용:
   a) 회원 화면에 isPersonalMode 조건부 렌더링 추가
      - 숨길 것: 트레이너 정보 카드, PT 진행 카드, 채팅 탭,
        트레이너 평가, PT 캘린더 일정
      - 보여줄 것: 개인 운동 기록 카드, 식단 기록, 체성분 기록,
        AI 인사이트, 월간 리포트
   b) 개인 운동 기록 화면 신규 (WorkoutLogScreen)
      - 오늘 운동 기록 목록 (운동종목, 세트, 무게, 횟수)
      - 운동 추가 화면 (종목 검색 + 수동 입력)
      - 운동 타이머 (시작/정지, 총 운동 시간 표시 - 시간:분)
      - 일별/주별/월별 운동 히스토리
   c) MemberHomeScreen에 개인모드 전용 레이아웃
      - 오늘 운동 요약 카드 (총 시간, 종목 수)
      - 이번 주 운동 일수 카드
      - 최근 체중 변화 미니 그래프
      - AI 인사이트 카드
   
   디자인: 토스 스타일, shimmer 로딩, 200ms 애니메이션
   ⚠️ lib/core/, lib/data/models/ 수정 금지

2. "trainer-transfer" — 트레이너 전환 시스템 전담
   작업 범위:
   - lib/presentation/screens/trainer/ (트레이너 측 UI)
   - lib/presentation/screens/member/ (회원 측 UI) 중 전환 관련만
   
   작업 내용:
   a) 회원 측 - 새 트레이너 초대 수락 화면
      - "○○ 트레이너가 요청을 보냈어요" 다이얼로그
      - 수락 시: 기존 트레이너 연결 해제 + 새 트레이너 연결
      - 거절 시: 기존 트레이너 유지
      - 수락 전 안내: "수락하면 회원 정보가 새 트레이너에게 공유돼요"
   b) 트레이너 측 - 회원 이동 알림
      - "○○님이 다른 트레이너로 이동했어요" 알림 카드
      - "정보를 삭제할까요?" 버튼 (데이터 삭제 선택)
      - 삭제하지 않으면 읽기 전용으로 보관
   c) 회원 측 - 과거 트레이너 데이터 관리
      - 설정 > 내 데이터 관리 화면
      - 과거 트레이너별 데이터 목록 (기간, 기록 수)
      - 선택적 삭제: "이 트레이너와의 기록을 삭제할까요?"
   d) 전환 플로우 (기존 자동 끊김 제거)
      - 새 트레이너가 초대코드 입력 → 회원에게 알림 →
        회원 수락 → 기존 트레이너에게 이동 알림 →
        데이터 이전 완료
   
   ⚠️ 기존 trainer_requests 시스템과 충돌하지 않게 주의

3. "inbody-ocr" — 인바디 사진 OCR 기능 전담
   작업 범위: lib/presentation/screens/member/inbody/ 관련 파일
   
   작업 내용:
   a) 인바디 사진 촬영/갤러리 선택 화면
      - 카메라 모드: 인바디 결과지에 가이드 프레임 오버레이
      - 갤러리 선택 지원
   b) AI 분석 결과 확인 화면
      - 추출된 수치 표시: 체중, 체지방률, 근육량, BMI, BMR, 체수분, 내장지방
      - 신뢰도 표시 (confidence)
      - 수동 수정 가능 (AI가 잘못 읽었을 때)
      - "확인" 누르면 body_records에 자동 저장
   c) 기존 인바디 화면(/member/inbody)에 "사진으로 기록" 버튼 추가
   
   ⚠️ Supabase Storage에 이미지 업로드 후 URL을 CF에 전달

4. "backend" — Cloud Functions 전담
   작업 범위: functions/src/ 만
   
   작업 내용:
   a) analyzeInbodyImage (신규 HTTP CF)
      - Claude Vision API로 인바디 결과지 이미지 분석
      - 프롬프트: "이 인바디 체성분 분석 결과지에서 다음 수치를 JSON으로 추출:
        체중, 체지방률, 골격근량, BMI, 기초대사량, 체수분, 내장지방"
      - 응답: { success, data: InbodyOcrResult, confidence }
   b) initiateTrainerTransfer (신규 HTTP CF)
      - 새 트레이너가 회원 초대 → trainer_transfers 컬렉션에 pending 생성
      - 회원에게 푸시 알림 전송
   c) respondTrainerTransfer (신규 HTTP CF)
      - 회원 수락: member.trainerId 변경 + 데이터 이전 + 기존 트레이너 알림
      - 회원 거절: status = rejected
   d) deleteUserTrainerData (신규 HTTP CF)
      - 특정 트레이너와 관련된 회원 데이터 선택적 삭제
      - 삭제 대상: 해당 트레이너가 만든 curriculums, 관련 schedules
      - 보존: body_records, diet_records (회원 본인 데이터)
   e) sendPushNotification (신규 HTTP CF)
      - 범용 푸시 알림 전송 함수
      - 입력: userId, title, body, data, notificationType
      - 수신자 FCM 토큰 조회 → 알림 설정 확인 → FCM 전송
      - Android: 알림 채널별 분기 (messages/reminders)
      - iOS: APNs badge count 포함
   f) onNewMessage (신규 Firestore 트리거 CF)
      - messages/{roomId}/messages/{messageId} onCreate 트리거
      - 수신자가 앱 비활성 상태인지 확인
      - 비활성이면 sendPushNotification 호출
      - 알림 제목: 발신자 displayName
      - 알림 본문: 메시지 content (50자 제한)
   
   ⚠️ 기존 CF의 Request/Response 인터페이스 변경 금지
   ⚠️ 모든 CF에 Firebase Auth 토큰 검증 필수

5. "data-layer" — Provider + Repository 전담
   작업 범위:
   - lib/presentation/providers/
   - lib/data/repositories/
   
   작업 내용:
   a) workoutLogProvider + workoutLogRepository 신규
      - CRUD: 운동 기록 생성/조회/수정/삭제
      - 일별/주별/월별 조회 쿼리
      - 총 운동 시간 계산
   b) trainerTransferProvider + trainerTransferRepository 신규
      - 전환 요청 생성/수락/거절
      - 대기 중 요청 실시간 리스너
   c) inbodyOcrProvider 신규
      - 이미지 업로드 → CF 호출 → 결과 파싱
      - 확인 시 bodyRecordsProvider에 저장 연동
   d) authProvider 수정
      - personal 역할 추가, 라우팅 분기
   e) membersProvider 수정
      - 트레이너 전환 시 회원 목록 갱신 로직
   
   ⚠️ 프로바이더 공개 인터페이스 변경 시 Lead에게 메시지
   ⚠️ 인터페이스 확정 후 UI 팀에게 알림

6. "push-notification" — 푸시 알림 시스템 전담
   작업 범위:
   - lib/presentation/providers/push_notification_provider.dart (신규)
   - lib/data/repositories/notification_repository.dart (신규)
   - lib/data/services/fcm_service.dart (신규)
   - lib/presentation/screens/*/settings/ (알림 설정 화면)
   
   작업 내용:
   a) FCM 서비스 구현
      - FCM 토큰 발급/갱신 → Firestore notification_settings에 저장
      - 포그라운드 메시지 수신 → flutter_local_notifications로 표시
      - 백그라운드 메시지 핸들러 (이미 main.dart에 등록됨)
      - 알림 클릭 시 해당 화면으로 이동 (go_router deep link)
   b) 앱 아이콘 배지 관리
      - flutter_app_badger로 배지 숫자 표시
      - 읽지 않은 알림 수 Firestore 실시간 리스너
      - 알림 읽음 처리 시 배지 -1
      - 앱 포그라운드 진입 시 배지 동기화
   c) 알림 설정 화면
      - 각 알림 유형별 ON/OFF 토글 (DM/PT/AI/전환/주간)
      - 방해 금지 시간 설정 (선택)
      - Firestore notification_settings 컬렉션 CRUD
   d) DM 메시지 푸시 연동
      - chatProvider에서 메시지 전송 시 푸시 트리거 확인
      - 메시지 미리보기 표시 (제목: 발신자명, 본문: 메시지 내용)
   
   ⚠️ iOS APNs 설정은 Xcode에서 별도 처리 필요 (Stage 1에서 기본 설정 완료)
   ⚠️ Android 알림 채널은 Stage 1에서 이미 생성됨

7. "premium-design" — 프리미엄 디자인 시스템 전담
   작업 범위:
   - lib/presentation/widgets/ (공유 위젯 수정/신규)
   - lib/core/utils/ (Stage 1에서 생성된 유틸 확장)
   - assets/animations/ (Lottie/Rive 에셋)
   - assets/sounds/ (사운드 에셋)
   
   작업 내용:
   a) 공통 위젯 프리미엄화
      - AppButton: 햅틱 피드백 + press scale animation + 사운드 피드백
      - AppCard: 글래스모피즘 옵션 + elevation 애니메이션 + 탭 리플 효과
      - AppTextField: focus 시 border 애니메이션 + 햅틱
      - AppDialog: BackdropFilter 블러 배경 + SlideUp 등장
      - AppBottomSheet: 글래스모피즘 + 드래그 핸들 애니메이션
      - AppSnackbar: slide-in + auto-dismiss 애니메이션
      - AppListTile: 탭 시 scale 마이크로 인터랙션
   b) 스켈레톤 UI 표준화
      - SkeletonCard, SkeletonList, SkeletonChart 위젯 생성
      - 다크모드 대응 shimmer 색상
      - 실제 데이터 구조와 동일한 형태 유지
   c) 이미지 캐싱 시스템
      - CachedNetworkImage 래퍼 위젯 (PalCachedImage)
      - 로딩: shimmer 표시 → 페이드인(300ms)
      - 에러: 기본 플레이스홀더 이미지
   d) Lottie/Rive 에셋 통합
      - 온보딩 슬라이드 Lottie 파일 (3개)
      - AI 분석 중 Rive 스피너
      - 목표 달성/PR 축하 Lottie 파일
      - 빈 상태 일러스트 Lottie 파일
      - PalLottie, PalRive 래퍼 위젯
   e) 스크롤 물리 효과
      - 앱 전체 기본 ScrollPhysics: BouncingScrollPhysics
      - SliverAppBar + 스크롤 연동 축소 패턴 표준화
      - 무한 스크롤 시 부드러운 로딩 인디케이터
   
   ⚠️ 이 Teammate는 lib/presentation/widgets/만 수정 (screens/ 수정 금지)
   ⚠️ 위젯 인터페이스 변경 시 모든 UI Teammate에게 메시지 필수
   ⚠️ Lottie/Rive 에셋은 LottieFiles.com에서 무료 에셋 URL 사용 또는 placeholder

규칙:
- Plan approval 필수 - 각 Teammate가 계획 제출 후 승인받고 작업
- data-layer가 Provider 인터페이스 확정 → personal-mode, trainer-transfer에 메시지
- backend가 CF 인터페이스 확정 → inbody-ocr, data-layer에 메시지
- Delegate Mode 사용 (Lead는 코드 작성 X, 조율만)
```

### Stage 2 태스크 의존성

```
[Stage 1 완료: Foundation + FCM 초기화 + 디자인 유틸] ← 선행 조건
     │
     ├──→ Task 1: workoutLogProvider + Repo (data-layer) ← 독립
     ├──→ Task 2: trainerTransferProvider + Repo (data-layer) ← 독립
     ├──→ Task 3: inbodyOcrProvider (data-layer) ← 독립
     ├──→ Task 4: pushNotificationProvider + Repo (data-layer) ← 독립
     │
     ├──→ Task 5: analyzeInbodyImage CF (backend) ← 독립
     ├──→ Task 6: initiateTrainerTransfer CF (backend) ← 독립
     ├──→ Task 7: respondTrainerTransfer CF (backend) ← blockedBy [Task 6]
     ├──→ Task 8: deleteUserTrainerData CF (backend) ← 독립
     ├──→ Task 9: sendPushNotification CF (backend) ← 독립
     ├──→ Task 10: onNewMessage 트리거 CF (backend) ← blockedBy [Task 9]
     │
     ├──→ Task 11: 개인모드 조건부 UI (personal-mode) ← blockedBy [Task 1]
     ├──→ Task 12: 운동 기록 화면 (personal-mode) ← blockedBy [Task 1]
     ├──→ Task 13: 개인모드 홈 레이아웃 (personal-mode) ← blockedBy [Task 1]
     │
     ├──→ Task 14: 회원 측 전환 수락 UI (trainer-transfer) ← blockedBy [Task 2]
     ├──→ Task 15: 트레이너 측 이동 알림 UI (trainer-transfer) ← blockedBy [Task 2]
     ├──→ Task 16: 데이터 관리/삭제 화면 (trainer-transfer) ← blockedBy [Task 2]
     │
     ├──→ Task 17: 인바디 OCR UI (inbody-ocr) ← blockedBy [Task 3, Task 5]
     │
     ├──→ Task 18: FCM 서비스 + 배지 관리 (push-notification) ← blockedBy [Task 4]
     ├──→ Task 19: 알림 설정 화면 (push-notification) ← blockedBy [Task 4]
     ├──→ Task 20: DM 푸시 연동 (push-notification) ← blockedBy [Task 4, Task 10]
     │
     ├──→ Task 21: 공통 위젯 프리미엄화 (premium-design) ← 독립 (Stage 1 유틸 사용)
     ├──→ Task 22: 스켈레톤 UI + 이미지 캐싱 (premium-design) ← 독립
     ├──→ Task 23: Lottie/Rive 에셋 통합 (premium-design) ← 독립
     └──→ Task 24: 스크롤 물리 + 글래스모피즘 (premium-design) ← 독립
```

**핵심 병렬성**: premium-design(T7)은 다른 모든 팀과 완전히 독립적으로 작업 가능. push-notification(T6)도 data-layer 이후 바로 독립 진행.

---

## 7. Stage 3: AI 인사이트 고도화 (Agent Teams 3명)

Stage 2 완료 후 팀 해체 → 새 팀 구성

### 인사이트 설계: 트레이너 vs 회원/개인

#### 트레이너 인사이트 (실행 가능한 비즈니스 조언)

| 유형 | 현재 (퀄리티 낮음) | 개선 후 | 우선순위 |
|------|------------------|--------|---------|
| 이탈 위험 | "김민수님 출석률이 낮습니다" | "김민수님이 2주간 출석률 40% 하락했어요. 비슷한 패턴의 회원 중 70%가 1개월 내 이탈했어요. 이번 주 중 연락해보세요" | 🔴 HIGH |
| 재등록 타이밍 | 없음 | "이수진님 PT 5회 남았어요. 지금까지 체중 -4.2kg 달성했고, 목표까지 2.1kg 남았어요. '목표 달성까지 조금만 더!' 로 재등록 제안하기 좋은 시점이에요" | 🔴 HIGH |
| 운동 성과 | "운동 성과가 좋습니다" | "박지영님 벤치프레스 4주간 +15kg 향상! 상체 근력이 빠르게 느는 중이에요. 다음 단계로 인클라인 벤치프레스를 추가해보세요" | 🟡 MED |
| 커리큘럼 제안 | 없음 | "최근 3명의 회원이 하체 운동에서 무릎 통증을 호소했어요. 레그프레스를 힙 스러스트로 대체하면 부상 위험을 줄일 수 있어요" | 🟡 MED |
| 수익 분석 | 없음 | "이번 달 수업 32회 완료, 예상 수입 480만원이에요. 지난달 대비 +12%. 특히 금요일 오후 시간대가 비어있어요" | 🟢 LOW |
| 전체 현황 | "회원 10명 관리 중" | "활성 회원 10명 중 8명이 주 2회 이상 출석 중이에요. 이번 주 집중 관리 대상: 김민수(이탈 위험), 이수진(재등록 임박)" | 🟡 MED |

#### 회원/개인모드 인사이트 (동기부여 + 구체적 가이드)

| 유형 | 현재 | 개선 후 | 우선순위 |
|------|------|--------|---------|
| 체성분 변화 | "체중이 줄었습니다" | "지난 4주간 체중 -2.1kg, 근육량 +0.8kg! 체지방만 빠지고 있어서 이상적인 다이어트 중이에요 💪" | 🔴 HIGH |
| 목표 달성 예측 | "순조롭습니다" | "현재 속도라면 목표 체중 70kg에 5주 후 도달해요. 주 3회 운동 + 일일 단백질 120g 유지하면 가능해요" | 🔴 HIGH |
| 운동 성과 | "중량이 늘었습니다" | "스쿼트 1RM이 지난달 대비 +10kg! 하체 근력 상위 30% 수준이에요. 이번 주 불가리안 스플릿 스쿼트로 약점을 보완해보세요" | 🟡 MED |
| 식단 피드백 | "식단을 기록해주세요" | "이번 주 평균 단백질 섭취 98g인데, 근육 성장을 위해 120g이 필요해요. 아침에 계란 2개(+14g) 추가하면 쉽게 채울 수 있어요" | 🟡 MED |
| 운동 일관성 | 없음 | "이번 달 12일 운동했어요! 지난달 8일 대비 +50% 🔥 꾸준함이 최고의 무기에요. 이번 주도 3회 목표 달성해볼까요?" | 🟡 MED |
| 휴식 제안 | 없음 | "5일 연속 운동했어요. 근육 회복을 위해 오늘은 가벼운 스트레칭이나 휴식을 추천해요. 쉬는 것도 운동의 일부에요 😊" | 🟢 LOW |
| 주간 리포트 | "이번 주 운동 3회" | "이번 주 요약: 운동 3회(2시간 15분), 체중 -0.3kg, 식단 평균 1,800kcal. 단백질 비율이 높아서 좋은 흐름이에요!" | 🟡 MED |

### 팀 생성 프롬프트

```
PAL AI 인사이트 시스템을 전면 개선하기 위한 Agent Team을 만들어줘.

팀 구성 (3명):

1. "trainer-insights" — 트레이너 인사이트 UI + 프롬프트
   작업 범위: lib/presentation/screens/trainer/insights/ 관련
   
   작업:
   - TrainerHomeScreen의 인사이트 카드 개선
   - 인사이트 상세 화면 리디자인
   - 인사이트 유형별 아이콘/색상 차별화:
     * 이탈 위험 (🔴 Error Red) → 즉시 행동 필요
     * 재등록 타이밍 (🟡 Warning Orange) → 기회 포착
     * 운동 성과 (🟢 Success Green) → 긍정적 피드백
     * 커리큘럼 제안 (🔵 Primary Blue) → 전문성 향상
     * 수익 분석 (🟣 AI Accent) → 비즈니스 인사이트
   - 인사이트 필터 (전체/긴급/성과/제안)
   - 각 인사이트에 "실행" 버튼 (이탈 위험 → 채팅 열기, 재등록 → 알림 보내기)

2. "member-insights" — 회원/개인모드 인사이트 UI + 프롬프트
   작업 범위: lib/presentation/screens/member/insights/ 관련
   
   작업:
   - MemberHomeScreen의 인사이트 카드 개선
   - 동기부여 중심 UI (이모지, 응원 메시지, 진행 바)
   - 인사이트 유형별 디자인:
     * 체성분 변화 → 전후 비교 미니 차트
     * 목표 예측 → 진행 게이지 + 예상 날짜
     * 운동 성과 → 개인 기록(PR) 축하 애니메이션
     * 식단 피드백 → 영양소 도넛 차트
     * 주간 리포트 → 요약 카드 (운동/식단/체성분)
   - 개인모드 전용: 트레이너 없이도 의미있는 인사이트
     * "혼자서도 잘하고 있어요" 격려 메시지
     * 자기 기록 vs 지난달 비교

3. "insight-engine" — Cloud Functions 인사이트 프롬프트 개선
   작업 범위: functions/src/ 의 인사이트 관련 CF만
   
   작업:
   a) generateInsights CF 프롬프트 전면 개선
      - 트레이너용: 실행 가능한 구체적 조언 (누구를, 언제, 왜, 어떻게)
      - 회원용: 동기부여 + 구체적 수치 + 실천 가능한 팁
   b) dailyInsightGenerator 개선
      - 개인모드 사용자도 인사이트 생성 대상에 포함
      - 운동 기록 데이터(workout_logs) 분석 추가
   c) weeklyInsightGenerator 개선
      - 주간 리포트 인사이트 추가
      - 회원별 맞춤 목표 달성률 계산
   d) 인사이트 우선순위 로직 개선
      - HIGH: 이탈 위험, 목표 달성 임박, 연속 기록 깨짐 위기
      - MEDIUM: 운동 성과, 체성분 변화, 식단 피드백
      - LOW: 일반 팁, 휴식 제안, 격려

규칙:
- insight-engine이 새 프롬프트 확정 → trainer-insights, member-insights에 공유
- 인사이트 JSON 스키마가 변경되면 UI 팀에 즉시 메시지
- Plan approval 필수
```

---

## 8. 운영 가이드

### 8.1 파일 충돌 방지 매트릭스 (Stage 2)

| Teammate | 전용 영역 | 공유 위험 영역 |
|----------|---------|-------------|
| personal-mode | `screens/member/` (개인모드 관련) | member 화면 수정 시 trainer-transfer와 충돌 가능 |
| trainer-transfer | `screens/trainer/requests/`, `screens/member/settings/` | member 설정 화면은 personal-mode와 조율 필요 |
| inbody-ocr | `screens/member/inbody/` | 독립적 (충돌 낮음) |
| backend | `functions/src/` | 완전 독립 (Flutter 코드 미접촉) |
| data-layer | `providers/`, `repositories/` | 모든 UI 팀의 블로커 |
| push-notification | `providers/push_*`, `services/fcm_*`, `screens/*/settings/` | settings 화면은 personal-mode/trainer-transfer와 조율 |
| premium-design | `presentation/widgets/`, `core/utils/` | ⚠️ 위젯 인터페이스 변경 시 모든 UI 팀에 영향 |

### 8.2 핵심 조율 포인트

```
1. data-layer → UI 팀 전체 (블로킹)
   "workoutLogProvider 인터페이스 확정됐어요. 사용법:
    - watchWorkoutLogs(userId, date) → Stream<List<WorkoutLogModel>>
    - addWorkoutLog(log) → Future<void>
    - getTotalDuration(userId, startDate, endDate) → Future<int>"

2. backend → inbody-ocr + data-layer (블로킹)
   "analyzeInbodyImage CF 응답 스키마:
    { success: true, data: { weight, bodyFatPercent, muscleMass, ... }, confidence: 0.85 }"

3. personal-mode ↔ trainer-transfer (조율)
   "member/settings 화면에 '내 데이터 관리' 섹션을 추가할 건데,
    personal-mode도 이 화면을 쓰는지? → personal-mode에서는 '과거 PT 기록'으로 표시"

4. backend → push-notification (블로킹)
   "onNewMessage CF 완성됐어요. FCM payload 스키마:
    { title: senderName, body: messageContent, data: { roomId, type: 'dm' } }"

5. premium-design → 모든 UI 팀 (일방향 알림)
   "AppButton 위젯에 햅틱 피드백 + scale 애니메이션 추가했어요.
    기존 인터페이스 유지됨, 추가 파라미터:
    - enableHaptic: true (기본값)
    - enableScaleAnimation: true (기본값)
    - soundType: SoundType.none (기본값)"

6. push-notification ↔ trainer-transfer (조율)
   "트레이너 전환 요청 시 푸시 알림 필요. 
    trainerTransferProvider에서 pushNotificationProvider.sendTransferRequest() 호출할까요,
    아니면 backend CF에서 직접 FCM 전송?"
```

### 8.3 Delegate Mode 설정

```
팀 시작 후 즉시 Shift+Tab → Delegate Mode

Lead 판단 기준:
- Plan에 테스트 미포함 → reject
- 다른 Teammate 전용 파일 수정 → reject
- data/models/ 수정 시도 → reject ("Stage 1에서 완료됨, 추가 필요시 Lead에게 요청")
- 기존 Provider 인터페이스 변경 → reject + 대안 요청
```

### 8.4 점진적 도입 (처음이라면)

```
Day 1-2: Stage 1 (단일 세션) — Foundation + FCM + 디자인 유틸 + build_runner
Day 3: 코드 리뷰 Agent Team (3명) — Stage 1 결과 리뷰 (연습용)
Day 4-7: Stage 2 Agent Team (7명) — 본격 병렬 개발
Day 8: 통합 테스트 (단일 세션) — 전체 플로우 검증 + 푸시 실기기 테스트
Day 9-10: Stage 3 Agent Team (3명) — 인사이트 고도화
Day 11: 최종 테스트 + 디자인 QA + 스토어 제출
```

### 8.5 비용 판단

| 단계 | Teammate 수 | 예상 토큰 | ROI |
|------|:-----------:|----------|-----|
| Stage 1 (단일) | 1 | 보통 | Foundation + FCM + 디자인 유틸은 순차 처리가 안전 |
| Stage 2 (7명) | 7 | 7x | 7개 독립 기능 동시 개발 → 시간 1/4~1/5 |
| Stage 3 (3명) | 3 | 3x | 프롬프트+UI 동시 작업 → 시간 1/2 |

---

## 부록: 전체 변경 요약

```
신규 Freezed 모델:     +5 (WorkoutLog, WorkoutExercise, TrainerTransfer, InbodyOcr, NotificationSettings)
신규 Repository:       +4 (workoutLog, trainerTransfer, inbodyOcr, notification)
신규 Provider:         +4 (workoutLog, trainerTransfer, inbodyOcr, pushNotification)
신규 Service:          +1 (fcmService)
신규 Cloud Functions:  +6 (analyzeInbody, initTransfer, respondTransfer, deleteData, sendPush, onNewMessage)
수정 Cloud Functions:  +3 (generateInsights x2, dailyInsight)
신규 Firestore 컬렉션: +2 (workout_logs, trainer_transfers)
신규 유틸리티:         +3 (haptic_utils, sound_utils, page_transitions)
신규 에셋:             assets/sounds/ (3파일), assets/animations/ (5+파일)
신규 위젯:             +8 (PalCachedImage, PalLottie, PalRive, SkeletonCard, SkeletonList,
                           SkeletonChart + 기존 위젯 7개 프리미엄화)
신규 화면:             +8 (운동기록, 운동추가, 인바디OCR, 전환수락, 데이터관리, 개인홈, 알림설정, 알림목록)
수정 화면:             +10 (역할선택, 회원홈, 트레이너홈, 인바디, 설정x2, 인사이트x3, 채팅)
신규 pubspec 패키지:   +6 (firebase_messaging, flutter_local_notifications, flutter_app_badger,
                           lottie, rive, audioplayers)

총 변경 규모: 약 40개 파일 신규 + 25개 파일 수정
```
