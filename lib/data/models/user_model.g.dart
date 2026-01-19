// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  uid: json['uid'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  role: $enumDecode(_$UserRoleTypeEnumMap, json['role']),
  profileImageUrl: json['profileImageUrl'] as String?,
  phone: json['phone'] as String?,
  memberCode: json['memberCode'] as String?,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'name': instance.name,
      'role': _$UserRoleTypeEnumMap[instance.role]!,
      'profileImageUrl': instance.profileImageUrl,
      'phone': instance.phone,
      'memberCode': instance.memberCode,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

const _$UserRoleTypeEnumMap = {
  UserRoleType.trainer: 'trainer',
  UserRoleType.member: 'member',
};
