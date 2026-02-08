import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_pal_app/core/theme/app_tokens.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/providers/theme_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/common/app_list_tile.dart';
import 'package:flutter_pal_app/presentation/widgets/common/app_section.dart';
import 'package:flutter_pal_app/presentation/widgets/common/mesh_gradient_background.dart';

/// 소셜 로그인 임시 이메일 체크 및 표시
String _getDisplayEmail(String? email) {
  if (email == null || email.isEmpty) return '-';
  // 소셜 로그인 임시/릴레이 이메일 패턴
  if (email.contains('privaterelay.appleid.com') ||
      email.contains('@privaterelay.') ||
      RegExp(r'^[a-z0-9]{10,}@').hasMatch(email)) {
    return '-';
  }
  return email;
}

/// 트레이너 설정 화면
class TrainerSettingsScreen extends ConsumerWidget {
  const TrainerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.go('/trainer/home'),
        ),
      ),
      body: MeshGradientBackground(
        child: ListView(
        children: [
          // 프로필 섹션
          _buildProfileSection(context, authState)
              .animate()
              .fadeIn(duration: 200.ms)
              .slideY(begin: 0.02, end: 0),
          const SizedBox(height: AppSpacing.xl),

          // 앱 설정
          AppSection(
            title: '앱 설정',
            animationDelay: 100.ms,
            child: AppListTileGroup(
              animate: false,
              children: [
                AppListTile(
                  leading: const Icon(Icons.person_outline),
                  title: '프로필 수정',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showEditProfileDialog(context, ref, authState),
                ),
                AppListTile(
                  leading: const Icon(Icons.notifications_none_rounded),
                  title: '알림 설정',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/notification-settings'),
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
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 지원
          AppSection(
            title: '지원',
            animationDelay: 200.ms,
            child: AppListTileGroup(
              animate: false,
              children: [
                AppListTile(
                  leading: const Icon(Icons.help_outline),
                  title: '고객센터',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: 고객센터
                  },
                ),
                AppListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: '이용약관',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: 이용약관
                  },
                ),
                AppListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: '개인정보 처리방침',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: 개인정보 처리방침
                  },
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
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 로그아웃
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.05),
                borderRadius: AppRadius.lgBorderRadius,
              ),
              child: InkWell(
                onTap: () => _showLogoutDialog(context, ref),
                borderRadius: AppRadius.lgBorderRadius,
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
          )
              .animate()
              .fadeIn(duration: 200.ms, delay: 150.ms)
              .slideY(begin: 0.02, end: 0),
          const SizedBox(height: AppSpacing.md),

          // 회원 탈퇴
          Center(
            child: TextButton(
              onPressed: () => _showDeleteAccountDialog(context, ref),
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
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, AuthState authState) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // 프로필 이미지
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
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
          ),
          const SizedBox(width: AppSpacing.md),
          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authState.displayName ?? '트레이너',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _getDisplayEmail(authState.email),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.gray600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: AppRadius.mdBorderRadius,
                  ),
                  child: const Text(
                    '트레이너',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
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
}
