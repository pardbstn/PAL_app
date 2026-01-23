import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_db_model.freezed.dart';
part 'exercise_db_model.g.dart';

/// 운동 DB 모델
/// /exercises 컬렉션 - 800개 한국어 번역 운동 데이터
@freezed
sealed class ExerciseDbModel with _$ExerciseDbModel {
  const factory ExerciseDbModel({
    /// 문서 ID
    required String id,

    /// 한글 운동명 (예: "바벨 벤치프레스")
    required String nameKo,

    /// 영문 운동명
    @Default('') String nameEn,

    /// 장비 (바벨, 덤벨, 케이블, 머신, 맨몸)
    required String equipment,

    /// 영문 장비명
    @Default('') String equipmentEn,

    /// 주요 근육군 (가슴, 등, 하체, 어깨, 팔, 복근)
    required String primaryMuscle,

    /// 보조 근육군
    @Default([]) List<String> secondaryMuscles,

    /// 난이도 (초급, 중급, 고급)
    @Default('초급') String level,

    /// 힘 방향 (push, pull, static)
    String? force,

    /// 운동 유형 (compound, isolation)
    String? mechanic,

    /// 운동 설명
    @Default([]) List<String> instructions,

    /// 이미지 URL
    String? imageUrl,

    /// 검색용 태그
    @Default([]) List<String> tags,
  }) = _ExerciseDbModel;

  factory ExerciseDbModel.fromJson(Map<String, dynamic> json) =>
      _$ExerciseDbModelFromJson(json);

  /// Firestore 문서로부터 생성
  factory ExerciseDbModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExerciseDbModel.fromJson({...data, 'id': doc.id});
  }
}

/// ExerciseDbModel 확장 메서드
extension ExerciseDbModelX on ExerciseDbModel {
  /// Firestore 저장용 Map 변환
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // ID는 문서 ID로 사용
    return json;
  }
}
