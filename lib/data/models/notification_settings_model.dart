import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_pal_app/data/models/user_model.dart';

part 'notification_settings_model.freezed.dart';
part 'notification_settings_model.g.dart';

/// 알림 설정 모델
@freezed
sealed class NotificationSettingsModel with _$NotificationSettingsModel {
  const factory NotificationSettingsModel({
    /// 사용자 ID
    required String userId,
    /// FCM 토큰
    @Default('') String fcmToken,
    /// DM 메시지 알림
    @Default(true) bool dmMessages,
    /// PT 리마인더 알림
    @Default(true) bool ptReminders,
    /// AI 인사이트 알림
    @Default(true) bool aiInsights,
    /// 트레이너 전환 요청 알림
    @Default(true) bool trainerTransfer,
    /// 주간 리포트 알림
    @Default(true) bool weeklyReport,
    /// 수정일
    @TimestampConverter() required DateTime updatedAt,
  }) = _NotificationSettingsModel;

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsModelFromJson(json);

  /// Firestore 문서로부터 생성
  factory NotificationSettingsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationSettingsModel.fromJson({...data, 'userId': doc.id});
  }
}
