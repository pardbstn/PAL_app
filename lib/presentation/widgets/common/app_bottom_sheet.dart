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
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
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
    final colorScheme = theme.colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final viewInsets = MediaQuery.of(context).viewInsets;

    // 배경색: Theme의 surface 색상 사용
    final backgroundColor = colorScheme.surface;

    // 드래그 핸들 색상: Theme의 outline 또는 onSurfaceVariant 사용
    final dragHandleColor = colorScheme.outlineVariant;

    // 최대 높이 계산 (기본값: 화면의 90%)
    final effectiveMaxHeight = maxHeight ?? screenHeight * 0.9;

    return Padding(
      // 키보드가 올라올 때 시트가 위로 밀림
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: effectiveMaxHeight,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 드래그 핸들
                if (showDragHandle) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: dragHandleColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                // 제목
                if (title != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      title!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                // 콘텐츠
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
