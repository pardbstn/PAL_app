import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/data/models/member_model.dart';
import 'package:flutter_pal_app/data/models/trainer_model.dart';
import 'package:flutter_pal_app/data/repositories/member_repository.dart';
import 'package:flutter_pal_app/data/repositories/user_repository.dart';
import 'package:flutter_pal_app/data/repositories/trainer_repository.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';

/// 회원 등록 다이얼로그 (바텀시트)
class AddMemberDialog extends ConsumerStatefulWidget {
  const AddMemberDialog({super.key});

  /// 바텀시트로 표시
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddMemberDialog(),
    );
  }

  @override
  ConsumerState<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends ConsumerState<AddMemberDialog> {
  late final FormGroup form;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    form = FormGroup({
      'memberTag': FormControl<String>(
        validators: [Validators.required, Validators.pattern(r'^.+#\d{4}$')],
      ),
      'phone': FormControl<String>(),
      'goal': FormControl<FitnessGoal>(
        value: FitnessGoal.fitness,
        validators: [Validators.required],
      ),
      'experience': FormControl<ExperienceLevel>(
        value: ExperienceLevel.beginner,
        validators: [Validators.required],
      ),
      'totalSessions': FormControl<int>(
        value: 20,
        validators: [Validators.required, Validators.min(1), Validators.max(200)],
      ),
      'targetWeight': FormControl<double>(),
      'memo': FormControl<String>(),
    });
  }

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // 핸들바
              _buildHandle(),

              // 헤더
              _buildHeader(),

              // 폼
              Expanded(
                child: ReactiveForm(
                  formGroup: form,
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      // 회원 코드 (필수)
                      _buildMemberTagField(),
                      const SizedBox(height: 16),

                      // 전화번호 (선택)
                      _buildPhoneField(),
                      const SizedBox(height: 24),

                      // 운동 정보 섹션
                      _buildSectionTitle('운동 정보'),
                      const SizedBox(height: 12),

                      // 목표 선택
                      _buildGoalDropdown(),
                      const SizedBox(height: 16),

                      // 운동 경력
                      _buildExperienceDropdown(),
                      const SizedBox(height: 24),

                      // PT 정보 섹션
                      _buildSectionTitle('PT 정보'),
                      const SizedBox(height: 12),

                      // PT 총 회차
                      _buildTotalSessionsField(),
                      const SizedBox(height: 16),

                      // 목표 체중 (선택)
                      _buildTargetWeightField(),
                      const SizedBox(height: 16),

                      // 메모 (선택)
                      _buildMemoField(),
                      const SizedBox(height: 32),

                      // 버튼
                      _buildButtons(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // 뒤로가기 버튼
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey[100],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_add,
              color: AppTheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '새 회원 등록',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '회원 정보를 입력해주세요',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey[100],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMemberTagField() {
    return ReactiveTextField<String>(
      formControlName: 'memberTag',
      decoration: InputDecoration(
        labelText: '회원 코드',
        hintText: '홍길동#1234',
        helperText: '회원 앱에서 확인할 수 있는 이름#코드를 입력하세요',
        prefixIcon: const Icon(Icons.tag),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textInputAction: TextInputAction.next,
      validationMessages: {
        ValidationMessage.required: (error) => '회원 코드는 필수입니다',
        ValidationMessage.pattern: (error) => '올바른 형식이 아닙니다 (예: 홍길동#1234)',
      },
    );
  }

  Widget _buildPhoneField() {
    return ReactiveTextField<String>(
      formControlName: 'phone',
      decoration: InputDecoration(
        labelText: '전화번호 (선택)',
        hintText: '010-0000-0000',
        prefixIcon: const Icon(Icons.phone_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
      ],
    );
  }

  Widget _buildGoalDropdown() {
    return ReactiveDropdownField<FitnessGoal>(
      formControlName: 'goal',
      decoration: InputDecoration(
        labelText: '운동 목표',
        prefixIcon: const Icon(Icons.flag_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: FitnessGoal.values.map((goal) {
        return DropdownMenuItem(
          value: goal,
          child: Row(
            children: [
              _getGoalIcon(goal),
              const SizedBox(width: 12),
              Text(_getGoalLabel(goal)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _getGoalIcon(FitnessGoal goal) {
    IconData iconData;
    Color color;

    switch (goal) {
      case FitnessGoal.diet:
        iconData = Icons.trending_down;
        color = Colors.orange;
      case FitnessGoal.bulk:
        iconData = Icons.fitness_center;
        color = Colors.red;
      case FitnessGoal.fitness:
        iconData = Icons.favorite;
        color = Colors.green;
      case FitnessGoal.rehab:
        iconData = Icons.healing;
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, size: 18, color: color),
    );
  }

  String _getGoalLabel(FitnessGoal goal) {
    switch (goal) {
      case FitnessGoal.diet:
        return '다이어트';
      case FitnessGoal.bulk:
        return '벌크업';
      case FitnessGoal.fitness:
        return '체력 향상';
      case FitnessGoal.rehab:
        return '재활';
    }
  }

  Widget _buildExperienceDropdown() {
    return ReactiveDropdownField<ExperienceLevel>(
      formControlName: 'experience',
      decoration: InputDecoration(
        labelText: '운동 경력',
        prefixIcon: const Icon(Icons.star_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: ExperienceLevel.values.map((level) {
        return DropdownMenuItem(
          value: level,
          child: Row(
            children: [
              _getExperienceIcon(level),
              const SizedBox(width: 12),
              Text(_getExperienceLabel(level)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _getExperienceIcon(ExperienceLevel level) {
    int starCount;
    Color color;

    switch (level) {
      case ExperienceLevel.beginner:
        starCount = 1;
        color = Colors.grey;
      case ExperienceLevel.intermediate:
        starCount = 2;
        color = Colors.orange;
      case ExperienceLevel.advanced:
        starCount = 3;
        color = Colors.amber;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        starCount,
        (index) => Icon(Icons.star, size: 16, color: color),
      ),
    );
  }

  String _getExperienceLabel(ExperienceLevel level) {
    switch (level) {
      case ExperienceLevel.beginner:
        return '입문자 (0~6개월)';
      case ExperienceLevel.intermediate:
        return '중급자 (6개월~2년)';
      case ExperienceLevel.advanced:
        return '숙련자 (2년 이상)';
    }
  }

  Widget _buildTotalSessionsField() {
    return ReactiveTextField<int>(
      formControlName: 'totalSessions',
      decoration: InputDecoration(
        labelText: 'PT 총 회차',
        hintText: '20',
        prefixIcon: const Icon(Icons.numbers),
        suffixText: '회',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      validationMessages: {
        ValidationMessage.required: (error) => 'PT 회차는 필수입니다',
        ValidationMessage.min: (error) => '최소 1회 이상이어야 합니다',
        ValidationMessage.max: (error) => '최대 200회까지 가능합니다',
      },
    );
  }

  Widget _buildTargetWeightField() {
    return ReactiveTextField<double>(
      formControlName: 'targetWeight',
      decoration: InputDecoration(
        labelText: '목표 체중 (선택)',
        hintText: '65.0',
        prefixIcon: const Icon(Icons.monitor_weight_outlined),
        suffixText: 'kg',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
    );
  }

  Widget _buildMemoField() {
    return ReactiveTextField<String>(
      formControlName: 'memo',
      decoration: InputDecoration(
        labelText: '메모 (선택)',
        hintText: '회원에 대한 메모를 입력하세요',
        prefixIcon: const Icon(Icons.note_outlined),
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      maxLines: 3,
      textInputAction: TextInputAction.done,
    );
  }

  Widget _buildButtons() {
    return ReactiveFormConsumer(
      builder: (context, formGroup, child) {
        return Row(
          children: [
            // 취소 버튼
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('취소'),
              ),
            ),
            const SizedBox(width: 16),

            // 저장 버튼
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: formGroup.valid && !_isLoading ? _onSubmit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        '회원 등록',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onSubmit() async {
    if (!form.valid) {
      form.markAllAsTouched();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userRepository = ref.read(userRepositoryProvider);
      final memberRepository = ref.read(memberRepositoryProvider);
      final trainerRepository = ref.read(trainerRepositoryProvider);

      // 트레이너 정보 가져오기 (provider에서 먼저 시도, 없으면 Firestore에서 직접 조회)
      TrainerModel? trainer = ref.read(currentTrainerProvider);

      if (trainer == null || trainer.id.isEmpty) {
        // 현재 로그인한 사용자 ID로 트레이너 조회
        final authState = ref.read(authProvider);
        final userId = authState.userId;

        if (userId != null && userId.isNotEmpty) {
          trainer = await trainerRepository.getByUserId(userId);

          // 트레이너가 없으면 생성
          if (trainer == null) {
            final trainerId = await trainerRepository.createForUser(userId);
            trainer = await trainerRepository.get(trainerId);
          }
        }
      }

      if (trainer == null || trainer.id.isEmpty) {
        throw Exception('트레이너 정보를 찾을 수 없습니다. 다시 로그인해주세요.');
      }

      // 폼 데이터 추출
      final memberTag = form.control('memberTag').value as String;
      final phone = form.control('phone').value as String?;
      final goal = form.control('goal').value as FitnessGoal;
      final experience = form.control('experience').value as ExperienceLevel;
      final totalSessions = form.control('totalSessions').value as int;
      final targetWeight = form.control('targetWeight').value as double?;
      final memo = form.control('memo').value as String?;

      // memberTag 파싱 (예: "홍길동#1234" -> name="홍길동", code="1234")
      final tagParts = memberTag.split('#');
      if (tagParts.length != 2) {
        throw Exception('올바른 회원 코드 형식이 아닙니다.');
      }
      final name = tagParts[0];
      final memberCode = tagParts[1];

      // 1. 이름과 코드로 기존 사용자 찾기
      final existingUser = await userRepository.getByNameAndCode(name, memberCode);

      if (existingUser == null) {
        throw Exception('회원을 찾을 수 없습니다.\n회원이 PAL 앱에 가입했는지 확인해주세요.');
      }

      // 이미 다른 트레이너에게 등록되어 있는지 확인
      final existingMember = await memberRepository.getByUserId(existingUser.uid);
      if (existingMember != null) {
        throw Exception('이미 다른 트레이너에게 등록된 회원입니다.');
      }

      // 전화번호 업데이트 (입력한 경우)
      if (phone != null && phone.isNotEmpty) {
        await userRepository.update(existingUser.uid, {'phone': phone});
      }

      // 2. 회원 프로필 생성
      final member = MemberModel(
        id: '',
        userId: existingUser.uid,
        trainerId: trainer.id,
        goal: goal,
        experience: experience,
        ptInfo: PtInfo(
          totalSessions: totalSessions,
          completedSessions: 0,
          startDate: DateTime.now(),
        ),
        targetWeight: targetWeight,
        memo: memo,
      );

      await memberRepository.create(member);

      // 트레이너의 memberIds에 추가
      await trainerRepository.addMember(trainer.id, existingUser.uid);

      if (mounted) {
        Navigator.pop(context, true); // 성공 시 true 반환
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('$name 회원이 등록되었습니다.'),
              ],
            ),
            backgroundColor: AppTheme.secondary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('등록 실패: $e')),
              ],
            ),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
