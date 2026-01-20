import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/presentation/widgets/skeleton/skeletons.dart';
import 'package:flutter_pal_app/presentation/widgets/states/states.dart';
import 'package:flutter_pal_app/data/models/schedule_model.dart';
import 'package:flutter_pal_app/data/repositories/schedule_repository.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:uuid/uuid.dart';

/// 트레이너 캘린더 화면 - 프로덕션 품질 버전
/// 기능:
/// - 월별/주별 무한 스와이프
/// - 시간대별 일정 블록 표시
/// - PT/개인 일정 구분
class TrainerCalendarScreen extends ConsumerStatefulWidget {
  const TrainerCalendarScreen({super.key});

  @override
  ConsumerState<TrainerCalendarScreen> createState() =>
      _TrainerCalendarScreenState();
}

class _TrainerCalendarScreenState extends ConsumerState<TrainerCalendarScreen> {
  // 상태 변수
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  bool _isWeekView = false;

  // 일정 캐시: 월별로 저장 (YYYY-MM 형식)
  final Map<String, List<ScheduleModel>> _schedulesCache = {};
  // 날짜별 일정 캐시: (YYYY-MM-DD 형식) - 성능 최적화
  final Map<String, List<ScheduleModel>> _schedulesPerDayCache = {};
  final Set<String> _loadingMonths = {};
  bool _isLoading = false;

  // PageController 설정 (무한 스와이프)
  late final PageController _monthPageController;
  late final PageController _weekPageController;
  static const int _initialPage = 120; // 앞뒤 10년 범위 (성능 최적화)

  // 주별 뷰 시간 설정
  static const int _dayStartHour = 6; // 6:00 AM
  static const int _dayEndHour = 29; // 다음날 5:00 AM (24 + 5)
  static const double _hourHeight = 60.0;

  @override
  void initState() {
    super.initState();
    _monthPageController = PageController(initialPage: _initialPage);
    _weekPageController = PageController(initialPage: _initialPage);
    // 데이터 로드는 첫 프레임 후 (로딩 인디케이터 없이)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await _loadSchedulesForMonth(_focusedMonth, showLoading: false);
        // 데이터 로드 완료 후 UI 업데이트
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _monthPageController.dispose();
    _weekPageController.dispose();
    super.dispose();
  }

  /// 페이지 인덱스로부터 월 계산
  DateTime _getMonthFromPage(int page) {
    final now = DateTime.now();
    final diff = page - _initialPage;
    return DateTime(now.year, now.month + diff, 1);
  }

  /// 페이지 인덱스로부터 주 시작일 계산
  DateTime _getWeekStartFromPage(int page) {
    final now = DateTime.now();
    final todayWeekStart = now.subtract(Duration(days: now.weekday % 7));
    final diff = page - _initialPage;
    return DateTime(
      todayWeekStart.year,
      todayWeekStart.month,
      todayWeekStart.day + (diff * 7),
    );
  }

  /// 월별 키 생성
  String _getMonthKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  /// 날짜별 키 생성 (성능 최적화용)
  String _getDayKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 월별 일정을 날짜별 캐시로 분배
  void _populateDayCache(String monthKey, List<ScheduleModel> schedules) {
    // 기존 월의 날짜별 캐시 제거
    _schedulesPerDayCache.removeWhere((key, _) => key.startsWith(monthKey));

    // 일정을 날짜별로 그룹화
    final Map<String, List<ScheduleModel>> grouped = {};
    for (final schedule in schedules) {
      final dayKey = _getDayKey(schedule.scheduledAt);
      grouped.putIfAbsent(dayKey, () => []).add(schedule);
    }

    // 정렬하여 캐시에 저장
    grouped.forEach((dayKey, daySchedules) {
      daySchedules.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      _schedulesPerDayCache[dayKey] = daySchedules;
    });
  }

