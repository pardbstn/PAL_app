import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/data/models/trainer_request_model.dart';
import 'package:flutter_pal_app/presentation/providers/trainer_request_provider.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/common/app_button.dart';
import 'package:flutter_pal_app/presentation/widgets/states/empty_state.dart';
import 'package:flutter_pal_app/presentation/widgets/states/error_state.dart';
import 'package:flutter_pal_app/presentation/widgets/trainer_request/request_card.dart';
import 'package:flutter_pal_app/presentation/widgets/animated/animated_widgets.dart';

/// 트레이너가 요청을 확인하고 답변하는 화면
class TrainerRequestsScreen extends ConsumerStatefulWidget {
  const TrainerRequestsScreen({super.key});

  @override
  ConsumerState<TrainerRequestsScreen> createState() => _TrainerRequestsScreenState();
}

class _TrainerRequestsScreenState extends ConsumerState<TrainerRequestsScreen> {
  RequestFilterType _selectedFilter = RequestFilterType.pending;

  @override
  Widget build(BuildContext context) {
    final trainer = ref.watch(currentTrainerProvider);

    if (trainer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('회원 요청')),
        body: const Center(
          child: Text('트레이너 정보를 불러올 수 없습니다.'),
        ),
      );
    }

    final trainerId = trainer.id;
    final pendingCountAsync = ref.watch(pendingRequestCountProvider(trainerId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('회원 요청'),
        actions: [
          // 대기 중인 요청 수 배지
          pendingCountAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (count) {
              if (count == 0) return const SizedBox.shrink();
              return Center(
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count개 대기',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 이번 달 수익 요약
          _RevenueSummaryCard(
            trainerId: trainerId,
          ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0),

          // 필터 탭
          _FilterTabs(
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) {
              setState(() => _selectedFilter = filter);
            },
          ),

          // 요청 목록
          Expanded(
            child: _RequestList(
              trainerId: trainerId,
              filter: _selectedFilter,
            ),
          ),
        ],
      ),
    );
  }
}

enum RequestFilterType {
  pending('대기중'),
  answered('답변완료'),
  all('전체');

  final String label;
  const RequestFilterType(this.label);
}

/// 수익 요약 카드
class _RevenueSummaryCard extends ConsumerWidget {
  final String trainerId;

