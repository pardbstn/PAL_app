import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/data/models/trainer_request_model.dart';
import 'package:flutter_pal_app/presentation/providers/trainer_request_provider.dart';
import 'package:flutter_pal_app/presentation/providers/subscription_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/common/app_button.dart';
import 'package:flutter_pal_app/data/models/subscription_model.dart';

/// 트레이너 요청 폼 위젯
/// 회원이 트레이너에게 질문/폼체크를 요청할 때 사용
class RequestFormWidget extends ConsumerStatefulWidget {
  final String memberId;
  final String trainerId;
  final VoidCallback? onSubmitSuccess;

  const RequestFormWidget({
    super.key,
    required this.memberId,
    required this.trainerId,
    this.onSubmitSuccess,
  });

  @override
  ConsumerState<RequestFormWidget> createState() => _RequestFormWidgetState();
}

class _RequestFormWidgetState extends ConsumerState<RequestFormWidget> {
  RequestType _selectedType = RequestType.question;
  final _contentController = TextEditingController();
  final List<XFile> _attachments = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
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
        const SnackBar(content: Text('질문 내용을 입력해주세요.')),
      );
      return;
    }

    // 폼체크인데 첨부파일이 없는 경우 경고
    if (_selectedType == RequestType.formCheck && _attachments.isEmpty) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('첨부파일 없음'),
          content: const Text('폼체크 요청에는 운동 영상이나 사진을 첨부하는 것이 좋아요.\n그래도 진행할까요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('진행'),
            ),
          ],
        ),
      );

      if (proceed != true) return;
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
        setState(() => _selectedType = RequestType.question);

        widget.onSubmitSuccess?.call();
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
    final subscriptionAsync = ref.watch(currentSubscriptionProvider(widget.memberId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 프리미엄 잔여 횟수 표시
        subscriptionAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (subscription) {
            if (subscription == null || subscription.plan != SubscriptionPlan.premium) {
              return const SizedBox.shrink();
            }
            final remainingQuota = subscription.monthlyQuestionCount;
            return _PremiumQuotaIndicator(
              remainingQuota: remainingQuota,
            ).animate().fadeIn(duration: 300.ms);
          },
        ),
        const SizedBox(height: 20),

        // 요청 타입 토글
        Text(
          '질문 유형',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _RequestTypeToggle(
          selectedType: _selectedType,
          onTypeChanged: (type) => setState(() => _selectedType = type),
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
          maxLines: 5,
          maxLength: 1000,
          decoration: InputDecoration(
            hintText: _selectedType == RequestType.formCheck
                ? '어떤 운동의 폼을 체크받고 싶으신가요?\n영상이나 이미지를 함께 첨부해주세요.'
                : '트레이너에게 궁금한 점을 질문해주세요.',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 첨부파일 섹션 (폼체크일 때만)
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
          _AttachmentSection(
            attachments: _attachments,
            onPickImage: _pickImage,
            onPickVideo: _pickVideo,
            onRemove: _removeAttachment,
          ),
          const SizedBox(height: 24),
        ],

        // 가격 인디케이터
        _PriceIndicator(
          type: _selectedType,
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
      ],
    );
  }
}

/// 프리미엄 잔여 횟수 인디케이터
class _PremiumQuotaIndicator extends StatelessWidget {
  final int remainingQuota;

  const _PremiumQuotaIndicator({required this.remainingQuota});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          // 잔여 횟수 시각화
          SizedBox(
            width: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: List.generate(3, (index) {
                final isFilled = index < remainingQuota;
                return Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isFilled ? AppTheme.primary : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// 요청 타입 토글
class _RequestTypeToggle extends StatelessWidget {
  final RequestType selectedType;
  final ValueChanged<RequestType> onTypeChanged;

  const _RequestTypeToggle({
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleOption(
              label: RequestType.question.label,
              price: '${_formatPrice(RequestType.question.price)}원',
              icon: Icons.help_outline,
              isSelected: selectedType == RequestType.question,
              onTap: () => onTypeChanged(RequestType.question),
            ),
          ),
          Expanded(
            child: _ToggleOption(
              label: RequestType.formCheck.label,
              price: '${_formatPrice(RequestType.formCheck.price)}원',
              icon: Icons.videocam_outlined,
              isSelected: selectedType == RequestType.formCheck,
              onTap: () => onTypeChanged(RequestType.formCheck),
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

class _ToggleOption extends StatelessWidget {
  final String label;
  final String price;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.price,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? Colors.white70 : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 첨부파일 섹션
class _AttachmentSection extends StatelessWidget {
  final List<XFile> attachments;
  final VoidCallback onPickImage;
  final VoidCallback onPickVideo;
  final void Function(int) onRemove;

  const _AttachmentSection({
    required this.attachments,
    required this.onPickImage,
    required this.onPickVideo,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // 기존 첨부파일들
        ...attachments.asMap().entries.map((entry) {
          return _AttachmentPreviewTile(
            file: entry.value,
            onRemove: () => onRemove(entry.key),
          );
        }),
        // 추가 버튼
        if (attachments.length < 5)
          _AddAttachmentTile(
            onPickImage: onPickImage,
            onPickVideo: onPickVideo,
          ),
      ],
    );
  }
}

class _AttachmentPreviewTile extends StatelessWidget {
  final XFile file;
  final VoidCallback onRemove;

  const _AttachmentPreviewTile({
    required this.file,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isVideo = file.path.endsWith('.mp4') || file.path.endsWith('.mov');

    return Stack(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isVideo
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
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
          top: 2,
          right: 2,
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
                size: 12,
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
      width: 72,
      height: 72,
    );
  }
}

class _AddAttachmentTile extends StatelessWidget {
  final VoidCallback onPickImage;
  final VoidCallback onPickVideo;

  const _AddAttachmentTile({
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
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(
            Icons.add_photo_alternate_outlined,
            size: 28,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}

/// 가격 인디케이터
class _PriceIndicator extends StatelessWidget {
  final RequestType type;

  const _PriceIndicator({required this.type});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '예상 결제 금액',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 2),
              Text(
                '프리미엄 회원은 월 3회 무료',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Text(
            '${_formatPrice(type.price)}원',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
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
