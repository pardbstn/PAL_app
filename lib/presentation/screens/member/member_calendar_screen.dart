import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/core/theme/app_tokens.dart';
import 'package:flutter_pal_app/data/models/schedule_model.dart';
import 'package:flutter_pal_app/data/repositories/schedule_repository.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/data/models/workout_log_model.dart';
import 'package:flutter_pal_app/data/repositories/workout_log_repository.dart';
import 'package:flutter_pal_app/presentation/providers/workout_log_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/skeleton/skeletons.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_pal_app/presentation/widgets/common/mesh_gradient_background.dart';

/// 회원 캘린더 화면 - 트레이너 스타일 UI/UX 적용
/// 기능:
/// - 월별/주별 무한 스와이프
/// - 시간대별 일정 블록 표시
/// - PT 일정 조회 (읽기 전용) + 개인 일정 관리
class MemberCalendarScreen extends ConsumerStatefulWidget {
  const MemberCalendarScreen({super.key});

  @override
  ConsumerState<MemberCalendarScreen> createState() =>
      _MemberCalendarScreenState();
}

class _MemberCalendarScreenState extends ConsumerState<MemberCalendarScreen> {
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

  // 운동 기록 캐시: 월별 (YYYY-MM 형식)
  final Map<String, List<WorkoutLogModel>> _workoutsCache = {};
  // 날짜별 운동 캐시: (YYYY-MM-DD 형식)
  final Map<String, List<WorkoutLogModel>> _workoutsPerDayCache = {};

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

  /// 월별 운동 기록을 날짜별 캐시로 분배
  void _populateWorkoutDayCache(String monthKey, List<WorkoutLogModel> workouts) {
    _workoutsPerDayCache.removeWhere((key, _) => key.startsWith(monthKey));

    final Map<String, List<WorkoutLogModel>> grouped = {};
    for (final workout in workouts) {
      final dayKey = _getDayKey(workout.workoutDate);
      grouped.putIfAbsent(dayKey, () => []).add(workout);
    }

    grouped.forEach((dayKey, dayWorkouts) {
      dayWorkouts.sort((a, b) => b.workoutDate.compareTo(a.workoutDate));
      _workoutsPerDayCache[dayKey] = dayWorkouts;
    });
  }

