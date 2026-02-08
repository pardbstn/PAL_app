import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/core/theme/app_tokens.dart';
import 'package:flutter_pal_app/data/models/trainer_request_model.dart';

/// 트레이너 요청 카드 위젯
/// 요청 내용, 상태, 첨부파일, 답변 등을 표시
class RequestCard extends StatelessWidget {
  final TrainerRequestModel request;
  final VoidCallback? onTap;
  final bool showMemberInfo;
  final bool showRevenue;

  const RequestCard({
    super.key,
    required this.request,
    this.onTap,
    this.showMemberInfo = false,
    this.showRevenue = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.gray100,
          ),
          boxShadow: AppShadows.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단: 타입 배지 + 상태 배지 + 날짜
            _HeaderSection(
              request: request,
              showMemberInfo: showMemberInfo,
            ),
            const SizedBox(height: 12),

            // 내용 미리보기
            _ContentPreview(content: request.content),
            const SizedBox(height: 12),

            // 첨부파일 썸네일 (있는 경우)
            if (request.hasAttachments) ...[
              _AttachmentThumbnails(attachmentUrls: request.attachmentUrls),
              const SizedBox(height: 12),
            ],

            // 답변 미리보기 (답변된 경우)
            if (request.isAnswered && request.response != null) ...[
              _ResponsePreview(response: request.response!),
              const SizedBox(height: 12),
            ],

            // 하단: 가격/수익 표시
            _FooterSection(
              request: request,
              showRevenue: showRevenue,
            ),
          ],
        ),
      ),
    );
  }
}

/// 헤더 섹션 (타입, 상태, 날짜)
class _HeaderSection extends StatelessWidget {
  final TrainerRequestModel request;
  final bool showMemberInfo;

  const _HeaderSection({
    required this.request,
    required this.showMemberInfo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // 요청 타입 배지
        _RequestTypeBadge(type: request.requestType),
        const SizedBox(width: 8),
        // 상태 배지
        _StatusBadge(status: request.status),
        const Spacer(),
        // 날짜
        Text(
          _formatDate(request.createdAt),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}시간 전';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}일 전';
    } else {
      return DateFormat('M/d').format(date);
    }
  }
}

/// 요청 타입 배지
class _RequestTypeBadge extends StatelessWidget {
  final RequestType type;

  const _RequestTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final icon = type == RequestType.question
        ? Icons.help_outline
        : type == RequestType.formCheck
            ? Icons.videocam_outlined
            : Icons.calendar_month;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppTheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            type.label,
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// 상태 배지
class _StatusBadge extends StatelessWidget {
  final RequestStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    final icon = _getStatusIcon(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return AppTheme.tertiary;
      case RequestStatus.answered:
        return AppTheme.secondary;
      case RequestStatus.expired:
        return AppTheme.error;
    }
  }

  IconData _getStatusIcon(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return Icons.access_time;
      case RequestStatus.answered:
        return Icons.check_circle_outline;
      case RequestStatus.expired:
        return Icons.error_outline;
    }
  }
}

/// 내용 미리보기
class _ContentPreview extends StatelessWidget {
  final String content;

  const _ContentPreview({required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      content,
      style: theme.textTheme.bodyMedium,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// 첨부파일 썸네일
class _AttachmentThumbnails extends StatelessWidget {
  final List<String> attachmentUrls;

  const _AttachmentThumbnails({required this.attachmentUrls});

  @override
  Widget build(BuildContext context) {
    final displayCount = attachmentUrls.length > 4 ? 4 : attachmentUrls.length;
    final remainingCount = attachmentUrls.length - displayCount;

    return Row(
      children: [
        // 썸네일들
        ...attachmentUrls.take(displayCount).map((url) {
          final isVideo = url.endsWith('.mp4') || url.endsWith('.mov');
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _ThumbnailItem(
              url: url,
              isVideo: isVideo,
            ),
          );
        }),
        // 더 있는 경우 카운트 표시
        if (remainingCount > 0)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '+$remainingCount',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ThumbnailItem extends StatelessWidget {
  final String url;
  final bool isVideo;

  const _ThumbnailItem({
    required this.url,
    required this.isVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        image: !isVideo
            ? DecorationImage(
                image: NetworkImage(url),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: isVideo
          ? Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            )
          : null,
    );
  }
}

/// 답변 미리보기
class _ResponsePreview extends StatelessWidget {
  final String response;

  const _ResponsePreview({required this.response});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.secondary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.secondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 12,
              color: AppTheme.secondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '트레이너 답변',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  response,
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 푸터 섹션 (가격/수익)
class _FooterSection extends StatelessWidget {
  final TrainerRequestModel request;
  final bool showRevenue;

  const _FooterSection({
    required this.request,
    required this.showRevenue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 만료 시간 경고 (대기 중인 경우)
        if (request.isPending) ...[
          _ExpiryWarning(createdAt: request.createdAt),
        ] else ...[
          const SizedBox.shrink(),
        ],
        // 가격 또는 수익 표시
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            showRevenue
                ? '수익: ${_formatPrice(request.trainerRevenue)}원'
                : request.priceText,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: showRevenue ? AppTheme.secondary : AppTheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}

/// 만료 경고
class _ExpiryWarning extends StatelessWidget {
  final DateTime createdAt;

  const _ExpiryWarning({required this.createdAt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hoursRemaining = 48 - DateTime.now().difference(createdAt).inHours;

    if (hoursRemaining <= 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error,
            size: 14,
            color: AppTheme.error,
          ),
          const SizedBox(width: 4),
          Text(
            '만료됨',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    final isUrgent = hoursRemaining <= 12;
    final color = isUrgent ? AppTheme.error : AppTheme.tertiary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '$hoursRemaining시간 남음',
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// 요청 카드 스켈레톤 (로딩용)
class RequestCardSkeleton extends StatelessWidget {
  const RequestCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.gray100,
        ),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 스켈레톤
          Row(
            children: [
              Container(
                width: 80,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 60,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const Spacer(),
              Container(
                width: 50,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 내용 스켈레톤
          Container(
            width: double.infinity,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 200,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          // 푸터 스켈레톤
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 80,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              Container(
                width: 70,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
