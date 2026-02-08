import 'dart:ui';
import 'package:flutter/material.dart';

/// PAL 앱 공통 다이얼로그 위젯
/// 모든 다이얼로그는 scale + fade 애니메이션과 반응형 너비를 지원합니다.
abstract class AppDialog {
  AppDialog._();

  /// 제목 텍스트 스타일 (Toss Design System)
  static TextStyle _titleStyle(BuildContext context) => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      );

  /// 메시지 텍스트 스타일 (Toss Design System)
  static TextStyle _messageStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.normal,
      color: isDark ? const Color(0xFF8B8B8B) : const Color(0xFF6B6B6B),
    );
  }

  /// 반응형 다이얼로그 너비 계산
  /// 웹에서는 min(400, screenWidth - 48)
  static double _getDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < 448 ? screenWidth - 48 : 400;
  }

  /// 확인 다이얼로그
  /// 취소/확인 두 버튼을 표시하고, 사용자의 선택에 따라 true/false 반환
  /// [isDanger]가 true이면 확인 버튼이 빨간색으로 표시됨
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDanger = false,
  }) {
    return _showAnimatedDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return _DialogContainer(
          width: _getDialogWidth(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: _titleStyle(context)),
              const SizedBox(height: 12),
              Text(message, style: _messageStyle(context)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF4F4F4),
                        foregroundColor: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(cancelText ?? '취소'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDanger ? const Color(0xFFF04452) : const Color(0xFF0064FF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(confirmText ?? '확인'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// 정보 다이얼로그
  /// 단일 확인 버튼만 표시
  static Future<void> info({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
  }) {
    return _showAnimatedDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _DialogContainer(
        width: _getDialogWidth(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: _titleStyle(context)),
            const SizedBox(height: 12),
            Text(message, style: _messageStyle(context)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(buttonText ?? '확인'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 입력 다이얼로그
  /// TextField를 포함하며, 확인 시 입력된 텍스트 반환, 취소 시 null 반환
  static Future<String?> input({
    required BuildContext context,
    required String title,
    String? initialValue,
    String? hint,
    String? confirmText,
  }) {
    return _showAnimatedDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _InputDialogContent(
        title: title,
        initialValue: initialValue,
        hint: hint,
        confirmText: confirmText,
        width: _getDialogWidth(context),
        titleStyle: _titleStyle(context),
      ),
    );
  }

  /// 커스텀 다이얼로그
  /// 사용자 정의 위젯을 다이얼로그로 표시
  static Future<T?> custom<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return _showAnimatedDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => _DialogContainer(
        width: _getDialogWidth(context),
        child: child,
      ),
    );
  }

  /// 애니메이션이 적용된 다이얼로그 표시
  /// scale + fade 애니메이션 사용
  static Future<T?> _showAnimatedDialog<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return builder(context);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }
}

/// 다이얼로그 컨테이너 위젯
/// 반응형 너비, 패딩, 테두리 반경 적용
class _DialogContainer extends StatelessWidget {
  const _DialogContainer({
    required this.child,
    required this.width,
  });

  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: width,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.78)
                  : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.5),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 입력 다이얼로그 내용 위젯
/// TextField의 상태 관리를 위해 StatefulWidget 사용
class _InputDialogContent extends StatefulWidget {
  const _InputDialogContent({
    required this.title,
    required this.width,
    required this.titleStyle,
    this.initialValue,
    this.hint,
    this.confirmText,
  });

  final String title;
  final String? initialValue;
  final String? hint;
  final String? confirmText;
  final double width;
  final TextStyle titleStyle;

  @override
  State<_InputDialogContent> createState() => _InputDialogContentState();
}

class _InputDialogContentState extends State<_InputDialogContent> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: widget.width,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.78)
                  : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.5),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: widget.titleStyle),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => Navigator.of(context).pop(_controller.text),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      child: const Text('취소'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(_controller.text),
                      child: Text(widget.confirmText ?? '확인'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
