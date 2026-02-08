import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_pal_app/core/theme/app_tokens.dart';
import 'package:flutter_pal_app/core/utils/animation_utils.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/providers/theme_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/animated/micro_interactions.dart';
import 'package:flutter_pal_app/presentation/widgets/common/app_list_tile.dart';
import 'package:flutter_pal_app/presentation/widgets/common/app_section.dart';
import 'package:flutter_pal_app/data/repositories/trainer_repository.dart';
import 'package:flutter_pal_app/data/repositories/member_repository.dart';
import 'package:flutter_pal_app/data/repositories/body_record_repository.dart';
import 'package:flutter_pal_app/data/repositories/user_repository.dart';
import 'package:flutter_pal_app/data/models/trainer_model.dart';
import 'package:flutter_pal_app/data/models/member_model.dart';
import 'package:flutter_pal_app/data/models/user_model.dart';
import 'package:flutter_pal_app/presentation/providers/trainer_rating_provider.dart';
import 'package:intl/intl.dart';

/// 회원의 담당 트레이너 정보 Provider
final memberTrainerProvider = FutureProvider.autoDispose<TrainerModel?>((ref) async {
  final member = ref.watch(currentMemberProvider);
  if (member == null || member.trainerId.isEmpty) return null;

  final repository = ref.watch(trainerRepositoryProvider);
  return await repository.get(member.trainerId);
});

/// 소셜 로그인 임시 이메일 체크 및 표시
String _getDisplayEmail(String? email) {
  if (email == null || email.isEmpty) return '-';

  // 소셜 로그인 임시/릴레이 이메일 패턴
  if (email.contains('privaterelay.appleid.com') || // Apple
      email.contains('@privaterelay.') ||
      RegExp(r'^[a-z0-9]{10,}@').hasMatch(email)) { // 랜덤 문자열 이메일
    return '-';
  }

  return email;
}

