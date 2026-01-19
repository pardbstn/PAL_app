import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/data/models/session_signature_model.dart';
import 'package:flutter_pal_app/data/repositories/session_signature_repository.dart';
import 'package:flutter_pal_app/presentation/widgets/session_complete_dialog.dart';

// ============================================================================
// Providers
// ============================================================================

/// 회원의 서명 기록 목록 Provider
final memberSignaturesProvider =
    StreamProvider.family<List<SessionSignatureModel>, String>(
        (ref, memberId) {
  final repo = ref.watch(sessionSignatureRepositoryProvider);
  return repo.watchByMemberId(memberId);
});

// ============================================================================
// Screen
// ============================================================================

/// 서명 기록 열람 화면
/// 회원별 전체 서명 기록 리스트
class SessionSignaturesScreen extends ConsumerWidget {
  final String memberId;
  final String memberName;

  const SessionSignaturesScreen({
    super.key,
    required this.memberId,
    required this.memberName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signaturesAsync = ref.watch(memberSignaturesProvider(memberId));

    return Scaffold(
      appBar: AppBar(
        title: Text('$memberName 서명 기록'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: signaturesAsync.when(
        loading: () => _buildShimmerLoading(),
        error: (error, _) => _buildErrorView(context, ref, error),
        data: (signatures) {
          if (signatures.isEmpty) {
            return _buildEmptyView();
          }
          return _buildSignatureList(context, signatures);
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
            ),
            const SizedBox(height: 16),
            const Text(
              '서명 기록을 불러오지 못했습니다',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(memberSignaturesProvider(memberId)),
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.draw_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '아직 서명 기록이 없습니다',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '수업 완료 시 서명을 받으면 여기에 표시됩니다',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignatureList(
    BuildContext context,
    List<SessionSignatureModel> signatures,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: signatures.length,
      itemBuilder: (context, index) {
        final signature = signatures[index];
        return _SignatureCard(
          signature: signature,
          onTap: () => SignatureViewDialog.show(context, signature: signature),
        );
      },
    );
  }
}

// ============================================================================
// Signature Card
// ============================================================================

class _SignatureCard extends StatelessWidget {
  final SessionSignatureModel signature;
  final VoidCallback onTap;

  const _SignatureCard({
    required this.signature,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 서명 썸네일
            Container(
              width: 80,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: signature.signatureImageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${signature.sessionNumber}회차',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    signature.signedDateFormatted,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    signature.signedTimeFormatted,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  if (signature.memo != null && signature.memo!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      signature.memo!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 화살표
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
