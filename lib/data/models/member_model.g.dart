// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PtInfo _$PtInfoFromJson(Map<String, dynamic> json) => _PtInfo(
  totalSessions: (json['totalSessions'] as num).toInt(),
  completedSessions: (json['completedSessions'] as num?)?.toInt() ?? 0,
  startDate: const TimestampConverter().fromJson(json['startDate']),
);

Map<String, dynamic> _$PtInfoToJson(_PtInfo instance) => <String, dynamic>{
  'totalSessions': instance.totalSessions,
  'completedSessions': instance.completedSessions,
  'startDate': const TimestampConverter().toJson(instance.startDate),
};

_MemberModel _$MemberModelFromJson(Map<String, dynamic> json) => _MemberModel(
  id: json['id'] as String,
  userId: json['userId'] as String,
  trainerId: json['trainerId'] as String,
  goal: $enumDecode(_$FitnessGoalEnumMap, json['goal']),
  experience: $enumDecode(_$ExperienceLevelEnumMap, json['experience']),
  ptInfo: PtInfo.fromJson(json['ptInfo'] as Map<String, dynamic>),
  targetWeight: (json['targetWeight'] as num?)?.toDouble(),
  memo: json['memo'] as String?,
);

Map<String, dynamic> _$MemberModelToJson(_MemberModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'trainerId': instance.trainerId,
      'goal': _$FitnessGoalEnumMap[instance.goal]!,
      'experience': _$ExperienceLevelEnumMap[instance.experience]!,
      'ptInfo': instance.ptInfo,
      'targetWeight': instance.targetWeight,
      'memo': instance.memo,
    };

const _$FitnessGoalEnumMap = {
  FitnessGoal.diet: 'diet',
  FitnessGoal.bulk: 'bulk',
  FitnessGoal.fitness: 'fitness',
  FitnessGoal.rehab: 'rehab',
};

const _$ExperienceLevelEnumMap = {
  ExperienceLevel.beginner: 'beginner',
  ExperienceLevel.intermediate: 'intermediate',
  ExperienceLevel.advanced: 'advanced',
};
