/// 음식 검색 Provider
///
/// 음식 검색, 최근 음식, 즐겨찾기 기능을 위한 Riverpod Provider
/// SharedPreferences를 사용하여 데이터 영속성 관리
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/food_item_model.dart';
import '../../data/services/food_database_service.dart';

// ============================================================
// SharedPreferences Keys & Constants
// ============================================================

/// 최근 음식 저장 키
const _recentFoodsKey = 'recent_foods';

/// 즐겨찾기 음식 저장 키
const _favoriteFoodsKey = 'favorite_foods';

/// 최대 최근 음식 개수
const _maxRecentFoods = 20;

// ============================================================
// Database Initialization Provider
// ============================================================

/// 음식 데이터베이스 초기화 상태
///
/// 앱 시작 시 음식 데이터베이스를 초기화합니다.
final foodDatabaseProvider = FutureProvider<void>((ref) async {
  await FoodDatabaseService.instance.init();
});

// ============================================================
// Search Providers
// ============================================================

/// 검색어 상태 Notifier
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

/// 검색어 상태 Provider
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

/// 검색 결과 (검색어 기반 필터링)
///
/// 검색어가 변경될 때마다 자동으로 결과를 업데이트합니다.
final searchResultsProvider = Provider<List<FoodItem>>((ref) {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  return FoodDatabaseService.instance.searchFood(query);
});

// ============================================================
// Recent Foods Providers
// ============================================================

/// 최근 음식 관리 Notifier
///
/// 최근 선택한 음식 목록을 관리하고 SharedPreferences에 저장합니다.
class RecentFoodsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    _load();
    return [];
  }

  /// SharedPreferences에서 데이터 로드
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_recentFoodsKey) ?? [];
    state = data;
  }

  /// SharedPreferences에 데이터 저장
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentFoodsKey, state);
  }

  /// 음식 추가 (중복 시 맨 앞으로 이동)
  ///
  /// [foodId] 추가할 음식 ID
  /// 최대 [_maxRecentFoods]개까지만 저장됩니다.
  Future<void> addFood(String foodId) async {
    final newList = [foodId, ...state.where((id) => id != foodId)]
        .take(_maxRecentFoods)
        .toList();
    state = newList;
    await _save();
  }

  /// 음식 제거
  ///
  /// [foodId] 제거할 음식 ID
  Future<void> removeFood(String foodId) async {
    state = state.where((id) => id != foodId).toList();
    await _save();
  }

  /// 전체 삭제
  ///
  /// 최근 음식 목록을 모두 삭제합니다.
  Future<void> clear() async {
    state = [];
    await _save();
  }
}

/// 최근 선택한 음식 ID 목록 Provider
final recentFoodIdsProvider = NotifierProvider<RecentFoodsNotifier, List<String>>(
  RecentFoodsNotifier.new,
);

/// 최근 선택한 음식 목록 (FoodItem으로 변환)
///
/// 최근 음식 ID를 FoodItem 객체로 변환하여 반환합니다.
final recentFoodsProvider = Provider<List<FoodItem>>((ref) {
  final ids = ref.watch(recentFoodIdsProvider);
  return FoodDatabaseService.instance.getFoodsByIds(ids);
});

// ============================================================
// Favorite Foods Providers
// ============================================================

/// 즐겨찾기 음식 관리 Notifier
///
/// 즐겨찾기 음식 목록을 관리하고 SharedPreferences에 저장합니다.
class FavoriteFoodsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    _load();
    return [];
  }

  /// SharedPreferences에서 데이터 로드
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_favoriteFoodsKey) ?? [];
    state = data;
  }

  /// SharedPreferences에 데이터 저장
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoriteFoodsKey, state);
  }

  /// 즐겨찾기 토글
  ///
  /// [foodId]가 즐겨찾기에 있으면 제거, 없으면 추가합니다.
  Future<void> toggle(String foodId) async {
    if (state.contains(foodId)) {
      state = state.where((id) => id != foodId).toList();
    } else {
      state = [...state, foodId];
    }
    await _save();
  }

  /// 즐겨찾기 추가
  ///
  /// [foodId] 추가할 음식 ID
  /// 이미 즐겨찾기에 있으면 무시됩니다.
  Future<void> add(String foodId) async {
    if (!state.contains(foodId)) {
      state = [...state, foodId];
      await _save();
    }
  }

  /// 즐겨찾기 제거
  ///
  /// [foodId] 제거할 음식 ID
  Future<void> remove(String foodId) async {
    state = state.where((id) => id != foodId).toList();
    await _save();
  }
}

/// 즐겨찾기 음식 ID 목록 Provider
final favoriteFoodIdsProvider = NotifierProvider<FavoriteFoodsNotifier, List<String>>(
  FavoriteFoodsNotifier.new,
);

/// 즐겨찾기 음식 목록 (FoodItem으로 변환)
///
/// 즐겨찾기 음식 ID를 FoodItem 객체로 변환하여 반환합니다.
final favoriteFoodsProvider = Provider<List<FoodItem>>((ref) {
  final ids = ref.watch(favoriteFoodIdsProvider);
  return FoodDatabaseService.instance.getFoodsByIds(ids);
});

/// 특정 음식이 즐겨찾기인지 확인
///
/// [foodId]가 즐겨찾기 목록에 포함되어 있는지 확인합니다.
final isFavoriteFoodProvider = Provider.family<bool, String>((ref, foodId) {
  final favorites = ref.watch(favoriteFoodIdsProvider);
  return favorites.contains(foodId);
});
