import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/core/theme/app_tokens.dart';
import 'package:flutter_pal_app/core/theme/web_theme.dart';
import 'package:flutter_pal_app/data/models/schedule_model.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/providers/schedule_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/web/web_widgets.dart';

/// 캘린더 뷰 모드
enum CalendarViewMode { month, week }

/// 캘린더 뷰 모드 Notifier
class CalendarViewModeNotifier extends Notifier<CalendarViewMode> {
  @override
  CalendarViewMode build() => CalendarViewMode.month;

  void setMode(CalendarViewMode mode) => state = mode;
  void toggleMode() => state = state == CalendarViewMode.month
      ? CalendarViewMode.week
      : CalendarViewMode.month;
}

/// 캘린더 뷰 모드 Provider
final calendarViewModeProvider =
    NotifierProvider<CalendarViewModeNotifier, CalendarViewMode>(
        CalendarViewModeNotifier.new);

/// 선택된 날짜 Notifier
class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void setDate(DateTime date) => state = date;
}

/// 선택된 날짜 Provider
final selectedDateProvider =
    NotifierProvider<SelectedDateNotifier, DateTime>(SelectedDateNotifier.new);

/// 포커스된 날짜 Notifier
class FocusedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void setDate(DateTime date) => state = date;
}

/// 포커스된 날짜 Provider
final focusedDateProvider =
    NotifierProvider<FocusedDateNotifier, DateTime>(FocusedDateNotifier.new);

/// 트레이너 일정 관리 웹 화면
/// - 주간/월간 캘린더 (table_calendar)
/// - 일정 추가/수정/삭제
/// - 드래그앤드롭 (향후 구현)
class TrainerScheduleWebScreen extends ConsumerStatefulWidget {
  const TrainerScheduleWebScreen({super.key});

  @override
  ConsumerState<TrainerScheduleWebScreen> createState() => _TrainerScheduleWebScreenState();
}

class _TrainerScheduleWebScreenState extends ConsumerState<TrainerScheduleWebScreen> {
  // 스케줄 캐시 (월별)
  final Map<String, List<ScheduleModel>> _schedulesCache = {};

