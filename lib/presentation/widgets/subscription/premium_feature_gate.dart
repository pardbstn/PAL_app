import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 프리미엄 기능 게이트 위젯
/// 프리미엄 전용 기능을 감싸서 접근 권한이 없으면 잠금 오버레이를 표시
class PremiumFeatureGate extends ConsumerWidget {
  /// 감쌀 자식 위젯
  final Widget child;

  /// 기능 키 (ai_workout_recommendation, ai_diet_analysis, monthly_report, trainer_question)
  final String featureKey;

  /// 잠금 아이콘 크기
  final double iconSize;

  /// 오버레이 blur 강도
  final double blurStrength;

  /// 잠금 메시지 (기본값: 프리미엄 전용)
  final String? lockedMessage;

  /// 잠금 시 탭 콜백 (null이면 기본 업그레이드 프롬프트)
  final VoidCallback? onLockedTap;

  const PremiumFeatureGate({
    super.key,
    required this.child,
    required this.featureKey,
    this.iconSize = 32,
    this.blurStrength = 5.0,
    this.lockedMessage,
    this.onLockedTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 모든 기능 무료 개방 - 프리미엄 제한 없음
    return child;
  }
}
