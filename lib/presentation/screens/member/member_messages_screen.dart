import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/data/repositories/trainer_repository.dart';
import 'package:flutter_pal_app/data/repositories/user_repository.dart';
import 'package:flutter_pal_app/data/models/trainer_model.dart';
import 'package:flutter_pal_app/data/models/user_model.dart';
import 'package:flutter_pal_app/data/models/member_model.dart';
import 'package:flutter_pal_app/presentation/widgets/common/mesh_gradient_background.dart';

/// 채팅 메시지 모델 (로컬)
class ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.timestamp,
    this.isRead = false,
  });
}

/// 회원 메시지 화면 - 프리미엄 1:1 채팅 UI
class MemberMessagesScreen extends ConsumerStatefulWidget {
  const MemberMessagesScreen({super.key});

  @override
  ConsumerState<MemberMessagesScreen> createState() =>
      _MemberMessagesScreenState();
}

class _MemberMessagesScreenState extends ConsumerState<MemberMessagesScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initDummyMessages();
  }

  /// 더미 채팅 메시지 초기화
  void _initDummyMessages() {
    // 실제 메시지 로드 시 여기에 구현
    // 현재는 빈 상태로 시작
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 메시지 전송
  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: _textController.text.trim(),
        isMe: true,
        timestamp: DateTime.now(),
        isRead: false,
      ));
    });
    _textController.clear();
    _scrollToBottom();
  }

  /// 스크롤을 맨 아래로 이동
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// 날짜 포맷팅
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return '오늘';
    } else if (messageDate == yesterday) {
      return '어제';
    } else {
      return '${date.month}월 ${date.day}일';
    }
  }

  /// 시간 포맷팅
  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$period $displayHour:$minute';
  }

  /// 같은 날인지 확인
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // 현재 회원 정보에서 trainerId 가져오기
    final currentMember = ref.watch(currentMemberProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBarWithTrainerInfo(
        theme,
        colorScheme,
        isDark,
        currentMember,
      ),
      body: MeshGradientBackground(
        child: Column(
        children: [
          // 준비 중 안내 배너
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '메시지 기능은 현재 준비 중이에요',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 채팅 메시지 영역
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState(theme, colorScheme)
                : _buildMessageList(theme, colorScheme, isDark),
          ),
          // 메시지 입력 영역
          _buildInputArea(theme, colorScheme, isDark),
        ],
      ),
      ),
    );
  }

  /// 앱바 빌드 (트레이너 정보 가져오기)
  PreferredSizeWidget _buildAppBarWithTrainerInfo(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
    MemberModel? currentMember,
  ) {
    // 트레이너 ID 가져오기
    final trainerId = currentMember?.trainerId;

    // 트레이너가 없는 경우
    if (trainerId == null) {
      return _buildAppBarWithoutTrainer(theme, colorScheme, isDark);
    }

    // 트레이너 정보 조회 Provider
    final trainerProvider = FutureProvider<TrainerModel?>((ref) async {
      final repo = ref.watch(trainerRepositoryProvider);
      return await repo.get(trainerId);
    });

    final trainerAsync = ref.watch(trainerProvider);

    return trainerAsync.when(
      data: (trainer) {
        if (trainer == null) {
          return _buildAppBarWithoutTrainer(theme, colorScheme, isDark);
        }

        // 트레이너의 UserModel에서 이름 가져오기 Provider
        final userProvider = FutureProvider<UserModel?>((ref) async {
          final repo = ref.watch(userRepositoryProvider);
          return await repo.get(trainer.userId);
        });

        final userAsync = ref.watch(userProvider);

        return userAsync.when(
          data: (user) {
            final trainerName = user?.name ?? '알 수 없음';
            final trainerInitial = trainerName.isNotEmpty ? trainerName[0] : '?';
            const isOnline = false; // 온라인 상태는 추후 구현

            return _buildAppBar(
              theme,
              colorScheme,
              isDark,
              trainerName: '$trainerName 트레이너',
              trainerInitial: trainerInitial,
              isOnline: isOnline,
            );
          },
          loading: () => _buildAppBarLoading(theme, colorScheme, isDark),
          error: (_, __) => _buildAppBarWithoutTrainer(theme, colorScheme, isDark),
        );
      },
      loading: () => _buildAppBarLoading(theme, colorScheme, isDark),
      error: (_, __) => _buildAppBarWithoutTrainer(theme, colorScheme, isDark),
    );
  }

  /// 앱바 빌드 (트레이너 정보 포함)
  PreferredSizeWidget _buildAppBar(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark, {
    required String trainerName,
    required String trainerInitial,
    required bool isOnline,
  }) {
    return AppBar(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: colorScheme.onSurface,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          // 트레이너 아바타
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primary,
                      AppTheme.primary.withValues(alpha: 0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    trainerInitial,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // 온라인 상태 표시
              if (isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppTheme.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.surface,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // 트레이너 정보
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                trainerName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: isDark ? Colors.white : const Color(0xFF191F28),
                ),
              ),
              Text(
                isOnline ? '온라인' : '오프라인',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isOnline ? AppTheme.secondary : colorScheme.outline,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.more_vert_rounded,
            color: colorScheme.onSurface,
          ),
          onPressed: () {
            // 더보기 메뉴 (더미)
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  /// 앱바 빌드 (트레이너 없음)
  PreferredSizeWidget _buildAppBarWithoutTrainer(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return AppBar(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: colorScheme.onSurface,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        '담당 트레이너 없음',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: isDark ? Colors.white : const Color(0xFF191F28),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  /// 앱바 빌드 (로딩 중)
  PreferredSizeWidget _buildAppBarLoading(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return AppBar(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: colorScheme.onSurface,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 16,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 60,
                height: 12,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  /// 빈 채팅 상태 UI
  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 40,
              color: colorScheme.primary,
            ),
          )
              .animate()
              .fadeIn(duration: 200.ms)
              .scale(begin: const Offset(0.8, 0.8)),
          const SizedBox(height: 16),
          Text(
            '아직 메시지가 없어요',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(delay: 50.ms, duration: 200.ms),
          const SizedBox(height: 8),
          Text(
            '트레이너에게 먼저 메시지를 보내보세요!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.outline,
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 200.ms),
        ],
      ),
    );
  }

  /// 메시지 목록 빌드
  Widget _buildMessageList(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final showDateSeparator = index == 0 ||
            !_isSameDay(
              _messages[index - 1].timestamp,
              message.timestamp,
            );

        // 새로 추가된 메시지인지 확인 (마지막 메시지이고 내 메시지인 경우)
        final isNewMessage = index == _messages.length - 1 && message.isMe;

        return Column(
          children: [
            // 날짜 구분선
            if (showDateSeparator)
              _buildDateSeparator(theme, colorScheme, message.timestamp),
            // 메시지 버블
            _buildMessageBubble(
              theme,
              colorScheme,
              isDark,
              message,
              isNewMessage,
            ),
          ],
        );
      },
    );
  }

  /// 날짜 구분선 빌드
  Widget _buildDateSeparator(
    ThemeData theme,
    ColorScheme colorScheme,
    DateTime date,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _formatDate(date),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  /// 메시지 버블 빌드
  Widget _buildMessageBubble(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
    ChatMessage message,
    bool isNewMessage,
  ) {
    final isMe = message.isMe;

    // 트레이너 이니셜 가져오기 (더미 데이터용)
    String trainerInitial = '김';

    Widget bubble = Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8,
          left: isMe ? 48 : 0,
          right: isMe ? 0 : 48,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 트레이너 아바타 (상대방 메시지일 때만)
            if (!isMe) ...[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primary,
                      AppTheme.primary.withValues(alpha: 0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    trainerInitial,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            // 메시지 버블
            Flexible(
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isMe
                          ? AppTheme.primary
                          : (isDark
                              ? colorScheme.surfaceContainerHighest
                              : colorScheme.surfaceContainerHigh),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isMe ? 20 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isMe ? AppTheme.primary : Colors.black)
                              .withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      message.text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isMe
                            ? Colors.white
                            : colorScheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 시간 및 읽음 표시
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.outline,
                          fontSize: 10,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead
                              ? Icons.done_all_rounded
                              : Icons.done_rounded,
                          size: 14,
                          color: message.isRead
                              ? AppTheme.primary
                              : colorScheme.outline,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // 새 메시지 애니메이션 적용
    if (isNewMessage) {
      return bubble
          .animate()
          .fadeIn(duration: 200.ms)
          .slideX(begin: 0.1, end: 0, duration: 200.ms);
    }

    return bubble;
  }

  /// 메시지 입력 영역 빌드
  Widget _buildInputArea(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 이미지 첨부 버튼
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.add_photo_alternate_outlined,
                  color: colorScheme.outline,
                  size: 20,
                ),
                onPressed: () {
                  // 이미지 첨부 (더미)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('이미지 첨부 기능은 준비 중이에요'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                padding: EdgeInsets.zero,
              ),
            ),
            // 텍스트 입력 필드
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: '메시지를 입력해주세요',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.outline,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 전송 버튼
            AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                final hasText = _textController.text.trim().isNotEmpty;
                return GestureDetector(
                  onTap: hasText ? _sendMessage : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: hasText
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.primary,
                                AppTheme.primary.withValues(alpha: 0.8),
                              ],
                            )
                          : null,
                      color: hasText ? null : colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      boxShadow: hasText
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      Icons.send_rounded,
                      color: hasText ? Colors.white : colorScheme.outline,
                      size: 20,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
