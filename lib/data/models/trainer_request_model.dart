import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'trainer_request_model.freezed.dart';
part 'trainer_request_model.g.dart';

enum RequestType {
  @JsonValue('question')
  question('1회 질문', 3000),
  @JsonValue('formCheck')
  formCheck('폼체크', 5000),
  @JsonValue('monthlyCoaching')
  monthlyCoaching('월간 코칭', 29000);

  final String label;
  final int price;
  const RequestType(this.label, this.price);
}

enum RequestStatus {
  @JsonValue('pending')
  pending('대기중'),
  @JsonValue('answered')
  answered('답변완료'),
  @JsonValue('expired')
  expired('만료됨');

  final String label;
  const RequestStatus(this.label);
}

class RequestTimestampConverter implements JsonConverter<DateTime, dynamic> {
  const RequestTimestampConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    return DateTime.now();
  }

  @override
  dynamic toJson(DateTime date) => date.toIso8601String();
}

class RequestNullableTimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const RequestNullableTimestampConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    return null;
  }

  @override
  dynamic toJson(DateTime? date) => date?.toIso8601String();
}

@freezed
sealed class TrainerRequestModel with _$TrainerRequestModel {
  const factory TrainerRequestModel({
    required String id,
    required String memberId,
    required String trainerId,
    required RequestType requestType,
    required String content,
    @Default([]) List<String> attachmentUrls,
    String? response,
    @Default(RequestStatus.pending) RequestStatus status,
    required int price,
    @RequestTimestampConverter() required DateTime createdAt,
    @RequestNullableTimestampConverter() DateTime? answeredAt,
  }) = _TrainerRequestModel;

  factory TrainerRequestModel.fromJson(Map<String, dynamic> json) =>
      _$TrainerRequestModelFromJson(json);

  factory TrainerRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TrainerRequestModel.fromJson({...data, 'id': doc.id});
  }
}

extension TrainerRequestModelX on TrainerRequestModel {
  Map<String, dynamic> toFirestore() {
    return {
      'memberId': memberId,
      'trainerId': trainerId,
      'requestType': requestType.name,
      'content': content,
      'attachmentUrls': attachmentUrls,
      if (response != null) 'response': response,
      'status': status.name,
      'price': price,
      'createdAt': Timestamp.fromDate(createdAt),
      if (answeredAt != null) 'answeredAt': Timestamp.fromDate(answeredAt!),
    };
  }

  bool get isPending => status == RequestStatus.pending;
  bool get isAnswered => status == RequestStatus.answered;
  bool get hasAttachments => attachmentUrls.isNotEmpty;

  String get priceText => '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원';

  String get statusText => status.label;

  /// 트레이너 수익 (70%)
  int get trainerRevenue => (price * 0.7).toInt();

  /// 플랫폼 수수료 (30%)
  int get platformFee => (price * 0.3).toInt();

  /// 만료 체크 (48시간)
  bool get isExpired {
    if (status != RequestStatus.pending) return false;
    return DateTime.now().difference(createdAt).inHours > 48;
  }
}