  @override
  Widget build(BuildContext context) {
    final trainer = ref.watch(currentTrainerProvider);
    final viewMode = ref.watch(calendarViewModeProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final focusedDate = ref.watch(focusedDateProvider);

    if (trainer == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // 현재 월의 스케줄 가져오기
    final monthParams = MonthScheduleParams(trainerId: trainer.id, month: focusedDate);
    final schedulesAsync = ref.watch(monthSchedulesProvider(monthParams));

    return Scaffold(
      backgroundColor: WebTheme.contentBgColor(context),
      body: Column(
        children: [
          // 헤더
          _buildHeader(context, viewMode, focusedDate),
          // 메인 컨텐츠
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final layoutType = getLayoutType(constraints.maxWidth);
                final isNarrow = layoutType == LayoutType.mobile;

                if (isNarrow) {
                  return _buildNarrowLayout(context, schedulesAsync, selectedDate, focusedDate, viewMode);
                }
                return _buildWideLayout(context, schedulesAsync, selectedDate, focusedDate, viewMode);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddScheduleDialog(context, selectedDate),
        icon: const Icon(Icons.add),
        label: const Text('일정 추가'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CalendarViewMode viewMode, DateTime focusedDate) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: WebTheme.headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? WebTheme.cardBgDark : WebTheme.cardBgLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            '일정 관리',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 32),
          // 월 네비게이션
          IconButton(
            onPressed: () => _changeMonth(-1),
            icon: const Icon(Icons.chevron_left),
            tooltip: '이전 달',
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(
              DateFormat('yyyy년 M월').format(focusedDate),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _changeMonth(1),
            icon: const Icon(Icons.chevron_right),
            tooltip: '다음 달',
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: _goToToday,
            child: const Text('오늘'),
          ),
          const Spacer(),
          // 뷰 모드 토글
          SegmentedButton<CalendarViewMode>(
            segments: const [
              ButtonSegment(value: CalendarViewMode.month, icon: Icon(Icons.calendar_view_month, size: 18), label: Text('월간')),
              ButtonSegment(value: CalendarViewMode.week, icon: Icon(Icons.calendar_view_week, size: 18), label: Text('주간')),
            ],
            selected: {viewMode},
            onSelectionChanged: (Set<CalendarViewMode> selected) {
              ref.read(calendarViewModeProvider.notifier).setMode(selected.first);
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.02, end: 0);
  }

  Widget _buildWideLayout(
    BuildContext context,
    AsyncValue<List<ScheduleModel>> schedulesAsync,
    DateTime selectedDate,
    DateTime focusedDate,
    CalendarViewMode viewMode,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 캘린더 (왼쪽)
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(24),
            decoration: WebTheme.cardDecoration(context),
            child: schedulesAsync.when(
              data: (schedules) {
                _updateCache(focusedDate, schedules);
                return _buildCalendar(context, schedules, selectedDate, focusedDate, viewMode);
              },
              loading: () => _buildCalendarLoading(context),
              error: (_, _) => _buildCalendarError(context),
            ),
          ),
        ),
        // 선택된 날짜의 일정 (오른쪽)
        SizedBox(
          width: 360,
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 24, 24, 24),
            decoration: WebTheme.cardDecoration(context),
            child: _buildSelectedDateSchedules(context, schedulesAsync, selectedDate),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(
    BuildContext context,
    AsyncValue<List<ScheduleModel>> schedulesAsync,
    DateTime selectedDate,
    DateTime focusedDate,
    CalendarViewMode viewMode,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            decoration: WebTheme.cardDecoration(context),
            child: schedulesAsync.when(
              data: (schedules) {
                _updateCache(focusedDate, schedules);
                return _buildCalendar(context, schedules, selectedDate, focusedDate, viewMode);
              },
              loading: () => _buildCalendarLoading(context),
              error: (_, _) => _buildCalendarError(context),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: WebTheme.cardDecoration(context),
            child: _buildSelectedDateSchedules(context, schedulesAsync, selectedDate),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(
    BuildContext context,
    List<ScheduleModel> schedules,
    DateTime selectedDate,
    DateTime focusedDate,
    CalendarViewMode viewMode,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: TableCalendar<ScheduleModel>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDate,
        selectedDayPredicate: (day) => isSameDay(selectedDate, day),
        calendarFormat: viewMode == CalendarViewMode.month ? CalendarFormat.month : CalendarFormat.week,
        eventLoader: (day) => _getSchedulesForDay(schedules, day),
        startingDayOfWeek: StartingDayOfWeek.sunday,
        headerVisible: false,
        daysOfWeekHeight: 40,
        rowHeight: 80,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: true,
          weekendTextStyle: TextStyle(color: isDark ? Colors.red[300] : Colors.red[400]),
          holidayTextStyle: TextStyle(color: isDark ? Colors.red[300] : Colors.red[400]),
          todayDecoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
          selectedDecoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          markerDecoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
          markerSize: 6,
          markerMargin: const EdgeInsets.symmetric(horizontal: 1),
          cellMargin: const EdgeInsets.all(4),
          cellPadding: const EdgeInsets.all(2),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          weekendStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.red[300] : Colors.red[400],
          ),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return null;

            final ptCount = events.where((e) => e.isPtSchedule).length;
            final personalCount = events.where((e) => e.isPersonalSchedule).length;

            return Positioned(
              bottom: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (ptCount > 0)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (personalCount > 0)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF8A00),
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (events.length > 2)
                    Text(
                      '+${events.length - 2}',
                      style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                    ),
                ],
              ),
            );
          },
        ),
        onDaySelected: (selectedDay, focusedDay) {
          ref.read(selectedDateProvider.notifier).setDate(selectedDay);
          ref.read(focusedDateProvider.notifier).setDate(focusedDay);
        },
        onPageChanged: (focusedDay) {
          ref.read(focusedDateProvider.notifier).setDate(focusedDay);
        },
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildCalendarLoading(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(64),
        child: CircularProgressIndicator(color: colorScheme.primary),
      ),
    );
  }

