import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/diet_record_model.dart';
import '../../../data/models/food_item_model.dart';
import '../../providers/food_search_provider.dart';
import 'food_search_item.dart';
import 'serving_size_dialog.dart';

/// 음식 검색 바텀시트
/// 끼니별 음식 추가 시 표시
class FoodSearchBottomSheet extends ConsumerStatefulWidget {
  final MealType mealType;
  final DateTime date;
  final Function(FoodItem food, double servingMultiplier) onFoodSelected;

  const FoodSearchBottomSheet({
    super.key,
    required this.mealType,
    required this.date,
    required this.onFoodSelected,
  });

  /// 바텀시트 표시 헬퍼 메서드
  static Future<void> show({
    required BuildContext context,
    required MealType mealType,
    required DateTime date,
    required Function(FoodItem food, double servingMultiplier) onFoodSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FoodSearchBottomSheet(
        mealType: mealType,
        date: date,
        onFoodSelected: onFoodSelected,
      ),
    );
  }

  @override
  ConsumerState<FoodSearchBottomSheet> createState() =>
      _FoodSearchBottomSheetState();
}

class _FoodSearchBottomSheetState extends ConsumerState<FoodSearchBottomSheet> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // 데이터베이스 초기화
    ref.read(foodDatabaseProvider);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 검색어 변경 처리
  void _onSearchChanged(String query) {
    ref.read(searchQueryProvider.notifier).setQuery(query);
  }

  /// 음식 항목 탭 처리
  void _onFoodTap(FoodItem food) async {
    // 최근 음식에 추가
    ref.read(recentFoodIdsProvider.notifier).addFood(food.id);

    // 수량 선택 다이얼로그
    final result = await ServingSizeDialog.show(
      context: context,
      food: food,
    );

    if (result != null && mounted) {
      widget.onFoodSelected(food, result);
      Navigator.of(context).pop();
    }
  }

  /// 식사 타입 라벨
  String _getMealTypeLabel(MealType mealType) {
    return switch (mealType) {
      MealType.breakfast => '아침',
      MealType.lunch => '점심',
      MealType.dinner => '저녁',
      MealType.snack => '간식',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final searchQuery = ref.watch(searchQueryProvider);
    final searchResults = ref.watch(searchResultsProvider);
    final recentFoods = ref.watch(recentFoodsProvider);
    final favoriteFoods = ref.watch(favoriteFoodsProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 핸들 바
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 제목
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  '${_getMealTypeLabel(widget.mealType)} 음식 추가',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // 검색창
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: '음식 이름 검색',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
              ),
            ),
          ),

          // 컨텐츠
          Expanded(
            child: searchQuery.isEmpty
                ? _buildDefaultContent(recentFoods, favoriteFoods)
                : _buildSearchResults(searchResults),
          ),
        ],
      ),
    );
  }

  /// 검색 전 기본 컨텐츠 (최근 음식 + 즐겨찾기)
  Widget _buildDefaultContent(
      List<FoodItem> recent, List<FoodItem> favorites) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (recent.isEmpty && favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '음식을 검색해 보세요',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // 즐겨찾기 섹션
        if (favorites.isNotEmpty) ...[
          _buildSectionHeader(
            '즐겨찾기',
            Icons.favorite,
            Theme.of(context).colorScheme.error,
          ),
          ...favorites.map(
            (food) => FoodSearchItem(
              food: food,
              onTap: () => _onFoodTap(food),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // 최근 먹은 음식 섹션
        if (recent.isNotEmpty) ...[
          _buildSectionHeader('최근 먹은 음식', Icons.history, null),
          ...recent.map(
            (food) => FoodSearchItem(
              food: food,
              onTap: () => _onFoodTap(food),
            ),
          ),
        ],
      ],
    );
  }

  /// 검색 결과
  Widget _buildSearchResults(List<FoodItem> results) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '검색 결과가 없어요',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final food = results[index];
        return FoodSearchItem(
          food: food,
          onTap: () => _onFoodTap(food),
        );
      },
    );
  }

  /// 섹션 헤더
  Widget _buildSectionHeader(String title, IconData icon, Color? iconColor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: iconColor ?? colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
