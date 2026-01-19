import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';

/// 회원 설정 화면
class MemberSettingsScreen extends ConsumerWidget {
  const MemberSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/member/home'),
        ),
      ),
      body: ListView(
        children: [
          // 프로필 섹션
          _buildProfileSection(context, authState),
          const Divider(height: 32),

          // 앱 설정
          _buildSectionHeader('앱 설정'),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('프로필 수정'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 프로필 수정 화면
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('알림 설정'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 알림 설정 화면
            },
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('다크 모드'),
            trailing: Switch(
              value: false,
              onChanged: (value) {
                // TODO: 다크모드 토글
              },
            ),
          ),
          const Divider(height: 32),

          // 내 PT 정보
          _buildSectionHeader('내 PT 정보'),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.fitness_center, color: AppTheme.secondary),
            ),
            title: const Text('담당 트레이너'),
            subtitle: const Text('김트레이너'), // TODO: 실제 데이터 연동
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 트레이너 정보 화면
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month_outlined),
            title: const Text('PT 일정'),
            subtitle: const Text('12/30회 진행'), // TODO: 실제 데이터 연동
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: PT 일정 화면
            },
          ),
          const Divider(height: 32),

          // 지원
          _buildSectionHeader('지원'),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('고객센터'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('이용약관'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('개인정보 처리방침'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('앱 정보'),
            subtitle: const Text('버전 1.0.0'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'PAL',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 PAL. All rights reserved.',
              );
            },
          ),
          const Divider(height: 32),

          // 로그아웃
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.error),
            title: const Text(
              '로그아웃',
              style: TextStyle(color: AppTheme.error),
            ),
            onTap: () => _showLogoutDialog(context, ref),
          ),
          const SizedBox(height: 16),

          // 회원 탈퇴
          Center(
            child: TextButton(
              onPressed: () => _showDeleteAccountDialog(context, ref),
              child: Text(
                '회원 탈퇴',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, AuthState authState) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.secondary,
                  AppTheme.secondary.withValues(alpha: 0.7),
                ],
              ),
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이름#코드 형식으로 표시
                Row(
                  children: [
                    Text(
                      authState.displayName ?? '회원',
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
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  authState.email ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '회원',
                    style: TextStyle(
                      color: AppTheme.secondary,
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
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
              backgroundColor: AppTheme.error,
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
          '정말 탈퇴하시겠습니까?\n모든 데이터가 삭제되며 복구할 수 없습니다.',
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
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('탈퇴'),
          ),
        ],
      ),
    );
  }
}
