import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/core/utils/haptic_utils.dart';

/// 버튼 변형 타입
enum AppButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  danger,
}

/// 버튼 사이즈
enum AppButtonSize {
  sm,
  md,
  lg,
}

/// PAL 앱 공통 버튼 위젯
/// 다양한 변형과 사이즈를 지원하며, 로딩 상태와 아이콘을 포함할 수 있습니다.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  /// 버튼에 표시될 텍스트
  final String label;

  /// 버튼 클릭 시 실행될 콜백 (null이면 비활성화)
  final VoidCallback? onPressed;

  /// 버튼 변형 타입
  final AppButtonVariant variant;

  /// 버튼 사이즈
  final AppButtonSize size;

  /// 버튼 왼쪽에 표시될 아이콘
  final IconData? icon;

  /// 로딩 상태 여부
  final bool isLoading;

  /// 전체 너비 사용 여부
  final bool isFullWidth;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  /// 버튼이 비활성화 상태인지 확인
  bool get _isDisabled => widget.onPressed == null || widget.isLoading;

  /// 사이즈별 수직 패딩 값
  double get _verticalPadding {
    switch (widget.size) {
      case AppButtonSize.sm:
        return 10;
      case AppButtonSize.md:
        return 16;
      case AppButtonSize.lg:
        return 18;
    }
  }

  /// 사이즈별 수평 패딩 값
  double get _horizontalPadding {
    switch (widget.size) {
      case AppButtonSize.sm:
        return 20;
      case AppButtonSize.md:
        return 24;
      case AppButtonSize.lg:
        return 28;
    }
  }

  /// 사이즈별 폰트 크기
  double get _fontSize {
    switch (widget.size) {
      case AppButtonSize.sm:
        return 14;
      case AppButtonSize.md:
        return 16;
      case AppButtonSize.lg:
        return 18;
    }
  }

  /// 변형별 배경색 (다크모드 지원)
  Color _getBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isDisabled) {
      return isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF4F4F4);
    }

    switch (widget.variant) {
      case AppButtonVariant.primary:
        return isDark
            ? Theme.of(context).colorScheme.primary
            : AppTheme.primary;
      case AppButtonVariant.secondary:
        return isDark
            ? Theme.of(context).colorScheme.secondary
            : AppTheme.secondary;
      case AppButtonVariant.outline:
        return Colors.transparent;
      case AppButtonVariant.ghost:
        return Colors.transparent;
      case AppButtonVariant.danger:
        return isDark
            ? Theme.of(context).colorScheme.error
            : AppTheme.error;
    }
  }

  /// 변형별 텍스트/아이콘 색상 (다크모드 지원)
  Color _getForegroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isDisabled) {
      return const Color(0xFFB0B0B0);
    }

    switch (widget.variant) {
      case AppButtonVariant.primary:
        return Colors.white;
      case AppButtonVariant.secondary:
        return Colors.white;
      case AppButtonVariant.outline:
        return isDark
            ? Theme.of(context).colorScheme.primary
            : AppTheme.primary;
      case AppButtonVariant.ghost:
        return isDark
            ? Theme.of(context).colorScheme.primary
            : AppTheme.primary;
      case AppButtonVariant.danger:
        return Colors.white;
    }
  }

  /// 변형별 테두리 (outline 변형에만 적용)
  Border? _getBorder(BuildContext context) {
    if (widget.variant != AppButtonVariant.outline) {
      return null;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? Theme.of(context).colorScheme.primary
        : AppTheme.primary;

    return Border.all(
      color: borderColor,
      width: 1.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor(context);
    final foregroundColor = _getForegroundColor(context);
    final border = _getBorder(context);

    Widget buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 로딩 인디케이터
        if (widget.isLoading)
          SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          ),
        // 아이콘 (로딩 중이 아닐 때만 표시)
        if (!widget.isLoading && widget.icon != null) ...[
          Icon(
            widget.icon,
            size: _fontSize + 2,
            color: foregroundColor,
          ),
          const SizedBox(width: 8),
        ],
        // 로딩 중일 때 간격
        if (widget.isLoading)
          const SizedBox(width: 8),
        // 레이블 텍스트
        Text(
          widget.label,
          style: TextStyle(
            fontSize: _fontSize,
            fontWeight: FontWeight.w600,
            color: foregroundColor,
          ),
        ),
      ],
    );

    Widget button = MouseRegion(
      cursor: _isDisabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      onEnter: (_) {
        if (!_isDisabled) {
          setState(() => _isHovered = true);
        }
      },
      onExit: (_) {
        setState(() => _isHovered = false);
      },
      child: GestureDetector(
        onTapDown: (_) {
          if (!_isDisabled) {
            setState(() => _isPressed = true);
          }
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
        },
        onTap: _isDisabled
            ? null
            : () {
                HapticUtils.light();
                widget.onPressed?.call();
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            vertical: _verticalPadding,
            horizontal: _horizontalPadding,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: border,
          ),
          child: buttonContent,
        ),
      ),
    );

    // 비활성화 상태일 때 포인터 이벤트 차단
    if (_isDisabled) {
      button = AbsorbPointer(child: button);
    } else {
      // hover/tap 애니메이션 적용
      button = button
          .animate(target: _isHovered ? 1 : 0)
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.01, 1.01),
            duration: 150.ms,
            curve: Curves.easeOut,
          )
          .animate(target: _isPressed ? 1 : 0)
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(0.97, 0.97),
            duration: 100.ms,
            curve: Curves.easeOut,
          );
    }

    // 전체 너비 적용
    if (widget.isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}
