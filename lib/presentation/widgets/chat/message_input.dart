import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 메시지 입력 위젯
class MessageInput extends StatefulWidget {
  final String chatRoomId;
  final Function(String content, String? imageUrl) onSend;

  const MessageInput({
    super.key,
    required this.chatRoomId,
    required this.onSend,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  File? _selectedImage;
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final supabase = Supabase.instance.client;
      final fileName =
          '${widget.chatRoomId}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase.storage.from('chat_images').upload(
            fileName,
            image,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      final imageUrl =
          supabase.storage.from('chat_images').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      debugPrint('이미지 업로드 실패: $e');
      return null;
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _selectedImage == null) return;

    setState(() {
      _isSending = true;
    });

    try {
      String? imageUrl;

      // 이미지 업로드
      if (_selectedImage != null) {
        imageUrl = await _uploadImage(_selectedImage!);
        if (imageUrl == null && text.isEmpty) {
          // 이미지 업로드 실패하고 텍스트도 없으면 중단
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('이미지 업로드에 실패했습니다')),
            );
          }
          return;
        }
      }

      // 메시지 전송
      await widget.onSend(
        text.isNotEmpty ? text : '📷 사진',
        imageUrl,
      );

      // 초기화
      _controller.clear();
      setState(() {
        _selectedImage = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasContent = _controller.text.isNotEmpty || _selectedImage != null;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant,
              width: 0.5,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 선택된 이미지 미리보기
            if (_selectedImage != null)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: _removeImage,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // 입력 영역
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 이미지 첨부 버튼
                  IconButton(
                    onPressed: _isSending ? null : _pickImage,
                    icon: Icon(
                      Icons.add_photo_alternate_outlined,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                  // 텍스트 입력
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 120),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                        enabled: !_isSending,
                        decoration: InputDecoration(
                          hintText: '메시지를 입력하세요',
                          hintStyle: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // 전송 버튼
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    child: IconButton(
                      onPressed: (_isSending || !hasContent) ? null : _send,
                      style: IconButton.styleFrom(
                        backgroundColor:
                            hasContent ? colorScheme.primary : Colors.transparent,
                        disabledBackgroundColor: colorScheme.surfaceContainerHighest,
                      ),
                      icon: _isSending
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : Icon(
                              Icons.send_rounded,
                              color: hasContent
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
