import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_pal_app/data/models/insight_model.dart';
import '../glass_card.dart';

/// AI 인사이트 카드 위젯
/// 스와이프 제스처로 읽음 처리/삭제 지원
/// 우선순위별 색상 표시와 애니메이션 효과 적용
class InsightCard extends StatelessWidget {
  /// 인사이트 데이터
  final InsightModel insight;

  /// 카드 탭 콜백
  final VoidCallback? onTap;

  /// 읽음 처리 콜백 (왼쪽 스와이프)
  final VoidCallback? onMarkRead;

  /// 삭제 콜백 (오른쪽 스와이프)
  final VoidCallback? onDelete;

  /// 애니메이션 인덱스 (시차 애니메이션용)
  final int animationIndex;

  const InsightCard({
    super.key,
    required this.insight,
    this.onTap,
    this.onMarkRead,
    this.onDelete,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(insight.id),
      // 왼쪽 스와이프 → 읽음 처리
      background: _buildSwipeBackground(
        alignment: Alignment.centerLeft,
        color: const Color(0xFF10B981), // success 색상
        icon: Icons.done,
        label: '읽음',
      ),
      // 오른쪽 스와이프 → 삭제
      secondaryBackground: _buildSwipeBackground(
        alignment: Alignment.centerRight,
        color: const Color(0xFFEF4444), // error 색상
        icon: Icons.delete_outline,
        label: '삭제',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // 왼쪽 → 오른쪽 스와이프: 읽음 처리
          onMarkRead?.call();
          return false; // 카드를 유지
        } else if (direction == DismissDirection.endToStart) {
          // 오른쪽 → 왼쪽 스와이프: 삭제 확인
          return await _showDeleteConfirmation(context);
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete?.call();
        }
      },
      child: _InsightCardContent(
        insight: insight,
        onTap: onTap,
      ),
    )
        .animate(delay: Duration(milliseconds: 50 * animationIndex))
        .fadeIn(duration: 400.ms, curve: Curves.easeOut)
        .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  /// 스와이프 배경 위젯
  Widget _buildSwipeBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: alignment == Alignment.centerLeft
            ? [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ]
            : [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: Colors.white),
              ],
      ),
    );
  }

  /// 삭제 확인 다이얼로그
  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('인사이트 삭제'),
            content: const Text('이 인사이트를 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                ),
                child: const Text('삭제'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

/// 인사이트 카드 내용 위젯
class _InsightCardContent extends StatelessWidget {
  final InsightModel insight;
  final VoidCallback? onTap;

  const _InsightCardContent({
    required this.insight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          padding: EdgeInsets.zero,
          borderRadius: 16,
          child: IntrinsicHeight(
            child: Row(
              children: [
                // 왼쪽 우선순위 색상 바
                _buildPriorityBar(),

                // 메인 컨텐츠
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 상단: 타입 아이콘 + 제목 + AI 배지 + 읽지 않음 표시
                        _buildHeader(colorScheme),
                        const SizedBox(height: 8),

                        // 중간: 메시지 (최대 2줄)
                        _buildMessage(colorScheme),
                        const SizedBox(height: 12),

                        // 하단: 회원 이름 + 상대 시간
                        _buildFooter(colorScheme),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 우선순위 색상 바 (왼쪽)
  Widget _buildPriorityBar() {
    return Container(
      width: 4,
      decoration: BoxDecoration(
        color: insight.priorityColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
    );
  }

  /// 상단 헤더 (타입 아이콘, 제목, AI 배지, 읽지 않음 표시)
  Widget _buildHeader(ColorScheme colorScheme) {
    return Row(
      children: [
        // 타입 아이콘
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: insight.priorityColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            insight.typeIcon,
            size: 16,
            color: insight.priorityColor,
          ),
        ),
        const SizedBox(width: 10),

        // 제목
        Expanded(
          child: Text(
            insight.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // AI 배지
        _buildAiBadge(),

        // 읽지 않음 표시
        if (!insight.isRead) ...[
          const SizedBox(width: 8),
          _buildUnreadDot(),
        ],
      ],
    );
  }

  /// AI 배지
  Widget _buildAiBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 10,
            color: Colors.white,
          ),
          SizedBox(width: 2),
          Text(
            'AI',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// 읽지 않음 표시 (빨간 점)
  Widget _buildUnreadDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Color(0xFFEF4444),
        shape: BoxShape.circle,
      ),
    );
  }

  /// 메시지 내용 (최대 2줄)
  Widget _buildMessage(ColorScheme colorScheme) {
    return Text(
      insight.message,
      style: TextStyle(
        fontSize: 13,
        color: colorScheme.onSurfaceVariant,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 하단 푸터 (회원 이름 + 상대 시간)
  Widget _buildFooter(ColorScheme colorScheme) {
    return Row(
      children: [
        // 회원 이름 (있는 경우)
        if (insight.isMemberRelated && insight.memberName != null) ...[
          Icon(
            Icons.person_outline,
            size: 14,
            color: colorScheme.outline,
          ),
          const SizedBox(width: 4),
          Text(
            insight.memberName!,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.outline,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
        ],

        // 상대 시간
        Icon(
          Icons.access_time,
          size: 14,
          color: colorScheme.outline,
        ),
        const SizedBox(width: 4),
        Text(
          _getRelativeTime(insight.createdAt),
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.outline,
          ),
        ),

        const Spacer(),

        // 조치 필요 표시 (actionSuggestion이 있고 아직 조치하지 않은 경우)
        if (insight.needsAttention && insight.actionSuggestion != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app,
                  size: 12,
                  color: Color(0xFFF59E0B),
                ),
                SizedBox(width: 4),
                Text(
                  '조치 필요',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// 상대 시간 계산
  /// 방금 전, 5분 전, 2시간 전, 3일 전 등
  String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) {
      return '방금 전';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}시간 전';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}일 전';
    } else if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return '$weeks주 전';
    } else if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return '$months개월 전';
    } else {
      final years = (diff.inDays / 365).floor();
      return '$years년 전';
    }
  }
}

/// 컴팩트 버전 인사이트 카드 (대시보드 등에서 사용)
class InsightCardCompact extends StatelessWidget {
  final InsightModel insight;
  final VoidCallback? onTap;
  final int animationIndex;

  const InsightCardCompact({
    super.key,
    required this.insight,
    this.onTap,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: insight.priorityColor,
              width: 3,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 타입 아이콘
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: insight.priorityColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                insight.typeIcon,
                size: 16,
                color: insight.priorityColor,
              ),
            ),
            const SizedBox(width: 12),

            // 제목 + 메시지
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    insight.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    insight.message,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 읽지 않음 표시
            if (!insight.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 50 * animationIndex))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.1, end: 0, duration: 300.ms);
  }
}