  /// 특정 월의 일정 로드
  /// [showLoading] - true면 로딩 인디케이터 표시 (현재 월에만 사용)
  Future<void> _loadSchedulesForMonth(DateTime month, {bool showLoading = true}) async {
    final monthKey = _getMonthKey(month);

    // 이미 캐시에 있으면 스킵
    if (_schedulesCache.containsKey(monthKey)) return;

    // 이미 로드 중이면 스킵
    if (_loadingMonths.contains(monthKey)) return;

    final trainer = ref.read(currentTrainerProvider);
    if (trainer == null) return;

    _loadingMonths.add(monthKey);

    // 현재 월에 대해서만 로딩 표시 (인접 월 프리로드 시에는 표시 안 함)
    if (showLoading && mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final repo = ref.read(scheduleRepositoryProvider);
      final schedules = await repo.getSchedulesForMonth(trainer.id, month);

      if (mounted) {
        // 캐시 업데이트 (setState 없이)
        _schedulesCache[monthKey] = schedules;
        _populateDayCache(monthKey, schedules);

        // 로딩 중이었으면 상태 업데이트
        if (showLoading) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      debugPrint('일정 로드 실패: $e');
      if (mounted) {
        _schedulesCache[monthKey] = [];
        _populateDayCache(monthKey, []);
        if (showLoading) {
          setState(() => _isLoading = false);
        }
      }
    } finally {
      _loadingMonths.remove(monthKey);
    }
  }

  /// 인접 월 사전 로드 (백그라운드, setState 없음)
  void _preloadAdjacentMonths(DateTime month) {
    final prevMonth = DateTime(month.year, month.month - 1, 1);
    final nextMonth = DateTime(month.year, month.month + 1, 1);
    // 로딩 인디케이터 없이 백그라운드 로드
    _loadSchedulesForMonth(prevMonth, showLoading: false);
    _loadSchedulesForMonth(nextMonth, showLoading: false);
  }

  /// 특정 날짜의 일정 조회 (O(1) 캐시 조회로 최적화)
  List<ScheduleModel> _getSchedulesForDate(DateTime date) {
    final dayKey = _getDayKey(date);
    return _schedulesPerDayCache[dayKey] ?? [];
  }

  /// 오늘로 이동
  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDate = now;
      _focusedMonth = now;
    });

    if (_isWeekView) {
      if (_weekPageController.hasClients) {
        _weekPageController.animateToPage(
          _initialPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      if (_monthPageController.hasClients) {
        _monthPageController.animateToPage(
          _initialPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }

    _loadSchedulesForMonth(now);
  }

  /// 특정 월로 점프
  void _jumpToMonth(DateTime month) {
    final now = DateTime.now();
    final monthsDiff = (month.year - now.year) * 12 + (month.month - now.month);
    final targetPage = _initialPage + monthsDiff;

    setState(() {
      _focusedMonth = month;
      _selectedDate = DateTime(month.year, month.month, 1);
    });

    if (_monthPageController.hasClients) {
      _monthPageController.jumpToPage(targetPage);
    }

    _loadSchedulesForMonth(month);
    _preloadAdjacentMonths(month);
  }

  /// 일정 데이터 새로고침
  Future<void> _refreshSchedules() async {
    // 캐시 비우고 현재 월 다시 로드 (로딩 인디케이터 없이 - 성능 최적화)
    _schedulesCache.clear();
    _schedulesPerDayCache.clear();
    await _loadSchedulesForMonth(_focusedMonth, showLoading: false);
    _preloadAdjacentMonths(_focusedMonth);
    // 데이터 로드 후 UI 업데이트
    if (mounted) setState(() {});
  }

  /// 월별/주별 뷰 전환 (페이지 동기화 포함)
  void _toggleViewMode() {
    final targetDate = _selectedDate;

    if (!_isWeekView) {
      // 월별 → 주별: 선택된 날짜 기준으로 주별 페이지 계산
      final weekPage = _getWeekPageForDate(targetDate);
      setState(() {
        _isWeekView = true;
        _focusedMonth = targetDate;
      });
      // 프레임 후 페이지 이동
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_weekPageController.hasClients) {
          _weekPageController.jumpToPage(weekPage);
        }
      });
    } else {
      // 주별 → 월별: 선택된 날짜 기준으로 월별 페이지 계산
      final monthPage = _getMonthPageForDate(targetDate);
      setState(() {
        _isWeekView = false;
        _focusedMonth = DateTime(targetDate.year, targetDate.month, 1);
      });
      // 프레임 후 페이지 이동
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_monthPageController.hasClients) {
          _monthPageController.jumpToPage(monthPage);
        }
      });
    }
  }

  /// 날짜로부터 주별 페이지 번호 계산
  int _getWeekPageForDate(DateTime date) {
    final now = DateTime.now();
    final todayWeekStart = now.subtract(Duration(days: now.weekday % 7));
    final targetWeekStart = date.subtract(Duration(days: date.weekday % 7));
    final weeksDiff = targetWeekStart.difference(todayWeekStart).inDays ~/ 7;
    return _initialPage + weeksDiff;
  }

  /// 날짜로부터 월별 페이지 번호 계산
  int _getMonthPageForDate(DateTime date) {
    final now = DateTime.now();
    final monthsDiff = (date.year - now.year) * 12 + (date.month - now.month);
    return _initialPage + monthsDiff;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? theme.scaffoldBackgroundColor
        : colorScheme.surface;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            Expanded(
              child: _isWeekView
                  ? _buildWeekViewWithSwipe()
                  : _buildMonthViewWithSwipe(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddScheduleBottomSheet(),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// 헤더 위젯 (년/월 + 오늘 + 뷰 전환)
  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showMonthPicker(),
            child: Row(
              children: [
                Text(
                  '${_focusedMonth.year}년 ${_focusedMonth.month}월',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, size: 24),
              ],
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
          IconButton(
            icon: Icon(
              _isWeekView ? Icons.calendar_month : Icons.view_week,
              color: theme.iconTheme.color,
            ),
            tooltip: _isWeekView ? '월별 보기' : '주별 보기',
            onPressed: () => _toggleViewMode(),
          ),
        ],
      ),
    );
  }

  /// 월 선택 바텀시트
  void _showMonthPicker() {
    DateTime tempMonth = _focusedMonth;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (dialogContext) => SizedBox(
        height: 300,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('취소'),
                  ),
                  const Text(
                    '월 선택',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _jumpToMonth(tempMonth);
                    },
                    child: const Text('확인'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.monthYear,
                initialDateTime: _focusedMonth,
                onDateTimeChanged: (date) {
                  tempMonth = date;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 월별 캘린더 (무한 스와이프)
  // ============================================================

  Widget _buildMonthViewWithSwipe() {
    return Column(
      children: [
        // 월별 캘린더 그리드 (RepaintBoundary로 격리)
        RepaintBoundary(
          child: SizedBox(
            height: 340,
            child: PageView.builder(
              controller: _monthPageController,
              onPageChanged: (page) async {
                final month = _getMonthFromPage(page);
                // 같은 월이면 무시
                if (_focusedMonth.year == month.year &&
                    _focusedMonth.month == month.month) {
                  return;
                }
                setState(() {
                  _focusedMonth = month;
                  // 선택된 날짜도 새 월로 업데이트 (같은 일자 유지, 없으면 말일)
                  final lastDayOfMonth = DateTime(month.year, month.month + 1, 0).day;
                  final newDay = _selectedDate.day > lastDayOfMonth
                      ? lastDayOfMonth
                      : _selectedDate.day;
                  _selectedDate = DateTime(month.year, month.month, newDay);
                });
                // 현재 월 로드 (로딩 인디케이터 없이 - 성능 최적화)
                await _loadSchedulesForMonth(month, showLoading: false);
                // 데이터 로드 완료 후 UI 업데이트
                if (mounted) setState(() {});
                // 인접 월은 다음 프레임에 로드 (UI 블로킹 방지)
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _preloadAdjacentMonths(month);
                });
              },
              itemBuilder: (context, page) {
                final month = _getMonthFromPage(page);
                return _buildMonthCalendar(month);
              },
            ),
          ),
        ),
        Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
        // 선택된 날짜의 일정 리스트
        Expanded(
          child: _buildScheduleList(_getSchedulesForDate(_selectedDate)),
        ),
      ],
    );
  }

  /// 월별 캘린더 그리드
  Widget _buildMonthCalendar(DateTime month) {
    final theme = Theme.of(context);
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final firstWeekday = firstDay.weekday % 7; // 일요일 = 0
    final daysInMonth = lastDay.day;
    final totalRows = ((firstWeekday + daysInMonth) / 7).ceil();
    final totalCells = totalRows * 7;

    return Column(
      children: [
        // 요일 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: ['일', '월', '화', '수', '목', '금', '토'].asMap().entries.map((
              e,
            ) {
              Color textColor;
              if (e.key == 0) {
                textColor = Colors.red;
              } else if (e.key == 6) {
                textColor = Colors.blue;
              } else {
                textColor = Colors.grey[600]!;
              }
              return Expanded(
                child: Center(
                  child: Text(
                    e.value,
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
        ),
        // 날짜 그리드
        Expanded(
          child: GridView.builder(
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
              final date = DateTime(month.year, month.month, dayOffset + 1);
              final isCurrentMonth = date.month == month.month;
              final isSelected = _isSameDay(date, _selectedDate);
              final isToday = _isSameDay(date, DateTime.now());
              final schedules = _getSchedulesForDate(date);
              final weekdayIndex = index % 7;

              // PT 일정과 개인 일정 존재 여부만 체크 (리스트 할당 없이)
              final hasPtSchedules = schedules.any((s) => s.scheduleType == ScheduleType.pt);
              final hasPersonalSchedules = schedules.any((s) => s.scheduleType == ScheduleType.personal);

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
                          fontWeight: isSelected || isToday
                              ? FontWeight.bold
                              : null,
                          color: _getDayTextColor(
                            isSelected: isSelected,
                            isCurrentMonth: isCurrentMonth,
                            weekdayIndex: weekdayIndex,
                            theme: theme,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      // 일정 도트 (PT: 파란색, 개인: 주황색)
                      if (isCurrentMonth &&
                          (hasPtSchedules || hasPersonalSchedules))
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (hasPtSchedules)
                              Container(
                                width: 5,
                                height: 5,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 1,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? theme.colorScheme.onPrimary
                                      : AppTheme.primary,
                                ),
                              ),
                            if (hasPersonalSchedules)
                              Container(
                                width: 5,
                                height: 5,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 1,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                                      : AppTheme.tertiary,
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
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

  // ============================================================
  // 주별 캘린더 (무한 스와이프 + 시간대별 블록)
  // ============================================================

  Widget _buildWeekViewWithSwipe() {
    return RepaintBoundary(
      child: PageView.builder(
        controller: _weekPageController,
        onPageChanged: (page) async {
          final weekStart = _getWeekStartFromPage(page);
          final weekEnd = weekStart.add(const Duration(days: 6));

          // 선택된 날짜 업데이트
          DateTime newSelectedDate = _selectedDate;
          if (_selectedDate.isBefore(weekStart) || _selectedDate.isAfter(weekEnd)) {
            newSelectedDate = weekStart;
          }

          // focusedMonth 업데이트
          final newFocusedMonth = DateTime(weekStart.year, weekStart.month, 1);

          // 상태가 변경된 경우에만 setState
          if (_focusedMonth.year != newFocusedMonth.year ||
              _focusedMonth.month != newFocusedMonth.month ||
              _selectedDate != newSelectedDate) {
            setState(() {
              _focusedMonth = newFocusedMonth;
              _selectedDate = newSelectedDate;
            });
          }

          // 주에 포함된 월들의 일정 로드 (백그라운드)
          await _loadSchedulesForMonth(weekStart, showLoading: false);
          if (weekStart.month != weekEnd.month) {
            await _loadSchedulesForMonth(weekEnd, showLoading: false);
          }
          // 데이터 로드 완료 후 UI 업데이트
          if (mounted) setState(() {});
        },
        itemBuilder: (context, page) {
          final weekStart = _getWeekStartFromPage(page);
          return _buildWeekView(weekStart);
        },
      ),
    );
  }

  /// 주별 뷰 (헤더 + 시간 그리드)
  Widget _buildWeekView(DateTime weekStart) {
    final weekDays = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return Column(
      children: [
        _buildWeekHeader(weekDays),
        Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
        Expanded(child: _buildWeekTimeGrid(weekDays)),
      ],
    );
  }

  /// 주별 헤더 (요일 + 날짜)
  Widget _buildWeekHeader(List<DateTime> weekDays) {
    const weekdayNames = ['일', '월', '화', '수', '목', '금', '토'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 50), // 시간 컬럼 공간
          ...weekDays.asMap().entries.map((e) {
            final date = e.value;
            final isSelected = _isSameDay(date, _selectedDate);
            final isToday = _isSameDay(date, DateTime.now());
            final schedules = _getSchedulesForDate(date);
            final hasSchedule = schedules.isNotEmpty;

            Color weekdayColor;
            if (e.key == 0) {
              weekdayColor = Colors.red;
            } else if (e.key == 6) {
              weekdayColor = Colors.blue;
            } else {
              weekdayColor = Colors.grey[600]!;
            }

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: Column(
                  children: [
                    Text(
                      weekdayNames[e.key],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: weekdayColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary
                            : isToday
                            ? AppTheme.primary.withValues(alpha: 0.1)
                            : null,
                        shape: BoxShape.circle,
                      ),
                      child: Builder(
                        builder: (context) {
                          final colorScheme = Theme.of(context).colorScheme;
                          return Center(
                            child: Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected || isToday
                                    ? FontWeight.bold
                                    : null,
                                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (hasSchedule)
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primary,
                        ),
                      )
                    else
                      const SizedBox(height: 4),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 주별 시간 그리드 (6AM ~ 다음날 5AM)
  Widget _buildWeekTimeGrid(List<DateTime> weekDays) {
    // 6:00 AM (6) ~ 다음날 5:00 AM (29)
    final hours = List.generate(
      _dayEndHour - _dayStartHour,
      (i) => _dayStartHour + i,
    );

    return SingleChildScrollView(
      child: SizedBox(
        height: hours.length * _hourHeight,
        child: Stack(
          children: [
            // 시간 라인 배경
            Column(
              children: hours.map((hour) {
                final displayHour = hour % 24;
                return Container(
                  height: _hourHeight,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: Center(
                          child: Text(
                            '${displayHour.toString().padLeft(2, '0')}:00',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(color: Colors.grey[200]!),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            // 각 요일 컬럼의 세로선
            Row(
              children: [
                const SizedBox(width: 50),
                ...weekDays.map((date) {
                  return Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Colors.grey[200]!),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
            // 일정 블록 렌더링
            Row(
              children: [
                const SizedBox(width: 50),
                ...weekDays.asMap().entries.map((entry) {
                  final dayIndex = entry.key;
                  final date = entry.value;
                  return Expanded(
                    child: _buildDayScheduleBlocks(
                      date,
                      dayIndex,
                      weekDays.length,
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 특정 날짜의 일정 블록들 렌더링
  Widget _buildDayScheduleBlocks(DateTime date, int dayIndex, int totalDays) {
    final schedules = _getSchedulesForDate(date);
    if (schedules.isEmpty) return const SizedBox.shrink();

    // 같은 시간대의 일정들을 그룹화
    final schedulesWithOverlap = _calculateOverlaps(schedules);

    // LayoutBuilder를 부모 레벨에서 한 번만 사용 (성능 최적화)
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        return Stack(
          children: schedulesWithOverlap.map((item) {
            final schedule = item.schedule;
            final overlapIndex = item.overlapIndex;
            final overlapCount = item.overlapCount;

            // 시작 시간의 Y 위치 계산
            int startHour = schedule.scheduledAt.hour;
            int startMinute = schedule.scheduledAt.minute;

            // 6시 이전 시작하는 일정은 6시부터 표시
            if (startHour < _dayStartHour) {
              startHour = _dayStartHour;
              startMinute = 0;
            }

            // 그리드 시작 기준(6시)으로 오프셋 계산
            final startOffset = (startHour - _dayStartHour) + (startMinute / 60.0);
            final top = startOffset * _hourHeight;

            // 블록 높이 계산 (duration 반영)
            final blockHeight = (schedule.duration / 60.0) * _hourHeight;

            // 겹침 처리: 픽셀 기반 계산
            final columnWidth = availableWidth / overlapCount;
            final leftPos = overlapIndex * columnWidth + 2;
            final width = columnWidth - 4; // 양쪽 2px 마진

            // 일정 유형에 따른 색상
            final isPt = schedule.scheduleType == ScheduleType.pt;
            final baseColor = isPt ? AppTheme.primary : AppTheme.tertiary;

            return Positioned(
              top: top,
              left: leftPos,
              width: width,
              height: blockHeight.clamp(20.0, double.infinity),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: _buildScheduleBlock(schedule, baseColor, blockHeight),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  /// 일정 블록 위젯
  Widget _buildScheduleBlock(
    ScheduleModel schedule,
    Color baseColor,
    double height,
  ) {
    return GestureDetector(
      onTap: () => _showScheduleDetail(schedule),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: baseColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: baseColor.withValues(alpha: 0.6), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (height >= 30)
              Text(
                schedule.displayTitle,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: baseColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (height >= 45)
              Text(
                schedule.timeString,
                style: TextStyle(
                  fontSize: 9,
                  color: baseColor.withValues(alpha: 0.8),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 일정 겹침 계산
  List<_ScheduleOverlapInfo> _calculateOverlaps(List<ScheduleModel> schedules) {
    if (schedules.isEmpty) return [];

    final result = <_ScheduleOverlapInfo>[];
    final sorted = List<ScheduleModel>.from(schedules)
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    // 겹치는 일정 그룹 찾기
    final groups = <List<ScheduleModel>>[];
    List<ScheduleModel>? currentGroup;

    for (final schedule in sorted) {
      if (currentGroup == null) {
        currentGroup = [schedule];
      } else {
        // 현재 그룹의 마지막 일정과 겹치는지 확인
        final lastInGroup = currentGroup.last;
        final lastEnd = lastInGroup.endTime;

        if (schedule.scheduledAt.isBefore(lastEnd)) {
          currentGroup.add(schedule);
        } else {
          groups.add(currentGroup);
          currentGroup = [schedule];
        }
      }
    }

    if (currentGroup != null) {
      groups.add(currentGroup);
    }

    // 각 그룹 내에서 인덱스 할당
    for (final group in groups) {
      for (int i = 0; i < group.length; i++) {
        result.add(
          _ScheduleOverlapInfo(
            schedule: group[i],
            overlapIndex: i,
            overlapCount: group.length,
          ),
        );
      }
    }

    return result;
  }

  // ============================================================
  // 일정 리스트 (월별 뷰에서 사용)
  // ============================================================

  Widget _buildScheduleList(List<ScheduleModel> schedules) {
    final weekdayNames = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdayNames[_selectedDate.weekday - 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 날짜 헤더
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
              if (schedules.isNotEmpty)
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
                    '${schedules.length}건',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
            ],
          ),
        ),
        // 범례
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'PT 일정',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.tertiary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '개인 일정',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // 일정 카드 리스트
        Expanded(
          child: _isLoading
              ? SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const ScheduleListSkeleton(itemCount: 5),
                )
              : schedules.isEmpty
              ? SingleChildScrollView(child: _buildEmptyState())
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    return _ScheduleCard(
                      schedule: schedules[index],
                      onTap: () => _showScheduleDetail(schedules[index]),
                      onStatusChanged: _refreshSchedules,
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// 빈 상태 위젯
  Widget _buildEmptyState() {
    return const EmptyState(
      type: EmptyStateType.sessions,
    );
  }

  // ============================================================
  // 일정 상세 바텀시트
  // ============================================================

  void _showScheduleDetail(ScheduleModel schedule) {
    final isPt = schedule.scheduleType == ScheduleType.pt;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isPt
                          ? AppTheme.primary.withValues(alpha: 0.1)
                          : AppTheme.tertiary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isPt ? 'PT 일정' : '개인 일정',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isPt ? AppTheme.primary : AppTheme.tertiary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _buildStatusChip(schedule.status),
                ],
              ),
              const SizedBox(height: 16),
              // 제목
              Text(
                schedule.displayTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // 시간
              Row(
                children: [
                  Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    schedule.timeRangeString,
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '(${schedule.duration}분)',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                ],
              ),
              if (schedule.note != null && schedule.note!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.note, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        schedule.note!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              // 액션 버튼: 수정 & 삭제
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showEditScheduleBottomSheet(schedule);
                      },
                      icon: Icon(
                        Icons.edit,
                        color: isPt ? AppTheme.primary : AppTheme.tertiary,
                      ),
                      label: Text(
                        '수정',
                        style: TextStyle(
                          color: isPt ? AppTheme.primary : AppTheme.tertiary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isPt ? AppTheme.primary : AppTheme.tertiary,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmDeleteSchedule(ctx, schedule),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text(
                        '삭제',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 상태 칩 위젯
  Widget _buildStatusChip(ScheduleStatus status) {
    Color color;
    String label;

    switch (status) {
      case ScheduleStatus.scheduled:
        color = Colors.blue;
        label = '예정';
      case ScheduleStatus.completed:
        color = Colors.green;
        label = '완료';
      case ScheduleStatus.cancelled:
        color = Colors.grey;
        label = '취소';
      case ScheduleStatus.noShow:
        color = Colors.red;
        label = '노쇼';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  /// 삭제 확인 다이얼로그
  void _confirmDeleteSchedule(BuildContext ctx, ScheduleModel schedule) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('일정 삭제'),
        content: const Text('이 일정을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              Navigator.pop(ctx);
              await ref
                  .read(scheduleRepositoryProvider)
                  .deleteSchedule(schedule.id);
              _refreshSchedules();
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 일정 추가 바텀시트 (PT/개인 토글 동작)
  // ============================================================

  void _showAddScheduleBottomSheet() {
    // 상태 변수
    ScheduleType scheduleType = ScheduleType.pt;
    String? selectedMemberId;
    String? selectedMemberName;
    String personalTitle = '';
    DateTime selectedDate = _selectedDate;
    TimeOfDay startTime = const TimeOfDay(hour: 17, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 18, minute: 0);
    String memo = '';
    int repeatWeeks = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (builderContext, setDialogState) {
          // PT 일정이면 회원 이름 필수, 개인 일정이면 제목 입력 필수
          final bool canSave = scheduleType == ScheduleType.pt
              ? (selectedMemberName?.trim().isNotEmpty ?? false)
              : personalTitle.trim().isNotEmpty;

          return Container(
            height: MediaQuery.of(builderContext).size.height * 0.85,
            decoration: BoxDecoration(
              color: Theme.of(builderContext).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // 헤더
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '일정 추가',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom:
                          MediaQuery.of(builderContext).viewInsets.bottom + 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 일정 유형 토글
                        const Text(
                          '일정 유형',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // PT 일정 버튼
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setDialogState(() {
                                    scheduleType = ScheduleType.pt;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: scheduleType == ScheduleType.pt
                                        ? AppTheme.primary
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.fitness_center,
                                        color: scheduleType == ScheduleType.pt
                                            ? Theme.of(builderContext).colorScheme.onPrimary
                                            : Colors.grey[600],
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'PT 일정',
                                        style: TextStyle(
                                          color: scheduleType == ScheduleType.pt
                                              ? Theme.of(builderContext).colorScheme.onPrimary
                                              : Colors.grey[600],
                                          fontWeight:
                                              scheduleType == ScheduleType.pt
                                              ? FontWeight.w600
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // 개인 일정 버튼
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setDialogState(() {
                                    scheduleType = ScheduleType.personal;
                                    selectedMemberId = null;
                                    selectedMemberName = null;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: scheduleType == ScheduleType.personal
                                        ? AppTheme.tertiary
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        color:
                                            scheduleType ==
                                                ScheduleType.personal
                                            ? Theme.of(builderContext).colorScheme.onPrimary
                                            : Colors.grey[600],
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '개인 일정',
                                        style: TextStyle(
                                          color:
                                              scheduleType ==
                                                  ScheduleType.personal
                                              ? Theme.of(builderContext).colorScheme.onPrimary
                                              : Colors.grey[600],
                                          fontWeight:
                                              scheduleType ==
                                                  ScheduleType.personal
                                              ? FontWeight.w600
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // PT 일정: 회원 이름 입력
                        if (scheduleType == ScheduleType.pt) ...[
                          Row(
                            children: [
                              const Text(
                                '회원 이름',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '*',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            onChanged: (v) {
                              setDialogState(() {
                                selectedMemberName = v;
                                // memberId는 이름 기반으로 생성
                                selectedMemberId = 'manual-$v';
                              });
                            },
                            decoration: InputDecoration(
                              hintText: '회원 이름을 입력하세요',
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[200]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[200]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // 개인 일정: 제목 입력
                        if (scheduleType == ScheduleType.personal) ...[
                          Row(
                            children: [
                              const Text(
                                '제목',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '*',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            onChanged: (v) {
                              setDialogState(() => personalTitle = v);
                            },
                            decoration: InputDecoration(
                              hintText: '일정 제목을 입력하세요',
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[200]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[200]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppTheme.tertiary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // 날짜
                        const Text('날짜', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: builderContext,
                              initialDate: selectedDate,
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 30),
                              ),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (date != null) {
                              setDialogState(() => selectedDate = date);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일 (${['월', '화', '수', '목', '금', '토', '일'][selectedDate.weekday - 1]})',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 시간
                        const Text('시간', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final time = await _showTimePicker(
                                    builderContext,
                                    startTime,
                                  );
                                  if (time != null) {
                                    setDialogState(() {
                                      startTime = time;
                                      // 종료 시간 자동 조정 (1시간 후)
                                      endTime = TimeOfDay(
                                        hour: (time.hour + 1) % 24,
                                        minute: time.minute,
                                      );
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        color: Colors.grey[600],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(_formatTime(startTime)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('~'),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final time = await _showTimePicker(
                                    builderContext,
                                    endTime,
                                  );
                                  if (time != null) {
                                    setDialogState(() => endTime = time);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_filled,
                                        color: Colors.grey[600],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(_formatTime(endTime)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // 메모
                        const Text(
                          '메모 (선택)',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          maxLines: 3,
                          onChanged: (v) => memo = v,
                          decoration: InputDecoration(
                            hintText: '메모를 입력하세요',
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[200]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[200]!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 주차별 반복
                        const Text(
                          '주차별 반복',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.repeat,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    repeatWeeks == 0
                                        ? '반복 없음'
                                        : '$repeatWeeks주 반복',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [0, 4, 8, 12].map((weeks) {
                                  final isSelected = repeatWeeks == weeks;
                                  final accentColor =
                                      scheduleType == ScheduleType.pt
                                      ? AppTheme.primary
                                      : AppTheme.tertiary;
                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: () => setDialogState(
                                        () => repeatWeeks = weeks,
                                      ),
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? accentColor.withValues(
                                                  alpha: 0.1,
                                                )
                                              : Theme.of(builderContext).colorScheme.surface,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? accentColor
                                                : Colors.grey[300]!,
                                          ),
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              if (isSelected)
                                                Icon(
                                                  Icons.check,
                                                  size: 16,
                                                  color: accentColor,
                                                ),
                                              if (isSelected)
                                                const SizedBox(width: 4),
                                              Text(
                                                weeks == 0 ? '없음' : '$weeks주',
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? accentColor
                                                      : Colors.grey[600],
                                                  fontWeight: isSelected
                                                      ? FontWeight.w600
                                                      : null,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 저장 버튼
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: canSave
                                ? () => _saveSchedule(
                                    builderContext,
                                    scheduleType,
                                    selectedMemberId,
                                    selectedMemberName,
                                    personalTitle,
                                    selectedDate,
                                    startTime,
                                    endTime,
                                    memo,
                                    repeatWeeks,
                                  )
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: scheduleType == ScheduleType.pt
                                  ? AppTheme.primary
                                  : AppTheme.tertiary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              disabledBackgroundColor: Colors.grey[300],
                            ),
                            child: Text(
                              repeatWeeks > 0
                                  ? '${repeatWeeks + 1}개 일정 추가'
                                  : '일정 추가',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 시간 포맷
  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  /// 시간 선택 다이얼로그
  Future<TimeOfDay?> _showTimePicker(
    BuildContext ctx,
    TimeOfDay initialTime,
  ) async {
    TimeOfDay selectedTime = initialTime;

    return showModalBottomSheet<TimeOfDay>(
      context: ctx,
      builder: (pickerContext) => StatefulBuilder(
        builder: (_, setPickerState) {
          return Container(
            height: 320,
            color: Theme.of(pickerContext).colorScheme.surface,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(pickerContext),
                        child: const Text('취소'),
                      ),
                      const Text(
                        '시간 선택',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(pickerContext, selectedTime),
                        child: const Text('확인'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: DateTime(
                      2024,
                      1,
                      1,
                      initialTime.hour,
                      initialTime.minute,
                    ),
                    minuteInterval: 5,
                    onDateTimeChanged: (dt) {
                      selectedTime = TimeOfDay(
                        hour: dt.hour,
                        minute: dt.minute,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 일정 저장
  Future<void> _saveSchedule(
    BuildContext dialogContext,
    ScheduleType scheduleType,
    String? memberId,
    String? memberName,
    String personalTitle,
    DateTime date,
    TimeOfDay startTime,
    TimeOfDay endTime,
    String memo,
    int repeatWeeks,
  ) async {
    final trainer = ref.read(currentTrainerProvider);
    if (trainer == null) return;

    Navigator.pop(dialogContext);

    try {
      final scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        startTime.hour,
        startTime.minute,
      );

      // 종료 시간이 시작 시간보다 이전이면 다음 날로 계산
      int endMinutes = endTime.hour * 60 + endTime.minute;
      int startMinutes = startTime.hour * 60 + startTime.minute;
      if (endMinutes <= startMinutes) {
        endMinutes += 24 * 60; // 다음 날
      }
      final duration = endMinutes - startMinutes;

      final uuid = const Uuid();
      final groupId = repeatWeeks > 0 ? uuid.v4() : null;
      final totalSchedules = repeatWeeks > 0 ? repeatWeeks + 1 : 1;
      final repo = ref.read(scheduleRepositoryProvider);

      for (int i = 0; i < totalSchedules; i++) {
        final scheduleDate = scheduledAt.add(Duration(days: 7 * i));
        final schedule = ScheduleModel(
          id: uuid.v4(),
          trainerId: trainer.id,
          memberId: scheduleType == ScheduleType.pt ? memberId! : trainer.id,
          memberName: scheduleType == ScheduleType.pt ? memberName : null,
          scheduledAt: scheduleDate,
          duration: duration > 0 ? duration : 60,
          status: ScheduleStatus.scheduled,
          scheduleType: scheduleType,
          title: scheduleType == ScheduleType.personal ? personalTitle : null,
          note: memo.isNotEmpty ? memo : null,
          groupId: groupId,
          createdAt: DateTime.now(),
        );
        await repo.addSchedule(schedule);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              totalSchedules > 1
                  ? '$totalSchedules개 일정이 추가되었습니다'
                  : '일정이 추가되었습니다',
            ),
            backgroundColor: scheduleType == ScheduleType.pt
                ? AppTheme.primary
                : AppTheme.tertiary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _refreshSchedules();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('일정 추가 실패: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ============================================================
  // 일정 수정 바텀시트
  // ============================================================

  void _showEditScheduleBottomSheet(ScheduleModel schedule) {
    // 기존 일정 데이터로 초기화
    final scheduleType = schedule.scheduleType;
    String? selectedMemberId = schedule.scheduleType == ScheduleType.pt
        ? schedule.memberId
        : null;
    String? selectedMemberName = schedule.memberName;
    String personalTitle = schedule.title ?? '';
    DateTime selectedDate = schedule.scheduledAt;
    TimeOfDay startTime = TimeOfDay(
      hour: schedule.scheduledAt.hour,
      minute: schedule.scheduledAt.minute,
    );
    TimeOfDay endTime = TimeOfDay(
      hour: schedule.endTime.hour,
      minute: schedule.endTime.minute,
    );
    String memo = schedule.note ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (builderContext, setDialogState) {
          final isPt = scheduleType == ScheduleType.pt;

          // PT 일정이면 회원 이름 필수, 개인 일정이면 제목 입력 필수
          final bool canSave = scheduleType == ScheduleType.pt
              ? (selectedMemberName?.trim().isNotEmpty ?? false)
              : personalTitle.trim().isNotEmpty;

          return Container(
            height: MediaQuery.of(builderContext).size.height * 0.75,
            decoration: BoxDecoration(
              color: Theme.of(builderContext).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // 헤더
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '일정 수정',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom:
                          MediaQuery.of(builderContext).viewInsets.bottom + 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 일정 유형 표시 (수정 불가)
                        const Text(
                          '일정 유형',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isPt
                                ? AppTheme.primary.withValues(alpha: 0.1)
                                : AppTheme.tertiary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isPt
                                    ? Icons.fitness_center
                                    : Icons.calendar_today,
                                color: isPt
                                    ? AppTheme.primary
                                    : AppTheme.tertiary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isPt ? 'PT 일정' : '개인 일정',
                                style: TextStyle(
                                  color: isPt
                                      ? AppTheme.primary
                                      : AppTheme.tertiary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // PT 일정: 회원 이름 입력
                        if (scheduleType == ScheduleType.pt) ...[
                          Row(
                            children: [
                              const Text(
                                '회원 이름',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '*',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            onChanged: (v) {
                              setDialogState(() {
                                selectedMemberName = v;
                                // memberId는 이름 기반으로 생성
                                selectedMemberId = 'manual-$v';
                              });
                            },
                            decoration: InputDecoration(
                              hintText: '회원 이름을 입력하세요',
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[200]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[200]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // 개인 일정: 제목 입력
                        if (scheduleType == ScheduleType.personal) ...[
                          Row(
                            children: [
                              const Text(
                                '제목',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '*',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: personalTitle,
                            onChanged: (v) {
                              setDialogState(() => personalTitle = v);
                            },
                            decoration: InputDecoration(
                              hintText: '일정 제목을 입력하세요',
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[200]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[200]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppTheme.tertiary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // 날짜
                        const Text('날짜', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: builderContext,
                              initialDate: selectedDate,
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 30),
                              ),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (date != null) {
                              setDialogState(() => selectedDate = date);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일 (${['월', '화', '수', '목', '금', '토', '일'][selectedDate.weekday - 1]})',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 시간
                        const Text('시간', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final time = await _showTimePicker(
                                    builderContext,
                                    startTime,
                                  );
                                  if (time != null) {
                                    setDialogState(() {
                                      startTime = time;
                                      // 종료 시간 자동 조정 (1시간 후)
                                      endTime = TimeOfDay(
                                        hour: (time.hour + 1) % 24,
                                        minute: time.minute,
                                      );
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        color: Colors.grey[600],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(_formatTime(startTime)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('~'),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final time = await _showTimePicker(
                                    builderContext,
                                    endTime,
                                  );
                                  if (time != null) {
                                    setDialogState(() => endTime = time);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_filled,
                                        color: Colors.grey[600],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(_formatTime(endTime)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // 메모
                        const Text(
                          '메모 (선택)',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: memo,
                          maxLines: 3,
                          onChanged: (v) => memo = v,
                          decoration: InputDecoration(
                            hintText: '메모를 입력하세요',
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[200]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[200]!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 저장 버튼
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: canSave
                                ? () => _updateSchedule(
                                    builderContext,
                                    schedule,
                                    selectedMemberId,
                                    selectedMemberName,
                                    personalTitle,
                                    selectedDate,
                                    startTime,
                                    endTime,
                                    memo,
                                  )
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: scheduleType == ScheduleType.pt
                                  ? AppTheme.primary
                                  : AppTheme.tertiary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              disabledBackgroundColor: Colors.grey[300],
                            ),
                            child: const Text(
                              '일정 수정',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 일정 수정 저장
  Future<void> _updateSchedule(
    BuildContext dialogContext,
    ScheduleModel originalSchedule,
    String? memberId,
    String? memberName,
    String personalTitle,
    DateTime date,
    TimeOfDay startTime,
    TimeOfDay endTime,
    String memo,
  ) async {
    Navigator.pop(dialogContext);

    try {
      final scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        startTime.hour,
        startTime.minute,
      );

      // 종료 시간이 시작 시간보다 이전이면 다음 날로 계산
      int endMinutes = endTime.hour * 60 + endTime.minute;
      int startMinutes = startTime.hour * 60 + startTime.minute;
      if (endMinutes <= startMinutes) {
        endMinutes += 24 * 60; // 다음 날
      }
      final duration = endMinutes - startMinutes;

      final updatedSchedule = originalSchedule.copyWith(
        memberId: originalSchedule.scheduleType == ScheduleType.pt
            ? (memberId ?? originalSchedule.memberId)
            : originalSchedule.memberId,
        memberName: originalSchedule.scheduleType == ScheduleType.pt
            ? memberName
            : originalSchedule.memberName,
        scheduledAt: scheduledAt,
        duration: duration > 0 ? duration : 60,
        title: originalSchedule.scheduleType == ScheduleType.personal
            ? personalTitle
            : null,
        note: memo.isNotEmpty ? memo : null,
      );

      await ref
          .read(scheduleRepositoryProvider)
          .updateSchedule(updatedSchedule);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('일정이 수정되었습니다'),
            backgroundColor: originalSchedule.scheduleType == ScheduleType.pt
                ? AppTheme.primary
                : AppTheme.tertiary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _refreshSchedules();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('일정 수정 실패: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// 날짜 비교 유틸리티
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

// ============================================================
// 일정 카드 위젯
// ============================================================

class _ScheduleCard extends ConsumerWidget {
  final ScheduleModel schedule;
  final VoidCallback onTap;
  final VoidCallback onStatusChanged;

  const _ScheduleCard({
    required this.schedule,
    required this.onTap,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 일정 겹침 정보 클래스
// ============================================================

class _ScheduleOverlapInfo {
  final ScheduleModel schedule;
  final int overlapIndex;
  final int overlapCount;

  _ScheduleOverlapInfo({
    required this.schedule,
    required this.overlapIndex,
    required this.overlapCount,
  });
}
