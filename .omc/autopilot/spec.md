# PAL UI Unification Specification

## Goals
1. 아이콘 정리 (화면당 4-5개로 감소)
2. 카드 AppCard로 통일
3. 버튼 AppButton/AppActionButton으로 통일
4. 그라데이션 제거
5. 폰트/스페이싱 AppTextStyle/AppSpacing 토큰으로 표준화

## Key Decisions
- **Gradients**: Remove ALL decorative gradients. Keep only AppColors.primary for CTA buttons.
- **Icons**: Target max 5 essential icons per screen (navigation, primary actions).
- **GradientGlassCard**: Replace with AppCard.accent variant.
- **Animation scope**: OUT OF SCOPE - do not change animation timing.
- **Dark mode**: Must verify both modes work for each changed screen.

## Implementation Phases

### Phase 1: Settings Screens (Low Risk)
- trainer_settings_screen.dart - gradient removal only
- member_settings_screen.dart - gradient removal only

### Phase 2: Member Home (Medium Complexity)
- Remove _PtProgressCard gradient → solid AppColors.primary
- Migrate custom containers to AppCard
- Remove chevron icons
- Enforce spacing/font tokens

### Phase 3: Trainer Home (Highest Complexity)
- Migrate GradientGlassCard to AppCard.accent
- Replace custom _buildPremiumCard methods
- Remove section header icons
- Enforce spacing/font tokens

## Token Reference

### AppSpacing
- xs: 4, sm: 8, md: 12, lg: 16, xl: 20, xxl: 24

### AppTextStyle
- titleLarge: 22, titleMedium: 18, titleSmall: 16
- bodyLarge: 16, bodyMedium: 14, bodySmall: 12, caption: 11

### AppCard Variants
- standard: White bg + gray 1px border + subtle shadow
- accent: White bg + primary 2px border + shadow
- elevated: White bg + gray border + deeper shadow
- record: White bg + gray border + no padding

## Files to Modify
1. trainer_settings_screen.dart (lines 224-229: profile gradient)
2. member_settings_screen.dart (lines 244-249: profile gradient)
3. member_home_screen.dart (lines 600-606: PT card gradient + containers)
4. trainer_home_screen.dart (GradientGlassCard, custom cards, icons)

## Out of Scope
- Animation timing changes
- New component creation
- Structural layout changes
- Business logic changes
