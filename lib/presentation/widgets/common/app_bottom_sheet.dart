import 'dart:ui';
import 'package:flutter/material.dart';

/// PAL 앱 공통 바텀 시트 위젯
///
/// 사용 예시:
/// ```dart
/// final result = await AppBottomSheet.show<String>(
///   context: context,
///   title: '옵션 선택',
///   child: Column(
///     children: [
///       ListTile(title: Text('옵션 1'), onTap: () => Navigator.pop(context, '옵션1')),
///       ListTile(title: Text('옵션 2'), onTap: () => Navigator.pop(context, '옵션2')),
///     ],
///   ),
/// );
/// ```
abstract class AppBottomSheet {
  /// 바텀 시트를 표시합니다.
  ///
  /// [context] - BuildContext
  /// [child] - 바텀 시트 내부에 표시할 위젯
  /// [title] - 바텀 시트 상단에 표시할 제목 (선택)
  /// [isDismissible] - 배경 탭으로 닫기 가능 여부 (기본값: true)
  /// [showDragHandle] - 드래그 핸들 표시 여부 (기본값: true)
  /// [maxHeight] - 최대 높이 비율 (기본값: 화면의 90%)
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isDismissible = true,
    bool showDragHandle = true,
    double? maxHeight,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) => _BottomSheetContent(
        title: title,
        showDragHandle: showDragHandle,
        maxHeight: maxHeight,
        child: child,
      ),
    );
  }
}

/// 바텀 시트 내부 콘텐츠 위젯
class _BottomSheetContent extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showDragHandle;
  final double? maxHeight;

  const _BottomSheetContent({
    required this.child,
    this.title,
    this.showDragHandle = true,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final viewInsets = MediaQuery.of(context).viewInsets;

    final isDark = theme.brightness == Brightness.dark;

    // 드래그 핸들 색상 (Toss 스타일)
    final dragHandleColor = const Color(0xFFD9D9D9);

    // 최대 높이 계산 (기본값: 화면의 90%)
    final effectiveMaxHeight = maxHeight ?? screenHeight * 0.9;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Padding(
        // 키보드가 올라올 때 시트가 위로 밀림
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: effectiveMaxHeight,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.92),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 드래그 핸들 (Toss 스타일) - 애니메이션 추가
                  if (showDragHandle) ...[
                    const SizedBox(height: 12),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity: value,
                            child: Container(
                              width: 36,
                              height: 4,
                              decoration: BoxDecoration(
                                color: dragHandleColor,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                  // 제목 (Toss 스타일)
                  if (title != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Text(
                        title!,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  // 콘텐츠 (Toss 스타일)
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
