import 'package:flutter/material.dart';
import 'package:flutter_pal_app/data/models/curriculum_model.dart';

/// 커리큘럼 운동 카드 위젯
class ExerciseCardWidget extends StatefulWidget {
  final Exercise exercise;
  final int index;
  final VoidCallback? onReplace;
  final Function(int? sets, int? reps, int? restSeconds)? onEdit;

  const ExerciseCardWidget({
    super.key,
    required this.exercise,
    required this.index,
    this.onReplace,
    this.onEdit,
  });

  @override
  State<ExerciseCardWidget> createState() => _ExerciseCardWidgetState();
}

class _ExerciseCardWidgetState extends State<ExerciseCardWidget> {
  bool _isEditing = false;
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _restController;

  @override
  void initState() {
    super.initState();
    _setsController = TextEditingController(text: '${widget.exercise.sets}');
    _repsController = TextEditingController(text: '${widget.exercise.reps}');
    _restController = TextEditingController(
      text: '${widget.exercise.restSeconds ?? 60}',
    );
  }

  @override
  void didUpdateWidget(covariant ExerciseCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise != widget.exercise) {
      _setsController.text = '${widget.exercise.sets}';
      _repsController.text = '${widget.exercise.reps}';
      _restController.text = '${widget.exercise.restSeconds ?? 60}';
    }
  }

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _restController.dispose();
    super.dispose();
  }

  void _saveEdit() {
    final sets = int.tryParse(_setsController.text);
    final reps = int.tryParse(_repsController.text);
    final rest = int.tryParse(_restController.text);
    widget.onEdit?.call(sets, reps, rest);
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const emerald = Color(0xFF10B981);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // 번호 배지
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: emerald.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${widget.index + 1}',
                  style: TextStyle(
                    color: emerald,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 운동 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.exercise.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.exercise.sets}세트 x ${widget.exercise.reps}회'
                      '${widget.exercise.restSeconds != null ? ' · 휴식 ${widget.exercise.restSeconds}초' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              // 액션 버튼들
              if (!_isEditing) ...[
                IconButton(
                  icon: const Icon(Icons.swap_horiz, size: 20),
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  tooltip: '대체 운동',
                  onPressed: widget.onReplace,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  tooltip: '수정',
                  onPressed: () => setState(() => _isEditing = true),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
          // 인라인 편집 모드
          if (_isEditing) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _buildEditField(context, '세트', _setsController),
                const SizedBox(width: 8),
                _buildEditField(context, '횟수', _repsController),
                const SizedBox(width: 8),
                _buildEditField(context, '휴식(초)', _restController),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.check, color: emerald, size: 20),
                  onPressed: _saveEdit,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 20,
                    color: theme.colorScheme.onSurface.withOpacity(0.5)),
                  onPressed: () => setState(() => _isEditing = false),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
          // 메모
          if (widget.exercise.note != null && widget.exercise.note!.isNotEmpty && !_isEditing) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(width: 44),
                Expanded(
                  child: Text(
                    widget.exercise.note!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: emerald.withOpacity(0.8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEditField(
    BuildContext context,
    String label,
    TextEditingController controller,
  ) {
    final theme = Theme.of(context);
    return Expanded(
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: theme.textTheme.bodySmall,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: theme.textTheme.labelSmall,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
