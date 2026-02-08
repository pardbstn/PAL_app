import 'package:flutter/material.dart';
import '../../widgets/animated/micro_interactions.dart';

/// 마이크로 인터렉션 데모 화면
/// 모든 프리미엄 터치 피드백을 시연
class MicroInteractionsDemo extends StatefulWidget {
  const MicroInteractionsDemo({super.key});

  @override
  State<MicroInteractionsDemo> createState() => _MicroInteractionsDemoState();
}

class _MicroInteractionsDemoState extends State<MicroInteractionsDemo> {
  bool _toggleValue = false;
  final List<String> _items = List.generate(5, (i) => 'Item ${i + 1}');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('마이크로 인터렉션 데모'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // 1. PremiumTapFeedback
          _buildSection(
            '1. Premium Tap Feedback',
            '스프링 애니메이션 + 그림자 변화 + 햅틱',
            PremiumTapFeedback(
              onTap: () => _showSnackBar('탭!'),
              onLongPress: () => _showSnackBar('롱프레스!'),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '탭하거나 길게 눌러보세요',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // 2. PremiumHoverEffect
          _buildSection(
            '2. Premium Hover Effect',
            '그림자 + 스케일 + 글로우 (웹/데스크톱)',
            PremiumHoverEffect(
              onTap: () => _showSnackBar('호버 카드 클릭!'),
              glowIntensity: 0.5,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.mouse,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '마우스를 올려보세요',
                      style: TextStyle(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // 3. PremiumInkEffect
          _buildSection(
            '3. Premium Ink Effect',
            '개선된 리플 효과',
            PremiumInkEffect(
              onTap: () => _showSnackBar('잉크 효과!'),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.water_drop,
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '리플 효과 확인',
                      style: TextStyle(
                        color: theme.colorScheme.onTertiaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // 4. InteractiveCard
          _buildSection(
            '4. Interactive Card',
            '3D 기울기 + 반사 효과 (웹/데스크톱)',
            InteractiveCard(
              onTap: () => _showSnackBar('인터랙티브 카드!'),
              maxTiltAngle: 15,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.threed_rotation, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      '마우스로 기울여보세요',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // 5. ToggleFeedback
          _buildSection(
            '5. Toggle Feedback',
            '스위치/토글 햅틱 피드백',
            ToggleFeedback(
              value: _toggleValue,
              onChanged: (value) => setState(() => _toggleValue = value),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _toggleValue
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _toggleValue
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _toggleValue ? Icons.toggle_on : Icons.toggle_off,
                      color: _toggleValue
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurface,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _toggleValue ? '켜짐' : '꺼짐',
                      style: TextStyle(
                        color: _toggleValue
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // 6. SwipeDeleteFeedback
          _buildSection(
            '6. Swipe Delete Feedback',
            '슬라이드 삭제 제스처',
            Column(
              children: _items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SwipeDeleteFeedback(
                    onDelete: () {
                      setState(() => _items.remove(item));
                      _showSnackBar('$item 삭제됨');
                    },
                    deleteColor: theme.colorScheme.error,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.drag_indicator,
                            color: theme.colorScheme.onSurface,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            item,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '← 왼쪽으로 스와이프',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 32),

          // 7. LongPressFeedback
          _buildSection(
            '7. Long Press Feedback',
            '롱프레스 진행 표시',
            LongPressFeedback(
              onTap: () => _showSnackBar('일반 탭'),
              onLongPress: () => _showSnackBar('롱프레스 완료!'),
              longPressDuration: const Duration(milliseconds: 800),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timer,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '길게 눌러보세요',
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // 기존 위젯들
          _buildSection(
            '기존 위젯 - TapFeedback',
            '간단한 탭 피드백',
            TapFeedback(
              onTap: () => _showSnackBar('기존 TapFeedback'),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '기존 탭 피드백 (하위 호환)',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          _buildSection(
            '기존 위젯 - HoverEffect',
            '간단한 호버 효과',
            HoverEffect(
              onTap: () => _showSnackBar('기존 HoverEffect'),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '기존 호버 효과 (하위 호환)',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String description, Widget child) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
