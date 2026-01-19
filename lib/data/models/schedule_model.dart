import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_model.freezed.dart';
part 'schedule_model.g.dart';

/// 일정 유형 (PT/개인)
enum ScheduleType {
  @JsonValue('pt')
  pt('PT 일정'),
  @JsonValue('personal')
  personal('개인 일정');

  final String label;
  const ScheduleType(this.label);
}

/// 일정 상태
enum ScheduleStatus {
  @JsonValue('scheduled')
  scheduled('예정'),
  @JsonValue('completed')
  completed('완료'),
  @JsonValue('cancelled')
  cancelled('취소'),
  @JsonValue('noShow')
  noShow('노쇼');

  final String label;
  const ScheduleStatus(this.label);
}

/// Timestamp 변환기
class ScheduleTimestampConverter implements JsonConverter<DateTime, dynamic> {
  const ScheduleTimestampConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json is Timestamp) {
      return json.toDate();
    } else if (json is String) {
      return DateTime.parse(json);
    }
    return DateTime.now();
  }

  @override
  dynamic toJson(DateTime date) => date.toIso8601String();
}

/// 일정 모델
@freezed
sealed class ScheduleModel with _$ScheduleModel {
  const factory ScheduleModel({
    required String id,
    required String trainerId,
    required String memberId,
    String? memberName,
    @ScheduleTimestampConverter() required DateTime scheduledAt,
    @Default(60) int duration,
    @Default(ScheduleStatus.scheduled) ScheduleStatus status,
    @Default(ScheduleType.pt) ScheduleType scheduleType, // PT/개인 일정 구분
    String? title, // 개인 일정용 제목 (nullable)
    String? note,
    String? groupId, // 반복 일정 그룹 ID
    @ScheduleTimestampConverter() required DateTime createdAt,
  }) = _ScheduleModel;

  factory ScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleModelFromJson(json);

  /// Firestore 문서로부터 생성
  factory ScheduleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ScheduleModel.fromJson({...data, 'id': doc.id});
  }
}

/// ScheduleModel 확장 메서드
extension ScheduleModelX on ScheduleModel {
  /// 종료 시간
  DateTime get endTime => scheduledAt.add(Duration(minutes: duration));

  /// 시간 문자열 (HH:mm)
  String get timeString =>
      '${scheduledAt.hour.toString().padLeft(2, '0')}:${scheduledAt.minute.toString().padLeft(2, '0')}';

  /// 시간 범위 문자열 (HH:mm - HH:mm)
  String get timeRangeString {
    final end = endTime;
    return '$timeString - ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
  }

  /// 날짜 문자열 (M월 d일)
  String get dateString => '${scheduledAt.month}월 ${scheduledAt.day}일';

  /// 완료 여부
  bool get isCompleted => status == ScheduleStatus.completed;

  /// 예정 여부
  bool get isScheduled => status == ScheduleStatus.scheduled;

  /// PT 일정 여부
  bool get isPtSchedule => scheduleType == ScheduleType.pt;

  /// 개인 일정 여부
  bool get isPersonalSchedule => scheduleType == ScheduleType.personal;

  /// 표시용 제목 (PT 일정은 회원명, 개인 일정은 title)
  String get displayTitle => isPtSchedule ? (memberName ?? '회원') : (title ?? '개인 일정');
}
