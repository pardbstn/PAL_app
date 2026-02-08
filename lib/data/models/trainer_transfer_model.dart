import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_pal_app/data/models/user_model.dart';

part 'trainer_transfer_model.freezed.dart';
part 'trainer_transfer_model.g.dart';

/// 트레이너 전환 상태
enum TransferStatus {
  @JsonValue('pending') pending,     // 대기 중
  @JsonValue('accepted') accepted,   // 수락됨
  @JsonValue('rejected') rejected,   // 거절됨
  @JsonValue('cancelled') cancelled, // 취소됨
}

/// 트레이너 전환 모델
@freezed
sealed class TrainerTransferModel with _$TrainerTransferModel {
  const factory TrainerTransferModel({
    /// Firestore 문서 ID
    @Default('') String id,
    /// 회원 ID
    required String memberId,
    /// 회원 이름
    required String memberName,
    /// 현재 트레이너 ID
    required String fromTrainerId,
    /// 현재 트레이너 이름
    required String fromTrainerName,
    /// 새 트레이너 ID
    required String toTrainerId,
    /// 새 트레이너 이름
    required String toTrainerName,
    /// 전환 상태
    @Default(TransferStatus.pending) TransferStatus status,
    /// 전환 사유
    @Default('') String reason,
    /// 요청일
    @TimestampConverter() required DateTime requestedAt,
    /// 응답일
    @NullableTimestampConverter() DateTime? respondedAt,
  }) = _TrainerTransferModel;

  factory TrainerTransferModel.fromJson(Map<String, dynamic> json) =>
      _$TrainerTransferModelFromJson(json);

  /// Firestore 문서로부터 생성
  factory TrainerTransferModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TrainerTransferModel.fromJson({...data, 'id': doc.id});
  }
}