/// 회원 설정 화면
class MemberSettingsScreen extends ConsumerWidget {
  const MemberSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final member = ref.watch(currentMemberProvider);
    final isPersonal = authState.userRole == UserRole.personal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.go('/member/home'),
        ),
      ),
      body: ListView(
        children: [
          // 프로필 섹션
          _buildProfileSection(context, authState)
              .animatePremiumEntrance(),
          const SizedBox(height: AppSpacing.xl),

          // 앱 설정
          AppSection(
            title: '앱 설정',
            animationDelay: 100.ms,
            child: AppListTileGroup(
              animate: true,
              animationDelay: const Duration(milliseconds: 100),
              children: [
                AppListTile(
                  leading: const Icon(Icons.person_outline),
                  title: '프로필 수정',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showEditProfileDialog(context, ref, authState),
                  animate: true,
                  animationDelay: const Duration(milliseconds: 150),
                ),
                AppListTile(
                  leading: const Icon(Icons.notifications_none_rounded),
                  title: '알림 설정',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/notification-settings'),
                  animate: true,
                  animationDelay: const Duration(milliseconds: 200),
                ),
                AppListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: '다크 모드',
                  trailing: Switch(
                    value: ref.watch(themeModeProvider) == ThemeMode.dark,
                    onChanged: (value) {
                      ref.read(themeModeProvider.notifier).toggleDarkMode(value);
                    },
                  ),
                  animate: true,
                  animationDelay: const Duration(milliseconds: 250),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 내 PT 정보 (개인모드에서는 목표 설정만 표시)
          AppSection(
            title: isPersonal ? '내 운동 정보' : '내 PT 정보',
            animationDelay: 200.ms,
            child: Column(
              children: [
                // 담당 트레이너 (PT 모드만)
                if (!isPersonal)
                  _buildTrainerTile(context, ref),
                // 트레이너 평가 (PT 모드만)
                if (!isPersonal)
                  _buildTrainerReviewTile(context, ref, member),
                // PT 일정 (PT 모드만)
                if (!isPersonal)
                  AppListTile(
                    leading: const Icon(Icons.calendar_month_outlined),
                    title: 'PT 일정',
                    subtitle: member != null
                        ? '${member.ptInfo.completedSessions}/${member.ptInfo.totalSessions}회 진행'
                        : '-',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: PT 일정 화면
                    },
                    animate: true,
                    animationDelay: const Duration(milliseconds: 300),
                  ),
                // 목표 설정
                AppListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: '목표 설정',
                  subtitle: member != null
                      ? '${member.goalLabel}${member.targetWeight != null ? ' • 목표 ${member.targetWeight}kg' : ''}'
                      : '목표 없음',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showGoalSettingDialog(context, ref, member),
                  animate: true,
                  animationDelay: const Duration(milliseconds: 350),
                ),
                // 내 데이터 관리 (PT 모드만)
                if (!isPersonal)
                  AppListTile(
                    leading: const Icon(Icons.folder_outlined),
                    title: '내 데이터 관리',
                    subtitle: '과거 트레이너 데이터 관리',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/member/data-management'),
                    animate: true,
                    animationDelay: const Duration(milliseconds: 400),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 지원
          AppSection(
            title: '지원',
            animationDelay: 300.ms,
            child: AppListTileGroup(
              animate: true,
              animationDelay: const Duration(milliseconds: 300),
              children: [
                AppListTile(
                  leading: const Icon(Icons.help_outline),
                  title: '고객센터',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: 고객센터
                  },
                  animate: true,
                  animationDelay: const Duration(milliseconds: 350),
                ),
                AppListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: '이용약관',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: 이용약관
                  },
                  animate: true,
                  animationDelay: const Duration(milliseconds: 400),
                ),
                AppListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: '개인정보 처리방침',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: 개인정보 처리방침
                  },
                  animate: true,
                  animationDelay: const Duration(milliseconds: 450),
                ),
                AppListTile(
                  leading: const Icon(Icons.info_outline),
                  title: '앱 정보',
                  subtitle: '버전 1.0.0',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'PAL',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2025 PAL. All rights reserved.',
                    );
                  },
                  animate: true,
                  animationDelay: const Duration(milliseconds: 500),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 로그아웃
          PremiumTapFeedback(
            onTap: () => _showLogoutDialog(context, ref),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.05),
                  borderRadius: AppRadius.lgBorderRadius,
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.2),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: AppColors.error),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          '로그아웃',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).animatePremiumEntrance(delay: const Duration(milliseconds: 400)),
          const SizedBox(height: AppSpacing.md),

          // 회원 탈퇴 (개인모드에서는 숨김)
          if (!isPersonal)
            Center(
              child: PremiumTapFeedback(
                enableShadow: false,
                scaleFactor: 0.95,
                onTap: () => _showDeleteAccountDialog(context, ref),
                child: const Text(
                  '회원 탈퇴',
                  style: TextStyle(
                    color: AppColors.gray500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  /// 담당 트레이너 타일 빌드
  Widget _buildTrainerTile(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        final trainerAsync = ref.watch(memberTrainerProvider);

        return trainerAsync.when(
          data: (trainer) {
            // 트레이너 이름을 가져오기 위한 FutureBuilder
            return FutureBuilder<UserModel?>(
              future: trainer != null
                  ? ref.read(userRepositoryProvider).get(trainer.userId)
                  : Future.value(null),
              builder: (context, snapshot) {
                final trainerName = snapshot.data?.name ?? '트레이너';

                return AppListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: AppRadius.smBorderRadius,
                    ),
                    child: const Icon(Icons.fitness_center, color: AppColors.secondary),
                  ),
                  title: '담당 트레이너',
                  subtitle: trainer != null ? trainerName : '담당 트레이너 없음',
                  trailing: Icon(
                    trainer != null ? Icons.chevron_right : Icons.info_outline,
                    color: trainer != null ? null : Theme.of(context).colorScheme.outline,
                  ),
                  onTap: trainer != null
                      ? () => _showTrainerInfoDialog(context, ref, trainer)
                      : () => _showNoTrainerDialog(context),
                  animate: true,
                  animationDelay: const Duration(milliseconds: 250),
                );
              },
            );
          },
          loading: () => AppListTile(
            leading: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: AppRadius.smBorderRadius,
              ),
              child: const Icon(Icons.fitness_center, color: AppColors.secondary),
            ),
            title: '담당 트레이너',
            subtitle: '로딩 중...',
            trailing: const Icon(Icons.chevron_right),
            animate: true,
            animationDelay: const Duration(milliseconds: 250),
          ),
          error: (_, __) => AppListTile(
            leading: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: AppRadius.smBorderRadius,
              ),
              child: const Icon(Icons.fitness_center, color: AppColors.secondary),
            ),
            title: '담당 트레이너',
            subtitle: '조회 실패',
            trailing: const Icon(Icons.chevron_right),
            animate: true,
            animationDelay: const Duration(milliseconds: 250),
          ),
        );
      },
    );
  }

  /// 트레이너 평가 타일 빌드
  Widget _buildTrainerReviewTile(BuildContext context, WidgetRef ref, MemberModel? member) {
    if (member == null || member.trainerId.isEmpty) {
      return const SizedBox.shrink();
    }

    final trainerAsync = ref.watch(memberTrainerProvider);

    return trainerAsync.when(
      data: (trainer) {
        if (trainer == null) return const SizedBox.shrink();

        final reviewParams = (trainerId: trainer.id, memberId: member.id);
        final reviewAsync = ref.watch(memberOwnReviewProvider(reviewParams));

        return reviewAsync.when(
          data: (review) {
            if (review != null) {
              // 이미 리뷰를 작성한 경우
              return AppListTile(
                leading: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: AppRadius.smBorderRadius,
                  ),
                  child: const Icon(Icons.rate_review, color: AppColors.secondary),
                ),
                title: '내가 작성한 리뷰',
                subtitle: '작성 완료',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showMyReviewDialog(context, review),
                animate: true,
                animationDelay: const Duration(milliseconds: 275),
              );
            } else {
              // 리뷰를 작성하지 않은 경우
              return AppListTile(
                leading: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.tertiary.withValues(alpha: 0.1),
                    borderRadius: AppRadius.smBorderRadius,
                  ),
                  child: const Icon(Icons.star_rate, color: AppColors.tertiary),
                ),
                title: '트레이너 평가하기',
                subtitle: '트레이너에게 리뷰를 남겨보세요',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(
                  '/member/review-trainer/${trainer.id}?memberId=${member.id}',
                ),
                animate: true,
                animationDelay: const Duration(milliseconds: 275),
              );
            }
          },
          loading: () => AppListTile(
            leading: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.tertiary.withValues(alpha: 0.1),
                borderRadius: AppRadius.smBorderRadius,
              ),
              child: const Icon(Icons.star_rate, color: AppColors.tertiary),
            ),
            title: '트레이너 평가',
            subtitle: '로딩 중...',
            animate: true,
            animationDelay: const Duration(milliseconds: 275),
          ),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// 내가 작성한 리뷰 다이얼로그 표시
  void _showMyReviewDialog(BuildContext context, dynamic review) {
    final dateStr = DateFormat('yyyy.MM.dd').format(review.createdAt);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('내가 작성한 리뷰'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReviewRatingRow('코칭 만족도', review.coachingSatisfaction),
            const SizedBox(height: AppSpacing.sm),
            _buildReviewRatingRow('소통', review.communication),
            const SizedBox(height: AppSpacing.sm),
            _buildReviewRatingRow('친절도', review.kindness),
            if (review.comment.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              const Text(
                '한줄평',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(review.comment),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Text(
              '작성일: $dateStr',
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 리뷰 평점 Row 빌드
  Widget _buildReviewRatingRow(String label, int value) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Row(
          children: List.generate(5, (i) => Icon(
            i < value ? Icons.star_rounded : Icons.star_outline_rounded,
            color: AppColors.tertiary,
            size: 20,
          )),
        ),
      ],
    );
  }

  Widget _buildProfileSection(BuildContext context, AuthState authState) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // 프로필 이미지 (프로필 등장 애니메이션)
          RepaintBoundary(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary,
              ),
              child: authState.photoUrl != null
                  ? ClipOval(
                      child: Image.network(
                        authState.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 36,
                    ),
            ).animateProfileEntrance(),
          ),
          const SizedBox(width: AppSpacing.md),
          // 정보 (프리미엄 등장 애니메이션 + 딜레이)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이름#코드 형식으로 표시
                Row(
                  children: [
                    Text(
                      authState.displayName ?? (authState.userRole == UserRole.personal ? '사용자' : '회원'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (authState.userModel?.memberCode != null) ...[
                      Text(
                        '#${authState.userModel!.memberCode}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ).animatePremiumEntrance(delay: const Duration(milliseconds: 100)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _getDisplayEmail(authState.email),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.gray600,
                  ),
                ).animatePremiumEntrance(delay: const Duration(milliseconds: 150)),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: AppRadius.mdBorderRadius,
                  ),
                  child: Text(
                    authState.userRole == UserRole.personal ? '개인' : '회원',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ).animatePremiumEntrance(delay: const Duration(milliseconds: 200)),
              ],
            ),
          ),
        ],
      ),
    );
  }


  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원 탈퇴'),
        content: const Text(
          '정말 탈퇴할까요?\n모든 데이터가 삭제되며 복구할 수 없어요.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 회원 탈퇴 로직
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('탈퇴'),
          ),
        ],
      ),
    );
  }

  /// 프로필 수정 다이얼로그 표시
  void _showEditProfileDialog(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
  ) {
    final nameController = TextEditingController(
      text: authState.displayName ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('프로필 수정'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: '이름',
            hintText: '이름을 입력해주세요',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('이름을 입력해주세요')),
                );
                return;
              }

              Navigator.pop(dialogContext);

              // 이름 업데이트
              await ref.read(authProvider.notifier).updateProfile(
                    name: newName,
                  );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('프로필이 수정됐어요')),
                );
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  /// 트레이너 미연결 안내 다이얼로그
  void _showNoTrainerDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person_search_rounded,
            color: colorScheme.secondary,
            size: 32,
          ),
        ),
        title: const Text('담당 트레이너 없음'),
        content: const Text(
          '현재 연결된 담당 트레이너가 없어요.\n\n'
          '트레이너가 회원 등록을 완료하면\n'
          '이곳에서 트레이너 정보를 확인할 수 있어요.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 트레이너 정보 다이얼로그 표시
  void _showTrainerInfoDialog(
    BuildContext context,
    WidgetRef ref,
    TrainerModel trainer,
  ) {
    // 트레이너의 UserModel 정보 가져오기
    ref.read(userRepositoryProvider).get(trainer.userId).then((user) {
      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('담당 트레이너'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 트레이너 프로필
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // 이름
                _buildInfoRow('이름', user?.name ?? '트레이너'),
                const SizedBox(height: AppSpacing.md),
                // 이메일
                if (user?.email != null && !user!.email.contains('privaterelay'))
                  Column(
                    children: [
                      _buildInfoRow('이메일', user.email),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                // 담당 회원 수
                _buildInfoRow('담당 회원', '${trainer.memberCount}명'),
                const SizedBox(height: AppSpacing.md),
                // 구독 티어
                _buildInfoRow(
                  '구독 플랜',
                  trainer.subscriptionTier == SubscriptionTier.free
                      ? 'Free'
                      : trainer.subscriptionTier == SubscriptionTier.basic
                          ? 'Basic'
                          : 'Pro',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    });
  }

  /// 목표 설정 다이얼로그 표시
  void _showGoalSettingDialog(
    BuildContext context,
    WidgetRef ref,
    MemberModel? member,
  ) {
    if (member == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원 정보를 불러오는 중이에요. 잠시 후 다시 시도해주세요.')),
      );
      return;
    }

    FitnessGoal selectedGoal = member.goal;
    final targetWeightController = TextEditingController(
      text: member.targetWeight?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('목표 설정'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 목표 선택
                const Text(
                  '운동 목표',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<FitnessGoal>(
                  value: selectedGoal,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  items: FitnessGoal.values.map((goal) {
                    final label = switch (goal) {
                      FitnessGoal.diet => '다이어트',
                      FitnessGoal.bulk => '벌크업',
                      FitnessGoal.fitness => '체력 향상',
                      FitnessGoal.rehab => '재활',
                    };
                    return DropdownMenuItem(
                      value: goal,
                      child: Text(label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedGoal = value);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                // 목표 체중
                const Text(
                  '목표 체중 (kg)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: targetWeightController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '예: 70.0',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () async {
                // 목표 체중 파싱
                double? targetWeight;
                final weightText = targetWeightController.text.trim();
                if (weightText.isNotEmpty) {
                  targetWeight = double.tryParse(weightText);
                  if (targetWeight == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('올바른 목표 체중을 입력해주세요')),
                    );
                    return;
                  }
                }

                Navigator.pop(dialogContext);

                try {
                  final memberRepository = ref.read(memberRepositoryProvider);
                  final bodyRecordRepo = ref.read(bodyRecordRepositoryProvider);

                  // 최신 체성분 기록에서 현재 체중 자동 가져오기
                  double? latestWeight;
                  try {
                    final latestRecord = await bodyRecordRepo.getLatestByMemberId(member.id);
                    latestWeight = latestRecord?.weight;
                  } catch (_) {}

                  // 목표 및 목표 체중 업데이트
                  await memberRepository.update(member.id, {
                    'goal': selectedGoal.name,
                    if (targetWeight != null) 'targetWeight': targetWeight,
                    if (latestWeight != null) 'startWeight': latestWeight,
                  });

                  if (context.mounted) {
                    if (targetWeight != null && latestWeight == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('목표가 설정됐어요. 체성분을 기록하면 달성률을 볼 수 있어요')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('목표가 설정됐어요')),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('목표 설정 실패: $e')),
                    );
                  }
                }
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  /// 정보 행 위젯
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.gray600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
