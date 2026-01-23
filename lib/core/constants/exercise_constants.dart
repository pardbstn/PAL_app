/// 운동 DB 로컬 데이터 (Firestore 데이터 없을 때 사용)
class ExerciseConstants {
  ExerciseConstants._();

  /// 전체 운동 목록
  static const List<Map<String, dynamic>> exercises = [
    // 가슴
    {'id': 'ex_001', 'nameKo': '바벨 벤치프레스', 'equipment': '바벨', 'primaryMuscle': '가슴', 'level': '중급'},
    {'id': 'ex_002', 'nameKo': '덤벨 벤치프레스', 'equipment': '덤벨', 'primaryMuscle': '가슴', 'level': '중급'},
    {'id': 'ex_003', 'nameKo': '인클라인 바벨 벤치프레스', 'equipment': '바벨', 'primaryMuscle': '가슴', 'level': '중급'},
    {'id': 'ex_004', 'nameKo': '인클라인 덤벨 벤치프레스', 'equipment': '덤벨', 'primaryMuscle': '가슴', 'level': '중급'},
    {'id': 'ex_005', 'nameKo': '디클라인 벤치프레스', 'equipment': '바벨', 'primaryMuscle': '가슴', 'level': '중급'},
    {'id': 'ex_006', 'nameKo': '덤벨 플라이', 'equipment': '덤벨', 'primaryMuscle': '가슴', 'level': '초급'},
    {'id': 'ex_007', 'nameKo': '케이블 크로스오버', 'equipment': '케이블', 'primaryMuscle': '가슴', 'level': '중급'},
    {'id': 'ex_008', 'nameKo': '체스트 프레스 머신', 'equipment': '머신', 'primaryMuscle': '가슴', 'level': '초급'},
    {'id': 'ex_009', 'nameKo': '펙 덱 플라이', 'equipment': '머신', 'primaryMuscle': '가슴', 'level': '초급'},
    {'id': 'ex_010', 'nameKo': '푸쉬업', 'equipment': '맨몸', 'primaryMuscle': '가슴', 'level': '초급'},
    {'id': 'ex_011', 'nameKo': '딥스', 'equipment': '맨몸', 'primaryMuscle': '가슴', 'level': '중급'},
    {'id': 'ex_012', 'nameKo': '인클라인 덤벨 플라이', 'equipment': '덤벨', 'primaryMuscle': '가슴', 'level': '중급'},

    // 등
    {'id': 'ex_013', 'nameKo': '바벨 로우', 'equipment': '바벨', 'primaryMuscle': '등', 'level': '중급'},
    {'id': 'ex_014', 'nameKo': '덤벨 로우', 'equipment': '덤벨', 'primaryMuscle': '등', 'level': '초급'},
    {'id': 'ex_015', 'nameKo': '랫 풀다운', 'equipment': '케이블', 'primaryMuscle': '등', 'level': '초급'},
    {'id': 'ex_016', 'nameKo': '시티드 로우', 'equipment': '케이블', 'primaryMuscle': '등', 'level': '초급'},
    {'id': 'ex_017', 'nameKo': '풀업', 'equipment': '맨몸', 'primaryMuscle': '등', 'level': '중급'},
    {'id': 'ex_018', 'nameKo': '데드리프트', 'equipment': '바벨', 'primaryMuscle': '등', 'level': '고급'},
    {'id': 'ex_019', 'nameKo': '티바 로우', 'equipment': '바벨', 'primaryMuscle': '등', 'level': '중급'},
    {'id': 'ex_020', 'nameKo': '페이스 풀', 'equipment': '케이블', 'primaryMuscle': '등', 'level': '초급'},
    {'id': 'ex_021', 'nameKo': '케이블 로우', 'equipment': '케이블', 'primaryMuscle': '등', 'level': '초급'},
    {'id': 'ex_022', 'nameKo': '원암 덤벨 로우', 'equipment': '덤벨', 'primaryMuscle': '등', 'level': '초급'},
    {'id': 'ex_023', 'nameKo': '하이퍼 익스텐션', 'equipment': '맨몸', 'primaryMuscle': '등', 'level': '초급'},
    {'id': 'ex_024', 'nameKo': '루마니안 데드리프트', 'equipment': '바벨', 'primaryMuscle': '등', 'level': '중급'},

    // 하체
    {'id': 'ex_025', 'nameKo': '바벨 스쿼트', 'equipment': '바벨', 'primaryMuscle': '하체', 'level': '중급'},
    {'id': 'ex_026', 'nameKo': '레그 프레스', 'equipment': '머신', 'primaryMuscle': '하체', 'level': '초급'},
    {'id': 'ex_027', 'nameKo': '레그 익스텐션', 'equipment': '머신', 'primaryMuscle': '하체', 'level': '초급'},
    {'id': 'ex_028', 'nameKo': '레그 컬', 'equipment': '머신', 'primaryMuscle': '하체', 'level': '초급'},
    {'id': 'ex_029', 'nameKo': '런지', 'equipment': '덤벨', 'primaryMuscle': '하체', 'level': '초급'},
    {'id': 'ex_030', 'nameKo': '불가리안 스플릿 스쿼트', 'equipment': '덤벨', 'primaryMuscle': '하체', 'level': '중급'},
    {'id': 'ex_031', 'nameKo': '프론트 스쿼트', 'equipment': '바벨', 'primaryMuscle': '하체', 'level': '고급'},
    {'id': 'ex_032', 'nameKo': '고블릿 스쿼트', 'equipment': '덤벨', 'primaryMuscle': '하체', 'level': '초급'},
    {'id': 'ex_033', 'nameKo': '힙 쓰러스트', 'equipment': '바벨', 'primaryMuscle': '하체', 'level': '중급'},
    {'id': 'ex_034', 'nameKo': '카프 레이즈', 'equipment': '머신', 'primaryMuscle': '하체', 'level': '초급'},
    {'id': 'ex_035', 'nameKo': '핵 스쿼트', 'equipment': '머신', 'primaryMuscle': '하체', 'level': '중급'},
    {'id': 'ex_036', 'nameKo': '덤벨 루마니안 데드리프트', 'equipment': '덤벨', 'primaryMuscle': '하체', 'level': '중급'},
    {'id': 'ex_037', 'nameKo': '스모 데드리프트', 'equipment': '바벨', 'primaryMuscle': '하체', 'level': '고급'},
    {'id': 'ex_038', 'nameKo': '스텝업', 'equipment': '덤벨', 'primaryMuscle': '하체', 'level': '초급'},

    // 어깨
    {'id': 'ex_039', 'nameKo': '바벨 오버헤드 프레스', 'equipment': '바벨', 'primaryMuscle': '어깨', 'level': '중급'},
    {'id': 'ex_040', 'nameKo': '덤벨 숄더 프레스', 'equipment': '덤벨', 'primaryMuscle': '어깨', 'level': '중급'},
    {'id': 'ex_041', 'nameKo': '덤벨 사이드 레터럴 레이즈', 'equipment': '덤벨', 'primaryMuscle': '어깨', 'level': '초급'},
    {'id': 'ex_042', 'nameKo': '덤벨 프론트 레이즈', 'equipment': '덤벨', 'primaryMuscle': '어깨', 'level': '초급'},
    {'id': 'ex_043', 'nameKo': '덤벨 리어 델트 플라이', 'equipment': '덤벨', 'primaryMuscle': '어깨', 'level': '초급'},
    {'id': 'ex_044', 'nameKo': '케이블 사이드 레터럴 레이즈', 'equipment': '케이블', 'primaryMuscle': '어깨', 'level': '초급'},
    {'id': 'ex_045', 'nameKo': '머신 숄더 프레스', 'equipment': '머신', 'primaryMuscle': '어깨', 'level': '초급'},
    {'id': 'ex_046', 'nameKo': '아놀드 프레스', 'equipment': '덤벨', 'primaryMuscle': '어깨', 'level': '중급'},
    {'id': 'ex_047', 'nameKo': '바벨 업라이트 로우', 'equipment': '바벨', 'primaryMuscle': '어깨', 'level': '중급'},
    {'id': 'ex_048', 'nameKo': '리버스 펙 덱', 'equipment': '머신', 'primaryMuscle': '어깨', 'level': '초급'},

    // 팔 (이두)
    {'id': 'ex_049', 'nameKo': '바벨 컬', 'equipment': '바벨', 'primaryMuscle': '팔', 'level': '초급'},
    {'id': 'ex_050', 'nameKo': '덤벨 컬', 'equipment': '덤벨', 'primaryMuscle': '팔', 'level': '초급'},
    {'id': 'ex_051', 'nameKo': '해머 컬', 'equipment': '덤벨', 'primaryMuscle': '팔', 'level': '초급'},
    {'id': 'ex_052', 'nameKo': '프리처 컬', 'equipment': '바벨', 'primaryMuscle': '팔', 'level': '초급'},
    {'id': 'ex_053', 'nameKo': '케이블 컬', 'equipment': '케이블', 'primaryMuscle': '팔', 'level': '초급'},
    {'id': 'ex_054', 'nameKo': '인클라인 덤벨 컬', 'equipment': '덤벨', 'primaryMuscle': '팔', 'level': '중급'},
    {'id': 'ex_055', 'nameKo': '컨센트레이션 컬', 'equipment': '덤벨', 'primaryMuscle': '팔', 'level': '초급'},

    // 팔 (삼두)
    {'id': 'ex_056', 'nameKo': '트라이셉스 푸쉬다운', 'equipment': '케이블', 'primaryMuscle': '팔', 'level': '초급'},
    {'id': 'ex_057', 'nameKo': '오버헤드 트라이셉스 익스텐션', 'equipment': '덤벨', 'primaryMuscle': '팔', 'level': '초급'},
    {'id': 'ex_058', 'nameKo': '스컬 크러셔', 'equipment': '바벨', 'primaryMuscle': '팔', 'level': '중급'},
    {'id': 'ex_059', 'nameKo': '클로즈그립 벤치프레스', 'equipment': '바벨', 'primaryMuscle': '팔', 'level': '중급'},
    {'id': 'ex_060', 'nameKo': '케이블 오버헤드 익스텐션', 'equipment': '케이블', 'primaryMuscle': '팔', 'level': '초급'},
    {'id': 'ex_061', 'nameKo': '킥백', 'equipment': '덤벨', 'primaryMuscle': '팔', 'level': '초급'},
    {'id': 'ex_062', 'nameKo': '다이아몬드 푸쉬업', 'equipment': '맨몸', 'primaryMuscle': '팔', 'level': '중급'},

    // 복근
    {'id': 'ex_063', 'nameKo': '크런치', 'equipment': '맨몸', 'primaryMuscle': '복근', 'level': '초급'},
    {'id': 'ex_064', 'nameKo': '레그 레이즈', 'equipment': '맨몸', 'primaryMuscle': '복근', 'level': '초급'},
    {'id': 'ex_065', 'nameKo': '플랭크', 'equipment': '맨몸', 'primaryMuscle': '복근', 'level': '초급'},
    {'id': 'ex_066', 'nameKo': '행잉 레그 레이즈', 'equipment': '맨몸', 'primaryMuscle': '복근', 'level': '중급'},
    {'id': 'ex_067', 'nameKo': '케이블 크런치', 'equipment': '케이블', 'primaryMuscle': '복근', 'level': '중급'},
    {'id': 'ex_068', 'nameKo': '러시안 트위스트', 'equipment': '맨몸', 'primaryMuscle': '복근', 'level': '초급'},
    {'id': 'ex_069', 'nameKo': '바이시클 크런치', 'equipment': '맨몸', 'primaryMuscle': '복근', 'level': '초급'},
    {'id': 'ex_070', 'nameKo': '사이드 플랭크', 'equipment': '맨몸', 'primaryMuscle': '복근', 'level': '초급'},
    {'id': 'ex_071', 'nameKo': 'AB 롤아웃', 'equipment': '맨몸', 'primaryMuscle': '복근', 'level': '중급'},
    {'id': 'ex_072', 'nameKo': '마운틴 클라이머', 'equipment': '맨몸', 'primaryMuscle': '복근', 'level': '초급'},

    // 추가 복합 운동
    {'id': 'ex_073', 'nameKo': '바벨 클린', 'equipment': '바벨', 'primaryMuscle': '전신', 'level': '고급'},
    {'id': 'ex_074', 'nameKo': '케틀벨 스윙', 'equipment': '덤벨', 'primaryMuscle': '전신', 'level': '중급'},
    {'id': 'ex_075', 'nameKo': '버피', 'equipment': '맨몸', 'primaryMuscle': '전신', 'level': '중급'},
    {'id': 'ex_076', 'nameKo': '트랩바 데드리프트', 'equipment': '바벨', 'primaryMuscle': '하체', 'level': '중급'},
    {'id': 'ex_077', 'nameKo': '컨벤셔널 데드리프트', 'equipment': '바벨', 'primaryMuscle': '등', 'level': '고급'},
    {'id': 'ex_078', 'nameKo': '랙 풀', 'equipment': '바벨', 'primaryMuscle': '등', 'level': '중급'},
    {'id': 'ex_079', 'nameKo': '와이드 그립 풀업', 'equipment': '맨몸', 'primaryMuscle': '등', 'level': '중급'},
    {'id': 'ex_080', 'nameKo': '클로즈 그립 랫 풀다운', 'equipment': '케이블', 'primaryMuscle': '등', 'level': '초급'},
  ];
}