  const _RevenueSummaryCard({required this.trainerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final monthlyRevenueAsync = ref.watch(trainerMonthlyRevenueProvider(trainerId));
    final pendingCountAsync = ref.watch(pendingRequestCountProvider(trainerId));

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E40AF), const Color(0xFF3B82F6)]
              : [AppTheme.primary, const Color(0xFF60A5FA)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // 이번 달 수익
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '이번 달 수익',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    monthlyRevenueAsync.when(
                      loading: () => const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      error: (_, __) => const Text(
                        '-',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      data: (revenue) => Text(
                        '${_formatPrice(revenue)}원',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 구분선
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              const SizedBox(width: 20),
              // 대기 중인 요청
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '대기 중',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    pendingCountAsync.when(
                      loading: () => const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      error: (_, __) => const Text(
                        '-',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      data: (count) => Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          AnimatedCounter(
                            value: count,
                            duration: const Duration(milliseconds: 800),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            '건',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 안내 문구
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.info_outline,
                  color: Colors.white70,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  '48시간 내 답변 시 수익이 정산됩니다',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}

/// 필터 탭
class _FilterTabs extends StatelessWidget {
  final RequestFilterType selectedFilter;
  final ValueChanged<RequestFilterType> onFilterChanged;

  const _FilterTabs({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: RequestFilterType.values.map((filter) {
          final isSelected = filter == selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter.label),
              selected: isSelected,
              onSelected: (_) => onFilterChanged(filter),
              selectedColor: AppTheme.primary.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primary : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// 요청 목록
class _RequestList extends ConsumerWidget {
  final String trainerId;
  final RequestFilterType filter;

  const _RequestList({
    required this.trainerId,
    required this.filter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(trainerPendingRequestsProvider(trainerId));

    return requestsAsync.when(
      loading: () => _buildLoadingSkeleton(context),
      error: (error, _) => ErrorState.fromError(
        error.toString(),
        onRetry: () => ref.invalidate(trainerPendingRequestsProvider(trainerId)),
      ),
      data: (requests) {
        // 필터 적용
        final filteredRequests = _filterRequests(requests, filter);

        if (filteredRequests.isEmpty) {
          return EmptyState(
            type: EmptyStateType.messages,
            customTitle: _getEmptyTitle(filter),
            customMessage: _getEmptyMessage(filter),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(trainerPendingRequestsProvider(trainerId));
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filteredRequests.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final request = filteredRequests[index];
              return RequestCard(
                request: request,
                showMemberInfo: true,
                showRevenue: true,
                onTap: () => _showResponseDialog(context, ref, request),
              ).animate().fadeIn(
                    duration: 300.ms,
                    delay: Duration(milliseconds: index * 50),
                  );
            },
          ),
        );
      },
    );
  }

  List<TrainerRequestModel> _filterRequests(
    List<TrainerRequestModel> requests,
    RequestFilterType filter,
  ) {
    switch (filter) {
      case RequestFilterType.pending:
        return requests.where((r) => r.isPending).toList();
      case RequestFilterType.answered:
        return requests.where((r) => r.isAnswered).toList();
      case RequestFilterType.all:
        return requests;
    }
  }

  String _getEmptyTitle(RequestFilterType filter) {
    switch (filter) {
      case RequestFilterType.pending:
        return '대기 중인 요청이 없습니다';
      case RequestFilterType.answered:
        return '답변한 요청이 없습니다';
      case RequestFilterType.all:
        return '요청이 없습니다';
    }
  }

  String _getEmptyMessage(RequestFilterType filter) {
    switch (filter) {
      case RequestFilterType.pending:
        return '새로운 요청이 들어오면 알려드릴게요';
      case RequestFilterType.answered:
        return '요청에 답변하면 여기에 표시됩니다';
      case RequestFilterType.all:
        return '회원의 요청이 들어오면 여기에 표시됩니다';
    }
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => Container(
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _showResponseDialog(
    BuildContext context,
    WidgetRef ref,
    TrainerRequestModel request,
  ) {
    final theme = Theme.of(context);
    final responseController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 핸들
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 요청 정보
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        request.requestType.label,
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '수익: ${request.trainerRevenue.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원',
                      style: TextStyle(
                        color: AppTheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 질문 내용
                Text(
                  '질문 내용',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(request.content),
                ),
                const SizedBox(height: 16),

                // 첨부파일
                if (request.hasAttachments) ...[
                  Text(
                    '첨부파일',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: request.attachmentUrls.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(request.attachmentUrls[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 이미 답변된 경우
                if (request.isAnswered && request.response != null) ...[
                  Text(
                    '내 답변',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.secondary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(request.response!),
                  ),
                ] else ...[
                  // 답변 입력
                  Text(
                    '답변 작성',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: responseController,
                    maxLines: 5,
                    maxLength: 2000,
                    decoration: InputDecoration(
                      hintText: '회원에게 전달할 답변을 작성해주세요.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 제출 버튼
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: isSubmitting ? '답변 전송 중...' : '답변 보내기',
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              if (responseController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('답변을 입력해주세요.')),
                                );
                                return;
                              }

                              setModalState(() => isSubmitting = true);

                              try {
                                await ref
                                    .read(trainerRequestNotifierProvider.notifier)
                                    .submitResponse(
                                      request.id,
                                      responseController.text.trim(),
                                    );

                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('답변이 전송되었습니다.'),
                                      backgroundColor: AppTheme.secondary,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('오류가 발생했습니다: $e'),
                                      backgroundColor: AppTheme.error,
                                    ),
                                  );
                                }
                              } finally {
                                setModalState(() => isSubmitting = false);
                              }
                            },
                      isLoading: isSubmitting,
                      icon: Icons.send,
                      variant: AppButtonVariant.primary,
                      size: AppButtonSize.lg,
                      isFullWidth: true,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