  /// 특정 월의 일정 로드
  /// [showLoading] - true면 로딩 인디케이터 표시 (현재 월에만 사용)
  Future<void> _loadSchedulesForMonth(DateTime month,
      {bool showLoading = true}) async {
    final monthKey = _getMonthKey(month);

    // 이미 캐시에 있으면 스킵 (일정 + 운동 모두 캐시됨)
    if (_schedulesCache.containsKey(monthKey) &&
        _workoutsCache.containsKey(monthKey)) {
      return;
    }

    // 이미 로드 중이면 스킵
    if (_loadingMonths.contains(monthKey)) return;

    final member = ref.read(currentMemberProvider);
    if (member == null) return;

    _loadingMonths.add(monthKey);

    // 현재 월에 대해서만 로딩 표시 (인접 월 프리로드 시에는 표시 안 함)
    if (showLoading && mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final repo = ref.read(scheduleRepositoryProvider);
      final schedules = await repo.getMemberSchedulesForMonth(member.id, month);

      if (mounted) {
        // 캐시 업데이트 (setState 없이)
        _schedulesCache[monthKey] = schedules;
        _populateDayCache(monthKey, schedules);

        // 운동 기록도 함께 로드
        try {
          final workoutRepo = ref.read(workoutLogRepositoryProvider);
          final workouts = await workoutRepo.getMonthlySummary(
            member.id,
            month.year,
            month.month,
          );
          _workoutsCache[monthKey] = workouts;
          _populateWorkoutDayCache(monthKey, workouts);
        } catch (e) {
          debugPrint('운동 기록 로드 실패: $e');
          _workoutsCache[monthKey] = [];
        }

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

  /// 특정 날짜의 운동 기록 조회
  List<WorkoutLogModel> _getWorkoutsForDate(DateTime date) {
    final dayKey = _getDayKey(date);
    return _workoutsPerDayCache[dayKey] ?? [];
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
    _workoutsCache.clear();
    _workoutsPerDayCache.clear();
    await _loadSchedulesForMonth(_focusedMonth, showLoading: false);
    _preloadAdjacentMonths(_focusedMonth);
    // 데이터 로드 후 UI 업데이트
    if (mounted) setState(() {});
  }

  /// 월별/주별 뷰 전환 (페이지 동기화 포함)
  void _toggleViewMode() {
    final targetDate = _selectedDate;

    if (!_isWeekView) {
      // 월별 -> 주별: 선택된 날짜 기준으로 주별 페이지 계산
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
      // 주별 -> 월별: 선택된 날짜 기준으로 월별 페이지 계산
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MeshGradientBackground(
        child: Stack(
        children: [
          SafeArea(
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
          Positioned(
            right: 16,
            bottom: AppNavGlass.fabBottomPadding,
            child: Builder(
              builder: (context) {
                final authState = ref.watch(authProvider);
                final isPersonal = authState.userRole == UserRole.personal;

                if (isPersonal) {
                  return FloatingActionButton.extended(
                    heroTag: 'schedule_fab',
                    onPressed: () => _showAddScheduleBottomSheet(),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('일정 추가'),
                  );
                }

                return FloatingActionButton.extended(
                  onPressed: () => _showAddScheduleBottomSheet(),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('일정 추가'),
                )
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .shimmer(
                      duration: 2000.ms,
                      color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.3),
                    );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  /// 헤더 위젯 (년/월 + 오늘 + 뷰 전환)
  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
      useRootNavigator: true,
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
                  final lastDayOfMonth =
                      DateTime(month.year, month.month + 1, 0).day;
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
              final hasPtSchedules =
                  schedules.any((s) => s.scheduleType == ScheduleType.pt);
              final hasPersonalSchedules =
                  schedules.any((s) => s.scheduleType == ScheduleType.personal);
              final hasWorkouts = _getWorkoutsForDate(date).isNotEmpty;

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
                            ? AppTheme.primary.withValues(alpha: 0.08)
                            : null,
                    borderRadius: BorderRadius.circular(12),
                    border: isToday && !isSelected
                        ? Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.5),
                            width: 1.5,
                          )
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
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
                      // 일정 도트 (PT: 파란색, 개인: 주황색, 운동: 초록색)
                      if (isCurrentMonth &&
                          (hasPtSchedules || hasPersonalSchedules || hasWorkouts))
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
                                      ? theme.colorScheme.onPrimary
                                          .withValues(alpha: 0.7)
                                      : AppTheme.tertiary,
                                ),
                              ),
                            if (hasWorkouts)
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
                                          .withValues(alpha: 0.7)
                                      : const Color(0xFF10B981),
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
          if (_selectedDate.isBefore(weekStart) ||
              _selectedDate.isAfter(weekEnd)) {
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
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary
                            : isToday
                                ? AppTheme.primary.withValues(alpha: 0.08)
                                : null,
                        borderRadius: BorderRadius.circular(12),
                        border: isToday && !isSelected
                            ? Border.all(
                                color: AppTheme.primary.withValues(alpha: 0.5),
                                width: 1.5,
                              )
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
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
                                color: isSelected
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurface,
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
            final startOffset =
                (startHour - _dayStartHour) + (startMinute / 60.0);
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
    final workouts = _getWorkoutsForDate(_selectedDate);
    final totalCount = schedules.length + workouts.length;

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
              if (totalCount > 0)
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
                    '$totalCount건',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
            ],
          ),
        ),
        // 범례
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Builder(
            builder: (context) {
              final authState = ref.watch(authProvider);
              final isPersonal = authState.userRole == UserRole.personal;

              return Row(
                children: [
                  // PT 일정 - 개인 모드에서는 숨김
                  if (!isPersonal) ...[
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
                  ],
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
                    isPersonal ? '일정' : '개인 일정',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '운동 기록',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              );
            },
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
              : (schedules.isEmpty && workouts.isEmpty)
                  ? SingleChildScrollView(child: _buildEmptyState())
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        // 일정 카드들
                        ...schedules.map((schedule) => _ScheduleCard(
                          schedule: schedule,
                          onTap: () => _showScheduleDetail(schedule),
                        )),
                        // 운동 기록 카드들
                        ...workouts.map((workout) => _WorkoutCard(
                          workout: workout,
                          onTap: () => _showWorkoutDetail(workout),
                        )),
                      ],
                    ),
        ),
      ],
    );
  }

  /// 빈 상태 위젯
  Widget _buildEmptyState() {
    final authState = ref.watch(authProvider);
    final isPersonal = authState.userRole == UserRole.personal;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            isPersonal ? '일정이나 운동 기록이 없어요' : '예정된 수업이 없어요',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            isPersonal ? '이 날짜에는 일정이나 운동 기록이 없어요' : '이 날짜에는 수업이 없어요',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      ),
    );
  }

  // ============================================================
  // 운동 기록 상세 바텀시트
  // ============================================================

  void _showWorkoutDetail(WorkoutLogModel workout) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SafeArea(
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 드래그 핸들
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 헤더
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '운동 기록',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (workout.durationMinutes > 0)
                      Text(
                        '${workout.durationMinutes}분',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // 제목
                if (workout.title.isNotEmpty) ...[
                  Text(
                    workout.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // 오운완 사진
                if (workout.imageUrl != null && workout.imageUrl!.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      workout.imageUrl!,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 운동 목록
                Text(
                  '운동 목록 (${workout.exercises.length}종목)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...workout.exercises.map((exercise) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _workoutCategoryColor(exercise.category),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            exercise.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          exercise.weight > 0
                              ? '${exercise.sets}세트 × ${exercise.reps}회 · ${exercise.weight.toStringAsFixed(0)}kg'
                              : '${exercise.sets}세트 × ${exercise.reps}회',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),

                // 메모
                if (workout.memo.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.sticky_note_2_outlined, size: 18, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            workout.memo,
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // 수정/삭제 버튼
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _editWorkout(workout);
                        },
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('수정'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _deleteWorkout(workout);
                        },
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('삭제'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          side: BorderSide(color: const Color(0xFFEF4444).withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 운동 기록 수정
  void _editWorkout(WorkoutLogModel workout) async {
    final result = await context.push<bool>(
      '/member/add-workout',
      extra: workout,
    );
    // 수정 완료 시 캐시 초기화 후 새로고침
    if (result == true && mounted) {
      _workoutsCache.clear();
      _workoutsPerDayCache.clear();
      await _loadSchedulesForMonth(_focusedMonth, showLoading: false);
      if (mounted) setState(() {});
    }
  }

  /// 운동 기록 삭제
  void _deleteWorkout(WorkoutLogModel workout) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('운동 기록 삭제'),
        content: const Text('이 운동 기록을 삭제할까요?\n삭제된 기록은 복구할 수 없어요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              try {
                await ref
                    .read(workoutLogNotifierProvider.notifier)
                    .deleteWorkoutLog(workout.id);
                // 캐시 초기화 후 새로고침
                _workoutsCache.clear();
                _workoutsPerDayCache.clear();
                await _loadSchedulesForMonth(_focusedMonth, showLoading: false);
                if (mounted) {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('운동 기록을 삭제했어요')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('삭제 실패: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  Color _workoutCategoryColor(WorkoutCategory category) {
    return switch (category) {
      WorkoutCategory.chest => const Color(0xFFF04452),
      WorkoutCategory.back => const Color(0xFF3B82F6),
      WorkoutCategory.shoulder => const Color(0xFF8B5CF6),
      WorkoutCategory.arm => const Color(0xFFFF8A00),
      WorkoutCategory.leg => const Color(0xFF00C471),
      WorkoutCategory.core => const Color(0xFF06B6D4),
      WorkoutCategory.cardio => const Color(0xFFEC4899),
      WorkoutCategory.other => const Color(0xFF6B7280),
    };
  }

  // ============================================================
  // 일정 상세 바텀시트
  // ============================================================

  void _showScheduleDetail(ScheduleModel schedule) {
    final isPt = schedule.scheduleType == ScheduleType.pt;
    final isPersonal = schedule.scheduleType == ScheduleType.personal;
    final authState = ref.watch(authProvider);
    final isPersonalMode = authState.userRole == UserRole.personal;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
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
                      isPt ? (isPersonalMode ? '일정' : 'PT 일정') : (isPersonalMode ? '일정' : '개인 일정'),
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
              // 액션 버튼: PT/개인 일정 모두 수정/삭제 가능
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
                        color: isPersonal ? AppTheme.tertiary : AppTheme.primary,
                      ),
                      label: Text(
                        '수정',
                        style: TextStyle(
                          color: isPersonal ? AppTheme.tertiary : AppTheme.primary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isPersonal ? AppTheme.tertiary : AppTheme.primary,
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
        content: const Text('이 일정을 삭제할까요?'),
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
  // 일정 추가 바텀시트 (PT/개인 일정 선택 가능)
  // ============================================================

  void _showAddScheduleBottomSheet() {
    final authState = ref.watch(authProvider);
    final isPersonalMode = authState.userRole == UserRole.personal;

    // 상태 변수
    ScheduleType scheduleType = isPersonalMode ? ScheduleType.personal : ScheduleType.pt; // 개인 모드는 개인 일정만
    String personalTitle = '';
    DateTime selectedDate = _selectedDate;
    TimeOfDay startTime = const TimeOfDay(hour: 17, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 18, minute: 0);
    String memo = '';
    int repeatWeeks = 0;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (builderContext, setDialogState) {
          return Container(
            height: MediaQuery.of(builderContext).size.height * 0.75,
            decoration: BoxDecoration(
              color: Theme.of(builderContext).colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
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
                      bottom: BorderSide(color: Theme.of(builderContext).dividerColor),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        scheduleType == ScheduleType.pt
                            ? (isPersonalMode ? '일정 추가' : 'PT 일정 추가')
                            : (isPersonalMode ? '일정 추가' : '개인 일정 추가'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(builderContext).colorScheme.onSurface,
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
                        // 일정 유형 선택 (개인 모드에서는 숨김)
                        if (!isPersonalMode) ...[
                          Text(
                            '일정 유형',
                            style: TextStyle(color: Theme.of(builderContext).colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setDialogState(
                                        () => scheduleType = ScheduleType.pt);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: scheduleType == ScheduleType.pt
                                          ? AppTheme.primary.withValues(alpha: 0.1)
                                          : Theme.of(builderContext).colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: scheduleType == ScheduleType.pt
                                            ? AppTheme.primary
                                            : Theme.of(builderContext).colorScheme.outline,
                                        width:
                                            scheduleType == ScheduleType.pt ? 2 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.fitness_center,
                                          size: 18,
                                          color: scheduleType == ScheduleType.pt
                                              ? AppTheme.primary
                                              : Theme.of(builderContext).colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'PT 일정',
                                          style: TextStyle(
                                            color: scheduleType == ScheduleType.pt
                                                ? AppTheme.primary
                                                : Theme.of(builderContext).colorScheme.onSurfaceVariant,
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
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setDialogState(() =>
                                      scheduleType = ScheduleType.personal);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: scheduleType == ScheduleType.personal
                                        ? AppTheme.tertiary
                                            .withValues(alpha: 0.1)
                                        : Theme.of(builderContext).colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: scheduleType == ScheduleType.personal
                                          ? AppTheme.tertiary
                                          : Theme.of(builderContext).colorScheme.outline,
                                      width: scheduleType == ScheduleType.personal
                                          ? 2
                                          : 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.event_note,
                                        size: 18,
                                        color:
                                            scheduleType == ScheduleType.personal
                                                ? AppTheme.tertiary
                                                : Theme.of(builderContext).colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '개인 일정',
                                        style: TextStyle(
                                          color: scheduleType ==
                                                  ScheduleType.personal
                                              ? AppTheme.tertiary
                                              : Theme.of(builderContext).colorScheme.onSurfaceVariant,
                                          fontWeight: scheduleType ==
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
                        ],

                        // 제목 입력 (개인 일정일 때만 표시)
                        if (scheduleType == ScheduleType.personal) ...[
                          Text(
                            '제목 (선택)',
                            style: TextStyle(color: Theme.of(builderContext).colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            onChanged: (v) {
                              setDialogState(() => personalTitle = v);
                            },
                            decoration: InputDecoration(
                              hintText: '미입력 시 "개인 일정"으로 저장됩니다',
                              filled: true,
                              fillColor: Theme.of(builderContext).colorScheme.surfaceContainerHighest,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(builderContext).colorScheme.outline.withValues(alpha: 0.3),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(builderContext).colorScheme.outline.withValues(alpha: 0.3),
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
                        Text('날짜', style: TextStyle(color: Theme.of(builderContext).colorScheme.onSurfaceVariant)),
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
                              color: Theme.of(builderContext).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Theme.of(builderContext).colorScheme.outline.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Theme.of(builderContext).colorScheme.onSurfaceVariant,
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
                        Text('시간', style: TextStyle(color: Theme.of(builderContext).colorScheme.onSurfaceVariant)),
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
                                    color: Theme.of(builderContext).colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Theme.of(builderContext).colorScheme.outline.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        color: Theme.of(builderContext).colorScheme.onSurfaceVariant,
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
                                    color: Theme.of(builderContext).colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Theme.of(builderContext).colorScheme.outline.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_filled,
                                        color: Theme.of(builderContext).colorScheme.onSurfaceVariant,
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
                        Text(
                          '메모 (선택)',
                          style: TextStyle(color: Theme.of(builderContext).colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          maxLines: 3,
                          onChanged: (v) => memo = v,
                          decoration: InputDecoration(
                            hintText: '메모를 입력해주세요',
                            filled: true,
                            fillColor: Theme.of(builderContext).colorScheme.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Theme.of(builderContext).colorScheme.outline.withValues(alpha: 0.3)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Theme.of(builderContext).colorScheme.outline.withValues(alpha: 0.3)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 주차별 반복
                        Text(
                          '주차별 반복',
                          style: TextStyle(color: Theme.of(builderContext).colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(builderContext).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Theme.of(builderContext).colorScheme.outline.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.repeat,
                                    color: Theme.of(builderContext).colorScheme.onSurfaceVariant,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    repeatWeeks == 0
                                        ? '반복 없음'
                                        : '$repeatWeeks주 반복',
                                    style: TextStyle(color: Theme.of(builderContext).colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [0, 4, 8, 12].map((weeks) {
                                  final isSelected = repeatWeeks == weeks;
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
                                              ? AppTheme.tertiary.withValues(
                                                  alpha: 0.1,
                                                )
                                              : Theme.of(builderContext)
                                                  .colorScheme
                                                  .surface,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppTheme.tertiary
                                                : Theme.of(builderContext).colorScheme.outline,
                                          ),
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              if (isSelected)
                                                const Icon(
                                                  Icons.check,
                                                  size: 16,
                                                  color: AppTheme.tertiary,
                                                ),
                                              if (isSelected)
                                                const SizedBox(width: 4),
                                              Text(
                                                weeks == 0 ? '없음' : '$weeks주',
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? AppTheme.tertiary
                                                      : Theme.of(builderContext).colorScheme.onSurfaceVariant,
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
                            onPressed: () => _saveSchedule(
                                      builderContext,
                                      scheduleType,
                                      personalTitle,
                                      selectedDate,
                                      startTime,
                                      endTime,
                                      memo,
                                      repeatWeeks,
                                    ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: scheduleType == ScheduleType.pt
                                  ? AppTheme.primary
                                  : AppTheme.tertiary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              disabledBackgroundColor: Theme.of(builderContext).colorScheme.surfaceContainerHighest,
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
      useRootNavigator: true,
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
                      bottom: BorderSide(color: Theme.of(pickerContext).dividerColor),
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

  /// 일정 저장 (PT/개인 일정)
  Future<void> _saveSchedule(
    BuildContext dialogContext,
    ScheduleType scheduleType,
    String personalTitle,
    DateTime date,
    TimeOfDay startTime,
    TimeOfDay endTime,
    String memo,
    int repeatWeeks,
  ) async {
    final member = ref.read(currentMemberProvider);
    if (member == null) return;

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
          // 개인 일정은 trainerId를 null로 설정 (회원만 볼 수 있음)
          trainerId: null,
          memberId: member.id,
          memberName: null,
          scheduledAt: scheduleDate,
          duration: duration > 0 ? duration : 60,
          status: ScheduleStatus.scheduled,
          scheduleType: scheduleType,
          title: scheduleType == ScheduleType.personal
              ? (personalTitle.trim().isNotEmpty ? personalTitle.trim() : '개인 일정')
              : null,
          note: memo.isNotEmpty ? memo : null,
          groupId: groupId,
          createdAt: DateTime.now(),
        );
        await repo.addSchedule(schedule);
      }

      if (mounted) {
        final typeLabel = scheduleType == ScheduleType.pt ? 'PT' : '개인';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              totalSchedules > 1
                  ? '$typeLabel 일정 $totalSchedules개가 추가됐어요'
                  : '$typeLabel 일정이 추가됐어요',
            ),
            backgroundColor:
                scheduleType == ScheduleType.pt ? AppTheme.primary : AppTheme.tertiary,
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
  // 일정 수정 바텀시트 (개인 일정 전용)
  // ============================================================

  void _showEditScheduleBottomSheet(ScheduleModel schedule) {
    final authState = ref.watch(authProvider);
    final isPersonalMode = authState.userRole == UserRole.personal;

    // 기존 일정 데이터로 초기화
    final bool isPtSchedule = schedule.scheduleType == ScheduleType.pt;
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
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (builderContext, setDialogState) {
          // PT 일정은 제목 불필요, 개인 일정은 제목 필수
          final bool canSave = isPtSchedule || personalTitle.trim().isNotEmpty;

          return Container(
            height: MediaQuery.of(builderContext).size.height * 0.65,
            decoration: BoxDecoration(
              color: Theme.of(builderContext).colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
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
                      bottom: BorderSide(color: Theme.of(builderContext).dividerColor),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isPtSchedule
                            ? (isPersonalMode ? '일정 수정' : 'PT 일정 수정')
                            : (isPersonalMode ? '일정 수정' : '개인 일정 수정'),
                        style: const TextStyle(
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
                        // 일정 유형 표시
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isPtSchedule
                                ? AppTheme.primary.withValues(alpha: 0.1)
                                : AppTheme.tertiary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPtSchedule
                                    ? Icons.fitness_center
                                    : Icons.event_note,
                                size: 16,
                                color: isPtSchedule
                                    ? AppTheme.primary
                                    : AppTheme.tertiary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isPtSchedule
                                    ? (isPersonalMode ? '일정' : 'PT 일정')
                                    : (isPersonalMode ? '일정' : '개인 일정'),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isPtSchedule
                                      ? AppTheme.primary
                                      : AppTheme.tertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 제목 입력 (개인 일정만)
                        if (!isPtSchedule) ...[
                          Row(
                            children: [
                              Text(
                                '제목',
                                style: TextStyle(color: Theme.of(builderContext).colorScheme.onSurfaceVariant),
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
                              hintText: '일정 제목을 입력해주세요',
                              filled: true,
                              fillColor: Theme.of(builderContext).colorScheme.surfaceContainerHighest,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(builderContext).colorScheme.outline.withValues(alpha: 0.3),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(builderContext).colorScheme.outline.withValues(alpha: 0.3),
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
                        Text('날짜', style: TextStyle(color: Theme.of(builderContext).colorScheme.onSurfaceVariant)),
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
                              color: Theme.of(builderContext).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Theme.of(builderContext).colorScheme.outline.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Theme.of(builderContext).colorScheme.onSurfaceVariant,
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
                        Text('시간', style: TextStyle(color: Theme.of(builderContext).colorScheme.onSurfaceVariant)),
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
                                    color: Theme.of(builderContext).colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Theme.of(builderContext).colorScheme.outline.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        color: Theme.of(builderContext).colorScheme.onSurfaceVariant,
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
                                    color: Theme.of(builderContext).colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Theme.of(builderContext).colorScheme.outline.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_filled,
                                        color: Theme.of(builderContext).colorScheme.onSurfaceVariant,
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
                        Text(
                          '메모 (선택)',
                          style: TextStyle(color: Theme.of(builderContext).colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: memo,
                          maxLines: 3,
                          onChanged: (v) => memo = v,
                          decoration: InputDecoration(
                            hintText: '메모를 입력해주세요',
                            filled: true,
                            fillColor: Theme.of(builderContext).colorScheme.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Theme.of(builderContext).colorScheme.outline.withValues(alpha: 0.3)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Theme.of(builderContext).colorScheme.outline.withValues(alpha: 0.3)),
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
                                      personalTitle,
                                      selectedDate,
                                      startTime,
                                      endTime,
                                      memo,
                                    )
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isPtSchedule
                                  ? AppTheme.primary
                                  : AppTheme.tertiary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              disabledBackgroundColor: Theme.of(builderContext).colorScheme.surfaceContainerHighest,
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
        scheduledAt: scheduledAt,
        duration: duration > 0 ? duration : 60,
        title: personalTitle,
        note: memo.isNotEmpty ? memo : null,
      );

      await ref
          .read(scheduleRepositoryProvider)
          .updateSchedule(updatedSchedule);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('일정이 수정됐어요'),
            backgroundColor: AppTheme.tertiary,
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

class _ScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;
  final VoidCallback onTap;

  const _ScheduleCard({
    required this.schedule,
    required this.onTap,
  });

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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isCompleted
        ? Colors.green.withValues(alpha: 0.3)
        : isCancelled
            ? Colors.grey.withValues(alpha: 0.3)
            : isDark
                ? AppColors.darkBorder
                : AppColors.gray100;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
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
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
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

// ============================================================
// 운동 기록 카드 위젯
// ============================================================

/// 운동 기록 카드
class _WorkoutCard extends StatelessWidget {
  final WorkoutLogModel workout;
  final VoidCallback? onTap;

  const _WorkoutCard({required this.workout, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 운동 부위 요약
    final categories = workout.exercises
        .map((e) => e.category)
        .toSet()
        .map((c) => _categoryName(c))
        .join(', ');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // 운동 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.title.isNotEmpty
                          ? workout.title
                          : categories.isNotEmpty
                              ? categories
                              : '운동 기록',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      workout.durationMinutes > 0
                          ? '${workout.exercises.length}개 운동 · ${workout.durationMinutes}분'
                          : '${workout.exercises.length}개 운동',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (workout.memo.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        workout.memo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // 운동 수
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${workout.exercises.length}종목',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _categoryName(WorkoutCategory category) {
    switch (category) {
      case WorkoutCategory.chest: return '가슴';
      case WorkoutCategory.back: return '등';
      case WorkoutCategory.shoulder: return '어깨';
      case WorkoutCategory.arm: return '팔';
      case WorkoutCategory.leg: return '하체';
      case WorkoutCategory.core: return '코어';
      case WorkoutCategory.cardio: return '유산소';
      case WorkoutCategory.other: return '기타';
    }
  }
}
