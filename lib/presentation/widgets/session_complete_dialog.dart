import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/data/models/curriculum_model.dart';
import 'package:flutter_pal_app/data/models/session_signature_model.dart';
import 'package:flutter_pal_app/data/repositories/curriculum_repository.dart';
import 'package:flutter_pal_app/data/repositories/member_repository.dart';
import 'package:flutter_pal_app/data/repositories/session_signature_repository.dart';
import 'package:flutter_pal_app/presentation/providers/curriculums_provider.dart';

/// 수업 완료 다이얼로그
/// PT 수업 완료 시 전자서명을 받는 다이얼로그
class SessionCompleteDialog extends ConsumerStatefulWidget {
  final CurriculumModel curriculum;
  final String memberId;
  final String trainerId;

  const SessionCompleteDialog({
    super.key,
    required this.curriculum,
    required this.memberId,
    required this.trainerId,
  });

  /// 다이얼로그 표시
  static Future<bool?> show(
    BuildContext context, {
    required CurriculumModel curriculum,
    required String memberId,
    required String trainerId,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SessionCompleteDialog(
        curriculum: curriculum,
        memberId: memberId,
        trainerId: trainerId,
      ),
    );
  }

  @override
  ConsumerState<SessionCompleteDialog> createState() =>
      _SessionCompleteDialogState();
}

class _SessionCompleteDialogState extends ConsumerState<SessionCompleteDialog> {
  final GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();
  final TextEditingController _memoController = TextEditingController();

  bool _isLoading = false;
  bool _showSuccess = false;
  String? _errorMessage;

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccess) {
      return _buildSuccessDialog();
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            _buildHeader(),
            const SizedBox(height: 20),

            // 메모 입력
            _buildMemoInput(),
            const SizedBox(height: 20),

            // 서명 영역
            _buildSignatureArea(),
            const SizedBox(height: 16),

            // 에러 메시지
            if (_errorMessage != null) _buildErrorMessage(),

            // 버튼
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.edit_document,
            color: AppTheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.curriculum.sessionNumber}회차 수업 완료',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.curriculum.title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
        ),
      ],
    );
  }

  Widget _buildMemoInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '수업 메모 (선택)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _memoController,
          maxLines: 2,
          minLines: 1,
          textInputAction: TextInputAction.done,
          onEditingComplete: () => FocusScope.of(context).unfocus(),
          decoration: InputDecoration(
            hintText: '오늘 수업에 대한 메모를 입력해주세요...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          enabled: !_isLoading,
        ),
      ],
    );
  }

  Widget _buildSignatureArea() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '회원 서명',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton.icon(
                onPressed: _isLoading ? null : _clearSignature,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('지우기'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[50],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SfSignaturePad(
                  key: _signaturePadKey,
                  backgroundColor: Colors.grey[50]!,
                  strokeColor: Colors.black,
                  minimumStrokeWidth: 2.0,
                  maximumStrokeWidth: 4.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '위 영역에 서명해주세요',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: AppTheme.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context, false),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('취소'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _completeSession,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    '수업 완료',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lottie 애니메이션 (성공 체크 또는 축하)
            SizedBox(
              width: 150,
              height: 150,
              child: Lottie.asset(
                'assets/animations/success.json',
                repeat: false,
                onLoaded: (composition) {
                  // 애니메이션 완료 후 자동 닫기
                  Future.delayed(const Duration(milliseconds: 2000), () {
                    if (mounted) {
                      Navigator.pop(context, true);
                    }
                  });
                },
                errorBuilder: (_, error, stackTrace) {
                  // Lottie 파일이 없을 경우 기본 아이콘
                  final navigator = Navigator.of(context);
                  Future.delayed(const Duration(milliseconds: 1500), () {
                    if (mounted) {
                      navigator.pop(true);
                    }
                  });
                  return Container(
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 100,
                      color: AppTheme.secondary,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '수업 완료!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.curriculum.sessionNumber}회차 수업이 완료됐어요',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearSignature() {
    _signaturePadKey.currentState?.clear();
    setState(() => _errorMessage = null);
  }

  Future<void> _completeSession() async {
    // 서명 확인
    final signatureData = await _signaturePadKey.currentState?.toImage();
    if (signatureData == null) {
      setState(() => _errorMessage = '서명을 해주세요');
      return;
    }

    // 서명이 비어있는지 확인 (최소한의 스트로크 체크)
    final byteData = await signatureData.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null || byteData.lengthInBytes < 1000) {
      setState(() => _errorMessage = '서명을 해주세요');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. 서명 이미지를 PNG로 변환
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // 2. Supabase Storage에 업로드
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = 'signatures/${widget.memberId}/$timestamp.png';

      final supabase = Supabase.instance.client;
      await supabase.storage.from('pal-storage').uploadBinary(
            filePath,
            pngBytes,
            fileOptions: const FileOptions(contentType: 'image/png'),
          );

      // 3. 업로드된 이미지 URL 가져오기
      final signatureUrl =
          supabase.storage.from('pal-storage').getPublicUrl(filePath);

      // 4. session_signatures 컬렉션에 저장
      final signatureRepo = ref.read(sessionSignatureRepositoryProvider);
      final now = DateTime.now();

      final signature = SessionSignatureModel(
        id: '', // Firestore에서 자동 생성
        memberId: widget.memberId,
        trainerId: widget.trainerId,
        curriculumId: widget.curriculum.id,
        sessionNumber: widget.curriculum.sessionNumber,
        signatureImageUrl: signatureUrl,
        signedAt: now,
        memo: _memoController.text.isNotEmpty ? _memoController.text : null,
        createdAt: now,
        updatedAt: now,
      );

      await signatureRepo.create(signature);

      // 5. 커리큘럼 완료 처리
      final curriculumRepo = ref.read(curriculumRepositoryProvider);
      await curriculumRepo.markAsCompleted(widget.curriculum.id);

      // 6. Member의 completedSessions +1
      final memberRepo = ref.read(memberRepositoryProvider);
      await memberRepo.incrementCompletedSession(widget.memberId);

      // 7. Provider 갱신
      ref.invalidate(curriculumsProvider(widget.memberId));

      // 8. 성공 화면 표시
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showSuccess = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '저장 중 문제가 생겼어요: $e';
        });
      }
    }
  }
}

/// 서명 이미지 보기 다이얼로그
class SignatureViewDialog extends StatelessWidget {
  final SessionSignatureModel signature;

  const SignatureViewDialog({
    super.key,
    required this.signature,
  });

  static Future<void> show(
    BuildContext context, {
    required SessionSignatureModel signature,
  }) {
    return showDialog(
      context: context,
      builder: (context) => SignatureViewDialog(signature: signature),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppTheme.secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${signature.sessionNumber}회차 서명',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${signature.signedDateFormatted} ${signature.signedTimeFormatted}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 서명 이미지
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  signature.signatureImageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.grey[400], size: 48),
                          const SizedBox(height: 8),
                          Text(
                            '이미지를 불러올 수 없어요',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // 메모
            if (signature.memo != null && signature.memo!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                '수업 메모',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  signature.memo!,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // 닫기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('확인'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
