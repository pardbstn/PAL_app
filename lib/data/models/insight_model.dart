/// 인사이트 모델
///
/// AI가 생성한 회원 관리 인사이트 정보를 저장
/// 트레이너에게 회원 관리에 필요한 알림과 추천을 제공
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'insight_model.freezed.dart';
part 'insight_model.g.dart';

/// 인사이트 유형
enum InsightType {
  /// 출석률 하락 경고
  @JsonValue('attendanceAlert')
  attendanceAlert,

  /// PT 종료 임박
  @JsonValue('ptExpiry')
  ptExpiry,

  /// 성과 알림
  @JsonValue('performance')
  performance,

  /// 추천
  @JsonValue('recommendation')
  recommendation,

  /// 체중 변화
  @JsonValue('weightProgress')
  weightProgress,

  /// 운동량 변화
  @JsonValue('workoutVolume')
  workoutVolume,
}

/// 인사이트 우선순위
enum InsightPriority {
  /// 빨간색 - 즉시 확인
  @JsonValue('high')
  high,

  /// 주황색 - 확인 권장
  @JsonValue('medium')
  medium,

  /// 파란색 - 참고
  @JsonValue('low')
  low,
}

/// AI 인사이트 모델
/// 트레이너에게 제공되는 회원 관리 인사이트
@freezed
sealed class InsightModel with _$InsightModel {
  const factory InsightModel({
    /// 문서 ID
    required String id,

    /// 트레이너 ID
    required String trainerId,

    /// 회원 ID (nullable - 전체 대시보드 인사이트일 수 있음)
    String? memberId,

    /// 회원 이름 (표시용)
    String? memberName,

    /// 인사이트 유형
    required InsightType type,

    /// 우선순위
    required InsightPriority priority,

    /// 제목
    required String title,

    /// 메시지 내용
    required String message,

    /// 권장 조치 사항 (nullable)
    String? actionSuggestion,

    /// 추가 데이터 (nullable)
    Map<String, dynamic>? data,

    /// 읽음 여부
    @Default(false) bool isRead,

    /// 조치 완료 여부
    @Default(false) bool isActionTaken,

    /// 생성일
    @TimestampConverter() required DateTime createdAt,

    /// 만료일 (nullable)
    @NullableTimestampConverter() DateTime? expiresAt,
  }) = _InsightModel;

  factory InsightModel.fromJson(Map<String, dynamic> json) =>
      _$InsightModelFromJson(json);

  /// Firestore 문서로부터 생성
  factory InsightModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InsightModel.fromJson({...data, 'id': doc.id});
  }
}

/// InsightModel 확장 메서드
extension InsightModelX on InsightModel {
  /// Firestore 저장용 Map 변환
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // ID는 문서 ID로 사용
    // enum을 문자열로 변환
    json['type'] = type.name;
    json['priority'] = priority.name;
    return json;
  }

  /// 우선순위 색상
  /// high: #EF4444 (빨간색)
  /// medium: #F59E0B (주황색)
  /// low: #3B82F6 (파란색)
  Color get priorityColor {
    switch (priority) {
      case InsightPriority.high:
        return const Color(0xFFEF4444);
      case InsightPriority.medium:
        return const Color(0xFFF59E0B);
      case InsightPriority.low:
        return const Color(0xFF3B82F6);
    }
  }

  /// 우선순위 아이콘
  IconData get priorityIcon {
    switch (priority) {
      case InsightPriority.high:
        return Icons.warning;
      case InsightPriority.medium:
        return Icons.info;
      case InsightPriority.low:
        return Icons.lightbulb;
    }
  }

  /// 인사이트 유형 아이콘
  IconData get typeIcon {
    switch (type) {
      case InsightType.attendanceAlert:
        return Icons.event_busy;
      case InsightType.ptExpiry:
        return Icons.timer_off;
      case InsightType.performance:
        return Icons.trending_up;
      case InsightType.recommendation:
        return Icons.recommend;
      case InsightType.weightProgress:
        return Icons.monitor_weight;
      case InsightType.workoutVolume:
        return Icons.fitness_center;
    }
  }

  /// 만료 여부
  bool get isExpired {
    if (expiresAt == null) return false;
    return expiresAt!.isBefore(DateTime.now());
  }

  /// 조치 필요 여부 (읽지 않았거나 조치가 필요한 경우)
  bool get needsAttention => !isRead || (!isActionTaken && actionSuggestion != null);

  /// 회원 관련 인사이트 여부
  bool get isMemberRelated => memberId != null;
}