  Widget _buildCalendarError(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(64),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            const Text('일정을 불러올 수 없어요'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                final trainer = ref.read(currentTrainerProvider);
                if (trainer != null) {
                  final focusedDate = ref.read(focusedDateProvider);
                  ref.invalidate(monthSchedulesProvider(MonthScheduleParams(trainerId: trainer.id, month: focusedDate)));
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDateSchedules(
    BuildContext context,
    AsyncValue<List<ScheduleModel>> schedulesAsync,
    DateTime selectedDate,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(Icons.event, color: colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('M월 d일 (E)', 'ko').format(selectedDate),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _isToday(selectedDate) ? '오늘' : _getRelativeDateLabel(selectedDate),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showAddScheduleDialog(context, selectedDate),
                icon: const Icon(Icons.add_circle_outline),
                tooltip: '일정 추가',
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
        // 일정 목록
        Expanded(
          child: schedulesAsync.when(
            data: (schedules) {
              final daySchedules = _getSchedulesForDay(schedules, selectedDate);
              daySchedules.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

              if (daySchedules.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_available, size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        '일정이 없어요',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => _showAddScheduleDialog(context, selectedDate),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('일정 추가'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: daySchedules.length,
                itemBuilder: (context, index) {
                  return _ScheduleCard(
                    schedule: daySchedules[index],
                    onTap: () => _showScheduleDetailDialog(context, daySchedules[index]),
                    onStatusChange: (status) => _updateScheduleStatus(daySchedules[index], status),
                  ).animate().fadeIn(duration: 200.ms, delay: (50 * index).ms).slideX(begin: 0.02, end: 0);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(
              child: Text('일정을 불러올 수 없어요', style: TextStyle(color: Colors.grey[600])),
            ),
          ),
        ),
      ],
    );
  }

  // 유틸리티 메서드들
  void _changeMonth(int delta) {
    final current = ref.read(focusedDateProvider);
    ref.read(focusedDateProvider.notifier).setDate(DateTime(current.year, current.month + delta, 1));
  }

  void _goToToday() {
    final today = DateTime.now();
    ref.read(selectedDateProvider.notifier).setDate(today);
    ref.read(focusedDateProvider.notifier).setDate(today);
  }

  void _updateCache(DateTime focusedDate, List<ScheduleModel> schedules) {
    final key = '${focusedDate.year}-${focusedDate.month}';
    _schedulesCache[key] = schedules;
  }

  List<ScheduleModel> _getSchedulesForDay(List<ScheduleModel> schedules, DateTime day) {
    return schedules.where((schedule) {
      return schedule.scheduledAt.year == day.year &&
          schedule.scheduledAt.month == day.month &&
          schedule.scheduledAt.day == day.day;
    }).toList();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  String _getRelativeDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff == -1) return '어제';
    if (diff == 1) return '내일';
    if (diff > 1 && diff <= 7) return '$diff일 후';
    if (diff < -1 && diff >= -7) return '${-diff}일 전';
    return DateFormat('yyyy.MM.dd').format(date);
  }

  Future<void> _showAddScheduleDialog(BuildContext context, DateTime date) async {
    // TODO: Implement add schedule dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${DateFormat('M월 d일').format(date)} 일정 추가 기능 준비 중')),
    );
  }

  Future<void> _showScheduleDetailDialog(BuildContext context, ScheduleModel schedule) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        final dialogColorScheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (schedule.isPtSchedule ? dialogColorScheme.primary : const Color(0xFFFF8A00)).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                schedule.isPtSchedule ? Icons.fitness_center : Icons.event,
                color: schedule.isPtSchedule ? dialogColorScheme.primary : const Color(0xFFFF8A00),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                schedule.displayTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(icon: Icons.access_time, label: '시간', value: schedule.timeRangeString),
            const SizedBox(height: 12),
            _DetailRow(icon: Icons.calendar_today, label: '날짜', value: schedule.dateString),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.circle,
              iconColor: _getStatusColor(schedule.status),
              label: '상태',
              value: _getStatusLabel(schedule.status),
            ),
            if (schedule.note != null && schedule.note!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _DetailRow(icon: Icons.notes, label: '메모', value: schedule.note!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('닫기'),
          ),
          if (schedule.status == ScheduleStatus.scheduled) ...[
            OutlinedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _updateScheduleStatus(schedule, ScheduleStatus.cancelled);
              },
              style: OutlinedButton.styleFrom(foregroundColor: dialogColorScheme.error),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _updateScheduleStatus(schedule, ScheduleStatus.completed);
              },
              child: const Text('완료'),
            ),
          ],
        ],
      );
      },
    );
  }

  Future<void> _updateScheduleStatus(ScheduleModel schedule, ScheduleStatus status) async {
    try {
      await ref.read(scheduleNotifierProvider.notifier).updateScheduleStatus(schedule.id, status);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('일정이 ${_getStatusLabel(status)}로 변경됐어요')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('상태 변경 실패: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String _getStatusLabel(ScheduleStatus status) {
    return switch (status) {
      ScheduleStatus.scheduled => '예정',
      ScheduleStatus.completed => '완료',
      ScheduleStatus.cancelled => '취소됨',
      ScheduleStatus.noShow => '노쇼',
    };
  }

  Color _getStatusColor(ScheduleStatus status) {
    return switch (status) {
      ScheduleStatus.scheduled => const Color(0xFF0064FF),
      ScheduleStatus.completed => const Color(0xFF00C471),
      ScheduleStatus.cancelled => Colors.grey,
      ScheduleStatus.noShow => const Color(0xFFF04452),
    };
  }
}

/// 일정 카드 위젯
class _ScheduleCard extends StatefulWidget {
  final ScheduleModel schedule;
  final VoidCallback onTap;
  final ValueChanged<ScheduleStatus> onStatusChange;

  const _ScheduleCard({
    required this.schedule,
    required this.onTap,
    required this.onStatusChange,
  });

  @override
  State<_ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<_ScheduleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPt = widget.schedule.isPtSchedule;
    final accentColor = isPt ? colorScheme.primary : const Color(0xFFFF8A00);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isHovered
                ? accentColor.withValues(alpha: 0.05)
                : (isDark ? const Color(0xFF2D2D2D) : Colors.grey[50]),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered ? accentColor.withValues(alpha: 0.3) : Colors.transparent,
            ),
            boxShadow: _isHovered
                ? [BoxShadow(color: accentColor.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))]
                : null,
          ),
          child: Row(
            children: [
              // 시간
              SizedBox(
                width: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.schedule.timeString,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    Text(
                      '${widget.schedule.duration}분',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              // 구분선
              Container(
                width: 3,
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: accentColor,
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
                        Icon(
                          isPt ? Icons.fitness_center : Icons.event,
                          size: 14,
                          color: accentColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.schedule.displayTitle,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (widget.schedule.note != null && widget.schedule.note!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.schedule.note!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // 상태 및 액션
              if (widget.schedule.status == ScheduleStatus.scheduled)
                PopupMenuButton<ScheduleStatus>(
                  icon: Icon(Icons.more_vert, size: 18, color: Colors.grey[500]),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onSelected: widget.onStatusChange,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: ScheduleStatus.completed,
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 18, color: Color(0xFF00C471)),
                          SizedBox(width: 8),
                          Text('완료'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: ScheduleStatus.noShow,
                      child: Row(
                        children: [
                          Icon(Icons.person_off, size: 18, color: Color(0xFFF04452)),
                          SizedBox(width: 8),
                          Text('노쇼'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: ScheduleStatus.cancelled,
                      child: Row(
                        children: [
                          Icon(Icons.cancel, size: 18, color: Colors.grey),
                          SizedBox(width: 8),
                          Text('취소'),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.schedule.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStatusLabel(widget.schedule.status),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(widget.schedule.status),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusLabel(ScheduleStatus status) {
    return switch (status) {
      ScheduleStatus.scheduled => '예정',
      ScheduleStatus.completed => '완료',
      ScheduleStatus.cancelled => '취소됨',
      ScheduleStatus.noShow => '노쇼',
    };
  }

  Color _getStatusColor(ScheduleStatus status) {
    return switch (status) {
      ScheduleStatus.scheduled => const Color(0xFF0064FF),
      ScheduleStatus.completed => const Color(0xFF00C471),
      ScheduleStatus.cancelled => Colors.grey,
      ScheduleStatus.noShow => const Color(0xFFF04452),
    };
  }
}

/// 상세 정보 행 위젯
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor ?? Colors.grey[500]),
        const SizedBox(width: 12),
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
