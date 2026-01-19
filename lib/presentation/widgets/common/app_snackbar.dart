import 'package:flutter/material.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';

/// 스낵바 변형 타입
enum AppSnackbarVariant {
  success,
  error,
  warning,
  info,
}

/// PAL 앱 공통 스낵바 위젯
///
/// 4가지 변형을 지원합니다:
/// - success: 성공 메시지 (초록색)
/// - error: 에러 메시지 (빨간색)
/// - warning: 경고 메시지 (주황색)
/// - info: 정보 메시지 (파란색)
abstract class AppSnackbar {
  AppSnackbar._();

  /// 스낵바 표시
  ///
  /// [context] BuildContext
  /// [message] 표시할 메시지
  /// [variant] 스낵바 변형 타입 (기본값: info)
  /// [duration] 표시 시간 (기본값: 3초)
  /// [actionLabel] 액션 버튼 라벨 (선택)
  /// [onAction] 액션 버튼 콜백 (선택)
  static void show({
    required BuildContext context,
    required String message,
    AppSnackbarVariant variant = AppSnackbarVariant.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    // 현재 표시 중인 스낵바 숨기기
    messenger.hideCurrentSnackBar();

    final (backgroundColor, icon) = _getVariantStyle(variant);

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      duration: duration,
      dismissDirection: DismissDirection.horizontal,
      action: actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onAction ?? () {},
            )
          : null,
    );

    messenger.showSnackBar(snackBar);
  }

  /// 성공 스낵바 표시
  static void success(BuildContext context, String message) {
    show(
      context: context,
      message: message,
      variant: AppSnackbarVariant.success,
    );
  }

  /// 에러 스낵바 표시
  static void error(BuildContext context, String message) {
    show(
      context: context,
      message: message,
      variant: AppSnackbarVariant.error,
    );
  }

  /// 경고 스낵바 표시
  static void warning(BuildContext context, String message) {
    show(
      context: context,
      message: message,
      variant: AppSnackbarVariant.warning,
    );
  }

  /// 정보 스낵바 표시
  static void info(BuildContext context, String message) {
    show(
      context: context,
      message: message,
      variant: AppSnackbarVariant.info,
    );
  }

  /// 변형 타입에 따른 스타일 반환
  static (Color, IconData) _getVariantStyle(AppSnackbarVariant variant) {
    return switch (variant) {
      AppSnackbarVariant.success => (AppTheme.secondary, Icons.check_circle),
      AppSnackbarVariant.error => (AppTheme.error, Icons.error),
      AppSnackbarVariant.warning => (AppTheme.tertiary, Icons.warning),
      AppSnackbarVariant.info => (AppTheme.primary, Icons.info),
    };
  }
}
