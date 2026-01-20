import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/data/models/trainer_model.dart';
import 'package:flutter_pal_app/data/repositories/trainer_repository.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/providers/theme_provider.dart';

/// 개발자 테스트용 이메일 (구독 티어 변경 가능)
const _devTestEmail = '10lys0404@naver.com';

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
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/trainer/home'),
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
            onTap: () => _showEditProfileDialog(context, ref, authState),
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
              value: ref.watch(themeModeProvider) == ThemeMode.dark,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).toggleDarkMode(value);
              },
            ),
          ),
          const Divider(height: 32),

          // 구독 정보
          _buildSectionHeader('구독 정보'),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.workspace_premium, color: AppTheme.primary),
            ),
            title: const Text('현재 플랜'),
            subtitle: const Text('Free'),
            trailing: TextButton(
              onPressed: () {
                // TODO: 플랜 업그레이드 화면
              },
              child: const Text('업그레이드'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.analytics_outlined),
            title: const Text('AI 사용량'),
            subtitle: const Text('이번 달: 0/1회'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: AI 사용량 상세
            },
          ),
          const Divider(height: 32),

          // 지원
          _buildSectionHeader('지원'),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('고객센터'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 고객센터
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('이용약관'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 이용약관
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('개인정보 처리방침'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 개인정보 처리방침
            },
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

          // 개발자 옵션 (테스트 계정만)
          if (authState.email == _devTestEmail) ...[
            _buildSectionHeader('🛠️ 개발자 옵션'),
            _buildDevSubscriptionTier(context, ref, authState),
            const Divider(height: 32),
          ],

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
          // 프로필 이미지
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary,
                  AppTheme.primary.withValues(alpha: 0.7),
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
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '트레이너',
                    style: TextStyle(
                      color: AppTheme.primary,
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
            hintText: '이름을 입력하세요',
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
                  const SnackBar(content: Text('이름을 입력해주세요.')),
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
                  const SnackBar(content: Text('프로필이 수정되었습니다.')),
                );
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  /// 개발자 옵션: 구독 티어 변경
  Widget _buildDevSubscriptionTier(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
  ) {
    final trainer = authState.trainerModel;
    final currentTier = trainer?.subscriptionTier ?? SubscriptionTier.free;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.developer_mode, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                '구독 티어 변경 (현재: ${currentTier.name.toUpperCase()})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTierButton(
                context,
                ref,
                tier: SubscriptionTier.free,
                currentTier: currentTier,
                trainerId: trainer?.id,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              _buildTierButton(
                context,
                ref,
                tier: SubscriptionTier.basic,
                currentTier: currentTier,
                trainerId: trainer?.id,
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              _buildTierButton(
                context,
                ref,
                tier: SubscriptionTier.pro,
                currentTier: currentTier,
                trainerId: trainer?.id,
                color: Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '⚠️ 테스트 목적으로만 사용하세요',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// 티어 변경 버튼
  Widget _buildTierButton(
    BuildContext context,
    WidgetRef ref, {
    required SubscriptionTier tier,
    required SubscriptionTier currentTier,
    required String? trainerId,
    required Color color,
  }) {
    final isSelected = tier == currentTier;

    return Expanded(
      child: ElevatedButton(
        onPressed: isSelected || trainerId == null
            ? null
            : () async {
                try {
                  await ref
                      .read(trainerRepositoryProvider)
                      .updateSubscriptionTier(trainerId, tier);

                  // Auth 상태에서 트레이너 데이터 새로고침
                  await ref.read(authProvider.notifier).refreshTrainerData();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${tier.name.toUpperCase()} 플랜으로 변경되었습니다'),
                        backgroundColor: color,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('변경 실패: $e'),
                        backgroundColor: AppTheme.error,
                      ),
                    );
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? color : color.withValues(alpha: 0.1),
          foregroundColor: isSelected ? Colors.white : color,
          elevation: isSelected ? 2 : 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: color.withValues(alpha: isSelected ? 1.0 : 0.5),
            ),
          ),
        ),
        child: Text(
          tier.name.toUpperCase(),
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
