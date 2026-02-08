/// 인바디 OCR Provider
///
/// 인바디 이미지 분석 기능을 위한 Riverpod Provider
/// 이미지 업로드 및 OCR 분석 결과 제공
library;

import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_pal_app/core/constants/api_constants.dart';
import 'package:flutter_pal_app/data/models/inbody_ocr_result.dart';
import 'package:flutter_pal_app/data/models/body_record_model.dart';
import 'package:flutter_pal_app/data/repositories/body_record_repository.dart';

// ============================================================
// OCR 분석 상태
// ============================================================

/// OCR 분석 상태
enum InbodyOcrStatus {
  /// 초기 상태
  idle,
  /// 이미지 업로드 중
  uploading,
  /// AI 분석 중
  analyzing,
  /// 분석 성공
  success,
  /// 분석 실패
  error,
}

/// OCR 분석 상태 클래스
class InbodyOcrState {
  final InbodyOcrStatus status;
  final InbodyOcrResult? result;
  final String? errorMessage;
  final double uploadProgress; // 0.0~1.0
  final String? imageUrl; // 업로드된 이미지 URL

  const InbodyOcrState({
    this.status = InbodyOcrStatus.idle,
    this.result,
    this.errorMessage,
    this.uploadProgress = 0.0,
    this.imageUrl,
  });

  InbodyOcrState copyWith({
    InbodyOcrStatus? status,
    InbodyOcrResult? result,
    String? errorMessage,
    double? uploadProgress,
    String? imageUrl,
  }) {
    return InbodyOcrState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  bool get isLoading =>
      status == InbodyOcrStatus.uploading ||
      status == InbodyOcrStatus.analyzing;
}

// ============================================================
// InBody OCR StateNotifier
// ============================================================

/// InBody OCR Notifier
class InbodyOcrNotifier extends Notifier<InbodyOcrState> {
  late final FirebaseFunctions _functions;
  late final SupabaseClient _supabase;

  @override
  InbodyOcrState build() {
    _functions = FirebaseFunctions.instanceFor(
      region: FunctionsRegion.asiaNortheast3,
    );
    _supabase = Supabase.instance.client;
    return const InbodyOcrState();
  }

  /// 이미지 분석 전체 플로우
  ///
  /// [imageFile] 분석할 인바디 이미지 파일
  /// [userId] 사용자 ID
  Future<void> analyzeImage(File imageFile, String userId) async {
    try {
      // 1. 업로드 시작
      state = state.copyWith(
        status: InbodyOcrStatus.uploading,
        uploadProgress: 0.0,
        errorMessage: null,
      );

      // 2. Supabase Storage에 이미지 업로드
      final fileName =
          '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imageBytes = await imageFile.readAsBytes();

      await _supabase.storage.from('inbody-images').uploadBinary(
            fileName,
            imageBytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      // 업로드 완료
      state = state.copyWith(uploadProgress: 1.0);

      // 3. 공개 URL 가져오기
      final imageUrl = _supabase.storage
          .from('inbody-images')
          .getPublicUrl(fileName);

      state = state.copyWith(imageUrl: imageUrl);

      // 4. AI 분석 시작
      state = state.copyWith(status: InbodyOcrStatus.analyzing);

      // 5. Cloud Function 호출
      final callable = _functions.httpsCallable(CloudFunctions.analyzeInbody);
      final response = await callable.call<Map<String, dynamic>>({
        'imageUrl': imageUrl,
        'userId': userId,
      });

      final data = response.data;

      // 6. 응답 검증
      if (data['success'] != true) {
        state = state.copyWith(
          status: InbodyOcrStatus.error,
          errorMessage: data['error'] ?? '분석에 실패했어요',
        );
        return;
      }

      // 7. 결과 파싱
      final result = InbodyOcrResult.fromJson(data);

      // 8. 성공 상태 업데이트
      state = state.copyWith(
        status: InbodyOcrStatus.success,
        result: result,
      );
    } on FirebaseFunctionsException catch (e) {
      state = state.copyWith(
        status: InbodyOcrStatus.error,
        errorMessage: e.message ?? 'OCR 분석 중 문제가 생겼어요',
      );
    } catch (e) {
      state = state.copyWith(
        status: InbodyOcrStatus.error,
        errorMessage: '이미지 업로드 또는 분석 중 문제가 생겼어요: $e',
      );
    }
  }

  /// OCR 결과 수동 수정
  ///
  /// [updatedResult] 수정된 OCR 결과
  void updateResult(InbodyOcrResult updatedResult) {
    state = state.copyWith(result: updatedResult);
  }

  /// 상태 초기화
  void reset() {
    state = const InbodyOcrState();
  }

  /// 체성분 기록으로 저장
  ///
  /// [memberId] 회원 ID
  Future<void> saveToBodyRecords(String memberId) async {
    final result = state.result;
    if (result == null) {
      throw Exception('저장할 OCR 결과가 없어요');
    }

    try {
      final repository = ref.read(bodyRecordRepositoryProvider);

      // 측정 날짜 파싱 (예: "2024-01-15" 형식)
      DateTime recordDate;
      if (result.measureDate != null && result.measureDate!.isNotEmpty) {
        try {
          recordDate = DateTime.parse(result.measureDate!);
        } catch (e) {
          // 파싱 실패 시 현재 날짜 사용
          recordDate = DateTime.now();
        }
      } else {
        recordDate = DateTime.now();
      }

      // BodyRecordModel 생성
      final bodyRecord = BodyRecordModel(
        id: '', // Firestore에서 자동 생성
        memberId: memberId,
        recordDate: recordDate,
        weight: result.weight ?? 0.0,
        bodyFatPercent: result.bodyFatPercent,
        muscleMass: result.skeletalMuscle,
        bmi: result.bmi,
        bmr: result.basalMetabolicRate,
        source: RecordSource.inbodyApi,
        note: 'OCR 자동 인식 (신뢰도: ${(result.confidence * 100).toStringAsFixed(1)}%)',
        createdAt: DateTime.now(),
      );

      // Firestore에 저장
      await repository.create(bodyRecord);

      // 성공 후 상태 초기화
      reset();
    } catch (e) {
      state = state.copyWith(
        status: InbodyOcrStatus.error,
        errorMessage: '체성분 기록 저장 중 문제가 생겼어요: $e',
      );
      rethrow;
    }
  }
}

// ============================================================
// Provider
// ============================================================

/// InBody OCR 상태 Provider
final inbodyOcrProvider =
    NotifierProvider<InbodyOcrNotifier, InbodyOcrState>(
        InbodyOcrNotifier.new);
