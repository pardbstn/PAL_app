# PAL 프리미엄 애니메이션 시스템

## 개요

PAL 앱의 고급 애니메이션 시스템은 flutter_animate 패키지를 기반으로 구축되었으며, 프리미엄 느낌의 사용자 경험을 제공합니다.

## 주요 특징

- **블러 효과**: 요소가 흐릿하게 나타나 선명해지는 프리미엄 등장 효과
- **스태거 애니메이션**: 리스트/그리드 아이템이 순차적으로 나타나는 효과
- **Impeller 최적화**: RepaintBoundary로 자동 래핑하여 렌더링 성능 향상
- **상태 피드백**: 에러/성공 상태를 시각적으로 전달하는 애니메이션
- **무한 반복**: 로딩 인디케이터용 펄스 효과

---

## 파일 구조

```
lib/core/utils/
├── animation_utils.dart        # 핵심 애니메이션 로직
└── animation_examples.dart     # 실제 사용 예시 모음
```

---

## 사용 가능한 애니메이션

### 1. 기본 애니메이션 (기존)

| 메서드 | 용도 | 사용법 |
|--------|------|--------|
| `fadeIn()` | 페이드 인 | `widget.animateFadeIn()` |
| `slideUp()` | 아래→위 슬라이드 | `widget.animateSlideUp()` |
| `slideDown()` | 위→아래 슬라이드 | `widget.animateSlideDown()` |
| `scaleIn()` | 확대 등장 | `widget.animateScaleIn()` |
| `cardEntrance()` | 카드 스태거 | `widget.animateListItem(index)` |
| `shake()` | 흔들기 | `AppAnimations.shake()` |
| `pulse()` | 펄스 | `AppAnimations.pulse()` |

### 2. 프리미엄 애니메이션 (신규)

#### 2.1 등장 효과

**premiumEntrance** - 최고급 등장 효과
```dart
Container(
  child: Text('중요한 콘텐츠'),
).animatePremiumEntrance(delay: Duration(milliseconds: 100))
```
- 블러 → 선명
- 페이드 인
- 아래→위 슬라이드
- 사용처: 대시보드 카드, 중요 섹션

**sectionEntrance** - 드라마틱한 섹션 등장
```dart
Card(
  child: DashboardSection(),
).animateSectionEntrance()
```
- 더 큰 이동 거리 (40px)
- 더 긴 지속 시간 (600ms)
- 사용처: 통계 섹션, 차트 컨테이너

**profileEntrance** - 프로필 전용 효과
```dart
CircleAvatar(
  backgroundImage: NetworkImage(url),
).animateProfileEntrance()
```
- 중앙 확대 (0.85 → 1.0)
- 튕기는 느낌 (easeOutBack)
- 사용처: 프로필 사진, 아바타, 로고

#### 2.2 리스트 애니메이션

**listItemEntrance** - 개선된 리스트 스태거
```dart
ListView.builder(
  itemBuilder: (context, index) {
    return ListTile(
      title: Text('Item $index'),
    ).animateListItemStagger(index);
  },
)
```
- 페이드 + 슬라이드 + 스케일
- maxStagger로 성능 최적화 (기본 8개)
- 사용처: 회원 목록, 운동 기록, PT 세션

**premiumCardEntrance** - 프리미엄 카드 그리드
```dart
GridView.builder(
  itemBuilder: (context, index) {
    return DashboardCard().animatePremiumCard(index);
  },
)
```
- 블러 + 페이드 + 슬라이드 + 스케일 (4가지 효과)
- 50ms 간격 스태거
- 사용처: 대시보드 그리드, 통계 카드

#### 2.3 인터랙션 피드백

**buttonAttention** - 버튼 강조
```dart
ElevatedButton(
  onPressed: () {},
  child: Text('저장'),
).animateButtonAttention()
```
- 펄스 + 글로우 효과
- 8% 확대
- 사용처: CTA 버튼, 중요한 액션

**errorShake** - 에러 피드백
```dart
if (hasError) {
  TextField().animateErrorShake();
}
```
- 좌우 흔들림 (10px)
- 페이드 효과로 주목도 향상
- 사용처: 폼 검증 실패, 로그인 오류

**successBounce** - 성공 피드백
```dart
Icon(Icons.check_circle).animateSuccessBounce()
```
- 15% 확대 후 탄성 복귀
- 긍정적인 느낌 전달
- 사용처: 저장 완료, 등록 성공

