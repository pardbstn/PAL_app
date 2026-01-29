# PAL 앱 스토어 배포 계획

## 개요
- **목표**: Google Play Store 및 Apple App Store에 PAL 앱 배포
- **예상 기간**: 2-3주 (심사 기간 포함)
- **비용**: Google $25 (일회성) + Apple $99/년

---

## Phase 1: 개발자 계정 설정 (1-2일)

### [ ] 1.1 Google Play Console 계정
- [ ] https://play.google.com/console 접속
- [ ] $25 결제 (일회성)
- [ ] 개발자 프로필 작성
- [ ] 신원 확인 (본인 인증)

### [ ] 1.2 Apple Developer Program 가입
- [ ] https://developer.apple.com 접속
- [ ] $99/년 결제
- [ ] Apple ID 2단계 인증 필수
- [ ] 개발자 계약 동의
- [ ] 승인 대기 (1-2일 소요)

---

## Phase 2: 앱 기본 설정 (1일)

### [ ] 2.1 앱 식별자 설정
```
Android: com.palapp.pal (예시)
iOS: com.palapp.pal (동일하게)
```

**수정 파일:**
- [ ] `android/app/build.gradle.kts` - applicationId 변경
- [ ] `ios/Runner.xcodeproj` - Bundle Identifier 변경

### [ ] 2.2 버전 관리
```yaml
# pubspec.yaml
version: 1.0.0+1  # version+buildNumber
```

### [ ] 2.3 앱 이름 설정
- [ ] Android: `android/app/src/main/AndroidManifest.xml` - android:label
- [ ] iOS: `ios/Runner/Info.plist` - CFBundleDisplayName

---

## Phase 3: 앱 아이콘 & 스플래시 (1일)

### [ ] 3.1 앱 아이콘 준비
- [ ] 1024x1024 PNG 원본 이미지 준비 (투명 배경 X)
- [ ] flutter_launcher_icons 패키지 설정

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#2563EB"
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
```

```bash
flutter pub get
dart run flutter_launcher_icons
```

### [ ] 3.2 스플래시 화면
```yaml
# pubspec.yaml
dev_dependencies:
  flutter_native_splash: ^2.3.0

flutter_native_splash:
  color: "#2563EB"
  image: assets/splash/logo.png
  android_12:
    color: "#2563EB"
    image: assets/splash/logo.png
```

```bash
dart run flutter_native_splash:create
```

---

## Phase 4: 스토어 에셋 준비 (2-3일)

### [ ] 4.1 스크린샷 (필수)
| 플랫폼 | 크기 | 수량 |
|--------|------|------|
| Android 폰 | 1080x1920 또는 1440x2560 | 최소 2장, 권장 4-8장 |
| iPhone 6.7" | 1290x2796 | 최소 2장 |
| iPhone 6.5" | 1284x2778 | 최소 2장 |
| iPhone 5.5" | 1242x2208 | 최소 2장 |
| iPad Pro 12.9" | 2048x2732 | 태블릿 지원시 |

**권장 스크린샷 구성:**
1. 메인 홈 화면
2. 회원 관리 화면
3. 체성분 그래프
4. AI 커리큘럼 생성
5. 실시간 알림

### [ ] 4.2 피처 그래픽 (Google Play)
- [ ] 1024x500 PNG/JPG
- [ ] 앱 로고 + 슬로건 포함

### [ ] 4.3 앱 아이콘 (스토어용)
- [ ] 512x512 PNG (Google Play)
- [ ] 1024x1024 PNG (App Store)

### [ ] 4.4 프로모션 영상 (선택)
- [ ] 30초-2분 앱 시연 영상
- [ ] YouTube 업로드 (Google Play)
- [ ] App Preview 형식 (App Store)

---

## Phase 5: 스토어 정보 작성 (1일)

### [ ] 5.1 앱 이름
```
PAL - PT 관리 플랫폼
```

### [ ] 5.2 짧은 설명 (80자)
```
트레이너를 위한 올인원 PT 관리 앱. AI 커리큘럼, 체성분 분석, 실시간 소통.
```

### [ ] 5.3 전체 설명 (4000자)
```
PAL은 PT 트레이너를 위한 스마트 회원 관리 플랫폼입니다.

[주요 기능]
✓ AI 커리큘럼 자동 생성
✓ 체성분 변화 추적 및 예측
✓ 실시간 회원 소통
✓ 일정 관리 및 알림
✓ 인바디 연동 (예정)

[이런 분께 추천]
• PT 트레이너
• 피트니스 센터 운영자
• 개인 트레이닝 전문가

