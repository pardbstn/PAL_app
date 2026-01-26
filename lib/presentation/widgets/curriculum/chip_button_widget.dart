import 'package:flutter/material.dart';

/// 칩 버튼 변형
enum ChipButtonVariant { defaultVariant, danger }

/// 선택 가능한 칩 버튼
class ChipButtonWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ChipButtonVariant variant;
  final int? orderNumber; // 순서 번호 (사이클용)

  const ChipButtonWidget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.variant = ChipButtonVariant.defaultVariant,
    this.orderNumber,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const emerald = Color(0xFF10B981);
    final dangerColor = theme.colorScheme.error;

    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (variant == ChipButtonVariant.danger) {
      if (isSelected) {
        backgroundColor = dangerColor.withOpacity(0.15);
        textColor = dangerColor;
        borderColor = dangerColor.withOpacity(0.5);
      } else {
        backgroundColor = theme.colorScheme.surfaceContainerHighest.withOpacity(0.5);
        textColor = theme.colorScheme.onSurface.withOpacity(0.7);
        borderColor = theme.colorScheme.outline.withOpacity(0.3);
      }
    } else {
      if (isSelected) {
        backgroundColor = emerald;
        textColor = Colors.white;
        borderColor = emerald;
      } else {
        backgroundColor = theme.colorScheme.surfaceContainerHighest.withOpacity(0.5);
        textColor = theme.colorScheme.onSurface.withOpacity(0.7);
        borderColor = theme.colorScheme.outline.withOpacity(0.3);
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (orderNumber != null && isSelected) ...[
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$orderNumber',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: textColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
