import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/data/models/trainer_request_model.dart';
import 'package:flutter_pal_app/presentation/providers/trainer_request_provider.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/providers/subscription_provider.dart';
import 'package:flutter_pal_app/data/models/subscription_model.dart';
import 'package:flutter_pal_app/presentation/widgets/common/app_button.dart';
import 'package:flutter_pal_app/presentation/widgets/states/empty_state.dart';
import 'package:flutter_pal_app/presentation/widgets/states/error_state.dart';
import 'package:flutter_pal_app/presentation/widgets/trainer_request/request_card.dart';

/// 회원이 트레이너에게 질문하는 화면
class TrainerQuestionScreen extends ConsumerStatefulWidget {
  const TrainerQuestionScreen({super.key});

  @override
  ConsumerState<TrainerQuestionScreen> createState() => _TrainerQuestionScreenState();
}

class _TrainerQuestionScreenState extends ConsumerState<TrainerQuestionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final member = ref.watch(currentMemberProvider);

    if (member == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('트레이너에게 질문')),
        body: const Center(
          child: Text('회원 정보를 불러올 수 없어요'),
        ),
      );
    }

    final memberId = member.id;
    final trainerId = member.trainerId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('트레이너에게 질문'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '새 질문'),
            Tab(text: '질문 내역'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 새 질문 탭
          _NewQuestionTab(
            memberId: memberId,
            trainerId: trainerId,
            onSubmitSuccess: () {
              // 제출 성공 시 질문 내역 탭으로 이동
              _tabController.animateTo(1);
            },
          ),
          // 질문 내역 탭
          _RequestHistoryTab(memberId: memberId),
        ],
      ),
    );
  }
}

/// 새 질문 탭
class _NewQuestionTab extends ConsumerStatefulWidget {
  final String memberId;
  final String trainerId;
  final VoidCallback onSubmitSuccess;

  const _NewQuestionTab({
    required this.memberId,
    required this.trainerId,
    required this.onSubmitSuccess,
  });

  @override
  ConsumerState<_NewQuestionTab> createState() => _NewQuestionTabState();
}

