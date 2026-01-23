import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/data/models/exercise_db_model.dart';
import 'package:flutter_pal_app/presentation/providers/exercise_search_provider.dart';

/// 운동 검색 + 제외 목록 위젯
class ExerciseSearchWidget extends ConsumerStatefulWidget {
  final List<ExerciseDbModel> excludedExercises;
  final ValueChanged<ExerciseDbModel> onExclude;
  final ValueChanged<ExerciseDbModel> onRemove;

  const ExerciseSearchWidget({
    super.key,
    required this.excludedExercises,
    required this.onExclude,
    required this.onRemove,
  });

  @override
  ConsumerState<ExerciseSearchWidget> createState() => _ExerciseSearchWidgetState();
}

class _ExerciseSearchWidgetState extends ConsumerState<ExerciseSearchWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  String _searchQuery = '';

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => _searchQuery = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dangerColor = theme.colorScheme.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 검색 입력
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onSearchChanged,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: '제외할 운동 검색...',
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFF10B981).withOpacity(0.5),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),

        // 검색 결과 드롭다운
        if (_searchQuery.isNotEmpty)
          _buildSearchResults(theme),

        // 제외된 운동 칩 목록
        if (widget.excludedExercises.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.excludedExercises.map((ex) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: dangerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: dangerColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ex.nameKo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: dangerColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => widget.onRemove(ex),
                      child: Icon(Icons.close, size: 14, color: dangerColor),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSearchResults(ThemeData theme) {
    final searchAsync = ref.watch(exerciseSearchProvider(_searchQuery));

    return searchAsync.when(
      data: (exercises) {
        // 이미 제외된 운동 필터링
        final filtered = exercises
            .where((ex) => !widget.excludedExercises.any((e) => e.id == ex.id))
            .take(5)
            .toList();

        if (filtered.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '검색 결과가 없습니다.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
            itemBuilder: (context, index) {
              final ex = filtered[index];
              return ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        ex.nameKo,
                        style: theme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      ex.equipment,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ex.primaryMuscle,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),
                onTap: () {
                  widget.onExclude(ex);
                  _controller.clear();
                  setState(() => _searchQuery = '');
                },
              );
            },
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Center(child: SizedBox(
          width: 20, height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
