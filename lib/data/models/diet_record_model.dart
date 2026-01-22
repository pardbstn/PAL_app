import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'diet_record_model.freezed.dart';
part 'diet_record_model.g.dart';

/// 식사 타입
enum MealType {
  @JsonValue('breakfast')
  breakfast,
  @JsonValue('lunch')
  lunch,
  @JsonValue('dinner')
  dinner,
  @JsonValue('snack')
  snack,
}

/// AI 분석 결과
@freezed
sealed class AiAnalysis with _$AiAnalysis {
  const factory AiAnalysis({
    /// AI가 인식한 음식명
    String? foodName,

    /// 칼로리 (kcal)
    double? calories,

    /// 단백질 (g)
    double? protein,

    /// 탄수화물 (g)
    double? carbs,

    /// 지방 (g)
    double? fat,

    /// 분석 신뢰도 (0.0 ~ 1.0)
    double? confidence,

    /// AI 피드백 메시지
    String? feedback,
  }) = _AiAnalysis;

  factory AiAnalysis.fromJson(Map<String, dynamic> json) =>
      _$AiAnalysisFromJson(json);
}

/// 식단 기록 모델
/// 식단 기록 (AI 분석 결과 포함)
@freezed
sealed class DietRecordModel with _$DietRecordModel {
  const factory DietRecordModel({
    /// 기록 문서 ID
    required String id,

    /// 회원 ID
    required String memberId,

    /// 기록 날짜
    @TimestampConverter() required DateTime recordDate,

    /// 식사 타입 ('breakfast'|'lunch'|'dinner'|'snack')
    required MealType mealType,

    /// 식단 사진 URL (Supabase)
    String? imageUrl,

    /// 음식 설명 (수동 입력)
    String? description,

    /// AI 분석 결과
    AiAnalysis? aiAnalysis,

    /// 메모
    String? note,

    /// 로컬 DB 음식 ID (음식 검색으로 추가된 경우)
    String? foodId,

    /// 수량 배수 (기본 1.0, 예: 0.5 = 반 인분)
    @Default(1.0) double servingMultiplier,

    /// 입력 방식 (search: 검색, ai: AI분석, manual: 수동입력)
    @Default('manual') String inputType,

    /// 음식명 (검색으로 추가된 경우 저장)
    String? foodName,

    /// 칼로리 (검색/수동 입력 시 직접 저장)
    double? calories,

    /// 탄수화물 (g)
    double? carbs,

    /// 단백질 (g)
    double? protein,

    /// 지방 (g)
    double? fat,

    /// 생성일
    @TimestampConverter() required DateTime createdAt,

    /// 수정일
    @TimestampConverter() required DateTime updatedAt,
  }) = _DietRecordModel;

  factory DietRecordModel.fromJson(Map<String, dynamic> json) =>
      _$DietRecordModelFromJson(json);

  /// Firestore 문서로부터 생성
  factory DietRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DietRecordModel.fromJson({...data, 'id': doc.id});
  }
}

/// DietRecordModel 확장 메서드
extension DietRecordModelX on DietRecordModel {
  /// Firestore 저장용 Map 변환
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // ID는 문서 ID로 사용
    return json;
  }

  /// 이미지가 있는지 여부
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  /// AI 분석이 완료되었는지 여부
  bool get hasAiAnalysis => aiAnalysis != null && aiAnalysis!.calories != null;

  /// 식사 타입 라벨
  String get mealTypeLabel => switch (mealType) {
        MealType.breakfast => '아침',
        MealType.lunch => '점심',
        MealType.dinner => '저녁',
        MealType.snack => '간식',
      };

  /// 총 칼로리 (AI 분석 결과 기준)
  double get totalCalories => aiAnalysis?.calories ?? 0;

  /// 영양 요약 문자열
  String get nutritionSummary {
    if (aiAnalysis == null) return '분석 대기';
    final a = aiAnalysis!;
    if (a.calories == null) return '분석 실패';
    return '${a.calories?.toStringAsFixed(0)}kcal | '
        'P:${a.protein?.toStringAsFixed(0)}g '
        'C:${a.carbs?.toStringAsFixed(0)}g '
        'F:${a.fat?.toStringAsFixed(0)}g';
  }

  /// 실제 칼로리 계산 (수량 배수 적용)
  double get actualCalories {
    final base = calories ?? aiAnalysis?.calories ?? 0;
    return base * servingMultiplier;
  }

  /// 실제 탄수화물 계산
  double get actualCarbs {
    final base = carbs ?? aiAnalysis?.carbs ?? 0;
    return base * servingMultiplier;
  }

  /// 실제 단백질 계산
  double get actualProtein {
    final base = protein ?? aiAnalysis?.protein ?? 0;
    return base * servingMultiplier;
  }

  /// 실제 지방 계산
  double get actualFat {
    final base = fat ?? aiAnalysis?.fat ?? 0;
    return base * servingMultiplier;
  }

  /// 표시할 음식명
  String get displayFoodName {
    return foodName ?? aiAnalysis?.foodName ?? description ?? '음식';
  }
}

/// AiAnalysis 확장 메서드
extension AiAnalysisX on AiAnalysis {
  /// 총 칼로리 (계산값)
  double get calculatedCalories {
    final p = protein ?? 0;
    final c = carbs ?? 0;
    final f = fat ?? 0;
    return (p * 4) + (c * 4) + (f * 9);
  }
}
