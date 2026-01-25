import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/data/models/schedule_model.dart';
import 'package:flutter_pal_app/data/repositories/schedule_repository.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/providers/members_provider.dart';

/// 일정 추가 화면
class AddScheduleScreen extends ConsumerStatefulWidget {
  final DateTime? initialDate;

  const AddScheduleScreen({super.key, this.initialDate});

  @override
  ConsumerState<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends ConsumerState<AddScheduleScreen> {
  String? _selectedMemberId;
  String? _selectedMemberName;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  int _duration = 60;
  int _repeatWeeks = 0; // 0, 4, 8, 12
  final _noteController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    // 현재 시간을 5분 단위로 반올림
    final now = TimeOfDay.now();
    final roundedMinute = ((now.minute / 5).ceil() * 5) % 60;
    final adjustedHour = now.minute > 55 ? (now.hour + 1) % 24 : now.hour;
    _selectedTime = TimeOfDay(hour: adjustedHour, minute: roundedMinute);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[weekday - 1];
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    DateTime tempDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        '취소',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    const Text(
                      '시간 선택',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedTime = TimeOfDay(
                            hour: tempDateTime.hour,
                            minute: tempDateTime.minute,
                          );
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        '확인',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: tempDateTime,
                  minuteInterval: 5,
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime newDateTime) {
                    tempDateTime = newDateTime;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSave() async {
    if (_selectedMemberId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('회원을 선택해주세요')));
      return;
    }

    final trainer = ref.read(currentTrainerProvider);
    if (trainer == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('트레이너 정보를 찾을 수 없습니다')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final scheduledAt = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final now = DateTime.now();
      final uuid = const Uuid();
      final groupId = _repeatWeeks > 0 ? uuid.v4() : null;

      // 반복 일정 생성 (첫 번째 일정 + repeatWeeks 만큼)
      final totalSchedules = _repeatWeeks > 0 ? _repeatWeeks + 1 : 1;

      debugPrint('=== 일정 추가 시작 ===');
      debugPrint('트레이너 ID: ${trainer.id}');
      debugPrint('회원 ID: $_selectedMemberId');
      debugPrint('회원 이름: $_selectedMemberName');
      debugPrint('예정 시간: $scheduledAt');
      debugPrint('반복 주차: $_repeatWeeks (총 $totalSchedules개 생성)');

      final repository = ref.read(scheduleRepositoryProvider);
      int savedCount = 0;

      for (int i = 0; i < totalSchedules; i++) {
        final scheduleDate = scheduledAt.add(Duration(days: 7 * i));

        final schedule = ScheduleModel(
          id: uuid.v4(),
          trainerId: trainer.id,
          memberId: _selectedMemberId!,
          memberName: _selectedMemberName,
          scheduledAt: scheduleDate,
          duration: _duration,
          status: ScheduleStatus.scheduled,
          note: _noteController.text.isNotEmpty ? _noteController.text : null,
          groupId: groupId,
          createdAt: now,
        );

        debugPrint('저장 중 ${i + 1}/$totalSchedules: ${scheduleDate.toString()}');
        await repository.addSchedule(schedule);
        savedCount++;
      }

      debugPrint('=== 일정 추가 완료: $savedCount개 저장됨 ===');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              savedCount > 1 ? '$savedCount개의 일정이 추가되었습니다' : '일정이 추가되었습니다',
            ),
            backgroundColor: AppTheme.secondary,
          ),
        );
        context.pop(true);
      }
    } catch (e, stackTrace) {
      debugPrint('일정 추가 실패: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('일정 추가 실패: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(membersWithUserProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/trainer/calendar');
            }
          },
        ),
        title: const Text('일정 추가'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 회원 선택
            _buildSectionTitle('회원 선택 *'),
            const SizedBox(height: 8),
            membersAsync.when(
              data: (members) {
                if (members.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '등록된 회원이 없습니다',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return DropdownButtonFormField<String>(
                  initialValue: _selectedMemberId,
                  items: members.map((m) {
                    final name = m.user?.name ?? '회원';
                    return DropdownMenuItem(
                      value: m.member.id,
                      child: Text(name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMemberId = value;
                      _selectedMemberName = members
                          .firstWhere((m) => m.member.id == value)
                          .user
                          ?.name;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: '회원을 선택해주세요',
                    border: OutlineInputBorder(),
                  ),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('회원 로드 실패: $e'),
            ),
            const SizedBox(height: 20),

            // 날짜 선택
            _buildSectionTitle('날짜 *'),
            const SizedBox(height: 8),
            _buildSelector(
              value:
                  '${_selectedDate.year}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.day.toString().padLeft(2, '0')} (${_getWeekdayName(_selectedDate.weekday)})',
              icon: Icons.calendar_today,
              onTap: _selectDate,
            ),
            const SizedBox(height: 20),

            // 시간 선택
            _buildSectionTitle('시간 *'),
            const SizedBox(height: 8),
            _buildSelector(
              value:
                  '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
              icon: Icons.access_time,
              onTap: _selectTime,
            ),
            const SizedBox(height: 20),

            // 수업 시간
            _buildSectionTitle('수업 시간'),
            const SizedBox(height: 8),
            _buildDurationChips(),
            const SizedBox(height: 24),

            // 반복 설정
            _buildSectionTitle('반복 설정'),
            const SizedBox(height: 8),
            _buildRepeatChips(),
            if (_repeatWeeks > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '매주 ${_getWeekdayName(_selectedDate.weekday)}요일, $_repeatWeeks주 동안 (총 ${_repeatWeeks + 1}회)',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ),
            const SizedBox(height: 20),

            // 메모
            _buildSectionTitle('메모 (선택)'),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '메모를 입력해주세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            // 저장 버튼
            ElevatedButton(
              onPressed: _isSaving ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _repeatWeeks > 0
                          ? '${_repeatWeeks + 1}개 일정 저장하기'
                          : '저장하기',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildSelector({
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value, style: const TextStyle(fontSize: 16)),
            Icon(icon, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationChips() {
    return Wrap(
      spacing: 8,
      children: [30, 60, 90].map((duration) {
        final isSelected = _duration == duration;
        return ChoiceChip(
          label: Text('$duration분'),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() => _duration = duration);
            }
          },
          selectedColor: AppTheme.primary.withValues(alpha: 0.2),
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.primary : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRepeatChips() {
    return Wrap(
      spacing: 8,
      children: [0, 4, 8, 12].map((weeks) {
        final isSelected = _repeatWeeks == weeks;
        final label = weeks == 0 ? '없음' : '$weeks주';
        return ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() => _repeatWeeks = weeks);
            }
          },
          selectedColor: AppTheme.primary.withValues(alpha: 0.2),
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.primary : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
}
