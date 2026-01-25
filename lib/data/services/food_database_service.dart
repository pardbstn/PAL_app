import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/food_item_model.dart';

/// 로컬 음식 데이터베이스 서비스
/// JSON 파일에서 음식 데이터를 로드하고 검색 기능 제공
class FoodDatabaseService {
  static FoodDatabaseService? _instance;
  static FoodDatabaseService get instance => _instance ??= FoodDatabaseService._();

  FoodDatabaseService._();

  List<FoodItem> _foods = [];
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  int get totalCount => _foods.length;

  /// 앱 시작 시 JSON 파일 로드
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final jsonString = await rootBundle.loadString('assets/data/food_database.json');
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final foodList = data['foods'] as List<dynamic>;

      _foods = foodList
          .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
          .toList();

      _isInitialized = true;
    } catch (e) {
      rethrow;
    }
  }

  /// 음식명으로 검색 (부분 일치, 최대 50개)
  List<FoodItem> searchFood(String keyword, {int limit = 50}) {
    if (!_isInitialized || keyword.isEmpty) return [];

    final normalizedKeyword = _normalize(keyword);

    return _foods
        .where((food) => _normalize(food.name).contains(normalizedKeyword))
        .take(limit)
        .toList();
  }

  /// ID로 음식 조회
  FoodItem? getFoodById(String id) {
    if (!_isInitialized) return null;

    try {
      return _foods.firstWhere((food) => food.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 여러 ID로 음식 목록 조회
  List<FoodItem> getFoodsByIds(List<String> ids) {
    if (!_isInitialized) return [];

    return ids
        .map((id) => getFoodById(id))
        .whereType<FoodItem>()
        .toList();
  }

  /// 검색 최적화를 위한 문자열 정규화
  /// 공백 제거, 소문자 변환
  String _normalize(String text) {
    return text.toLowerCase().replaceAll(' ', '').replaceAll('/', '');
  }

  /// 초성 검색 지원 (미래 확장용)
  /// TODO: 한글 초성 검색 구현
  bool _matchesChosung(String text, String keyword) {
    // 추후 구현
    return false;
  }
}
