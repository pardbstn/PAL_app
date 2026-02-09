/// 식단 분석 모델
///
/// AI Vision API로 분석된 식단 정보를 저장
/// 회원의 영양 섭취 추적에 사용
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'diet_analysis_model.freezed.dart';
part 'diet_analysis_model.g.dart';

/// 식사 유형
enum MealType {
  /// 아침
  @JsonValue('breakfast')
  breakfast,

  /// 점심
  @JsonValue('lunch')
  lunch,

  /// 저녁
  @JsonValue('dinner')
  dinner,

  /// 간식
  @JsonValue('snack')
  snack,
}

/// AI가 개별 인식한 음식 항목
@freezed
sealed class AnalyzedFoodItem with _$AnalyzedFoodItem {
  const factory AnalyzedFoodItem({
    /// 음식 이름
    required String foodName,

    /// 추정 중량 (g)
    @Default(0.0) double estimatedWeight,

    /// 칼로리 (kcal)
    required double calories,

    /// 단백질 (g)
    required double protein,

    /// 탄수화물 (g)
    required double carbs,

    /// 지방 (g)
    required double fat,

    /// 양 추정 근거
    @Default('') String portionNote,

    /// 로컬 DB 매칭으로 보정되었는지 여부
    @Default(false) bool dbCorrected,
  }) = _AnalyzedFoodItem;

  factory AnalyzedFoodItem.fromJson(Map<String, dynamic> json) =>
      _$AnalyzedFoodItemFromJson(json);
}

/// 식단 분석 모델
/// AI Vision API로 분석된 음식 정보
@freezed
sealed class DietAnalysisModel with _$DietAnalysisModel {
  const factory DietAnalysisModel({
    /// 문서 ID
    required String id,

    /// 회원 ID
    required String memberId,

    /// 식사 유형
    required MealType mealType,

    /// 이미지 URL
    required String imageUrl,

    /// 음식 이름 (전체 요약)
    required String foodName,

    /// 총 칼로리 (kcal)
    required int calories,

    /// 총 단백질 (g)
    required double protein,

    /// 총 탄수화물 (g)
    required double carbs,

    /// 총 지방 (g)
    required double fat,

    /// AI 분석 신뢰도 (0.0 ~ 1.0)
    @Default(0.5) double confidence,

    /// 개별 음식 항목 (AI 분석 + DB 보정)
    @Default([]) List<AnalyzedFoodItem> foods,

    /// 분석 일시
    @TimestampConverter() required DateTime analyzedAt,

    /// 생성 일시
    @TimestampConverter() DateTime? createdAt,
  }) = _DietAnalysisModel;

  factory DietAnalysisModel.fromJson(Map<String, dynamic> json) =>
      _$DietAnalysisModelFromJson(json);

  /// Firestore 문서로부터 생성
  factory DietAnalysisModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DietAnalysisModel.fromJson({...data, 'id': doc.id});
  }
}

/// DietAnalysisModel 확장 메서드
extension DietAnalysisModelX on DietAnalysisModel {
  /// Firestore 저장용 Map 변환
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // ID는 문서 ID로 사용
    // enum을 문자열로 변환
    json['mealType'] = mealType.name;
    return json;
  }

  /// 식사 유형 한글 라벨
  String get mealTypeLabel {
    switch (mealType) {
      case MealType.breakfast:
        return '아침';
      case MealType.lunch:
        return '점심';
      case MealType.dinner:
        return '저녁';
      case MealType.snack:
        return '간식';
    }
  }

  /// 식사 유형 아이콘
  IconData get mealTypeIcon {
    switch (mealType) {
      case MealType.breakfast:
        return Icons.wb_sunny;
      case MealType.lunch:
        return Icons.wb_cloudy;
      case MealType.dinner:
        return Icons.nights_stay;
      case MealType.snack:
        return Icons.cookie;
    }
  }

  /// 식사 유형 색상
  Color get mealTypeColor {
    switch (mealType) {
      case MealType.breakfast:
        return const Color(0xFFFF8A00); // 주황색
      case MealType.lunch:
        return const Color(0xFF00C471); // 초록색
      case MealType.dinner:
        return const Color(0xFF3B82F6); // 파란색
      case MealType.snack:
        return const Color(0xFF8B5CF6); // 보라색
    }
  }

  /// 신뢰도 라벨
  String get confidenceLabel {
    if (confidence >= 0.8) return '높음';
    if (confidence >= 0.5) return '보통';
    return '낮음';
  }

  /// 신뢰도 색상
  Color get confidenceColor {
    if (confidence >= 0.8) return const Color(0xFF00C471);
    if (confidence >= 0.5) return const Color(0xFFFF8A00);
    return const Color(0xFFF04452);
  }

  /// 총 칼로리 포맷
  String get caloriesFormatted => '$calories kcal';

  /// 영양소 요약
  String get nutritionSummary =>
      '탄 ${carbs.toStringAsFixed(0)}g · 단 ${protein.toStringAsFixed(0)}g · 지 ${fat.toStringAsFixed(0)}g';
}

/// 일일 영양 요약 모델
@freezed
sealed class DailyNutritionSummary with _$DailyNutritionSummary {
  const factory DailyNutritionSummary({
    required DateTime date,
    @Default(0) int totalCalories,
    @Default(0.0) double totalProtein,
    @Default(0.0) double totalCarbs,
    @Default(0.0) double totalFat,
    @Default([]) List<DietAnalysisModel> records,
  }) = _DailyNutritionSummary;
}

/// DailyNutritionSummary 확장 메서드
extension DailyNutritionSummaryX on DailyNutritionSummary {
  /// 목표 칼로리 대비 퍼센트 (기본 목표: 2000kcal)
  double calorieProgress([int targetCalories = 2000]) =>
      (totalCalories / targetCalories).clamp(0.0, 1.0);

  /// 목표 단백질 대비 퍼센트 (기본 목표: 60g)
  double proteinProgress([double targetProtein = 60]) =>
      (totalProtein / targetProtein).clamp(0.0, 1.0);

  /// 목표 탄수화물 대비 퍼센트 (기본 목표: 300g)
  double carbsProgress([double targetCarbs = 300]) =>
      (totalCarbs / targetCarbs).clamp(0.0, 1.0);

  /// 목표 지방 대비 퍼센트 (기본 목표: 65g)
  double fatProgress([double targetFat = 65]) =>
      (totalFat / targetFat).clamp(0.0, 1.0);

  /// 식사 유형별 기록 그룹화
  Map<MealType, List<DietAnalysisModel>> get recordsByMealType {
    final grouped = <MealType, List<DietAnalysisModel>>{};
    for (final record in records) {
      grouped.putIfAbsent(record.mealType, () => []).add(record);
    }
    return grouped;
  }
}
