import 'package:flutter/material.dart';

/// 숫자 선택 위젯 (1-10)
class WheelPickerWidget extends StatefulWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const WheelPickerWidget({
    super.key,
    required this.label,
    required this.value,
    this.min = 1,
    this.max = 10,
    required this.onChanged,
  });

  @override
  State<WheelPickerWidget> createState() => _WheelPickerWidgetState();
}

class _WheelPickerWidgetState extends State<WheelPickerWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const emerald = Color(0xFF00C471);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Text(
          widget.label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        // Up arrow
        GestureDetector(
          onTap: () {
            if (widget.value < widget.max) {
              widget.onChanged(widget.value + 1);
            }
          },
          child: Icon(
            Icons.keyboard_arrow_up,
            color: widget.value < widget.max
                ? emerald
                : theme.colorScheme.onSurface.withOpacity(0.2),
          ),
        ),
        const SizedBox(height: 4),
        // Value display (tappable)
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isExpanded
                    ? emerald
                    : theme.colorScheme.outline.withOpacity(0.3),
                width: _isExpanded ? 2 : 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '${widget.value}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Down arrow
        GestureDetector(
          onTap: () {
            if (widget.value > widget.min) {
              widget.onChanged(widget.value - 1);
            }
          },
          child: Icon(
            Icons.keyboard_arrow_down,
            color: widget.value > widget.min
                ? emerald
                : theme.colorScheme.onSurface.withOpacity(0.2),
          ),
        ),
        // Dropdown overlay
        if (_isExpanded)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 192),
            width: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: widget.max - widget.min + 1,
              itemBuilder: (context, index) {
                final val = widget.min + index;
                final isSelected = val == widget.value;
                return GestureDetector(
                  onTap: () {
                    widget.onChanged(val);
                    setState(() => _isExpanded = false);
                  },
                  child: Container(
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? emerald : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    child: Text(
                      '$val',
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
