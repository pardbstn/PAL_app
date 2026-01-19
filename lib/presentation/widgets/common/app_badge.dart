import 'package:flutter/material.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';

/// 배지 변형 타입
enum AppBadgeVariant {
  primary,
  success,
  warning,
  danger,
  info,
  neutral,
}

/// 배지 크기
enum AppBadgeSize {
  sm,
  md,
}

/// PAL 앱 공통 배지 위젯
/// 다양한 상태와 정보를 시각적으로 표현하는 배지
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.primary,
    this.size = AppBadgeSize.md,
    this.icon,
  });

  /// 배지에 표시할 텍스트
  final String label;

  /// 배지 변형 (색상 스타일)
  final AppBadgeVariant variant;

  /// 배지 크기
  final AppBadgeSize size;

  /// 선택적 아이콘 (텍스트 앞에 표시)
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = _getColors(context);
    final padding = _getPadding();
    final fontSize = _getFontSize();

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: fontSize + 2,
              color: colors.textColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: colors.textColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  EdgeInsets _getPadding() {
    return switch (size) {
      AppBadgeSize.sm => const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      AppBadgeSize.md => const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    };
  }

  double _getFontSize() {
    return switch (size) {
      AppBadgeSize.sm => 10,
      AppBadgeSize.md => 12,
    };
  }

  _BadgeColors _getColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return switch (variant) {
      AppBadgeVariant.primary => _BadgeColors(
        backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
        textColor: isDark ? const Color(0xFF60A5FA) : AppTheme.primary,
      ),
      AppBadgeVariant.success => _BadgeColors(
        backgroundColor: AppTheme.secondary.withValues(alpha: 0.1),
        textColor: isDark ? const Color(0xFF34D399) : AppTheme.secondary,
      ),
      AppBadgeVariant.warning => _BadgeColors(
        backgroundColor: AppTheme.tertiary.withValues(alpha: 0.1),
        textColor: isDark ? const Color(0xFFFBBF24) : AppTheme.tertiary,
      ),
      AppBadgeVariant.danger => _BadgeColors(
        backgroundColor: AppTheme.error.withValues(alpha: 0.1),
        textColor: isDark ? const Color(0xFFF87171) : AppTheme.error,
      ),
      AppBadgeVariant.info => _BadgeColors(
        backgroundColor: Colors.blue.withValues(alpha: 0.1),
        textColor: isDark ? Colors.blue[300]! : Colors.blue,
      ),
      AppBadgeVariant.neutral => _BadgeColors(
        backgroundColor: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        textColor: isDark ? Colors.grey[300]! : Colors.grey[700]!,
      ),
    };
  }
}

/// 배지 색상 정보
class _BadgeColors {
  const _BadgeColors({
    required this.backgroundColor,
    required this.textColor,
  });

  final Color backgroundColor;
  final Color textColor;
}

/// 목표(Goal) 배지 위젯
/// 회원의 PT 목표를 시각적으로 표현
class GoalBadge extends StatelessWidget {
  const GoalBadge({
    super.key,
    required this.goal,
    this.size = AppBadgeSize.md,
  });

  /// 목표 문자열 (diet, bulk, fitness, rehab)
  final String goal;

  /// 배지 크기
  final AppBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final config = _getGoalConfig();
    final colors = _getColors(context, config.colorType);
    final padding = _getPadding();
    final fontSize = _getFontSize();

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${config.emoji} ${config.label}',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: colors.textColor,
          height: 1.2,
        ),
      ),
    );
  }

  EdgeInsets _getPadding() {
    return switch (size) {
      AppBadgeSize.sm => const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      AppBadgeSize.md => const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    };
  }

  double _getFontSize() {
    return switch (size) {
      AppBadgeSize.sm => 10,
      AppBadgeSize.md => 12,
    };
  }

  _GoalConfig _getGoalConfig() {
    final normalized = goal.toLowerCase().trim();

    return switch (normalized) {
      'diet' || '다이어트' => const _GoalConfig(
        emoji: '\u{1F525}', // 🔥
        label: '다이어트',
        colorType: _GoalColorType.warning,
      ),
      'bulk' || '벌크업' => const _GoalConfig(
        emoji: '\u{1F4AA}', // 💪
        label: '벌크업',
        colorType: _GoalColorType.purple,
      ),
      'fitness' || '체력향상' => const _GoalConfig(
        emoji: '\u{1F3C3}', // 🏃
        label: '체력향상',
        colorType: _GoalColorType.success,
      ),
      'rehab' || '재활' => const _GoalConfig(
        emoji: '\u{1FA79}', // 🩹
        label: '재활',
        colorType: _GoalColorType.info,
      ),
      _ => _GoalConfig(
        emoji: '\u{1F3AF}', // 🎯
        label: goal,
        colorType: _GoalColorType.neutral,
      ),
    };
  }

  _BadgeColors _getColors(BuildContext context, _GoalColorType colorType) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return switch (colorType) {
      _GoalColorType.warning => _BadgeColors(
        backgroundColor: AppTheme.tertiary.withValues(alpha: 0.1),
        textColor: isDark ? const Color(0xFFFBBF24) : AppTheme.tertiary,
      ),
      _GoalColorType.purple => _BadgeColors(
        backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
        textColor: isDark ? const Color(0xFFA78BFA) : const Color(0xFF8B5CF6),
      ),
      _GoalColorType.success => _BadgeColors(
        backgroundColor: AppTheme.secondary.withValues(alpha: 0.1),
        textColor: isDark ? const Color(0xFF34D399) : AppTheme.secondary,
      ),
      _GoalColorType.info => _BadgeColors(
        backgroundColor: Colors.blue.withValues(alpha: 0.1),
        textColor: isDark ? Colors.blue[300]! : Colors.blue,
      ),
      _GoalColorType.neutral => _BadgeColors(
        backgroundColor: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        textColor: isDark ? Colors.grey[300]! : Colors.grey[700]!,
      ),
    };
  }
}

