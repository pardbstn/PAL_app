import 'dart:typed_data';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../data/models/inbody_record_model.dart';
import '../../../data/services/ai_service.dart';
import '../../providers/inbody_provider.dart';

/// 회원 인바디 화면
/// 최근 인바디 결과, 체성분 차트, 히스토리 표시
/// AI 사진 분석을 통해 인바디 결과지를 자동으로 입력
class MemberInbodyScreen extends ConsumerWidget {
  final String memberId;
  final String? memberName;

  const MemberInbodyScreen({
    super.key,
    required this.memberId,
    this.memberName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestAsync = ref.watch(latestInbodyProvider(memberId));
    final historyAsync = ref.watch(inbodyHistoryProvider(memberId));

    return Scaffold(
      appBar: AppBar(
        title: Text(memberName != null ? '$memberName 인바디' : '인바디 기록'),
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(latestInbodyProvider(memberId));
          ref.invalidate(inbodyHistoryProvider(memberId));
        },
        child: latestAsync.when(
          loading: () => const _InbodyScreenSkeleton(),
          error: (e, st) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('문제가 생겼어요\n$e'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    ref.invalidate(latestInbodyProvider(memberId));
                  },
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
          data: (latest) {
            if (latest == null) {
              return _buildEmptyState(context, ref);
            }
            return _buildContent(context, ref, latest, historyAsync);
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: AppNavGlass.fabBottomPadding),
        child: FloatingActionButton.extended(
          onPressed: () => _showImageSourceDialog(context, ref),
          icon: const Icon(Icons.camera_alt),
          label: const Text('인바디 촬영'),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assessment_outlined,
            size: 80,
            color: colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            '인바디 기록이 없어요',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '인바디 결과지를 촬영하여 기록을 추가해 보세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.construction,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '인바디 연동 기능 추가 예정',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => _showImageSourceDialog(context, ref),
            icon: const Icon(Icons.camera_alt),
            label: const Text('인바디 촬영'),
          ),
        ],
      ).animate().fadeIn(duration: 200.ms),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    InbodyRecordModel latest,
    AsyncValue<List<InbodyRecordModel>> historyAsync,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 최신 인바디 결과 카드
          _InbodyResultCard(record: latest)
              .animate()
              .fadeIn(duration: 200.ms)
              .slideY(begin: 0.02, end: 0),

          const SizedBox(height: 24),

          // 체성분 도넛 차트
          _BodyCompositionChart(record: latest)
              .animate()
              .fadeIn(duration: 200.ms, delay: 50.ms)
              .slideY(begin: 0.02, end: 0),

          const SizedBox(height: 24),

          // 히스토리 그래프
          historyAsync.when(
            loading: () => const _ChartSkeleton(),
            error: (e, st) => const SizedBox.shrink(),
            data: (history) {
              if (history.length < 2) {
                return const SizedBox.shrink();
              }
              return _InbodyHistoryChart(records: history)
                  .animate()
                  .fadeIn(duration: 200.ms, delay: 100.ms)
                  .slideY(begin: 0.02, end: 0);
            },
          ),

          const SizedBox(height: 24),

          // 히스토리 리스트
          _buildHistorySection(context, ref, historyAsync),

          const SizedBox(height: 80), // FAB 공간
        ],
      ),
    );
  }

  Widget _buildHistorySection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<InbodyRecordModel>> historyAsync,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '측정 기록',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        historyAsync.when(
          loading: () => const _HistoryListSkeleton(),
          error: (e, st) => Text('오류: $e'),
          data: (history) {
            if (history.isEmpty) {
              return const Text('기록이 없어요');
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final record = history[index];
                return _InbodyHistoryTile(
                  record: record,
                  onDelete: () => _deleteRecord(context, ref, record),
                ).animate().fadeIn(
                      duration: 200.ms,
                      delay: Duration(milliseconds: 50 * index),
                    );
              },
            );
          },
        ),
      ],
    );
  }

  /// 이미지 소스 선택 다이얼로그 표시
  void _showImageSourceDialog(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '인바디 결과지 촬영',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'AI가 결과지를 분석하여 자동으로 기록합니다',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                title: const Text('카메라로 촬영'),
                subtitle: const Text('인바디 결과지를 직접 촬영합니다'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndAnalyzeImage(context, ref, ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                title: const Text('갤러리에서 선택'),
                subtitle: const Text('저장된 인바디 결과지 사진을 불러옵니다'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndAnalyzeImage(context, ref, ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// 이미지 선택 및 AI 분석
  Future<void> _pickAndAnalyzeImage(
    BuildContext context,
    WidgetRef ref,
    ImageSource source,
  ) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, imageQuality: 85);
    if (image == null) return;

    if (!context.mounted) return;

    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              '인바디 결과지를 분석 중입니다...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'AI가 사진에서 데이터를 추출하고 있어요',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      ),
    );

    try {
      // 1. Supabase Storage에 업로드
      // iPad 호환성을 위해 XFile에서 바이트로 직접 읽어서 업로드
      final supabase = Supabase.instance.client;
      final Uint8List imageBytes = await image.readAsBytes();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$memberId/$timestamp.jpg';

      await supabase.storage.from('inbody-images').uploadBinary(
            fileName,
            imageBytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      final imageUrl =
          supabase.storage.from('inbody-images').getPublicUrl(fileName);

      // 2. AI 분석 호출
      final notifier = ref.read(inbodyAnalysisProvider.notifier);
      final result = await notifier.analyzeInbodyImage(
        memberId: memberId,
        imageUrl: imageUrl,
      );

      if (!context.mounted) return;
      Navigator.of(context).pop(); // 로딩 다이얼로그 닫기

      if (result.success) {
        // 성공 시 분석 결과 다이얼로그 표시
        _showAnalysisResultDialog(context, ref, result);
      } else {
        // 에러 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? '분석에 실패했어요'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } on StorageException catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미지 업로드 실패: ${e.message}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('문제가 생겼어요: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// AI 분석 결과 다이얼로그 표시
  void _showAnalysisResultDialog(
    BuildContext context,
    WidgetRef ref,
    InbodyAnalysisResult result,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final analysis = result.analysis;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('분석 완료'),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '인바디 결과지에서 추출된 데이터입니다.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
              ),
              const SizedBox(height: 16),
              if (analysis != null) ...[
                _buildAnalysisRow(
                  context,
                  '체중',
                  analysis.weight != null
                      ? '${analysis.weight!.toStringAsFixed(1)} kg'
                      : '-',
                  Icons.monitor_weight_outlined,
                  colorScheme.primary,
                ),
                _buildAnalysisRow(
                  context,
                  '골격근량',
                  analysis.skeletalMuscleMass != null
                      ? '${analysis.skeletalMuscleMass!.toStringAsFixed(1)} kg'
                      : '-',
                  Icons.fitness_center,
                  Colors.green,
                ),
                _buildAnalysisRow(
                  context,
                  '체지방률',
                  analysis.bodyFatPercent != null
                      ? '${analysis.bodyFatPercent!.toStringAsFixed(1)} %'
                      : '-',
                  Icons.water_drop_outlined,
                  Colors.orange,
                ),
                _buildAnalysisRow(
                  context,
                  '체지방량',
                  analysis.bodyFatMass != null
                      ? '${analysis.bodyFatMass!.toStringAsFixed(1)} kg'
                      : '-',
                  Icons.pie_chart_outline,
                  Colors.orange.shade300,
                ),
                _buildAnalysisRow(
                  context,
                  'BMI',
                  analysis.bmi != null
                      ? analysis.bmi!.toStringAsFixed(1)
                      : '-',
                  Icons.straighten,
                  Colors.blue,
                ),
                if (analysis.basalMetabolicRate != null)
                  _buildAnalysisRow(
                    context,
                    '기초대사량',
                    '${analysis.basalMetabolicRate!.toStringAsFixed(0)} kcal',
                    Icons.local_fire_department,
                    Colors.red,
                  ),
                if (analysis.inbodyScore != null)
                  _buildAnalysisRow(
                    context,
                    '인바디 점수',
                    '${analysis.inbodyScore}점',
                    Icons.star,
                    Colors.amber,
                  ),
              ] else
                const Text('분석 데이터를 불러올 수 없어요.'),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 프로바이더 갱신
              ref.invalidate(latestInbodyProvider(memberId));
              ref.invalidate(inbodyHistoryProvider(memberId));
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 분석 결과 행 빌더
  Widget _buildAnalysisRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  /// 인바디 기록 삭제
  Future<void> _deleteRecord(
    BuildContext context,
    WidgetRef ref,
    InbodyRecordModel record,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기록 삭제'),
        content: const Text('이 인바디 기록을 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final notifier = ref.read(inbodyNotifierProvider.notifier);
      final success = await notifier.deleteRecord(memberId, record.id);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('기록이 삭제됐어요'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

/// 최신 인바디 결과 카드
class _InbodyResultCard extends StatelessWidget {
  final InbodyRecordModel record;

  const _InbodyResultCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.gray100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '최근 측정 결과',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatDate(record.measuredAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    context,
                    '체중',
                    '${record.weight.toStringAsFixed(1)}kg',
                    Icons.monitor_weight_outlined,
                    colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    context,
                    '골격근량',
                    '${record.skeletalMuscleMass.toStringAsFixed(1)}kg',
                    Icons.fitness_center,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    context,
                    '체지방률',
                    '${record.bodyFatPercent.toStringAsFixed(1)}%',
                    Icons.water_drop_outlined,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            if (record.inbodyScore != null) ...[
              const Divider(height: 32),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '인바디 점수',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Text(
                    '${record.inbodyScore}점',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
  }
}

/// 체성분 도넛 차트
class _BodyCompositionChart extends StatelessWidget {
  final InbodyRecordModel record;

  const _BodyCompositionChart({required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 체성분 비율 계산
    final totalWeight = record.weight;
    final fatMass =
        record.bodyFatMass ?? (totalWeight * record.bodyFatPercent / 100);
    final muscleMass = record.skeletalMuscleMass;
    final otherMass = totalWeight - fatMass - muscleMass;

    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.gray100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '체성분 분석',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(
                            value: muscleMass,
                            title:
                                '${(muscleMass / totalWeight * 100).toStringAsFixed(0)}%',
                            color: Colors.green,
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: fatMass,
                            title:
                                '${(fatMass / totalWeight * 100).toStringAsFixed(0)}%',
                            color: Colors.orange,
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: otherMass > 0 ? otherMass : 0,
                            title:
                                '${(otherMass / totalWeight * 100).toStringAsFixed(0)}%',
                            color: Colors.blue,
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem(
                        '골격근량',
                        '${muscleMass.toStringAsFixed(1)}kg',
                        Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _buildLegendItem(
                        '체지방량',
                        '${fatMass.toStringAsFixed(1)}kg',
                        Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _buildLegendItem(
                        '기타',
                        '${otherMass.toStringAsFixed(1)}kg',
                        Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 히스토리 라인 차트
class _InbodyHistoryChart extends StatelessWidget {
  final List<InbodyRecordModel> records;

  const _InbodyHistoryChart({required this.records});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 날짜순 정렬 (오래된 것 먼저)
    final sortedRecords = List<InbodyRecordModel>.from(records)
      ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));

    // 최근 10개만 표시
    final displayRecords = sortedRecords.length > 10
        ? sortedRecords.sublist(sortedRecords.length - 10)
        : sortedRecords;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '변화 추이',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildChartLegend('체중', colorScheme.primary),
                const SizedBox(width: 16),
                _buildChartLegend('골격근량', Colors.green),
                const SizedBox(width: 16),
                _buildChartLegend('체지방률', Colors.orange),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 10,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: colorScheme.outline.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < displayRecords.length) {
                            final date = displayRecords[index].measuredAt;
                            return Text(
                              '${date.month}/${date.day}',
                              style: TextStyle(
                                fontSize: 10,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            );
                          }
                          return const Text('');
                        },
                        interval: 1,
                        reservedSize: 24,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    // 체중 라인
                    LineChartBarData(
                      spots: displayRecords.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value.weight);
                      }).toList(),
                      isCurved: true,
                      color: colorScheme.primary,
                      barWidth: 2,
                      dotData: const FlDotData(show: true),
                    ),
                    // 골격근량 라인
                    LineChartBarData(
                      spots: displayRecords.asMap().entries.map((e) {
                        return FlSpot(
                            e.key.toDouble(), e.value.skeletalMuscleMass);
                      }).toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 2,
                      dotData: const FlDotData(show: true),
                    ),
                    // 체지방률 라인
                    LineChartBarData(
                      spots: displayRecords.asMap().entries.map((e) {
                        return FlSpot(
                            e.key.toDouble(), e.value.bodyFatPercent);
                      }).toList(),
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 2,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }
}

/// 히스토리 타일
class _InbodyHistoryTile extends StatelessWidget {
  final InbodyRecordModel record;
  final VoidCallback onDelete;

  const _InbodyHistoryTile({
    required this.record,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${record.measuredAt.day}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                '${record.measuredAt.month}월',
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        title: Text(
          '${record.weight.toStringAsFixed(1)}kg',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '골격근 ${record.skeletalMuscleMass.toStringAsFixed(1)}kg · '
          '체지방 ${record.bodyFatPercent.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: onDelete,
          color: colorScheme.error,
        ),
      ),
    );
  }
}

/// 스켈레톤 로딩
class _InbodyScreenSkeleton extends StatelessWidget {
  const _InbodyScreenSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 240,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartSkeleton extends StatelessWidget {
  const _ChartSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class _HistoryListSkeleton extends StatelessWidget {
  const _HistoryListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
