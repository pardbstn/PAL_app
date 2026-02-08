import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_pal_app/core/theme/app_tokens.dart';
import 'package:flutter_pal_app/data/models/trainer_transfer_model.dart';
import 'package:flutter_pal_app/presentation/providers/trainer_transfer_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/trainer_transfer/transfer_request_dialog.dart';

/// 회원 홈 화면에 표시되는 전환 요청 대기 배너
class TransferPendingBanner extends ConsumerWidget {
  final String memberId;

  const TransferPendingBanner({
    super.key,
    required this.memberId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingTransfersAsync = ref.watch(pendingTransfersProvider(memberId));

    return pendingTransfersAsync.when(
      data: (transfers) {
        if (transfers.isEmpty) {
          return const SizedBox.shrink();
        }

        // 가장 최근 전환 요청만 표시
        final transfer = transfers.first;

        return _buildBanner(context, transfer);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildBanner(BuildContext context, TrainerTransferModel transfer) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showTransferDialog(context, transfer),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // 아이콘
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person_add_alt_1_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '새 트레이너 연결 요청',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${transfer.toTrainerName} 트레이너',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ),

            // 화살표
            Icon(
              Icons.chevron_right,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 200.ms, curve: Curves.easeOut)
          .slideY(begin: -0.05, end: 0, duration: 200.ms, curve: Curves.easeOut),
    );
  }

  void _showTransferDialog(BuildContext context, TrainerTransferModel transfer) {
    showDialog(
      context: context,
      builder: (context) => TransferRequestDialog(transfer: transfer),
    );
  }
}
