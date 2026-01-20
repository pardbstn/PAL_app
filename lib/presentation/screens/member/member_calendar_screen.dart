import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_pal_app/data/models/schedule_model.dart';
import 'package:flutter_pal_app/data/repositories/schedule_repository.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/skeleton/skeletons.dart';
import 'package:flutter_pal_app/presentation/widgets/states/states.dart';

/// 회원 캘린더 화면 - PT 일정 조회 전용 (수정 불가)
class MemberCalendarScreen extends ConsumerStatefulWidget {
  const MemberCalendarScreen({super.key});

  @override
  ConsumerState<MemberCalendarScreen> createState() =>
      _MemberCalendarScreenState();
}

class _MemberCalendarScreenState extends ConsumerState<MemberCalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  // 스케줄 캐시
  List<ScheduleModel> _schedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSchedules();
    });
  }

  Future<void> _loadSchedules() async {
    final member = ref.read(currentMemberProvider);
    if (member == null) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(scheduleRepositoryProvider);
      final schedules = await repo.getMemberSchedules(member.id);
      if (mounted) {
        setState(() {
          _schedules = schedules;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('일정 로드 실패: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<ScheduleModel> _getSchedulesForDate(DateTime date) {
    return _schedules.where((s) {
      return s.scheduledAt.year == date.year &&
          s.scheduledAt.month == date.month &&
          s.scheduledAt.day == date.day;
    }).toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  bool _hasScheduleOnDate(DateTime date) {
    return _schedules.any((s) =>
        s.scheduledAt.year == date.year &&
        s.scheduledAt.month == date.month &&
        s.scheduledAt.day == date.day);
  }

  void _goToToday() {
    setState(() {
      _selectedDate = DateTime.now();
      _focusedMonth = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('캘린더'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: _goToToday,
            tooltip: '오늘',
          ),
        ],
      ),
      body: _isLoading
          ? const CalendarSkeleton()
          : Column(
              children: [
                // 월 네비게이션
                _buildMonthNavigation(theme, colorScheme),

                // 요일 헤더
                _buildWeekdayHeader(theme, colorScheme),

                // 달력 그리드
                Expanded(
                  flex: 2,
                  child: _buildCalendarGrid(theme, colorScheme),
                ),

                const Divider(height: 1),

                // 선택한 날짜의 일정 목록
                Expanded(
                  flex: 3,
                  child: _buildScheduleList(theme, colorScheme),
                ),
              ],
            ),
    );
  }

  Widget _buildMonthNavigation(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month - 1,
                );
              });
            },
          ),
          Text(
            DateFormat('yyyy년 M월', 'ko').format(_focusedMonth),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month + 1,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader(ThemeData theme, ColorScheme colorScheme) {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: weekdays.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          Color textColor = colorScheme.onSurface;
          if (index == 0) textColor = Colors.red;
          if (index == 6) textColor = Colors.blue;

          return Expanded(
            child: Center(
              child: Text(
                day,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(ThemeData theme, ColorScheme colorScheme) {
    final firstDayOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    final today = DateTime.now();

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        final dayOffset = index - firstWeekday;
        if (dayOffset < 0 || dayOffset >= daysInMonth) {
          return const SizedBox.shrink();
        }

        final date = DateTime(
          _focusedMonth.year,
          _focusedMonth.month,
          dayOffset + 1,
        );

        final isToday = date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;
        final isSelected = date.year == _selectedDate.year &&
            date.month == _selectedDate.month &&
            date.day == _selectedDate.day;
        final hasSchedule = _hasScheduleOnDate(date);
        final weekday = date.weekday % 7;

        return GestureDetector(
          onTap: () {
            setState(() => _selectedDate = date);
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary
                  : isToday
                      ? colorScheme.primaryContainer
                      : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : weekday == 0
                            ? Colors.red
                            : weekday == 6
                                ? Colors.blue
                                : colorScheme.onSurface,
                    fontWeight: isToday || isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                if (hasSchedule && !isSelected)
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScheduleList(ThemeData theme, ColorScheme colorScheme) {
    final daySchedules = _getSchedulesForDate(_selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            DateFormat('M월 d일 (E)', 'ko').format(_selectedDate),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: daySchedules.isEmpty
              ? Center(
                  child: EmptyState(
                    type: EmptyStateType.sessions,
                    customTitle: '일정 없음',
                    customMessage: '이 날에 예정된 PT 일정이 없습니다',
                    iconSize: 80,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: daySchedules.length,
                  itemBuilder: (context, index) {
                    return _buildScheduleCard(
                        daySchedules[index], theme, colorScheme);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildScheduleCard(
      ScheduleModel schedule, ThemeData theme, ColorScheme colorScheme) {
    final timeFormat = DateFormat('HH:mm');
    final startTime = timeFormat.format(schedule.scheduledAt);
    final endTime = timeFormat.format(
      schedule.scheduledAt.add(Duration(minutes: schedule.duration)),
    );

    final isPT = schedule.scheduleType == ScheduleType.pt;
    final statusColor = _getStatusColor(schedule.status, colorScheme);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 시간 표시
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  startTime,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  endTime,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // 구분선
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: isPT ? colorScheme.primary : colorScheme.secondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),

            // 일정 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        schedule.title ?? 'PT 세션',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getStatusText(schedule.status),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (schedule.note != null && schedule.note!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        schedule.note!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ScheduleStatus status, ColorScheme colorScheme) {
    switch (status) {
      case ScheduleStatus.scheduled:
        return colorScheme.primary;
      case ScheduleStatus.completed:
        return Colors.green;
      case ScheduleStatus.cancelled:
        return Colors.red;
      case ScheduleStatus.noShow:
        return Colors.orange;
    }
  }

  String _getStatusText(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.scheduled:
        return '예정';
      case ScheduleStatus.completed:
        return '완료';
      case ScheduleStatus.cancelled:
        return '취소';
      case ScheduleStatus.noShow:
        return '노쇼';
    }
  }
}