enum _GoalColorType {
  warning,
  purple,
  success,
  info,
  neutral,
}

class _GoalConfig {
  const _GoalConfig({
    required this.emoji,
    required this.label,
    required this.colorType,
  });

  final String emoji;
  final String label;
  final _GoalColorType colorType;
}

/// 경험 수준(Experience) 배지 위젯
/// 회원의 운동 경험 수준을 시각적으로 표현
class ExperienceBadge extends StatelessWidget {
  const ExperienceBadge({
    super.key,
    required this.experience,
    this.size = AppBadgeSize.md,
  });

  /// 경험 수준 문자열 (beginner, intermediate, advanced)
  final String experience;

  /// 배지 크기
  final AppBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final config = _getExperienceConfig();
    final colors = _getColors(context, config.colorType);
    final padding = _getPadding();
    final fontSize = _getFontSize();

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${config.stars} ${config.label}',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: colors.textColor,
          height: 1.2,
        ),
      ),
    );
  }

  EdgeInsets _getPadding() {
    return switch (size) {
      AppBadgeSize.sm => const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      AppBadgeSize.md => const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    };
  }

  double _getFontSize() {
    return switch (size) {
      AppBadgeSize.sm => 10,
      AppBadgeSize.md => 12,
    };
  }

  _ExperienceConfig _getExperienceConfig() {
    final normalized = experience.toLowerCase().trim();

    return switch (normalized) {
      'beginner' || '입문' => const _ExperienceConfig(
        stars: '\u2B50', // ⭐
        label: '입문',
        colorType: _ExperienceColorType.neutral,
      ),
      'intermediate' || '중급' => const _ExperienceConfig(
        stars: '\u2B50\u2B50', // ⭐⭐
        label: '중급',
        colorType: _ExperienceColorType.primary,
      ),
      'advanced' || '상급' => const _ExperienceConfig(
        stars: '\u2B50\u2B50\u2B50', // ⭐⭐⭐
        label: '상급',
        colorType: _ExperienceColorType.warning,
      ),
      _ => _ExperienceConfig(
        stars: '\u2B50', // ⭐
        label: experience,
        colorType: _ExperienceColorType.neutral,
      ),
    };
  }

  _BadgeColors _getColors(BuildContext context, _ExperienceColorType colorType) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return switch (colorType) {
      _ExperienceColorType.neutral => _BadgeColors(
        backgroundColor: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        textColor: isDark ? Colors.grey[300]! : Colors.grey[700]!,
      ),
      _ExperienceColorType.primary => _BadgeColors(
        backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
        textColor: isDark ? const Color(0xFF60A5FA) : AppTheme.primary,
      ),
      _ExperienceColorType.warning => _BadgeColors(
        backgroundColor: AppTheme.tertiary.withValues(alpha: 0.1),
        textColor: isDark ? const Color(0xFFFBBF24) : AppTheme.tertiary,
      ),
    };
  }
}

enum _ExperienceColorType {
  neutral,
  primary,
  warning,
}

class _ExperienceConfig {
  const _ExperienceConfig({
    required this.stars,
    required this.label,
    required this.colorType,
  });

  final String stars;
  final String label;
  final _ExperienceColorType colorType;
}

/// 상태(Status) 배지 위젯
/// PT 진행 상태를 시각적으로 표현
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    this.size = AppBadgeSize.md,
  });

  /// 상태 문자열 (active, completed, expiring 또는 한글)
  final String status;

  /// 배지 크기
  final AppBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig();
    final colors = _getColors(context, config.colorType);
    final padding = _getPadding();
    final fontSize = _getFontSize();

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: colors.textColor,
          height: 1.2,
        ),
      ),
    );
  }

  EdgeInsets _getPadding() {
    return switch (size) {
      AppBadgeSize.sm => const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      AppBadgeSize.md => const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    };
  }

  double _getFontSize() {
    return switch (size) {
      AppBadgeSize.sm => 10,
      AppBadgeSize.md => 12,
    };
  }

  _StatusConfig _getStatusConfig() {
    final normalized = status.toLowerCase().trim();

    return switch (normalized) {
      'active' || '진행중' => const _StatusConfig(
        label: '진행중',
        colorType: _StatusColorType.success,
      ),
      'completed' || '완료' => const _StatusConfig(
        label: '완료',
        colorType: _StatusColorType.neutral,
      ),
      'expiring' || '임박' || 'pt임박' => const _StatusConfig(
        label: 'PT임박',
        colorType: _StatusColorType.danger,
      ),
      _ => _StatusConfig(
        label: status,
        colorType: _StatusColorType.neutral,
      ),
    };
  }

  _BadgeColors _getColors(BuildContext context, _StatusColorType colorType) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return switch (colorType) {
      _StatusColorType.success => _BadgeColors(
        backgroundColor: AppTheme.secondary.withValues(alpha: 0.1),
        textColor: isDark ? const Color(0xFF34D399) : AppTheme.secondary,
      ),
      _StatusColorType.neutral => _BadgeColors(
        backgroundColor: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        textColor: isDark ? Colors.grey[300]! : Colors.grey[700]!,
      ),
      _StatusColorType.danger => _BadgeColors(
        backgroundColor: AppTheme.error.withValues(alpha: 0.1),
        textColor: isDark ? const Color(0xFFF87171) : AppTheme.error,
      ),
    };
  }
}

enum _StatusColorType {
  success,
  neutral,
  danger,
}

class _StatusConfig {
  const _StatusConfig({
    required this.label,
    required this.colorType,
  });

  final String label;
  final _StatusColorType colorType;
}
