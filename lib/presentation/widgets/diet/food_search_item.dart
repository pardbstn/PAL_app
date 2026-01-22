import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/food_item_model.dart';
import '../../providers/food_search_provider.dart';

/// 음식 검색 결과 아이템 위젯
class FoodSearchItem extends ConsumerWidget {
  final FoodItem food;
  final VoidCallback onTap;

  const FoodSearchItem({
    super.key,
    required this.food,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isFavorite = ref.watch(isFavoriteFoodProvider(food.id));

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 음식 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 음식명
                    Text(
                      food.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // 1회제공량 | 칼로리
                    Text(
                      '${food.servingSizeText} | ${food.calories.toInt()}kcal',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // 탄단지
                    Text(
                      '탄 ${food.carbs.toInt()}g | 단 ${food.protein.toInt()}g | 지 ${food.fat.toInt()}g',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // 즐겨찾기 버튼
              IconButton(
                onPressed: () {
                  ref.read(favoriteFoodIdsProvider.notifier).toggle(food.id);
                },
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? theme.colorScheme.error : theme.hintColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
