import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/core/theme/app_tokens.dart';
import 'package:flutter_pal_app/data/models/curriculum_model.dart';
import 'package:flutter_pal_app/data/models/curriculum_template_model.dart';
import 'package:flutter_pal_app/data/models/member_model.dart' as member_model;
import 'package:flutter_pal_app/data/repositories/curriculum_repository.dart';
import 'package:flutter_pal_app/data/repositories/curriculum_template_repository.dart';
import 'package:flutter_pal_app/data/repositories/member_repository.dart';
import 'package:flutter_pal_app/data/services/ai_service.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';

/// AI 커리큘럼 생성 화면
/// Step 1: 회원 정보 입력
/// Step 2: 생성된 커리큘럼 미리보기 & 수정
class AiCurriculumGeneratorScreen extends ConsumerStatefulWidget {
  final String? memberId;
  final String? memberName;

  const AiCurriculumGeneratorScreen({
    super.key,
    this.memberId,
    this.memberName,
  });

  @override
  ConsumerState<AiCurriculumGeneratorScreen> createState() =>
      _AiCurriculumGeneratorScreenState();
}

class _AiCurriculumGeneratorScreenState
    extends ConsumerState<AiCurriculumGeneratorScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isGenerating = false;
  bool _isLoadingMember = true;

  // Step 1: 입력 폼 데이터
  FitnessGoal _selectedGoal = FitnessGoal.diet;
  ExperienceLevel _selectedExperience = ExperienceLevel.beginner;
  int _sessionCount = 8;
  final TextEditingController _restrictionsController = TextEditingController();

  // Step 2: 생성된 커리큘럼
  List<GeneratedCurriculum> _generatedCurriculums = [];

  // 펼쳐진 커리큘럼 카드 인덱스 추적
  final Set<int> _expandedCards = {};

  // 로딩 카운트다운
  int _remainingSeconds = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _loadMemberData();
  }

  /// 회원 정보 로드하여 목표/경험 자동 설정
  Future<void> _loadMemberData() async {
    if (widget.memberId == null) {
      setState(() => _isLoadingMember = false);
      return;
    }

    try {
      final memberRepo = ref.read(memberRepositoryProvider);
      final member = await memberRepo.get(widget.memberId!);

      if (member != null && mounted) {
        setState(() {
          // member_model enum을 로컬 enum으로 변환
          _selectedGoal = _convertGoal(member.goal);
          _selectedExperience = _convertExperience(member.experience);
          // 기존 PT 총 회차가 있으면 그걸로 설정
          if (member.ptInfo.totalSessions > 0) {
            _sessionCount = member.ptInfo.totalSessions;
          }
          // 메모가 있으면 제한사항으로 설정
          if (member.memo != null && member.memo!.isNotEmpty) {
            _restrictionsController.text = member.memo!;
          }
          _isLoadingMember = false;
        });
      } else {
        setState(() => _isLoadingMember = false);
      }
    } catch (e) {
      debugPrint('Error loading member data: $e');
      setState(() => _isLoadingMember = false);
    }
  }

  /// member_model.FitnessGoal을 로컬 FitnessGoal로 변환
  FitnessGoal _convertGoal(member_model.FitnessGoal goal) {
    return switch (goal) {
      member_model.FitnessGoal.diet => FitnessGoal.diet,
      member_model.FitnessGoal.bulk => FitnessGoal.bulk,
      member_model.FitnessGoal.fitness => FitnessGoal.fitness,
      member_model.FitnessGoal.rehab => FitnessGoal.rehab,
    };
  }

  /// member_model.ExperienceLevel을 로컬 ExperienceLevel로 변환
  ExperienceLevel _convertExperience(member_model.ExperienceLevel exp) {
    return switch (exp) {
      member_model.ExperienceLevel.beginner => ExperienceLevel.beginner,
      member_model.ExperienceLevel.intermediate => ExperienceLevel.intermediate,
      member_model.ExperienceLevel.advanced => ExperienceLevel.advanced,
    };
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pageController.dispose();
    _restrictionsController.dispose();
    super.dispose();
  }

  /// 카운트다운 타이머 시작
  void _startCountdownTimer() {
    // 예상 시간 계산: 기본 10초 + 회차당 2초
    final estimatedSeconds = 10 + (_sessionCount * 2);
    _remainingSeconds = estimatedSeconds;

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        }
      });
    });
  }

  /// 카운트다운 타이머 중지
  void _stopCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _remainingSeconds = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentStep == 0 ? 'AI 커리큘럼 생성' : '커리큘럼 미리보기'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            if (_currentStep > 0 && !_isGenerating) {
              _goToPreviousStep();
            } else {
              // 회원 상세 페이지로 돌아가기
              if (widget.memberId != null) {
                context.go('/trainer/members/${widget.memberId}');
              } else {
                context.go('/trainer/members');
              }
            }
          },
        ),
      ),
      body: Column(
        children: [
          // 스텝 인디케이터
          _buildStepIndicator(),
          // 페이지 컨텐츠
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1InputForm(),
                _isGenerating ? _buildLoadingView() : _buildStep2Preview(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _buildStepCircle(0, '정보 입력'),
          Expanded(
            child: Container(
              height: 2,
              color: _currentStep >= 1 ? AppTheme.primary : Colors.grey[300],
            ),
          ),
          _buildStepCircle(1, '미리보기'),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isCurrent ? 40 : 32,
          height: isCurrent ? 40 : 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppTheme.primary : Colors.grey[300],
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isActive && !isCurrent
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? AppTheme.primary : Colors.grey[600],
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // Step 1: 입력 폼
  Widget _buildStep1InputForm() {
    // 회원 데이터 로딩 중
    if (_isLoadingMember) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('회원 정보를 불러오는 중'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 회원 정보 표시 (있는 경우)
          if (widget.memberName != null) ...[
            _buildMemberCard(),
            const SizedBox(height: 24),
          ],

          // 운동 목표 선택
          _buildSectionTitle('운동 목표', Icons.flag_outlined),
          const SizedBox(height: 12),
          _buildGoalSelector(),
          const SizedBox(height: 24),

          // 운동 경력 선택
          _buildSectionTitle('운동 경력', Icons.fitness_center),
          const SizedBox(height: 12),
          _buildExperienceSelector(),
          const SizedBox(height: 24),

          // 회차 수 선택
          _buildSectionTitle('생성할 회차 수', Icons.calendar_today_outlined),
          const SizedBox(height: 12),
          _buildSessionCountSelector(),
          const SizedBox(height: 24),

          // 제한사항 입력
          _buildSectionTitle('제한사항 (선택)', Icons.warning_amber_outlined),
          const SizedBox(height: 12),
          _buildRestrictionsInput(),
          const SizedBox(height: 32),

          // 템플릿 사용 버튼
          _buildUseTemplateButton(),
          const SizedBox(height: 16),

          // 생성 버튼
          _buildGenerateButton(),
        ],
      ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.02, end: 0),
    );
  }

  Widget _buildMemberCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.1),
            AppTheme.secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: AppTheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.memberName!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '커리큘럼 생성 대상',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primary),
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

  Widget _buildGoalSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: FitnessGoal.values.map((goal) {
        final isSelected = _selectedGoal == goal;
        return GestureDetector(
          onTap: () => setState(() => _selectedGoal = goal),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.primary : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  goal.icon,
                  size: 20,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
                const SizedBox(width: 8),
                Text(
                  goal.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExperienceSelector() {
    return Row(
      children: ExperienceLevel.values.map((level) {
        final isSelected = _selectedExperience == level;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedExperience = level),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: level != ExperienceLevel.advanced ? 12 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? level.color.withValues(alpha: 0.15)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? level.color : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    level.icon,
                    color: isSelected ? level.color : Colors.grey[600],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    level.label,
                    style: TextStyle(
                      color: isSelected ? level.color : Colors.grey[700],
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSessionCountSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '회차 수',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                '$_sessionCount회',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.primary,
              inactiveTrackColor: AppTheme.primary.withValues(alpha: 0.2),
              thumbColor: AppTheme.primary,
              overlayColor: AppTheme.primary.withValues(alpha: 0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: _sessionCount.toDouble(),
              min: 4,
              max: 24,
              divisions: 20,
              onChanged: (value) {
                setState(() => _sessionCount = value.toInt());
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('4회', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text('24회', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRestrictionsInput() {
    return TextField(
      controller: _restrictionsController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: '부상, 통증, 기타 제한사항을 입력해주세요\n예: 무릎 부상으로 스쿼트 불가, 허리 디스크 주의',
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildUseTemplateButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: _showTemplateDialog,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.secondary,
          side: const BorderSide(color: AppTheme.secondary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_copy_outlined, size: 20),
            SizedBox(width: 8),
            Text(
              '저장된 템플릿 사용',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _generateCurriculum,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: AppTheme.primary.withValues(alpha: 0.4),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 22),
            SizedBox(width: 8),
            Text(
              'AI 커리큘럼 생성',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 템플릿 선택 다이얼로그
  void _showTemplateDialog() async {
    final trainer = ref.read(currentTrainerProvider);
    if (trainer == null) return;

    // 현재 선택된 goal/experience 매핑
    final goalMap = {
      FitnessGoal.diet: member_model.FitnessGoal.diet,
      FitnessGoal.bulk: member_model.FitnessGoal.bulk,
      FitnessGoal.fitness: member_model.FitnessGoal.fitness,
      FitnessGoal.rehab: member_model.FitnessGoal.rehab,
    };
    final experienceMap = {
      ExperienceLevel.beginner: member_model.ExperienceLevel.beginner,
      ExperienceLevel.intermediate: member_model.ExperienceLevel.intermediate,
      ExperienceLevel.advanced: member_model.ExperienceLevel.advanced,
    };

    final selectedGoal = goalMap[_selectedGoal]!;
    final selectedExperience = experienceMap[_selectedExperience]!;

    // 로딩 다이얼로그
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 전체 템플릿만 로드 (한 번의 쿼리로 처리)
      final repository = ref.read(curriculumTemplateRepositoryProvider);
      final allTemplates = await repository.getByTrainerId(trainer.id);

      if (!mounted) return;
      Navigator.pop(context); // 로딩 닫기

      if (allTemplates.isEmpty) {
        // 템플릿이 없을 때 안내 다이얼로그
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            icon: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.folder_open,
                color: AppTheme.secondary,
                size: 40,
              ),
            ),
            title: const Text('저장된 템플릿이 없어요'),
            content: const Text(
              'AI로 커리큘럼을 생성한 후 "템플릿으로 저장" 버튼을 눌러 템플릿을 만들어 보세요.\n\n'
              '템플릿을 저장하면 다른 회원에게도 빠르게 적용할 수 있어 API 호출을 줄일 수 있어요.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // AI 생성 버튼 클릭과 동일한 효과
                  _generateCurriculum();
                },
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('AI로 생성하기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                ),
              ),
            ],
          ),
        );
        return;
      }

      // 클라이언트 측에서 매칭 템플릿 필터링 (복합 인덱스 불필요)
      final matchingTemplateIds = allTemplates
          .where((t) => t.goal == selectedGoal && t.experience == selectedExperience)
          .map((t) => t.id)
          .toSet();

      // 템플릿 선택 다이얼로그
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => _buildTemplateSelectionSheet(
          allTemplates,
          matchingTemplateIds,
        ),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('템플릿 로드 실패: $e')),
        );
      }
    }
  }

  Widget _buildTemplateSelectionSheet(
    List<CurriculumTemplateModel> allTemplates,
    Set<String> matchingTemplateIds,
  ) {
    // 추천 템플릿을 먼저, 그 다음 일반 템플릿 순으로 정렬
    final sortedTemplates = List<CurriculumTemplateModel>.from(allTemplates)
      ..sort((a, b) {
        final aIsMatching = matchingTemplateIds.contains(a.id);
        final bIsMatching = matchingTemplateIds.contains(b.id);
        if (aIsMatching && !bIsMatching) return -1;
        if (!aIsMatching && bIsMatching) return 1;
        // 같은 카테고리 내에서는 사용 횟수 순으로 정렬
        return b.usageCount.compareTo(a.usageCount);
      });

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // 핸들
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 타이틀
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.folder_copy, color: AppTheme.secondary),
                  const SizedBox(width: 8),
                  const Text(
                    '템플릿 선택',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 매칭 템플릿 안내
            if (matchingTemplateIds.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    const Icon(Icons.recommend, size: 18, color: AppTheme.secondary),
                    const SizedBox(width: 4),
                    Text(
                      '추천 (${_selectedGoal.label} / ${_selectedExperience.label})',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // 템플릿 목록
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: sortedTemplates.length,
                itemBuilder: (context, index) {
                  final template = sortedTemplates[index];
                  final isRecommended = matchingTemplateIds.contains(template.id);
                  return _buildTemplateCard(template, isRecommended);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTemplateCard(CurriculumTemplateModel template, bool isRecommended) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isRecommended
            ? const BorderSide(color: AppTheme.secondary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _useTemplate(template),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isRecommended)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '추천',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondary,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      template.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    '${template.usageCount}회 사용',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildTag(template.goalLabel),
                  const SizedBox(width: 8),
                  _buildTag(template.experienceLabel),
                  const SizedBox(width: 8),
                  _buildTag('${template.sessionCount}회차'),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${template.totalExerciseCount}개 운동',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  /// 템플릿 사용
  void _useTemplate(CurriculumTemplateModel template) {
    Navigator.pop(context); // 바텀시트 닫기

    // 템플릿 세션을 GeneratedCurriculum으로 변환
    final curriculums = template.sessions.map((session) {
      return GeneratedCurriculum(
        sessionNumber: session.sessionNumber,
        title: session.title,
        exercises: session.exercises.map((e) {
          return GeneratedExercise(
            name: e.name,
            sets: e.sets,
            reps: e.reps,
            weight: e.weight,
          );
        }).toList(),
      );
    }).toList();

    // 사용 횟수 증가
    ref
        .read(curriculumTemplateRepositoryProvider)
        .incrementUsageCount(template.id);

    // 미리보기 스텝으로 이동
    setState(() {
      _generatedCurriculums = curriculums;
      _sessionCount = template.sessionCount;
      _currentStep = 1;
    });
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('템플릿 "${template.name}"이 적용됐어요'),
        backgroundColor: AppTheme.secondary,
      ),
    );
  }

  // 로딩 뷰
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie 애니메이션 (네트워크에서 로드)
          SizedBox(
            width: 200,
            height: 200,
            child: Lottie.network(
              'https://lottie.host/7a7f8f0e-5f5e-4b5b-8f0e-7a7f8f0e5f5e/AI-loading.json',
              errorBuilder: (context, error, stackTrace) {
                // 네트워크 오류 시 대체 애니메이션
                return _buildFallbackLoadingAnimation();
              },
              frameBuilder: (context, child, composition) {
                if (composition == null) {
                  return _buildFallbackLoadingAnimation();
                }
                return child;
              },
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'AI가 커리큘럼을 생성하고 있어요',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1500.ms),
          const SizedBox(height: 8),
          Text(
            '${_selectedGoal.label} 목표에 맞는 $_sessionCount회차 프로그램',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          // 남은 시간 카운트다운
          _buildCountdownTimer(),
          const SizedBox(height: 24),
          // 진행 상태 텍스트
          _buildLoadingStatusText(),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  /// 남은 시간 카운트다운 위젯
  Widget _buildCountdownTimer() {
    if (_remainingSeconds <= 0) {
      return Text(
        '거의 완료됐어요...',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppTheme.secondary,
        ),
      );
    }

    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final timeStr = minutes > 0
        ? '$minutes분 ${seconds.toString().padLeft(2, '0')}초'
        : '$seconds초';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer_outlined,
            size: 20,
            color: AppTheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            '예상 남은 시간: $timeStr',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackLoadingAnimation() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 바깥 원
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.3),
              width: 4,
            ),
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.2, 1.2),
              duration: 1500.ms,
            )
            .fadeOut(duration: 1500.ms),
        // 가운데 아이콘
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppTheme.primary,
                AppTheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(
            Icons.auto_awesome,
            color: Colors.white,
            size: 40,
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .rotate(duration: 2000.ms)
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.1, 1.1),
              duration: 1000.ms,
            )
            .then()
            .scale(
              begin: const Offset(1.1, 1.1),
              end: const Offset(1, 1),
              duration: 1000.ms,
            ),
      ],
    );
  }

  Widget _buildLoadingStatusText() {
    return Column(
      children: [
        _buildStatusItem('회원 데이터 분석', true),
        _buildStatusItem('운동 프로그램 설계', true),
        _buildStatusItem('세부 운동 구성', false),
      ],
    );
  }

  Widget _buildStatusItem(String text, bool isComplete) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isComplete)
            const Icon(Icons.check_circle, color: AppTheme.secondary, size: 18)
          else
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primary.withValues(alpha: 0.5),
              ),
            ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isComplete ? Colors.grey[700] : Colors.grey[500],
              fontWeight: isComplete ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // Step 2: 미리보기
  Widget _buildStep2Preview() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _generatedCurriculums.length,
            itemBuilder: (context, index) {
              return _buildCurriculumCard(index)
                  .animate()
                  .fadeIn(delay: (index * 50).ms, duration: 200.ms)
                  .slideY(begin: 0.02, duration: 200.ms);
            },
          ),
        ),
        // 하단 버튼
        _buildBottomActions(),
      ],
    );
  }

  Widget _buildCurriculumCard(int index) {
    final curriculum = _generatedCurriculums[index];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpanded = _expandedCards.contains(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.gray100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          onExpansionChanged: (expanded) {
            setState(() {
              if (expanded) {
                _expandedCards.add(index);
              } else {
                _expandedCards.remove(index);
              }
            });
          },
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary,
                  AppTheme.primary.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${curriculum.sessionNumber}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          title: Text(
            curriculum.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            '${curriculum.exercises.length}개 운동',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () => _editCurriculum(index),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              // 펼침 상태에 따라 아이콘 회전
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.expand_more,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          children: [
            Divider(
              color: isDark ? AppColors.darkBorder : AppColors.gray100,
              height: 1,
            ),
            const SizedBox(height: 8),
            ...curriculum.exercises.asMap().entries.map((entry) {
              final exerciseIndex = entry.key;
              final exercise = entry.value;
              return _buildExerciseItem(index, exerciseIndex, exercise);
            }),
            const SizedBox(height: 8),
            // 운동 추가 버튼
            OutlinedButton.icon(
              onPressed: () => _addExercise(index),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('운동 추가'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: BorderSide(
                  color: AppTheme.primary.withValues(alpha: 0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseItem(
      int curriculumIndex, int exerciseIndex, GeneratedExercise exercise) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.gray100,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBorder : AppColors.gray100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${exerciseIndex + 1}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${exercise.sets}세트 × ${exercise.reps}회',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: () =>
                _editExercise(curriculumIndex, exerciseIndex, exercise),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            onPressed: () => _deleteExercise(curriculumIndex, exerciseIndex),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 템플릿 저장 버튼
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _saveAsTemplate,
                icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                label: const Text('템플릿으로 저장'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.secondary,
                  side: const BorderSide(color: AppTheme.secondary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 하단 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _regenerateCurriculum,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.primary),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, size: 20),
                        SizedBox(width: 8),
                        Text('다시 생성'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _saveCurriculum,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save_outlined, size: 20),
                        SizedBox(width: 8),
                        Text(
                          '커리큘럼 저장',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 템플릿으로 저장
  void _saveAsTemplate() async {
    final trainer = ref.read(currentTrainerProvider);
    if (trainer == null) return;

    final nameController = TextEditingController(
      text: '${_selectedGoal.label} $_sessionCount회차 커리큘럼',
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.bookmark_add, color: AppTheme.secondary),
            SizedBox(width: 8),
            Text('템플릿으로 저장'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '이 커리큘럼을 템플릿으로 저장하면 다른 회원에게도 적용할 수 있어요',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '템플릿 이름',
                border: OutlineInputBorder(),
                hintText: '예: 초보자 다이어트 8주',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildTag(_selectedGoal.label),
                const SizedBox(width: 8),
                _buildTag(_selectedExperience.label),
                const SizedBox(width: 8),
                _buildTag('$_sessionCount회차'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('템플릿 이름을 입력해주세요.')),
                );
                return;
              }
              Navigator.pop(context, nameController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondary,
            ),
            child: const Text('저장'),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;
    if (!mounted) return;

    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final repository = ref.read(curriculumTemplateRepositoryProvider);

      // goal/experience 변환
      final goalMap = {
        FitnessGoal.diet: member_model.FitnessGoal.diet,
        FitnessGoal.bulk: member_model.FitnessGoal.bulk,
        FitnessGoal.fitness: member_model.FitnessGoal.fitness,
        FitnessGoal.rehab: member_model.FitnessGoal.rehab,
      };
      final experienceMap = {
        ExperienceLevel.beginner: member_model.ExperienceLevel.beginner,
        ExperienceLevel.intermediate: member_model.ExperienceLevel.intermediate,
        ExperienceLevel.advanced: member_model.ExperienceLevel.advanced,
      };

      final now = DateTime.now();

      // GeneratedCurriculum을 TemplateSession으로 변환
      final sessions = _generatedCurriculums.map((c) {
        return TemplateSession(
          sessionNumber: c.sessionNumber,
          title: c.title,
          exercises: c.exercises.map((e) {
            return Exercise(
              name: e.name,
              sets: e.sets,
              reps: e.reps,
              weight: e.weight,
            );
          }).toList(),
        );
      }).toList();

      final template = CurriculumTemplateModel(
        id: '',
        trainerId: trainer.id,
        name: result,
        goal: goalMap[_selectedGoal]!,
        experience: experienceMap[_selectedExperience]!,
        sessionCount: _sessionCount,
        sessions: sessions,
        usageCount: 0,
        createdAt: now,
        updatedAt: now,
      );

      await repository.create(template);

      if (mounted) Navigator.pop(context); // 로딩 닫기

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('템플릿 "$result"이 저장됐어요'),
            backgroundColor: AppTheme.secondary,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // 로딩 닫기
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('템플릿 저장 실패: $e')),
        );
      }
    }
  }

  // 액션 메서드들
  void _generateCurriculum() async {
    // AI 기능은 이제 무제한 사용 가능
    setState(() {
      _isGenerating = true;
      _currentStep = 1;
    });
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // 카운트다운 시작
    _startCountdownTimer();

    try {
      // AI 서비스 호출
      final aiService = ref.read(aiServiceProvider);

      // goal을 API 형식으로 변환
      final goalMap = {
        FitnessGoal.diet: 'diet',
        FitnessGoal.bulk: 'bulk',
        FitnessGoal.fitness: 'fitness',
        FitnessGoal.rehab: 'rehab',
      };

      // experience를 API 형식으로 변환
      final experienceMap = {
        ExperienceLevel.beginner: 'beginner',
        ExperienceLevel.intermediate: 'intermediate',
        ExperienceLevel.advanced: 'advanced',
      };

      final aiCurriculums = await aiService.generateCurriculum(
        memberId: widget.memberId ?? '',
        goal: goalMap[_selectedGoal] ?? 'fitness',
        experience: experienceMap[_selectedExperience] ?? 'beginner',
        sessionCount: _sessionCount,
        restrictions: _restrictionsController.text.isNotEmpty
            ? _restrictionsController.text
            : null,
      );

      // AI 결과를 로컬 모델로 변환
      final curriculums = aiCurriculums.map((ai) {
        return GeneratedCurriculum(
          sessionNumber: ai.sessionNumber,
          title: ai.title,
          exercises: ai.exercises.map((e) {
            return GeneratedExercise(
              name: e.name,
              sets: e.sets,
              reps: e.reps,
              weight: null, // weight는 문자열로 오므로 별도 처리 필요시 추가
            );
          }).toList(),
        );
      }).toList();

      // 타이머 중지
      _stopCountdownTimer();

      setState(() {
        _generatedCurriculums = curriculums;
        _isGenerating = false;
      });
    } catch (e) {
      // 타이머 중지
      _stopCountdownTimer();

      // 에러 발생 시 샘플 데이터로 폴백 (개발/테스트용)
      if (mounted) {
        // 2초 후 샘플 데이터로 진행
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          final curriculums = _generateSampleCurriculums();
          setState(() {
            _generatedCurriculums = curriculums;
            _isGenerating = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('AI 서버 연결 실패. 샘플 데이터로 진행해요.\n($e)'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  List<GeneratedCurriculum> _generateSampleCurriculums() {
    final templates = {
      FitnessGoal.diet: [
        ('상체 근력 + 유산소', ['벤치프레스', '덤벨플라이', '숄더프레스', '트레드밀']),
        ('하체 + 코어', ['스쿼트', '레그프레스', '레그컬', '플랭크']),
        ('전신 순환 운동', ['버피', '케틀벨스윙', '마운틴클라이머', '점프스쿼트']),
        ('상체 근지구력', ['푸쉬업', '풀업', '딥스', '플랭크']),
      ],
      FitnessGoal.bulk: [
        ('가슴 집중', ['벤치프레스', '인클라인프레스', '덤벨플라이', '케이블크로스']),
        ('등 집중', ['랫풀다운', '바벨로우', '시티드로우', '데드리프트']),
        ('하체 집중', ['스쿼트', '레그프레스', '런지', '레그익스텐션']),
        ('어깨/팔 집중', ['숄더프레스', '사이드레터럴', '바이셉컬', '트라이셉익스텐션']),
      ],
      FitnessGoal.fitness: [
        ('기초 체력 강화', ['스쿼트', '푸쉬업', '플랭크', '버피']),
        ('심폐 지구력', ['트레드밀', '로잉머신', '사이클', '점프로프']),
        ('유연성 & 밸런스', ['요가', '스트레칭', '밸런스보드', '필라테스']),
        ('기능성 훈련', ['TRX', '메디신볼', '보수볼', '저항밴드']),
      ],
      FitnessGoal.rehab: [
        ('관절 가동성', ['스트레칭', '폼롤러', '밴드운동', '가벼운 유산소']),
        ('근력 회복', ['머신운동', '저항밴드', '자체중량운동', '아이소메트릭']),
        ('균형 & 안정성', ['보수볼', '밸런스패드', '한발서기', '코어안정화']),
        ('점진적 강화', ['가벼운 웨이트', '케이블머신', '서킷트레이닝', '수영']),
      ],
    };

    final selectedTemplates = templates[_selectedGoal]!;
    final curriculums = <GeneratedCurriculum>[];

    for (int i = 0; i < _sessionCount; i++) {
      final templateIndex = i % selectedTemplates.length;
      final template = selectedTemplates[templateIndex];

      curriculums.add(GeneratedCurriculum(
        sessionNumber: i + 1,
        title: template.$1,
        exercises: template.$2.map((name) {
          final sets = _selectedExperience == ExperienceLevel.beginner
              ? 3
              : _selectedExperience == ExperienceLevel.intermediate
                  ? 4
                  : 5;
          final reps = _selectedGoal == FitnessGoal.bulk ? 8 : 12;
          return GeneratedExercise(name: name, sets: sets, reps: reps);
        }).toList(),
      ));
    }

    return curriculums;
  }

  void _goToPreviousStep() {
    setState(() {
      _currentStep = 0;
      _generatedCurriculums = [];
    });
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _editCurriculum(int index) {
    final curriculum = _generatedCurriculums[index];
    final titleController = TextEditingController(text: curriculum.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회차 수정'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: '제목',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _generatedCurriculums[index] = GeneratedCurriculum(
                  sessionNumber: curriculum.sessionNumber,
                  title: titleController.text,
                  exercises: curriculum.exercises,
                );
              });
              Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _editExercise(
      int curriculumIndex, int exerciseIndex, GeneratedExercise exercise) {
    final nameController = TextEditingController(text: exercise.name);
    final setsController =
        TextEditingController(text: exercise.sets.toString());
    final repsController =
        TextEditingController(text: exercise.reps.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('운동 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '운동명',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: setsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '세트',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: repsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '반복',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              final newExercise = GeneratedExercise(
                name: nameController.text,
                sets: int.tryParse(setsController.text) ?? exercise.sets,
                reps: int.tryParse(repsController.text) ?? exercise.reps,
              );
              setState(() {
                _generatedCurriculums[curriculumIndex].exercises[exerciseIndex] =
                    newExercise;
              });
              Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _deleteExercise(int curriculumIndex, int exerciseIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('운동 삭제'),
        content: const Text('이 운동을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _generatedCurriculums[curriculumIndex]
                    .exercises
                    .removeAt(exerciseIndex);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _addExercise(int curriculumIndex) {
    final nameController = TextEditingController();
    final setsController = TextEditingController(text: '4');
    final repsController = TextEditingController(text: '12');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('운동 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '운동명',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: setsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '세트',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: repsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '반복',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final newExercise = GeneratedExercise(
                  name: nameController.text,
                  sets: int.tryParse(setsController.text) ?? 4,
                  reps: int.tryParse(repsController.text) ?? 12,
                );
                setState(() {
                  _generatedCurriculums[curriculumIndex]
                      .exercises
                      .add(newExercise);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  void _regenerateCurriculum() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('다시 생성'),
        content: const Text('현재 수정 내용이 사라집니다. 다시 생성하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _goToPreviousStep();
            },
            child: const Text('다시 생성'),
          ),
        ],
      ),
    );
  }

  void _saveCurriculum() async {
    // memberId 확인
    if (widget.memberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원 정보가 없어요.')),
      );
      return;
    }

    // trainerId 가져오기
    final trainer = ref.read(currentTrainerProvider);
    if (trainer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('트레이너 정보를 불러올 수 없어요.')),
      );
      return;
    }

    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final repository = ref.read(curriculumRepositoryProvider);
      final now = DateTime.now();

      // 각 커리큘럼 저장
      for (final generated in _generatedCurriculums) {
        final curriculum = CurriculumModel(
          id: '', // Firestore에서 자동 생성
          memberId: widget.memberId!,
          trainerId: trainer.id,
          sessionNumber: generated.sessionNumber,
          title: generated.title,
          exercises: generated.exercises
              .map((e) => Exercise(
                    name: e.name,
                    sets: e.sets,
                    reps: e.reps,
                    weight: e.weight,
                  ))
              .toList(),
          isAiGenerated: true,
          createdAt: now,
          updatedAt: now,
        );

        await repository.create(curriculum);
      }

      // 회원의 totalSessions 업데이트
      final memberRepository = ref.read(memberRepositoryProvider);
      await memberRepository.updateSessionProgress(
        widget.memberId!,
        totalSessions: _generatedCurriculums.length,
      );

      // 로딩 닫기
      if (mounted) Navigator.pop(context);

      // 성공 다이얼로그
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            icon: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppTheme.secondary,
                size: 48,
              ),
            ),
            title: const Text('저장 완료'),
            content: Text(
              '${_generatedCurriculums.length}회차 커리큘럼이 저장됐어요',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // 다이얼로그 닫기
                  // 회원 목록 페이지로 이동
                  context.go('/trainer/members');
                },
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // 로딩 닫기
      if (mounted) Navigator.pop(context);

      // 에러 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    }
  }
}

// 데이터 모델
enum FitnessGoal {
  diet('체중 감량', Icons.local_fire_department),
  bulk('근육 증가', Icons.fitness_center),
  fitness('체력 향상', Icons.directions_run),
  rehab('재활/회복', Icons.healing);

  final String label;
  final IconData icon;
  const FitnessGoal(this.label, this.icon);
}

enum ExperienceLevel {
  beginner('입문', Icons.star_outline, AppTheme.tertiary),
  intermediate('중급', Icons.star_half, AppTheme.primary),
  advanced('상급', Icons.star, AppTheme.secondary);

  final String label;
  final IconData icon;
  final Color color;
  const ExperienceLevel(this.label, this.icon, this.color);
}

class GeneratedCurriculum {
  final int sessionNumber;
  final String title;
  final List<GeneratedExercise> exercises;

  GeneratedCurriculum({
    required this.sessionNumber,
    required this.title,
    required this.exercises,
  });
}

class GeneratedExercise {
  final String name;
  final int sets;
  final int reps;
  final double? weight;

  GeneratedExercise({
    required this.name,
    required this.sets,
    required this.reps,
    this.weight,
  });
}