지금 PAL과 함께 스마트한 PT 관리를 시작하세요!
```

### [ ] 5.4 키워드 (App Store, 100자)
```
PT,트레이너,피트니스,헬스,운동,체성분,다이어트,근육,커리큘럼,회원관리
```

### [ ] 5.5 카테고리
- Google Play: 건강/운동
- App Store: 건강 및 피트니스

---

## Phase 6: 법적 요구사항 (1-2일)

### [ ] 6.1 개인정보처리방침 (필수)
웹페이지 URL 필요. 포함 내용:
- [ ] 수집하는 개인정보 항목 (이메일, 체성분 데이터 등)
- [ ] 수집 목적
- [ ] 보관 기간
- [ ] 제3자 제공 여부 (Firebase, Kakao 등)
- [ ] 사용자 권리 (삭제 요청 등)
- [ ] 연락처

**호스팅 옵션:**
- Notion 페이지 공개
- GitHub Pages
- Firebase Hosting

### [ ] 6.2 서비스 이용약관 (권장)
- [ ] 서비스 설명
- [ ] 사용자 의무
- [ ] 책임 제한
- [ ] 분쟁 해결

### [ ] 6.3 앱 콘텐츠 등급
- [ ] Google Play: 설문지 작성 → 자동 등급 부여
- [ ] App Store: 연령 등급 설문 작성

---

## Phase 7: 빌드 & 서명 (1일)

### [ ] 7.1 Android 릴리즈 빌드

**키스토어 생성 (최초 1회):**
```bash
keytool -genkey -v -keystore ~/pal-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias pal-key
```

**key.properties 생성:**
```properties
# android/key.properties (gitignore 추가!)
storePassword=<비밀번호>
keyPassword=<비밀번호>
keyAlias=pal-key
storeFile=/path/to/pal-release-key.jks
```

**build.gradle.kts 서명 설정:**
```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
        storeFile = file(keystoreProperties["storeFile"] as String)
        storePassword = keystoreProperties["storePassword"] as String
    }
}
```

**빌드:**
```bash
flutter build appbundle --release
# 결과: build/app/outputs/bundle/release/app-release.aab
```

### [ ] 7.2 iOS 릴리즈 빌드

**Xcode 설정:**
- [ ] Signing & Capabilities > Team 선택
- [ ] Automatically manage signing 체크
- [ ] Bundle Identifier 확인

**빌드:**
```bash
flutter build ipa --release
# 또는 Xcode > Product > Archive
```

**App Store Connect 업로드:**
- Xcode > Window > Organizer > Distribute App
- 또는 Transporter 앱 사용

---

## Phase 8: 스토어 제출 (1일)

### [ ] 8.1 Google Play Console
1. [ ] 앱 만들기
2. [ ] 스토어 등록정보 입력
3. [ ] 콘텐츠 등급 설문
4. [ ] 가격 및 배포 국가 설정
5. [ ] 앱 번들 업로드 (내부 테스트 → 프로덕션)
6. [ ] 검토 제출

### [ ] 8.2 App Store Connect
1. [ ] 새로운 앱 생성
2. [ ] 앱 정보 입력
3. [ ] 스크린샷 업로드
4. [ ] 빌드 선택
5. [ ] 앱 심사 정보 입력
6. [ ] 심사 제출

---

## Phase 9: 심사 대응 (3-7일)

### [ ] 9.1 Google Play 심사
- 보통 1-3일 소요
- 정책 위반시 수정 후 재제출

### [ ] 9.2 App Store 심사
- 보통 1-7일 소요
- 거절시 App Review Board에 이의 제기 가능

**자주 거절되는 사유:**
- 로그인 필수 앱인데 테스트 계정 미제공
- 개인정보처리방침 누락/불충분
- 앱 설명과 실제 기능 불일치
- 백그라운드 위치 사용 이유 불명확

---

## 체크리스트 요약

### 배포 전 필수 확인
- [ ] 모든 기능 정상 작동
- [ ] 크래시 없음
- [ ] Firebase 프로덕션 환경 설정
- [ ] API 키 보안 처리
- [ ] 테스트 계정 준비 (심사용)
- [ ] 개인정보처리방침 URL
- [ ] 앱 아이콘 & 스크린샷
- [ ] 릴리즈 빌드 테스트

### 배포 후 모니터링
- [ ] Firebase Crashlytics 연동
- [ ] 사용자 리뷰 모니터링
- [ ] 성능 모니터링 (Firebase Performance)

---

## 일정 요약

| Phase | 작업 | 예상 기간 |
|-------|------|----------|
| 1 | 개발자 계정 | 1-2일 |
| 2 | 앱 기본 설정 | 1일 |
| 3 | 아이콘 & 스플래시 | 1일 |
| 4 | 스토어 에셋 | 2-3일 |
| 5 | 스토어 정보 | 1일 |
| 6 | 법적 요구사항 | 1-2일 |
| 7 | 빌드 & 서명 | 1일 |
| 8 | 스토어 제출 | 1일 |
| 9 | 심사 대기 | 3-7일 |
| **총** | | **12-19일** |

---

## 참고 자료
- [Google Play Console 도움말](https://support.google.com/googleplay/android-developer)
- [App Store Connect 도움말](https://developer.apple.com/app-store-connect/)
- [Flutter 배포 가이드](https://docs.flutter.dev/deployment)
