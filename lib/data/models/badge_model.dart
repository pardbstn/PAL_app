import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'streak_model.dart';

part 'badge_model.freezed.dart';
part 'badge_model.g.dart';

enum BadgeType {
  @JsonValue('streak')
  streak('연속 기록'),
  @JsonValue('achievement')
  achievement('목표 달성'),
  @JsonValue('milestone')
  milestone('마일스톤');

  final String label;
  const BadgeType(this.label);
}

@freezed
sealed class BadgeModel with _$BadgeModel {
  const factory BadgeModel({
    required String id,
    required String code,
    required String name,
    required String description,
    required String iconUrl,
    required int requiredStreak,
    required StreakType streakType,
    @Default(BadgeType.streak) BadgeType badgeType,
  }) = _BadgeModel;

  factory BadgeModel.fromJson(Map<String, dynamic> json) =>
      _$BadgeModelFromJson(json);

  factory BadgeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BadgeModel.fromJson({...data, 'id': doc.id});
  }
}

extension BadgeModelX on BadgeModel {
  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'requiredStreak': requiredStreak,
      'streakType': streakType.name,
      'badgeType': badgeType.name,
    };
  }

  bool isEarned(StreakModel streak) {
    final currentStreak = streakType == StreakType.weight
        ? streak.weightStreak
        : streak.dietStreak;
    return currentStreak >= requiredStreak;
  }
}

// 기본 배지 정의
class DefaultBadges {
  static const List<Map<String, dynamic>> badges = [
    {
      'code': 'weight_7day',
      'name': '7일 연속 체중 기록',
      'description': '7일 연속으로 체중을 기록했습니다!',
      'iconUrl': 'assets/badges/weight_7.png',
      'requiredStreak': 7,
      'streakType': 'weight',
    },
    {
      'code': 'weight_30day',
      'name': '30일 연속 체중 기록',
      'description': '한 달 동안 매일 체중을 기록했습니다!',
      'iconUrl': 'assets/badges/weight_30.png',
      'requiredStreak': 30,
      'streakType': 'weight',
    },
    {
      'code': 'diet_7day',
      'name': '7일 연속 식단 기록',
      'description': '7일 연속으로 식단을 기록했습니다!',
      'iconUrl': 'assets/badges/diet_7.png',
      'requiredStreak': 7,
      'streakType': 'diet',
    },
    {
      'code': 'diet_30day',
      'name': '30일 연속 식단 기록',
      'description': '한 달 동안 매일 식단을 기록했습니다!',
      'iconUrl': 'assets/badges/diet_30.png',
      'requiredStreak': 30,
      'streakType': 'diet',
    },
  ];
}
