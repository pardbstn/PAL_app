import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';

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

  // 더미 트레이너 정보
  final String _trainerName = '김철수 트레이너';
  final String _trainerInitial = '김';
  final bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _initDummyMessages();
  }

  /// 더미 채팅 메시지 초기화
  void _initDummyMessages() {
    final now = DateTime.now();
    _messages.addAll([
      ChatMessage(
        id: '1',
        text: '안녕하세요! 오늘 운동 준비 되셨나요?',
        isMe: false,
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        isRead: true,
      ),
      ChatMessage(
        id: '2',
        text: '네! 오늘 상체 위주로 하고 싶어요',
        isMe: true,
        timestamp: now.subtract(const Duration(days: 1, hours: 1, minutes: 55)),
        isRead: true,
      ),
      ChatMessage(
        id: '3',
        text: '좋아요! 벤치프레스랑 덤벨 운동 위주로 진행할게요. 워밍업 충분히 해오세요!',
        isMe: false,
        timestamp: now.subtract(const Duration(days: 1, hours: 1, minutes: 50)),
        isRead: true,
      ),
      ChatMessage(
        id: '4',
        text: '오늘 수업 고생하셨습니다! 벤치프레스 자세가 많이 좋아졌어요.',
        isMe: false,
        timestamp: now.subtract(const Duration(hours: 3)),
        isRead: true,
      ),
      ChatMessage(
        id: '5',
        text: '감사합니다! 다음 주도 열심히 할게요!',
        isMe: true,
        timestamp: now.subtract(const Duration(hours: 2, minutes: 50)),
        isRead: true,
      ),
      ChatMessage(
        id: '6',
        text: '식단 기록도 꼼꼼히 해주시면 더 좋은 결과 나올 거예요',
        isMe: false,
        timestamp: now.subtract(const Duration(hours: 2, minutes: 45)),
        isRead: true,
      ),
      ChatMessage(
        id: '7',
        text: '네 알겠습니다! 오늘부터 기록해볼게요',
        isMe: true,
        timestamp: now.subtract(const Duration(hours: 2, minutes: 40)),
        isRead: true,
      ),
      ChatMessage(
        id: '8',
        text: '다음 수업은 수요일 오후 3시에 뵐게요!',
        isMe: false,
        timestamp: now.subtract(const Duration(hours: 1)),
        isRead: true,
      ),
    ]);
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

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(theme, colorScheme, isDark),
      body: Column(
        children: [
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
    );
  }

  /// 앱바 빌드
  PreferredSizeWidget _buildAppBar(
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
                    _trainerInitial,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // 온라인 상태 표시
              if (_isOnline)
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
                _trainerName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                _isOnline ? '온라인' : '오프라인',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _isOnline ? AppTheme.secondary : colorScheme.outline,
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
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.8, 0.8)),
          const SizedBox(height: 16),
          Text(
            '아직 메시지가 없습니다',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 8),
          Text(
            '트레이너에게 먼저 메시지를 보내보세요!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.outline,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    _trainerInitial,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      content: const Text('이미지 첨부 기능은 준비 중입니다'),
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
                    hintText: '메시지를 입력하세요',
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
