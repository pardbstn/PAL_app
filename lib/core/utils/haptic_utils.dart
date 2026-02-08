import 'package:flutter/services.dart';

/// PAL 햅틱 피드백 유틸리티
///
/// 토스 스타일 햅틱 피드백을 제공합니다.
/// 모든 터치 인터랙션에서 적절한 햅틱을 사용하세요.
abstract class HapticUtils {
  HapticUtils._();

  /// 가벼운 탭 (버튼 클릭, 리스트 아이템 탭)
  static void light() => HapticFeedback.lightImpact();

  /// 중간 탭 (토글 전환, 슬라이더 조작)
  static void medium() => HapticFeedback.mediumImpact();

  /// 강한 탭 (삭제, 경고, 중요 액션)
  static void heavy() => HapticFeedback.heavyImpact();

  /// 선택 변경 (세그먼트 변경, 탭 전환)
  static void selection() => HapticFeedback.selectionClick();

  /// 성공 완료 (저장 완료, 제출 성공)
  static void success() => HapticFeedback.mediumImpact();

  /// 에러 발생
  static void error() => HapticFeedback.heavyImpact();

  /// 진동 (특별한 이벤트 - 목표 달성 등)
  static void vibrate() => HapticFeedback.vibrate();
}
