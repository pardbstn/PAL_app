import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_pal_app/core/theme/app_tokens.dart';
import 'package:flutter_pal_app/core/utils/animation_utils.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/common/app_card.dart';
import 'package:flutter_pal_app/presentation/widgets/common/app_button.dart';
import 'package:flutter_pal_app/presentation/widgets/common/app_section.dart';

/// 회원 데이터 관리 화면
/// 과거 트레이너와의 데이터를 조회하고 삭제할 수 있습니다.
class DataManagementScreen extends ConsumerStatefulWidget {
  const DataManagementScreen({super.key});

  @override
  ConsumerState<DataManagementScreen> createState() =>
      _DataManagementScreenState();
}

class _DataManagementScreenState extends ConsumerState<DataManagementScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _pastTrainers = [];

  @override
  void initState() {
    super.initState();
    _loadPastTrainers();
  }

  /// 과거 트레이너 데이터 로드
  Future<void> _loadPastTrainers() async {
    setState(() => _isLoading = true);

    try {
      final authState = ref.read(authProvider);
      final userId = authState.userId;

      if (userId == null || userId.isEmpty) {
        throw Exception('사용자 정보를 찾을 수 없어요');
      }

      // TODO: 실제로는 Firestore에서 과거 트레이너 데이터를 조회해야 함
      // 현재는 더미 데이터로 대체
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _pastTrainers = [];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('데이터 로드 실패: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// 트레이너 데이터 삭제
  Future<void> _deleteTrainerData(String trainerId, String trainerName) async {
    final confirmed = await _showDeleteConfirmDialog(trainerName);
    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final authState = ref.read(authProvider);
      final userId = authState.userId;

      if (userId == null || userId.isEmpty) {
        throw Exception('사용자 정보를 찾을 수 없어요');
      }

      // deleteUserTrainerData Cloud Function 호출
      final callable = FirebaseFunctions.instance.httpsCallable(
        'deleteUserTrainerData',
      );

      await callable.call({
        'userId': userId,
        'trainerId': trainerId,
      });

      if (!mounted) return;

      // 목록에서 제거
      setState(() {
        _pastTrainers.removeWhere((t) => t['id'] == trainerId);
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('트레이너 데이터를 삭제했어요'),
          backgroundColor: const Color(0xFF00C471),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('삭제 실패: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// 삭제 확인 다이얼로그
  Future<bool?> _showDeleteConfirmDialog(String trainerName) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('데이터 삭제'),
        content: Text(
          '이 트레이너와의 기록을 삭제할까요?\n\n'
          '커리큘럼과 일정이 삭제되고, 체성분/식단 기록은 유지돼요.',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제하기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 데이터 관리'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_pastTrainers.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // 설명
        AppSection(
          title: '과거 트레이너 데이터',
          animationDelay: 0.ms,
          child: Text(
            '더 이상 필요하지 않은 트레이너의 데이터를 삭제할 수 있어요.\n'
            '커리큘럼과 일정이 삭제되며, 체성분과 식단 기록은 유지돼요.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray600,
              height: 1.5,
            ),
          ).animatePremiumEntrance(),
        ),
        const SizedBox(height: AppSpacing.xl),

        // 트레이너 목록
        ..._pastTrainers.asMap().entries.map((entry) {
          final index = entry.key;
          final trainer = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _buildTrainerCard(trainer, index),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.folder_open_rounded,
              size: 64,
              color: AppColors.gray400,
            ),
          ).animatePremiumEntrance(),
          const SizedBox(height: AppSpacing.xl),
          Text(
            '관리할 데이터가 없어요',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ).animatePremiumEntrance(delay: const Duration(milliseconds: 100)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '과거 트레이너와의 데이터가 여기에 표시돼요',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray500,
            ),
          ).animatePremiumEntrance(delay: const Duration(milliseconds: 150)),
        ],
      ),
    );
  }

  Widget _buildTrainerCard(Map<String, dynamic> trainer, int index) {
    final name = trainer['name'] as String? ?? '트레이너';
    final trainerId = trainer['id'] as String;
    final period = trainer['period'] as String? ?? '-';
    final recordCount = trainer['recordCount'] as int? ?? 0;

    return AppCard(
      variant: AppCardVariant.elevated,
      animate: true,
      animationDelay: Duration(milliseconds: 100 + (index * 50)),
      child: Row(
        children: [
          // 트레이너 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '기간: $period',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.gray600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '기록 수: $recordCount개',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),

          // 삭제 버튼
          AppButton(
            label: '삭제하기',
            variant: AppButtonVariant.outline,
            size: AppButtonSize.sm,
            onPressed: () => _deleteTrainerData(trainerId, name),
          ),
        ],
      ),
    );
  }
}
