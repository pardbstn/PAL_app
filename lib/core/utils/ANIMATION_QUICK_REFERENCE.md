# 애니메이션 빠른 참조 가이드

## 가장 많이 쓰는 5가지

```dart
// 1. 리스트 아이템 (가장 흔함)
ListTile(...).animateListItemStagger(index)

// 2. 카드 그리드
Card(...).animatePremiumCard(index)

// 3. 큰 섹션
Container(...).animateSectionEntrance()

// 4. 프로필/아바타
CircleAvatar(...).animateProfileEntrance()

// 5. 에러 피드백
TextField(...).animateErrorShake()
```

## 전체 애니메이션 목록

### 등장 효과
| 메서드 | 언제 사용 | 예시 |
|--------|----------|------|
| `animatePremiumEntrance()` | 중요한 콘텐츠 | 대시보드 카드, 헤더 |
| `animateSectionEntrance()` | 큰 영역 | 통계 섹션, 차트 |
| `animateProfileEntrance()` | 원형 이미지 | 프로필, 아바타 |
| `animateFadeIn()` | 단순 등장 | 텍스트, 아이콘 |
| `animateSlideUp()` | 아래→위 | 모달, 바텀시트 |
| `animateScaleIn()` | 확대 등장 | 버튼, 작은 요소 |

### 리스트/그리드
| 메서드 | 언제 사용 | 예시 |
|--------|----------|------|
| `animateListItemStagger(index)` | 긴 리스트 | 회원 목록, 운동 기록 |
| `animatePremiumCard(index)` | 카드 그리드 | 대시보드 그리드 |
| `animateListItem(index)` | 간단한 리스트 | 설정 항목 |

### 인터랙션 피드백
| 메서드 | 언제 사용 | 예시 |
|--------|----------|------|
| `animateErrorShake()` | 에러 발생 | 폼 검증 실패 |
| `animateSuccessBounce()` | 성공 | 저장 완료 아이콘 |
| `animateButtonAttention()` | 버튼 강조 | CTA, 중요 액션 |

### 로딩
| 메서드 | 언제 사용 | 예시 |
|--------|----------|------|
| `animateLoadingPulse()` | 로딩 중 | 스켈레톤 UI |

## 패턴별 예시

### 대시보드 화면
```dart
Column(
  children: [
    // 헤더
    ProfileHeader().animateSectionEntrance(),

    // 카드 그리드
    GridView.builder(
      itemBuilder: (context, index) {
        return StatCard().animatePremiumCard(index);
      },
    ),
  ],
)
```

### 리스트 화면
```dart
ListView.builder(
  itemCount: members.length,
  itemBuilder: (context, index) {
    return ListTile(
      leading: CircleAvatar(...).animateProfileEntrance(),
      title: Text(members[index].name),
    ).animateListItemStagger(index);
  },
)
```

### 폼 검증
```dart
Widget buildTextField() {
  Widget field = TextField(
    decoration: InputDecoration(
      errorText: hasError ? '필수 항목' : null,
    ),
  );

  if (hasError) {
    field = field.animateErrorShake();
  }

  return field;
}
```

### 성공 피드백
```dart
if (saved) {
  Icon(Icons.check_circle, color: Colors.green)
    .animateSuccessBounce()
}
```

### 스켈레톤 로더
```dart
Container(
  height: 50,
  color: Colors.grey[300],
).animateLoadingPulse()
```

## 성능 팁

### ✅ 좋은 예
```dart
// 중요한 요소만 애니메이션
Column(
  children: [
    Title().animatePremiumEntrance(),
    Body(),  // 애니메이션 없음 = 빠름
  ],
)

// 스태거 제한
widget.animateListItemStagger(index, maxStagger: 8)
```

### ❌ 나쁜 예
```dart
// 모든 요소에 애니메이션
Column(
  children: [
    Title().animatePremiumEntrance(),
    Subtitle().animatePremiumEntrance(),  // 과함
    Body().animatePremiumEntrance(),      // 과함
  ],
)

// 스태거 제한 없음
widget.animateListItemStagger(index, maxStagger: 100)  // 느림
```

## 커스터마이징

### 지연 시간
```dart
widget.animatePremiumEntrance(
  delay: Duration(milliseconds: 200)
)
```

### 스태거 간격
```dart
// 빠르게
widget.animateListItemStagger(index, maxStagger: 5)

// 천천히
widget.animateListItemStagger(index, maxStagger: 12)
```

### 직접 효과 사용
```dart
widget.animate(
  effects: AppAnimations.premiumEntrance(
    duration: Duration(milliseconds: 700),
    slideOffset: 30,
    blurAmount: 12,
  ),
)
```

## 트러블슈팅

### 애니메이션이 버벅임
→ 확장 메서드 사용 (RepaintBoundary 자동 적용됨)

### 스태거가 너무 느림
→ `maxStagger` 값 줄이기 (5-8 권장)

### 블러가 안 보임
→ Impeller 이슈일 수 있음. 다른 효과 사용

---

**전체 문서**: `docs/ANIMATION_SYSTEM.md`
**예시 코드**: `lib/core/utils/animation_examples.dart`
