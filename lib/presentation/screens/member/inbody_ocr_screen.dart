import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_pal_app/core/theme/app_tokens.dart';
import 'package:flutter_pal_app/core/utils/haptic_utils.dart';
import 'package:flutter_pal_app/data/models/inbody_ocr_result.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/providers/inbody_ocr_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/common/app_button.dart';
import 'package:flutter_pal_app/presentation/widgets/common/app_card.dart';

/// 인바디 OCR 화면
///
/// 3단계 플로우:
/// 1. 이미지 선택 (카메라/갤러리)
/// 2. AI 분석 (업로드 + OCR)
/// 3. 결과 확인 및 수정
class InbodyOcrScreen extends ConsumerStatefulWidget {
  /// 트레이너가 접근할 때 회원 ID를 직접 전달
  final String? memberId;

  const InbodyOcrScreen({super.key, this.memberId});

  @override
  ConsumerState<InbodyOcrScreen> createState() => _InbodyOcrScreenState();
}

class _InbodyOcrScreenState extends ConsumerState<InbodyOcrScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 상태 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(inbodyOcrProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ocrState = ref.watch(inbodyOcrProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          '인바디 사진 분석',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            HapticUtils.selection();
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 단계 인디케이터
            _buildStepIndicator(ocrState, colorScheme),

            // 메인 콘텐츠
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: _buildContent(ocrState, colorScheme, theme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 단계 인디케이터
  Widget _buildStepIndicator(InbodyOcrState state, ColorScheme colorScheme) {
    int currentStep = 0;
    if (_selectedImage != null || state.status == InbodyOcrStatus.uploading) {
      currentStep = 1;
    }
    if (state.status == InbodyOcrStatus.analyzing) {
      currentStep = 2;
    }
    if (state.status == InbodyOcrStatus.success) {
      currentStep = 3;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          _buildStepCircle(1, '선택', currentStep >= 1, colorScheme),
          _buildStepLine(currentStep >= 2, colorScheme),
          _buildStepCircle(2, '분석', currentStep >= 2, colorScheme),
          _buildStepLine(currentStep >= 3, colorScheme),
          _buildStepCircle(3, '완료', currentStep >= 3, colorScheme),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildStepCircle(
    int step,
    String label,
    bool isActive,
    ColorScheme colorScheme,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? colorScheme.primary : colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$step',
                style: TextStyle(
                  color: isActive ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(bool isActive, ColorScheme colorScheme) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isActive ? colorScheme.primary : colorScheme.surfaceContainerHighest,
      ),
    );
  }

  /// 메인 콘텐츠 (상태별 분기)
  Widget _buildContent(
    InbodyOcrState state,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    // 에러 상태
    if (state.status == InbodyOcrStatus.error) {
      return _buildErrorView(state.errorMessage, colorScheme, theme);
    }

    // 성공 상태 - 결과 표시
    if (state.status == InbodyOcrStatus.success && state.result != null) {
      return _buildResultView(state.result!, colorScheme, theme);
    }

    // 분석 중
    if (state.status == InbodyOcrStatus.uploading ||
        state.status == InbodyOcrStatus.analyzing) {
      return _buildAnalyzingView(state, colorScheme, theme);
    }

    // 이미지 선택됨 (아직 분석 안 함)
    if (_selectedImage != null && state.status == InbodyOcrStatus.idle) {
      return _buildImagePreview(colorScheme, theme);
    }

    // 초기 상태 - 이미지 선택 UI
    return _buildImageSelectionView(colorScheme, theme);
  }

  /// Step 1: 이미지 선택 화면
  Widget _buildImageSelectionView(ColorScheme colorScheme, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.xl),
        Text(
          '인바디 결과지 사진을\n선택해주세요',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 100.ms, duration: 200.ms),

        const SizedBox(height: AppSpacing.sm),

        Text(
          'AI가 자동으로 체성분 데이터를 인식해요',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms, duration: 200.ms),

        const SizedBox(height: AppSpacing.xxl),

        // 카메라 버튼
        _buildImageSourceButton(
          icon: Icons.camera_alt_outlined,
          label: '카메라로 촬영',
          onTap: () => _pickImage(ImageSource.camera),
          colorScheme: colorScheme,
          theme: theme,
          delay: 300,
        ),

        const SizedBox(height: AppSpacing.md),

        // 갤러리 버튼
        _buildImageSourceButton(
          icon: Icons.photo_library_outlined,
          label: '갤러리에서 선택',
          onTap: () => _pickImage(ImageSource.gallery),
          colorScheme: colorScheme,
          theme: theme,
          delay: 400,
        ),
      ],
    );
  }

  Widget _buildImageSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    required ThemeData theme,
    required int delay,
  }) {
    return AppCard(
      variant: AppCardVariant.elevated,
      onTap: onTap,
      animationDelay: Duration(milliseconds: delay),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 28,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  /// 이미지 미리보기 (선택 후, 분석 전)
  Widget _buildImagePreview(ColorScheme colorScheme, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '선택한 사진',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // 이미지 미리보기
        ClipRRect(
          borderRadius: AppRadius.lgBorderRadius,
          child: Image.file(
            _selectedImage!,
            fit: BoxFit.cover,
          ),
        ).animate().fadeIn(duration: 200.ms),

        const SizedBox(height: AppSpacing.xl),

        // 분석 시작 버튼
        AppButton(
          label: 'AI 분석 시작하기',
          onPressed: _startAnalysis,
          size: AppButtonSize.lg,
          isFullWidth: true,
        ),

        const SizedBox(height: AppSpacing.md),

        // 다시 선택 버튼
        AppButton(
          label: '다시 선택하기',
          onPressed: () {
            setState(() {
              _selectedImage = null;
            });
          },
          variant: AppButtonVariant.outline,
          size: AppButtonSize.lg,
          isFullWidth: true,
        ),
      ],
    );
  }

  /// Step 2: 분석 중 화면
  Widget _buildAnalyzingView(
    InbodyOcrState state,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    final isUploading = state.status == InbodyOcrStatus.uploading;
    final statusText = isUploading ? '사진을 업로드하고 있어요...' : 'AI가 결과지를 분석하고 있어요...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.xxl),

        // 로딩 애니메이션
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: colorScheme.primary,
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1500.ms, color: colorScheme.primary.withValues(alpha: 0.3)),
        ),

        const SizedBox(height: AppSpacing.xxl),

        Text(
          statusText,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 200.ms),

        const SizedBox(height: AppSpacing.md),

        if (isUploading && state.uploadProgress > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: state.uploadProgress,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: colorScheme.primary,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${(state.uploadProgress * 100).toInt()}%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

        if (!isUploading)
          Text(
            '잠시만 기다려주세요',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 100.ms, duration: 200.ms),
      ],
    );
  }

  /// Step 3: 결과 확인 화면
  Widget _buildResultView(
    InbodyOcrResult result,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 저장 완료 배지
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.1),
            borderRadius: AppRadius.lgBorderRadius,
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF10B981),
                size: 24,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '자동 저장 완료!',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '체성분 기록과 그래프에 반영되었어요',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.1, end: 0),

        const SizedBox(height: AppSpacing.lg),

        // 신뢰도 표시
        if (result.confidence > 0)
          _buildConfidenceCard(result.confidence, colorScheme, theme),

        const SizedBox(height: AppSpacing.lg),

        Text(
          '인식된 체성분 데이터',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        Text(
          '값이 잘못되었다면 탭해서 수정할 수 있어요',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // 측정 날짜
        if (result.measureDate != null && result.measureDate!.isNotEmpty)
          _buildResultField(
            label: '측정 날짜',
            value: result.measureDate!,
            unit: '',
            onEdit: (newValue) {
              // 날짜는 편집 불가능하도록 처리
            },
            colorScheme: colorScheme,
            theme: theme,
            isEditable: false,
            delay: 100,
          ),

        // 체중
        if (result.weight != null)
          _buildResultField(
            label: '체중',
            value: result.weight!.toStringAsFixed(1),
            unit: 'kg',
            onEdit: (newValue) => _updateField('weight', newValue),
            colorScheme: colorScheme,
            theme: theme,
            delay: 200,
          ),

        // 골격근량
        if (result.skeletalMuscle != null)
          _buildResultField(
            label: '골격근량',
            value: result.skeletalMuscle!.toStringAsFixed(1),
            unit: 'kg',
            onEdit: (newValue) => _updateField('skeletalMuscle', newValue),
            colorScheme: colorScheme,
            theme: theme,
            delay: 300,
          ),

        // 체지방량
        if (result.bodyFat != null)
          _buildResultField(
            label: '체지방량',
            value: result.bodyFat!.toStringAsFixed(1),
            unit: 'kg',
            onEdit: (newValue) => _updateField('bodyFat', newValue),
            colorScheme: colorScheme,
            theme: theme,
            delay: 400,
          ),

        // 체지방률
        if (result.bodyFatPercent != null)
          _buildResultField(
            label: '체지방률',
            value: result.bodyFatPercent!.toStringAsFixed(1),
            unit: '%',
            onEdit: (newValue) => _updateField('bodyFatPercent', newValue),
            colorScheme: colorScheme,
            theme: theme,
            delay: 500,
          ),

        // BMI
        if (result.bmi != null)
          _buildResultField(
            label: 'BMI',
            value: result.bmi!.toStringAsFixed(1),
            unit: '',
            onEdit: (newValue) => _updateField('bmi', newValue),
            colorScheme: colorScheme,
            theme: theme,
            delay: 600,
          ),

        // 기초대사량
        if (result.basalMetabolicRate != null)
          _buildResultField(
            label: '기초대사량',
            value: result.basalMetabolicRate!.toStringAsFixed(0),
            unit: 'kcal',
            onEdit: (newValue) => _updateField('basalMetabolicRate', newValue),
            colorScheme: colorScheme,
            theme: theme,
            delay: 700,
          ),

        const SizedBox(height: AppSpacing.xl),

        // 확인 버튼 (돌아가기)
        AppButton(
          label: '확인',
          onPressed: () {
            HapticUtils.success();
            context.pop();
          },
          size: AppButtonSize.lg,
          isFullWidth: true,
          icon: Icons.check,
        ).animate().fadeIn(delay: 800.ms, duration: 200.ms),

        const SizedBox(height: AppSpacing.md),

        // 다시 촬영 버튼
        AppButton(
          label: '다시 촬영하기',
          onPressed: () {
            setState(() {
              _selectedImage = null;
            });
            ref.read(inbodyOcrProvider.notifier).reset();
          },
          variant: AppButtonVariant.outline,
          size: AppButtonSize.lg,
          isFullWidth: true,
        ).animate().fadeIn(delay: 900.ms, duration: 200.ms),
      ],
    );
  }

  Widget _buildResultField({
    required String label,
    required String value,
    required String unit,
    required Function(String) onEdit,
    required ColorScheme colorScheme,
    required ThemeData theme,
    bool isEditable = true,
    required int delay,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        variant: AppCardVariant.standard,
        animationDelay: Duration(milliseconds: delay),
        onTap: isEditable
            ? () => _showEditDialog(label, value, unit, onEdit, theme)
            : null,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        value,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      if (unit.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text(
                          unit,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (isEditable)
              Icon(
                Icons.edit_outlined,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }

  /// 신뢰도 카드
  Widget _buildConfidenceCard(
    double confidence,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    final confidencePercent = (confidence * 100).toInt();
    final isHigh = confidence >= 0.8;

    return AppCard(
      variant: AppCardVariant.accent,
      child: Row(
        children: [
          Icon(
            isHigh ? Icons.check_circle : Icons.info_outline,
            color: isHigh ? colorScheme.primary : colorScheme.tertiary,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI 인식 신뢰도',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$confidencePercent%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isHigh ? colorScheme.primary : colorScheme.tertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 에러 화면
  Widget _buildErrorView(String? errorMessage, ColorScheme colorScheme, ThemeData theme) {
    final isNotInbody = errorMessage?.contains('인바디 결과지가 아닙니다') == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.xxl),

        Icon(
          isNotInbody ? Icons.image_not_supported_outlined : Icons.error_outline,
          size: 80,
          color: isNotInbody ? colorScheme.tertiary : colorScheme.error,
        ).animate().fadeIn(duration: 200.ms).scale(delay: 100.ms, duration: 200.ms),

        const SizedBox(height: AppSpacing.xl),

        Text(
          isNotInbody ? '인바디 결과지가 아니에요' : '분석에 실패했어요',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms, duration: 200.ms),

        const SizedBox(height: AppSpacing.md),

        Text(
          isNotInbody
              ? '인바디 체성분 분석 결과지 사진을 올려주세요'
              : (errorMessage ?? '알 수 없는 문제가 생겼어요'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms, duration: 200.ms),

        const SizedBox(height: AppSpacing.xxl),

        AppButton(
          label: isNotInbody ? '인바디 사진 올리기' : '다시 시도하기',
          onPressed: () {
            setState(() {
              _selectedImage = null;
            });
            ref.read(inbodyOcrProvider.notifier).reset();
          },
          size: AppButtonSize.lg,
          isFullWidth: true,
        ).animate().fadeIn(delay: 400.ms, duration: 200.ms),
      ],
    );
  }

  // ============================================================
  // 액션 메서드
  // ============================================================

  /// 이미지 선택
  Future<void> _pickImage(ImageSource source) async {
    try {
      HapticUtils.selection();

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        // 이미지 선택 후 자동으로 분석 시작
        _startAnalysis();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 선택 중 문제가 생겼어요: $e')),
      );
    }
  }

  /// AI 분석 시작
  Future<void> _startAnalysis() async {
    if (_selectedImage == null) return;

    final memberId = widget.memberId ?? ref.read(currentMemberProvider)?.id;
    if (memberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 정보를 불러올 수 없어요')),
      );
      return;
    }

    HapticUtils.selection();

    await ref.read(inbodyOcrProvider.notifier).analyzeImage(
          _selectedImage!,
          memberId,
        );
  }

  /// 필드 값 수정
  void _updateField(String fieldName, String newValue) {
    final currentResult = ref.read(inbodyOcrProvider).result;
    if (currentResult == null) return;

    final doubleValue = double.tryParse(newValue);
    if (doubleValue == null) return;

    InbodyOcrResult updatedResult;

    switch (fieldName) {
      case 'weight':
        updatedResult = currentResult.copyWith(weight: doubleValue);
        break;
      case 'skeletalMuscle':
        updatedResult = currentResult.copyWith(skeletalMuscle: doubleValue);
        break;
      case 'bodyFat':
        updatedResult = currentResult.copyWith(bodyFat: doubleValue);
        break;
      case 'bodyFatPercent':
        updatedResult = currentResult.copyWith(bodyFatPercent: doubleValue);
        break;
      case 'bmi':
        updatedResult = currentResult.copyWith(bmi: doubleValue);
        break;
      case 'basalMetabolicRate':
        updatedResult = currentResult.copyWith(basalMetabolicRate: doubleValue);
        break;
      default:
        return;
    }

    ref.read(inbodyOcrProvider.notifier).updateResult(updatedResult);
  }

  /// 편집 다이얼로그 표시
  void _showEditDialog(
    String label,
    String currentValue,
    String unit,
    Function(String) onEdit,
    ThemeData theme,
  ) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$label 수정'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: InputDecoration(
            suffixText: unit,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              onEdit(controller.text);
              Navigator.of(context).pop();
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 체성분 기록에 저장
  Future<void> _saveToRecords() async {
    final memberId = widget.memberId ?? ref.read(currentMemberProvider)?.id;
    if (memberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 정보를 불러올 수 없어요')),
      );
      return;
    }

    try {
      HapticUtils.success();

      await ref.read(inbodyOcrProvider.notifier).saveToBodyRecords(memberId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('체성분 기록에 저장했어요')),
      );

      // 기록 화면으로 돌아가기
      context.pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 중 문제가 생겼어요: $e')),
      );
    }
  }
}