class _NewQuestionTabState extends ConsumerState<_NewQuestionTab> {
  RequestType _selectedType = RequestType.question;
  final _contentController = TextEditingController();
  final List<XFile> _attachments = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _attachments.addAll(pickedFiles.take(5 - _attachments.length));
      });
    }
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(source: ImageSource.gallery);

    if (video != null && _attachments.length < 5) {
      setState(() {
        _attachments.add(video);
      });
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  Future<void> _submitRequest() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('질문 내용을 입력해주세요')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // TODO: 첨부파일 업로드 로직 추가
      final attachmentUrls = <String>[];

      final requestId = await ref.read(trainerRequestNotifierProvider.notifier).createRequest(
        memberId: widget.memberId,
        trainerId: widget.trainerId,
        requestType: _selectedType,
        content: _contentController.text.trim(),
        attachmentUrls: attachmentUrls,
      );

      if (requestId != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('질문이 전송됐어요'),
            backgroundColor: AppTheme.secondary,
          ),
        );

        // 폼 초기화
        _contentController.clear();
        _attachments.clear();
        _selectedType = RequestType.question;

        widget.onSubmitSuccess();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('문제가 생겼어요: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subscriptionAsync = ref.watch(currentSubscriptionProvider(widget.memberId));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프리미엄 잔여 횟수 표시
          subscriptionAsync.when(
            loading: () => _buildQuotaSkeleton(context),
            error: (_, __) => const SizedBox.shrink(),
            data: (subscription) {
              if (subscription == null || subscription.plan != SubscriptionPlan.premium) {
                return const SizedBox.shrink();
              }
              final remainingQuota = subscription.monthlyQuestionCount;
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary.withValues(alpha: 0.1),
                      AppTheme.secondary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star,
                        color: AppTheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '프리미엄 무료 질문',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '이번 달 $remainingQuota회 남음',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 200.ms).slideX(begin: -0.02, end: 0);
            },
          ),
          const SizedBox(height: 24),

          // 요청 타입 선택
          Text(
            '질문 유형',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _RequestTypeCard(
                  type: RequestType.question,
                  isSelected: _selectedType == RequestType.question,
                  onTap: () => setState(() => _selectedType = RequestType.question),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RequestTypeCard(
                  type: RequestType.formCheck,
                  isSelected: _selectedType == RequestType.formCheck,
                  onTap: () => setState(() => _selectedType = RequestType.formCheck),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 질문 내용 입력
          Text(
            '질문 내용',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contentController,
            maxLines: 6,
            maxLength: 1000,
            decoration: InputDecoration(
              hintText: _selectedType == RequestType.formCheck
                  ? '어떤 운동의 폼을 체크받고 싶으신가요?\n영상이나 이미지를 함께 첨부해주세요'
                  : '트레이너에게 궁금한 점을 질문해주세요',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 첨부파일 (폼체크일 때만)
          if (_selectedType == RequestType.formCheck) ...[
            Text(
              '첨부파일',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '운동 영상이나 사진을 첨부해주세요 (최대 5개)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // 기존 첨부파일들
                ..._attachments.asMap().entries.map((entry) {
                  return _AttachmentPreview(
                    file: entry.value,
                    onRemove: () => _removeAttachment(entry.key),
                  );
                }),
                // 추가 버튼
                if (_attachments.length < 5)
                  _AddAttachmentButton(
                    onPickImage: _pickAttachment,
                    onPickVideo: _pickVideo,
                  ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // 가격 안내
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '예상 결제 금액',
                  style: theme.textTheme.bodyLarge,
                ),
                Text(
                  _selectedType.price == 0 ? '무료' : '${_formatPrice(_selectedType.price)}원',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 제출 버튼
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: _isSubmitting ? '전송 중...' : '질문 보내기',
              onPressed: _isSubmitting ? null : _submitRequest,
              isLoading: _isSubmitting,
              icon: Icons.send,
              variant: AppButtonVariant.primary,
              size: AppButtonSize.lg,
              isFullWidth: true,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildQuotaSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
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

/// 요청 타입 선택 카드
class _RequestTypeCard extends StatelessWidget {
  final RequestType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _RequestTypeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final icon = type == RequestType.question
        ? Icons.help_outline
        : Icons.videocam_outlined;
    final description = type == RequestType.question
        ? '운동, 식단 등\n궁금한 점 질문'
        : '운동 영상으로\n자세 교정 받기';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.1)
              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: isSelected ? AppTheme.primary : Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              type.label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.primary : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary
                    : Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${type.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 첨부파일 미리보기
class _AttachmentPreview extends StatelessWidget {
  final XFile file;
  final VoidCallback onRemove;

  const _AttachmentPreview({
    required this.file,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isVideo = file.path.endsWith('.mp4') || file.path.endsWith('.mov');

    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isVideo
                ? const Center(
                    child: Icon(Icons.videocam, size: 32, color: Colors.grey),
                  )
                : FutureBuilder<Widget>(
                    future: _buildImagePreview(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return snapshot.data!;
                      }
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    },
                  ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppTheme.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<Widget> _buildImagePreview() async {
    final bytes = await file.readAsBytes();
    return Image.memory(
      bytes,
      fit: BoxFit.cover,
      width: 80,
      height: 80,
    );
  }
}

/// 첨부파일 추가 버튼
class _AddAttachmentButton extends StatelessWidget {
  final VoidCallback onPickImage;
  final VoidCallback onPickVideo;

  const _AddAttachmentButton({
    required this.onPickImage,
    required this.onPickVideo,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'image') {
          onPickImage();
        } else {
          onPickVideo();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'image',
          child: Row(
            children: [
              Icon(Icons.image),
              SizedBox(width: 8),
              Text('이미지'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'video',
          child: Row(
            children: [
              Icon(Icons.videocam),
              SizedBox(width: 8),
              Text('영상'),
            ],
          ),
        ),
      ],
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.5),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(
            Icons.add,
            size: 32,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}

/// 질문 내역 탭
class _RequestHistoryTab extends ConsumerWidget {
  final String memberId;

  const _RequestHistoryTab({required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(memberRequestsProvider(memberId));

    return requestsAsync.when(
      loading: () => _buildLoadingSkeleton(context),
      error: (error, _) => ErrorState.fromError(
        error.toString(),
        onRetry: () => ref.invalidate(memberRequestsProvider(memberId)),
      ),
      data: (requests) {
        if (requests.isEmpty) {
          return const EmptyState(
            type: EmptyStateType.messages,
            customTitle: '아직 질문 내역이 없어요',
            customMessage: '트레이너에게 궁금한 점을 질문해보세요',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(memberRequestsProvider(memberId));
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final request = requests[index];
              return RequestCard(
                request: request,
                onTap: () => _showRequestDetail(context, request),
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
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _showRequestDetail(BuildContext context, TrainerRequestModel request) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
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

              // 요청 타입 & 상태
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
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(request.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      request.statusText,
                      style: TextStyle(
                        color: _getStatusColor(request.status),
                        fontWeight: FontWeight.bold,
                      ),
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
              Text(
                request.content,
                style: theme.textTheme.bodyMedium,
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: request.attachmentUrls.map((url) {
                    return Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(url),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // 답변
              if (request.isAnswered && request.response != null) ...[
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: AppTheme.secondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '트레이너 답변',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.secondary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    request.response!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // 날짜 정보
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '요청일: ${_formatDate(request.createdAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (request.answeredAt != null)
                    Text(
                      '답변일: ${_formatDate(request.answeredAt!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
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

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
