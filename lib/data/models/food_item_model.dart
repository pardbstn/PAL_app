import 'package:freezed_annotation/freezed_annotation.dart';

part 'food_item_model.freezed.dart';
part 'food_item_model.g.dart';

/// 음식 항목 모델
/// 영양 정보 데이터베이스의 개별 음식 항목
@freezed
sealed class FoodItem with _$FoodItem {
  const FoodItem._();

  const factory FoodItem({
    /// 음식 ID
    required String id,

    /// 음식명
    required String name,

    /// 1회 제공량 (g)
    required double servingSize,

    /// 열량 (kcal)
    required double calories,

    /// 탄수화물 (g)
    required double carbs,

    /// 단백질 (g)
    required double protein,

    /// 지방 (g)
    required double fat,

    /// 당류 (g)
    double? sugar,

    /// 나트륨 (mg)
    double? sodium,
  }) = _FoodItem;

  factory FoodItem.fromJson(Map<String, dynamic> json) =>
      _$FoodItemFromJson(json);
}

/// FoodItem 확장 메서드
extension FoodItemX on FoodItem {
  /// 영양 요약 문자열
  /// 예: "250kcal | 탄30g 단20g 지10g"
  String get nutritionSummary =>
      '${calories.toInt()}kcal | 탄${carbs.toInt()}g 단${protein.toInt()}g 지${fat.toInt()}g';

  /// 1회 제공량 텍스트
  String get servingSizeText => '${servingSize.toInt()}g';

  /// 주어진 배수로 영양 정보 계산
  /// [multiplier] 배수 (예: 0.5 = 반 인분, 2.0 = 두 인분)
  FoodItem multiply(double multiplier) {
    return FoodItem(
      id: id,
      name: name,
      servingSize: servingSize * multiplier,
      calories: calories * multiplier,
      carbs: carbs * multiplier,
      protein: protein * multiplier,
      fat: fat * multiplier,
      sugar: sugar != null ? sugar! * multiplier : null,
      sodium: sodium != null ? sodium! * multiplier : null,
    );
  }

  /// 칼로리 비율 기반 매크로 영양소 비율 (%)
  /// 반환: {'carbs': %, 'protein': %, 'fat': %}
  Map<String, double> get macroRatios {
    // 칼로리 계산: 탄수화물 4kcal/g, 단백질 4kcal/g, 지방 9kcal/g
    final carbsCal = carbs * 4;
    final proteinCal = protein * 4;
    final fatCal = fat * 9;
    final totalCal = carbsCal + proteinCal + fatCal;

    if (totalCal == 0) {
      return {'carbs': 0, 'protein': 0, 'fat': 0};
    }

    return {
      'carbs': (carbsCal / totalCal) * 100,
      'protein': (proteinCal / totalCal) * 100,
      'fat': (fatCal / totalCal) * 100,
    };
  }
}
