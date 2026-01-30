import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../data/models/streak_model.dart';

/// 스트릭 히스토리를 보여주는 캘린더 위젯
/// 기록이 있는 날짜를 하이라이트하고 현재 스트릭을 불꽃 색상으로 표시
class StreakCalendarWidget extends StatefulWidget {
  final StreakModel? streak;
  final StreakType type;
  final List<DateTime>? recordDates;
  final Function(DateTime)? onDaySelected;

  const StreakCalendarWidget({
    super.key,
    required this.streak,
    required this.type,
    this.recordDates,
    this.onDaySelected,
  });

  @override
  State<StreakCalendarWidget> createState() => _StreakCalendarWidgetState();
}

class _StreakCalendarWidgetState extends State<StreakCalendarWidget> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  late CalendarFormat _calendarFormat;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;
  }

  // 스트릭 기반으로 기록된 날짜 계산
  List<DateTime> get _streakDates {
    if (widget.recordDates != null) {
      return widget.recordDates!;
    }

    if (widget.streak == null) return [];

    final lastRecordDate = widget.type == StreakType.weight
        ? widget.streak!.lastWeightRecordDate
        : widget.streak!.lastDietRecordDate;

    final currentStreak = widget.type == StreakType.weight
        ? widget.streak!.weightStreak
        : widget.streak!.dietStreak;

    if (lastRecordDate == null || currentStreak == 0) return [];

    // 연속 기록된 날짜들 생성
    final dates = <DateTime>[];
    for (int i = 0; i < currentStreak; i++) {
      dates.add(lastRecordDate.subtract(Duration(days: i)));
    }
    return dates;
  }

  bool _isRecordedDay(DateTime day) {
    return _streakDates.any((d) =>
        d.year == day.year && d.month == day.month && d.day == day.day);
  }

  bool _isCurrentStreakDay(DateTime day) {
    final lastRecordDate = widget.type == StreakType.weight
        ? widget.streak?.lastWeightRecordDate
        : widget.streak?.lastDietRecordDate;

    if (lastRecordDate == null) return false;

    return day.year == lastRecordDate.year &&
        day.month == lastRecordDate.month &&
        day.day == lastRecordDate.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 타입별 색상
    final primaryColor = widget.type == StreakType.weight
        ? const Color(0xFF2563EB) // Primary
        : const Color(0xFF10B981); // Success

    final fireColor = const Color(0xFFFF6B35); // 불꽃 색상

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TableCalendar(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now(),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            widget.onDaySelected?.call(selectedDay);
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          locale: 'ko_KR',
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: theme.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: colorScheme.onSurface,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: colorScheme.onSurface,
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: theme.textTheme.bodySmall!.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
            weekendStyle: theme.textTheme.bodySmall!.copyWith(
              color: colorScheme.error.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: theme.textTheme.bodyMedium!.copyWith(
              color: colorScheme.error,
            ),
            todayDecoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            todayTextStyle: theme.textTheme.bodyMedium!.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            selectedDecoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: theme.textTheme.bodyMedium!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              if (_isRecordedDay(day)) {
                final isCurrentStreak = _isCurrentStreakDay(day);
                return _buildRecordedDay(
                  day,
                  isCurrentStreak ? fireColor : primaryColor,
                  isCurrentStreak,
                  theme,
                );
              }
              return null;
            },
            markerBuilder: (context, day, events) {
              if (_isRecordedDay(day)) {
                return Positioned(
                  bottom: 4,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _isCurrentStreakDay(day)
                          ? fireColor
                          : primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(primaryColor, fireColor, theme, colorScheme),
        const SizedBox(height: 12),
        _buildStreakSummary(primaryColor, theme, colorScheme),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildRecordedDay(
    DateTime day,
    Color color,
    bool isCurrentStreak,
    ThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: isCurrentStreak ? 2 : 1,
        ),
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(
    Color primaryColor,
    Color fireColor,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(
            color: primaryColor,
            label: '기록 완료',
            theme: theme,
          ),
          _buildLegendItem(
            color: fireColor,
            label: '현재',
            icon: '🔥',
            theme: theme,
          ),
          _buildLegendItem(
            color: colorScheme.outline,
            label: '미기록',
            theme: theme,
            isEmpty: true,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required ThemeData theme,
    String? icon,
    bool isEmpty = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null)
          Text(icon, style: const TextStyle(fontSize: 14))
        else
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: isEmpty ? Colors.transparent : color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: isEmpty ? 1 : 2,
              ),
            ),
          ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakSummary(
    Color primaryColor,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final currentStreak = widget.type == StreakType.weight
        ? widget.streak?.weightStreak ?? 0
        : widget.streak?.dietStreak ?? 0;

    final longestStreak = widget.type == StreakType.weight
        ? widget.streak?.longestWeightStreak ?? 0
        : widget.streak?.longestDietStreak ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withValues(alpha: 0.1),
            primaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              icon: Icons.local_fire_department,
              iconColor: const Color(0xFFFF6B35),
              label: '현재',
              value: '$currentStreak일',
              theme: theme,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildSummaryItem(
              icon: Icons.emoji_events,
              iconColor: const Color(0xFFF59E0B),
              label: '최장 기록',
              value: '$longestStreak일',
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
