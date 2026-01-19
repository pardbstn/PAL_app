# PAL 디자인 시스템 사용 예시

## 1. 디자인 토큰

```dart
import 'package:flutter_pal_app/core/theme/app_tokens.dart';

// 간격 (Spacing)
Padding(padding: EdgeInsets.all(AppSpacing.md)); // 16
SizedBox(height: AppSpacing.lg); // 24

// 둥글기 (Radius)
BorderRadius.circular(AppRadius.md); // 12
Container(
  decoration: BoxDecoration(
    borderRadius: AppRadius.lgBorderRadius, // BorderRadius.circular(16)
  ),
);

// 그림자 (Shadows)
Container(
  decoration: BoxDecoration(
    boxShadow: AppShadows.md,
  ),
);

// 애니메이션 지속 시간
AnimatedContainer(
  duration: AppDurations.normal, // 300ms
);
```

## 2. 버튼 (AppButton)

```dart
import 'package:flutter_pal_app/presentation/widgets/common/common_widgets.dart';

// 기본 버튼
AppButton(
  label: '저장',
  onPressed: () => print('저장됨'),
);

// 다양한 변형
AppButton(
  label: '삭제',
  variant: AppButtonVariant.danger,
  onPressed: () => print('삭제됨'),
);

AppButton(
  label: '취소',
  variant: AppButtonVariant.outline,
  onPressed: () => Navigator.pop(context),
);

AppButton(
  label: '더보기',
  variant: AppButtonVariant.ghost,
  onPressed: () {},
);

// 아이콘 포함
AppButton(
  label: 'AI 커리큘럼 생성',
  icon: Icons.auto_awesome,
  onPressed: () {},
);

// 로딩 상태
AppButton(
  label: '저장 중...',
  isLoading: true,
  onPressed: null,
);

// 전체 너비
AppButton(
  label: '로그인',
  isFullWidth: true,
  size: AppButtonSize.lg,
  onPressed: () {},
);
```

## 3. 카드 (AppCard)

```dart
// 기본 카드 (elevated)
AppCard(
  child: Text('카드 내용'),
);

// 테두리 카드
AppCard(
  variant: AppCardVariant.outlined,
  child: ListTile(
    title: Text('회원명'),
    subtitle: Text('PT 20회'),
  ),
);

// 채워진 카드
AppCard(
  variant: AppCardVariant.filled,
  padding: EdgeInsets.all(AppSpacing.lg),
  child: Text('배경이 회색인 카드'),
);

// 글래스 카드 (배경 블러 효과)
AppCard(
  variant: AppCardVariant.glass,
  child: Text('글래스모피즘 효과'),
);

// 탭 가능한 카드
AppCard(
  onTap: () => print('카드 탭됨'),
  isHoverable: true,
  child: Text('탭하세요'),
);
```

## 4. 텍스트 필드 (AppTextField)

```dart
// 기본 입력
AppTextField(
  label: '이름',
  hint: '이름을 입력하세요',
  controller: _nameController,
);

// 에러 표시
AppTextField(
  label: '이메일',
  hint: 'example@email.com',
  errorText: '올바른 이메일 형식이 아닙니다',
  controller: _emailController,
);

// 비밀번호
AppTextField(
  label: '비밀번호',
  obscureText: true,
  suffix: IconButton(
    icon: Icon(Icons.visibility),
    onPressed: () => setState(() => _showPassword = !_showPassword),
  ),
);

// 아이콘 포함
AppTextField(
  label: '전화번호',
  prefixIcon: Icons.phone,
  keyboardType: TextInputType.phone,
);

// 여러 줄
AppTextField(
  label: '메모',
  maxLines: 4,
  hint: '회원에 대한 메모를 작성하세요',
);

// Form과 함께 사용
AppTextField(
  label: '몸무게',
  keyboardType: TextInputType.number,
  validator: (value) {
    if (value == null || value.isEmpty) return '필수 입력입니다';
    return null;
  },
);
```

## 5. 배지 (AppBadge)

```dart
// 기본 배지
AppBadge(
  label: '신규',
  variant: AppBadgeVariant.primary,
);

AppBadge(
  label: '완료',
  variant: AppBadgeVariant.success,
  icon: Icons.check,
);

// 목표 배지
GoalBadge(goal: 'diet');     // 🔥 다이어트 (주황)
GoalBadge(goal: 'bulk');     // 💪 벌크업 (보라)
GoalBadge(goal: 'fitness');  // 🏃 체력향상 (초록)
GoalBadge(goal: 'rehab');    // 🩹 재활 (파랑)

// 경험 배지
ExperienceBadge(experience: 'beginner');     // ⭐ 입문
ExperienceBadge(experience: 'intermediate'); // ⭐⭐ 중급
ExperienceBadge(experience: 'advanced');     // ⭐⭐⭐ 상급

// 상태 배지
StatusBadge(status: 'active');    // 진행중 (초록)
StatusBadge(status: 'completed'); // 완료 (회색)
StatusBadge(status: 'expiring');  // PT임박 (빨강)
```

