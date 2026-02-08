import 'package:flutter/material.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/core/theme/app_tokens.dart';
import 'package:flutter_pal_app/data/models/subscription_model.dart';

/// 구독 플랜 카드 위젯
/// 무료/프리미엄 플랜의 정보를 표시하고 선택/업그레이드 기능 제공
class SubscriptionCard extends StatelessWidget {
  /// 플랜 종류
  final SubscriptionPlan plan;

  /// 월 가격 (무료면 0)
  final int monthlyPrice;

  /// 기능 목록
  final List<SubscriptionFeature> features;

  /// 현재 플랜 여부
  final bool isCurrentPlan;

  /// 추천 플랜 여부 (하이라이트 테두리)
  final bool isRecommended;

  /// 선택/업그레이드 버튼 콜백
  final VoidCallback? onSelect;

  /// 로딩 상태
  final bool isLoading;

  const SubscriptionCard({
    super.key,
    required this.plan,
    required this.monthlyPrice,
    required this.features,
    this.isCurrentPlan = false,
    this.isRecommended = false,
    this.onSelect,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPremium = plan == SubscriptionPlan.premium;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isRecommended
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primary,
                  AppTheme.primary.withValues(alpha: 0.8),
                ],
              )
            : null,
        boxShadow: isRecommended
            ? [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      padding: isRecommended ? const EdgeInsets.all(3) : EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(isRecommended ? 14 : 16),
          border: isRecommended
              ? null
              : Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.gray100,
                  width: 1,
                ),
          boxShadow: isRecommended
              ? null
              : AppShadows.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 헤더 영역
            _buildHeader(context, isPremium),
            // 가격 영역
            _buildPriceSection(context, isPremium),
            // 기능 목록
            _buildFeaturesList(context),
            // 버튼 영역
            _buildActionButton(context, isPremium),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isPremium) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          // 플랜 아이콘
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPremium
                  ? AppTheme.primary.withValues(alpha: 0.1)
                  : (isDark ? Colors.white10 : Colors.grey.shade100),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPremium ? Icons.workspace_premium : Icons.person_outline,
              size: 24,
              color: isPremium
                  ? AppTheme.primary
                  : (isDark ? Colors.white70 : Colors.black54),
            ),
          ),
          const SizedBox(width: 12),
          // 플랜 이름
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.label,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isRecommended)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '추천',
                      style: TextStyle(
                        color: AppTheme.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // 현재 플랜 배지
          if (isCurrentPlan)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.secondary.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppTheme.secondary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '현재 플랜',
                    style: TextStyle(
                      color: AppTheme.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(BuildContext context, bool isPremium) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (monthlyPrice == 0)
            Text(
              '무료',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            )
          else ...[
            Text(
              _formatPrice(monthlyPrice),
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '원/월',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 8),
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: feature.isIncluded
                            ? AppTheme.secondary.withValues(alpha: 0.1)
                            : (isDark ? Colors.white10 : Colors.grey.shade100),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        feature.isIncluded ? Icons.check : Icons.close,
                        size: 16,
                        color: feature.isIncluded
                            ? AppTheme.secondary
                            : (isDark ? Colors.white38 : Colors.black26),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feature.title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: feature.isIncluded
                                  ? null
                                  : (isDark ? Colors.white38 : Colors.black38),
                              decoration: feature.isIncluded
                                  ? null
                                  : TextDecoration.lineThrough,
                            ),
                          ),
                          if (feature.description != null)
                            Text(
                              feature.description!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (feature.badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          feature.badge!,
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, bool isPremium) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: isCurrentPlan || isLoading ? null : onSelect,
        style: ElevatedButton.styleFrom(
          backgroundColor: isCurrentPlan
              ? (isDark ? Colors.white10 : Colors.grey.shade200)
              : (isPremium ? AppTheme.primary : Colors.transparent),
          foregroundColor: isCurrentPlan
              ? (isDark ? Colors.white38 : Colors.black38)
              : (isPremium ? Colors.white : AppTheme.primary),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isPremium || isCurrentPlan
                ? BorderSide.none
                : const BorderSide(color: AppTheme.primary, width: 2),
          ),
          elevation: isPremium && !isCurrentPlan ? 2 : 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                isCurrentPlan
                    ? '현재 사용 중'
                    : (isPremium ? '프리미엄 시작하기' : '무료로 시작'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

/// 구독 기능 모델
class SubscriptionFeature {
  final String title;
  final String? description;
  final bool isIncluded;
  final String? badge;

  const SubscriptionFeature({
    required this.title,
    this.description,
    required this.isIncluded,
    this.badge,
  });
}

/// 무료 플랜 기능 목록
const List<SubscriptionFeature> freeFeatures = [
  SubscriptionFeature(
    title: '체중/운동 기록',
    description: '무제한 기록',
    isIncluded: true,
  ),
  SubscriptionFeature(
    title: '진행 그래프',
    description: '체중, 인바디 추이',
    isIncluded: true,
  ),
  SubscriptionFeature(
    title: 'AI 운동 추천',
    isIncluded: false,
  ),
  SubscriptionFeature(
    title: 'AI 식단 분석',
    isIncluded: false,
  ),
  SubscriptionFeature(
    title: '월간 리포트',
    isIncluded: false,
  ),
  SubscriptionFeature(
    title: '트레이너 질문',
    isIncluded: false,
  ),
];

/// 프리미엄 플랜 기능 목록
const List<SubscriptionFeature> premiumFeatures = [
  SubscriptionFeature(
    title: '체중/운동 기록',
    description: '무제한 기록',
    isIncluded: true,
  ),
  SubscriptionFeature(
    title: '진행 그래프',
    description: '체중, 인바디 추이',
    isIncluded: true,
  ),
  SubscriptionFeature(
    title: 'AI 운동 추천',
    description: '맞춤형 프로그램',
    isIncluded: true,
    badge: 'AI',
  ),
  SubscriptionFeature(
    title: 'AI 식단 분석',
    description: '영양 밸런스 체크',
    isIncluded: true,
    badge: 'AI',
  ),
  SubscriptionFeature(
    title: '월간 리포트',
    description: '상세 진행 분석',
    isIncluded: true,
    badge: 'NEW',
  ),
  SubscriptionFeature(
    title: '트레이너 질문',
    description: '월 3회',
    isIncluded: true,
  ),
];