#### 2.4 로딩 상태

**loadingPulse** - 무한 반복 펄스
```dart
Container(
  height: 200,
  color: Colors.grey[300],
).animateLoadingPulse()
```
- 0.5 ↔ 1.0 투명도 전환
- 자동 무한 반복
- 사용처: 스켈레톤 UI, 로딩 인디케이터

---

## 성능 최적화

### Impeller 렌더링 최적화

모든 확장 메서드는 자동으로 `RepaintBoundary`로 래핑됩니다:

```dart
Widget animatePremiumEntrance({Duration? delay}) {
  return RepaintBoundary(  // 자동 래핑
    child: animate(
      effects: AppAnimations.premiumEntrance(delay: delay ?? Duration.zero),
    ),
  );
}
```

**장점:**
- 애니메이션이 독립 레이어로 분리
- 부모 위젯 재빌드 시 영향 최소화
- 프레임 드롭 감소

### 스태거 최적화

긴 리스트에서 무한 지연 방지:

```dart
static Duration staggerDelay(int index, {int maxDelay = 5}) {
  final effectiveIndex = index.clamp(0, maxDelay);  // 최대값 제한
  return Duration(milliseconds: 50 * effectiveIndex);
}
```

- 인덱스 8 이후는 지연 증가 안 함 (기본값)
- 긴 리스트에서도 빠른 초기 렌더링

---

## 실전 사용 예시

### 대시보드 화면

```dart
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 프로필 헤더
            ProfileHeader().animateSectionEntrance(),

            SizedBox(height: 24),

            // 통계 그리드
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 6,
              itemBuilder: (context, index) {
                return StatCard(
                  title: '통계 ${index + 1}',
                  value: '${(index + 1) * 100}',
                ).animatePremiumCard(index);  // 프리미엄 스태거
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

### 회원 목록 화면

```dart
class MemberListScreen extends StatelessWidget {
  final List<Member> members;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(member.photoUrl),
          ).animateProfileEntrance(),  // 프로필 전용
          title: Text(member.name),
          subtitle: Text('${member.age}세'),
        ).animateListItemStagger(index, maxStagger: 8);  // 리스트 스태거
      },
    );
  }
}
```

### 폼 검증

```dart
class MemberForm extends StatefulWidget {
  @override
  State<MemberForm> createState() => _MemberFormState();
}

class _MemberFormState extends State<MemberForm> {
  bool _hasError = false;
  bool _isSuccess = false;

  void _submit() {
    if (_nameController.text.isEmpty) {
      setState(() => _hasError = true);
    } else {
      setState(() => _isSuccess = true);
      _save();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget nameField = TextField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: '회원 이름',
        errorText: _hasError ? '필수 항목입니다' : null,
        suffixIcon: _isSuccess
          ? Icon(Icons.check_circle, color: Colors.green)
              .animateSuccessBounce()  // 성공 바운스
          : null,
      ),
    );

    // 에러 시 흔들기
    if (_hasError) {
      nameField = nameField.animateErrorShake();
    }

