import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_pal_app/core/theme/app_tokens.dart';
import 'package:flutter_pal_app/core/utils/animation_utils.dart';
import 'package:flutter_pal_app/data/models/trainer_transfer_model.dart';
import 'package:flutter_pal_app/presentation/providers/trainer_transfer_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/common/app_button.dart';
import 'package:flutter_pal_app/presentation/widgets/common/app_card.dart';

/// 회원에게 보여지는 트레이너 전환 요청 수락/거절 다이얼로그
class TransferRequestDialog extends ConsumerStatefulWidget {
  final TrainerTransferModel transfer;

  const TransferRequestDialog({
    super.key,
    required this.transfer,
  });

  @override
  ConsumerState<TransferRequestDialog> createState() =>
      _TransferRequestDialogState();
}

class _TransferRequestDialogState extends ConsumerState<TransferRequestDialog> {
  bool _isProcessing = false;

  /// 전환 요청 수락
  Future<void> _handleAccept() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      await ref
          .read(trainerTransferNotifierProvider.notifier)
          .acceptTransfer(widget.transfer.id);

      if (!mounted) return;

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('트레이너 연결을 수락했어요'),
          backgroundColor: const Color(0xFF00C471),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('수락에 실패했어요'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// 전환 요청 거절
  Future<void> _handleReject() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      await ref
          .read(trainerTransferNotifierProvider.notifier)
          .rejectTransfer(widget.transfer.id);

      if (!mounted) return;

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('트레이너 연결을 거절했어요'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('거절에 실패했어요'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 타이틀
            Text(
              '새 트레이너 연결 요청',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ).animatePremiumEntrance(),
            const SizedBox(height: AppSpacing.lg),

            // 본문
            Text(
              '${widget.transfer.toTrainerName} 트레이너가 연결 요청을 보냈어요',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
            ).animatePremiumEntrance(delay: const Duration(milliseconds: 50)),
            const SizedBox(height: AppSpacing.lg),

            // 안내 카드
            AppCard(
              variant: AppCardVariant.standard,
              padding: const EdgeInsets.all(AppSpacing.md),
              animate: true,
              animationDelay: const Duration(milliseconds: 100),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '수락하면 회원 정보가 새 트레이너에게 공유돼요',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.gray400 : AppColors.gray700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 버튼
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: '거절하기',
                    variant: AppButtonVariant.outline,
                    onPressed: _isProcessing ? null : _handleReject,
                    isLoading: false,
                  )
                      .animatePremiumEntrance(
                          delay: const Duration(milliseconds: 150))
                      .animate(delay: 150.ms)
                      .fadeIn(duration: 200.ms)
                      .slideX(begin: -0.05, end: 0),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    label: '수락하기',
                    variant: AppButtonVariant.primary,
                    onPressed: _isProcessing ? null : _handleAccept,
                    isLoading: _isProcessing,
                  )
                      .animatePremiumEntrance(
                          delay: const Duration(milliseconds: 200))
                      .animate(delay: 200.ms)
                      .fadeIn(duration: 200.ms)
                      .slideX(begin: 0.05, end: 0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
