import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('캘린더'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const CalendarSkeleton()
          : Column(
              children: [
                // 헤더 (년/월 + 오늘 버튼)
                _buildHeader(theme),

                // 요일 헤더
                _buildWeekdayHeader(theme),

                // 달력 그리드
                Expanded(
                  flex: 2,
                  child: _buildCalendarGrid(theme),
                ),

                Divider(height: 1, color: theme.colorScheme.outlineVariant),

                // 선택한 날짜의 일정 목록
                Expanded(
                  flex: 3,
                  child: _buildScheduleList(theme),
                ),
              ],
            ),
    );
  }

  /// 헤더 위젯 (년/월 + 오늘 버튼) - 트레이너 스타일과 동일
  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            '${_focusedMonth.year}년 ${_focusedMonth.month}월',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _goToToday,
            child: Text(
              '오늘',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader(ThemeData theme) {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: weekdays.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          Color textColor;
          if (index == 0) {
            textColor = Colors.red;
          } else if (index == 6) {
            textColor = Colors.blue;
          } else {
            textColor = Colors.grey[600]!;
          }

          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(ThemeData theme) {
    final firstDayOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;
    final totalRows = ((firstWeekday + daysInMonth) / 7).ceil();
    final totalCells = totalRows * 7;

    final today = DateTime.now();

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
        mainAxisExtent: (340 - 50) / totalRows, // 동적 높이 조절
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        final dayOffset = index - firstWeekday;
        final date = DateTime(
          _focusedMonth.year,
          _focusedMonth.month,
          dayOffset + 1,
        );

        final isCurrentMonth = date.month == _focusedMonth.month;
        final isToday = date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;
        final isSelected = date.year == _selectedDate.year &&
            date.month == _selectedDate.month &&
            date.day == _selectedDate.day;
        final hasSchedule = isCurrentMonth && _hasScheduleOnDate(date);
        final weekdayIndex = index % 7;

        return GestureDetector(
          onTap: () {
            setState(() => _selectedDate = date);
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary
                  : isToday
                      ? AppTheme.primary.withValues(alpha: 0.1)
                      : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        isSelected || isToday ? FontWeight.bold : null,
                    color: _getDayTextColor(
                      isSelected: isSelected,
                      isCurrentMonth: isCurrentMonth,
                      weekdayIndex: weekdayIndex,
                      theme: theme,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                // 일정 도트 (PT: 파란색) - 현재 월에만 표시
                if (hasSchedule)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : AppTheme.primary,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 날짜 텍스트 색상 결정
  Color _getDayTextColor({
    required bool isSelected,
    required bool isCurrentMonth,
    required int weekdayIndex,
    required ThemeData theme,
  }) {
    if (isSelected) return theme.colorScheme.onPrimary;
    if (!isCurrentMonth) return Colors.grey[300]!;
    if (weekdayIndex == 0) return Colors.red;
    if (weekdayIndex == 6) return Colors.blue;
    return theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface;
  }

  Widget _buildScheduleList(ThemeData theme) {
    final daySchedules = _getSchedulesForDate(_selectedDate);
    final weekdayNames = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdayNames[_selectedDate.weekday - 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 날짜 헤더 - 트레이너 스타일과 동일
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                '${_selectedDate.month}월 ${_selectedDate.day}일 ($weekday)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              if (daySchedules.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${daySchedules.length}건',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
            ],
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
                    return _ScheduleCard(schedule: daySchedules[index]);
                  },
                ),
        ),
      ],
    );
  }
}

/// 일정 카드 위젯 - 트레이너 스타일과 동일 (읽기 전용)
class _ScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;

  const _ScheduleCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final startTime =
        '${schedule.scheduledAt.hour.toString().padLeft(2, '0')}:${schedule.scheduledAt.minute.toString().padLeft(2, '0')}';
    final endTime =
        '${schedule.endTime.hour.toString().padLeft(2, '0')}:${schedule.endTime.minute.toString().padLeft(2, '0')}';
    final isCompleted = schedule.status == ScheduleStatus.completed;
    final isCancelled = schedule.status == ScheduleStatus.cancelled;
    final isPt = schedule.scheduleType == ScheduleType.pt;
    // 시간이 지난 일정인지 확인 (종료 시간 기준)
    final isPast = schedule.endTime.isBefore(DateTime.now());

    // 일정 유형에 따른 색상
    final accentColor = isPt ? AppTheme.primary : AppTheme.tertiary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? Colors.green.withValues(alpha: 0.3)
              : isCancelled
                  ? Colors.grey.withValues(alpha: 0.3)
                  : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 시간
          SizedBox(
            width: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  startTime,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isCancelled ? Colors.grey : null,
                  ),
                ),
                Text(
                  endTime,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          // 컬러바
          Container(
            width: 3,
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green
                  : isCancelled
                      ? Colors.grey
                      : accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // 유형 태그
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: (isCancelled ? Colors.grey : accentColor)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isPt ? 'PT' : '개인',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isCancelled ? Colors.grey : accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        schedule.displayTitle,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          decoration: isCompleted || isCancelled || isPast
                              ? TextDecoration.lineThrough
                              : null,
                          color: isCompleted || isCancelled || isPast
                              ? Colors.grey
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (schedule.note != null && schedule.note!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    schedule.note!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