    return Column(
      children: [
        nameField,
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: _submit,
          child: Text('저장'),
        ).animateButtonAttention(),  // 버튼 강조
      ],
    );
  }
}
```

### 로딩 스켈레톤

```dart
class MemberListSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // 프로필 스켈레톤
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ).animateLoadingPulse(),  // 무한 펄스

              SizedBox(width: 16),

              // 텍스트 스켈레톤
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ).animateLoadingPulse(),

                    SizedBox(height: 8),

                    Container(
                      height: 12,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ).animateLoadingPulse(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

---

## 커스터마이징

### 지속 시간 조정

```dart
AppAnimations.premiumEntrance(
  duration: Duration(milliseconds: 700),  // 기본 500ms
  delay: Duration(milliseconds: 100),
  slideOffset: 30,  // 기본 20px
  blurAmount: 12,   // 기본 8px
)
```

### 스태거 간격 조정

```dart
// maxStagger를 늘려 더 많은 아이템에 지연 적용
widget.animateListItemStagger(index, maxStagger: 15)

// maxStagger를 줄여 빠른 렌더링
widget.animateListItemStagger(index, maxStagger: 5)
```

### 직접 Effect 조합

```dart
Container().animate(
  effects: [
    ...AppAnimations.premiumEntrance(),
    // 추가 효과
    TintEffect(
      color: Colors.blue,
      begin: 0,
      end: 0.2,
    ),
  ],
)
```

---

## 애니메이션 선택 가이드

| 상황 | 추천 애니메이션 | 이유 |
|------|----------------|------|
| 대시보드 카드 | `premiumCardEntrance` | 블러 효과로 고급스러움 |
| 통계 섹션 | `sectionEntrance` | 큰 영역에 어울리는 드라마틱함 |
| 회원 목록 | `listItemStagger` | 성능 최적화된 스태거 |
| 프로필 사진 | `profileEntrance` | 중앙 확대로 포커스 |
| CTA 버튼 | `buttonAttention` | 주목도 향상 |
| 폼 에러 | `errorShake` | 명확한 피드백 |
| 저장 성공 | `successBounce` | 긍정적인 느낌 |
| 로딩 중 | `loadingPulse` | 무한 반복 |

---

## 주의사항

### 1. 과도한 애니메이션 자제

```dart
// ❌ 나쁜 예: 모든 요소에 애니메이션
Column(
  children: [
    Text('Title').animatePremiumEntrance(),
    Text('Subtitle').animatePremiumEntrance(),
    Text('Body').animatePremiumEntrance(),
    // 너무 많음!
  ],
)

// ✅ 좋은 예: 중요한 요소만
Column(
  children: [
    Text('Title').animatePremiumEntrance(),
    Text('Subtitle'),  // 애니메이션 없음
    Text('Body'),      // 애니메이션 없음
  ],
)
```

### 2. 스태거는 리스트/그리드에만

```dart
// ❌ 정적 위젯에 스태거 사용 X
Column(
  children: [
    Button1().animatePremiumCard(0),
    Button2().animatePremiumCard(1),
  ],
)

// ✅ 동적 리스트에만 사용
ListView.builder(
  itemBuilder: (context, index) {
    return Item().animatePremiumCard(index);
  },
)
```

### 3. 블러 효과는 신중하게

블러 효과는 렌더링 비용이 높습니다. 중요한 UI 요소에만 사용하세요:

```dart
// ✅ 메인 콘텐츠에만
MainCard().animatePremiumEntrance()

// ❌ 작은 아이콘까지 블러 X
Icon(Icons.star).animatePremiumEntrance()  // 과함
Icon(Icons.star).animateFadeIn()  // 충분함
```

---

## 데모 실행

전체 데모 화면을 보려면:

```dart
import 'package:pal/core/utils/animation_examples.dart';

// 라우터에 추가
GoRoute(
  path: '/animation-demo',
  builder: (context, state) => AnimationDemoScreen(),
)

// 또는 직접 푸시
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => AnimationDemoScreen()),
)
```

---

## 트러블슈팅

### 애니메이션이 버벅임

**원인:** RepaintBoundary 누락 또는 과도한 중첩
**해결:** 확장 메서드 사용 (자동 최적화됨)

```dart
// ✅ 확장 메서드 사용
widget.animatePremiumEntrance()

// ❌ 직접 animate() 호출
widget.animate(effects: AppAnimations.premiumEntrance())
```

### 블러 효과가 안 보임

**원인:** Impeller 렌더러에서 BlurEffect 지원 확인 필요
**해결:** `flutter run --no-enable-impeller` 또는 다른 효과 사용

```dart
// 대안: 블러 없이 페이드 + 슬라이드
widget.animateSlideUp()
```

### 스태거가 너무 느림

**원인:** maxStagger 값이 너무 높음
**해결:** maxStagger 값 줄이기

```dart
// 기본값 8 → 5로 줄임
widget.animateListItemStagger(index, maxStagger: 5)
```

---

## 참고 자료

- [flutter_animate 공식 문서](https://pub.dev/packages/flutter_animate)
- [Flutter 애니메이션 가이드](https://docs.flutter.dev/ui/animations)
- [Impeller 렌더러](https://github.com/flutter/flutter/wiki/Impeller)

---

## 업데이트 히스토리

- **2026-02-01**: 프리미엄 애니메이션 시스템 추가
  - 블러 효과 등장 애니메이션
  - 개선된 스태거 시스템
  - Impeller 최적화
  - 10가지 실전 예시 추가
