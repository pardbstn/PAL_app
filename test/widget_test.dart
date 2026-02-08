// PAL 앱 기본 테스트
//
// Firebase 앱은 통합 테스트가 필요하므로
// 여기서는 기본 유닛 테스트만 수행

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pal_app/data/models/member_model.dart';

void main() {
  group('MemberModel 테스트', () {
    test('FitnessGoal 라벨이 올바르게 반환되어야 함', () {
      // 다이어트 목표 테스트
      expect(FitnessGoal.diet.name, 'diet');
      expect(FitnessGoal.bulk.name, 'bulk');
      expect(FitnessGoal.fitness.name, 'fitness');
      expect(FitnessGoal.rehab.name, 'rehab');
    });

    test('ExperienceLevel 값이 올바르게 정의되어야 함', () {
      expect(ExperienceLevel.beginner.name, 'beginner');
      expect(ExperienceLevel.intermediate.name, 'intermediate');
      expect(ExperienceLevel.advanced.name, 'advanced');
    });
  });

  group('PtInfo 테스트', () {
    test('PtInfo 생성이 올바르게 되어야 함', () {
      final ptInfo = PtInfo(
        totalSessions: 30,
        completedSessions: 10,
        startDate: DateTime(2024, 1, 1),
      );

      expect(ptInfo.totalSessions, 30);
      expect(ptInfo.completedSessions, 10);
    });
  });
}