## 6. 아바타 (AppAvatar)

```dart
// 이미지 아바타
AppAvatar(
  imageUrl: 'https://example.com/profile.jpg',
  size: AppAvatarSize.lg,
);

// 이니셜 아바타 (이미지 없을 때)
AppAvatar(
  name: '김철수',  // 'ㄱ' 또는 '김' 첫 글자로 이니셜 생성
  size: AppAvatarSize.md,
);

// 온라인 표시
AppAvatar(
  imageUrl: 'https://example.com/profile.jpg',
  showOnlineIndicator: true,
  isOnline: true,
);

// 다양한 크기
AppAvatar(name: '김', size: AppAvatarSize.xs);  // 24
AppAvatar(name: '김', size: AppAvatarSize.sm);  // 32
AppAvatar(name: '김', size: AppAvatarSize.md);  // 40
AppAvatar(name: '김', size: AppAvatarSize.lg);  // 56
AppAvatar(name: '김', size: AppAvatarSize.xl);  // 80
```

## 7. 바텀시트 (AppBottomSheet)

```dart
// 기본 바텀시트
AppBottomSheet.show(
  context: context,
  title: '옵션 선택',
  child: Column(
    children: [
      ListTile(title: Text('옵션 1'), onTap: () {}),
      ListTile(title: Text('옵션 2'), onTap: () {}),
    ],
  ),
);

// 닫기 불가능한 바텀시트
AppBottomSheet.show(
  context: context,
  isDismissible: false,
  showDragHandle: false,
  child: WillPopScope(
    onWillPop: () async => false,
    child: Text('필수 선택입니다'),
  ),
);

// 최대 높이 제한
AppBottomSheet.show(
  context: context,
  maxHeight: 0.5, // 화면의 50%
  child: ListView.builder(...),
);
```

## 8. 다이얼로그 (AppDialog)

```dart
// 확인 다이얼로그
final confirmed = await AppDialog.confirm(
  context: context,
  title: '삭제 확인',
  message: '정말 삭제하시겠습니까?',
  confirmText: '삭제',
  cancelText: '취소',
  isDanger: true,
);
if (confirmed == true) {
  // 삭제 실행
}

// 정보 다이얼로그
await AppDialog.info(
  context: context,
  title: '알림',
  message: '저장이 완료되었습니다.',
);

// 입력 다이얼로그
final name = await AppDialog.input(
  context: context,
  title: '이름 변경',
  initialValue: '기존 이름',
  hint: '새 이름을 입력하세요',
);
if (name != null) {
  // 이름 업데이트
}

// 커스텀 다이얼로그
await AppDialog.custom(
  context: context,
  child: MyCustomWidget(),
);
```

## 9. 스낵바 (AppSnackbar)

```dart
// 성공 메시지
AppSnackbar.success(context, '저장되었습니다');

// 에러 메시지
AppSnackbar.error(context, '저장에 실패했습니다');

// 경고 메시지
AppSnackbar.warning(context, 'PT 잔여 횟수가 3회 남았습니다');

// 정보 메시지
AppSnackbar.info(context, '새로운 회원이 등록되었습니다');

// 액션 버튼 포함
AppSnackbar.show(
  context: context,
  message: '회원이 삭제되었습니다',
  variant: AppSnackbarVariant.info,
  actionLabel: '실행취소',
  onAction: () {
    // 삭제 취소 로직
  },
);

// 지속 시간 설정
AppSnackbar.show(
  context: context,
  message: '5초간 표시됩니다',
  duration: Duration(seconds: 5),
);
```

## 통합 예시: 회원 카드

```dart
AppCard(
  onTap: () => Navigator.push(...),
  isHoverable: true,
  child: Padding(
    padding: EdgeInsets.all(AppSpacing.md),
    child: Row(
      children: [
        AppAvatar(
          imageUrl: member.profileImageUrl,
          name: member.name,
          size: AppAvatarSize.lg,
          showOnlineIndicator: true,
          isOnline: member.isOnline,
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(member.name, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  GoalBadge(goal: member.goal),
                  SizedBox(width: AppSpacing.sm),
                  ExperienceBadge(experience: member.experience),
                ],
              ),
            ],
          ),
        ),
        StatusBadge(status: member.status),
      ],
    ),
  ),
);
```
