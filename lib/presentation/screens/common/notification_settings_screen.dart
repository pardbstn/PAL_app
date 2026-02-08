import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_pal_app/core/theme/app_tokens.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/providers/push_notification_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/common/app_section.dart';

/// 알림 설정 화면
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userId = authState.userId;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('알림 설정'),
        ),
        body: const Center(
          child: Text('로그인이 필요합니다'),
        ),
      );
    }

    final settingsAsync = ref.watch(notificationSettingsProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('알림 설정'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              Text(
                '알림 설정을 불러올 수 없어요',
                style: TextStyle(
                  color: AppColors.gray600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        data: (settings) {
          if (settings == null) {
            return const Center(
              child: Text('알림 설정이 없어요'),
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            children: [
              // 메시지 섹션
              AppSection(
                title: '메시지',
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                animationDelay: 0.ms,
                child: _SettingTile(
                  icon: Icons.chat_bubble_outline,
                  iconColor: AppColors.primary,
                  title: 'DM 메시지 알림',
                  subtitle: '새로운 메시지가 도착하면 알려드려요',
                  value: settings.dmMessages,
                  onChanged: (value) => _updateSetting(
                    ref,
                    userId,
                    'dmMessages',
                    value,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // 일정 섹션
              AppSection(
                title: '일정',
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                animationDelay: 100.ms,
                child: _SettingTile(
                  icon: Icons.calendar_today_outlined,
                  iconColor: AppColors.secondary,
                  title: 'PT 리마인더 알림',
                  subtitle: 'PT 일정을 미리 알려드려요',
                  value: settings.ptReminders,
                  onChanged: (value) => _updateSetting(
                    ref,
                    userId,
                    'ptReminders',
                    value,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // 분석 섹션
              AppSection(
                title: '분석',
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                animationDelay: 200.ms,
                child: Column(
                  children: [
                    _SettingTile(
                      icon: Icons.insights_outlined,
                      iconColor: AppColors.tertiary,
                      title: 'AI 인사이트 알림',
                      subtitle: '운동 분석 결과를 알려드려요',
                      value: settings.aiInsights,
                      onChanged: (value) => _updateSetting(
                        ref,
                        userId,
                        'aiInsights',
                        value,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _SettingTile(
                      icon: Icons.assessment_outlined,
                      iconColor: AppColors.aiAccent,
                      title: '주간 리포트 알림',
                      subtitle: '주간 운동 리포트를 보내드려요',
                      value: settings.weeklyReport,
                      onChanged: (value) => _updateSetting(
                        ref,
                        userId,
                        'weeklyReport',
                        value,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // 기타 섹션
              AppSection(
                title: '기타',
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                animationDelay: 300.ms,
                child: _SettingTile(
                  icon: Icons.transfer_within_a_station_outlined,
                  iconColor: AppColors.tertiary,
                  title: '트레이너 전환 요청 알림',
                  subtitle: '트레이너 변경 요청을 알려드려요',
                  value: settings.trainerTransfer,
                  onChanged: (value) => _updateSetting(
                    ref,
                    userId,
                    'trainerTransfer',
                    value,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // 안내 텍스트
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  '알림을 끄면 중요한 메시지를 놓칠 수 있어요',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.gray500,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
                  .animate(delay: 400.ms)
                  .fadeIn(duration: 200.ms)
                  .slideY(begin: 0.01, end: 0),
            ],
          );
        },
      ),
    );
  }

  /// 설정 업데이트
  Future<void> _updateSetting(
    WidgetRef ref,
    String userId,
    String settingName,
    bool value,
  ) async {
    await ref.read(pushNotificationProvider.notifier).updateSetting(
          userId,
          settingName,
          value,
        );
  }
}

/// 설정 타일 위젯
class _SettingTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: AppRadius.lgBorderRadius,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.gray200,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // 아이콘
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.smBorderRadius,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              // 텍스트
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.gray400 : AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // 스위치
              Switch.adaptive(
                value: value,
                onChanged: (newValue) {
                  // Haptic feedback
                  HapticFeedback.mediumImpact();
                  onChanged(newValue);
                },
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 200.ms, curve: Curves.easeOut)
        .slideY(begin: 0.01, end: 0, duration: 200.ms, curve: Curves.easeOut);
  }
}
