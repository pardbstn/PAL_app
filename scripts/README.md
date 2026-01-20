# PAL 데모 데이터 스크립트

심사용 데모 데이터를 Firebase에 생성하는 스크립트입니다.

## 실행 방법

### 방법 1: Dart 스크립트 (권장)

```bash
cd scripts
dart pub get
dart run seed_demo_data.dart
```

**사전 준비:**
1. `scripts/seed_demo_data.dart` 파일 상단의 Firebase 설정 수정
2. Firebase Console > 프로젝트 설정에서 값 확인

```dart
const String firebaseProjectId = 'your-project-id';  // Firebase 프로젝트 ID
const String firebaseApiKey = 'YOUR_API_KEY';        // Web API Key
```

### 방법 2: Node.js 스크립트 (Firebase Admin SDK)

```bash
cd scripts
npm install
node seed_demo_data.js
```

**사전 준비:**
1. Firebase Console > 프로젝트 설정 > 서비스 계정 > 새 비공개 키 생성
2. 다운로드한 JSON 파일을 `scripts/serviceAccountKey.json`으로 저장

---

## 생성되는 데이터

### 트레이너 (1명)
| 항목 | 값 |
|------|-----|
| 이메일 | test@pal.com |
| 비밀번호 | password123 |
| 이름 | 김태훈 |
| 구독 | Pro |

### 회원 (5명)

| 이름 | 시나리오 | 목표 | PT 진행 | 특징 |
|------|---------|------|---------|------|
| 박지민 | 다이어트 성공 | diet | 20/24회 | 68kg→58.5kg, 목표 근접 |
| 이준호 | 벌크업 중 | bulk | 18/36회 | 70kg→76.5kg, 근육 증가 |
| 김서연 | 출석률 하락 | fitness | 8/24회 | 최근 출석률 저조 |
| 최민수 | PT 종료 임박 | diet | 22/24회 | 85kg→78kg, 재등록 필요 |
| 정하늘 | 신규 회원 | fitness | 2/24회 | 운동 초보, 적응 중 |

### 각 회원별 데이터

| 데이터 유형 | 생성량 |
|------------|-------|
| 체중 기록 | 8주치 (주 2회) |
| 운동 기록 | 4주치 커리큘럼 |
| 식단 기록 | 1주치 (하루 2-3끼) |
| 인바디 | 2회 (등록 시, 4주 후) |
| 채팅 메시지 | 10개 |

---

## 체중 변화 패턴

| 시나리오 | 패턴 | 예상 결과 |
|---------|------|----------|
| 다이어트 성공 | 주 1kg 꾸준히 감량 | 68kg → 60kg |
| 벌크업 중 | 주 0.5kg 점진적 증량 | 72kg → 76kg |
| 출석률 하락 | 초반 감량 → 정체/요요 | 55kg → 53kg (정체) |
| PT 종료 임박 | 꾸준한 감량 (목표 근접) | 85kg → 77kg |
| 신규 회원 | 아직 변화 미미 | 58kg 유지 |

---

## 주의사항

- 이미 존재하는 트레이너 계정은 재사용됩니다
- 기존 데이터를 삭제하지 않고 추가합니다
- **실제 서비스 환경에서는 실행하지 마세요**
- 에뮬레이터에서 테스트하려면 `FIRESTORE_EMULATOR_HOST` 환경변수 설정

---

## 파일 구조

```
scripts/
├── seed_demo_data.dart    # Dart 스크립트 (firedart 패키지 사용)
├── seed_demo_data.js      # Node.js 스크립트 (firebase-admin)
├── pubspec.yaml           # Dart 의존성 (firedart, uuid)
├── package.json           # Node.js 의존성
├── serviceAccountKey.json # Firebase 서비스 계정 키 (직접 추가)
└── README.md              # 이 파일
```
