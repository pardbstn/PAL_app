// ignore_for_file: avoid_print
/// PAL 심사용 데모 데이터 생성 스크립트
///
/// 실행 방법:
/// ```bash
/// cd scripts
/// dart pub get
/// dart run seed_demo_data.dart
/// ```
///
/// 환경 설정:
/// - Firebase 프로젝트 ID와 API Key 필요 (아래 상수 수정)
///
/// 생성되는 데이터:
/// - 트레이너 1명 (test@pal.com / password123)
/// - 회원 5명 (다이어트성공, 벌크업중, 출석률하락, PT종료임박, 신규)
/// - 각 회원별 8주치 체중 기록
/// - 각 회원별 4주치 운동 기록
/// - 각 회원별 1주치 식단 기록
/// - 각 회원별 인바디 기록 2회
/// - 각 회원별 채팅 메시지 10개
library;

import 'dart:math';
import 'package:firedart/firedart.dart';
import 'package:uuid/uuid.dart';

// ============================================================
// Firebase 설정 (프로젝트에 맞게 수정 필요)
// ============================================================

const String firebaseProjectId = 'pal-app-demo'; // Firebase 프로젝트 ID
const String firebaseApiKey = 'YOUR_API_KEY'; // Firebase Web API Key

// ============================================================
// 상수 정의
// ============================================================

const String trainerEmail = 'test@pal.com';
const String trainerPassword = 'password123';
const String trainerName = '김태훈';
const String trainerPhone = '010-1234-5678';

final random = Random();
final uuid = Uuid();

// 회원 시나리오 정의
final memberScenarios = [
  {
    'name': '박지민',
    'email': 'member1@test.com',
    'gender': 'female',
    'birthDate': DateTime(1995, 3, 15),
    'height': 165.0,
    'goal': 'diet',
    'experience': 'beginner',
    'scenario': 'diet_success',
    'startWeight': 68.0,
    'currentWeight': 58.5,
    'targetWeight': 55.0,
    'totalSessions': 24,
    'completedSessions': 20,
  },
  {
    'name': '이준호',
    'email': 'member2@test.com',
    'gender': 'male',
    'birthDate': DateTime(1992, 7, 22),
    'height': 178.0,
    'goal': 'bulk',
    'experience': 'intermediate',
    'scenario': 'bulking',
    'startWeight': 70.0,
    'currentWeight': 76.5,
    'targetWeight': 80.0,
    'totalSessions': 36,
    'completedSessions': 18,
  },
  {
    'name': '김서연',
    'email': 'member3@test.com',
    'gender': 'female',
    'birthDate': DateTime(1998, 11, 8),
    'height': 162.0,
    'goal': 'fitness',
    'experience': 'beginner',
    'scenario': 'attendance_drop',
    'startWeight': 55.0,
    'currentWeight': 56.2,
    'targetWeight': 52.0,
    'totalSessions': 24,
    'completedSessions': 8,
  },
  {
    'name': '최민수',
    'email': 'member4@test.com',
    'gender': 'male',
    'birthDate': DateTime(1988, 5, 30),
    'height': 175.0,
    'goal': 'diet',
    'experience': 'advanced',
    'scenario': 'ending_soon',
    'startWeight': 85.0,
    'currentWeight': 78.0,
    'targetWeight': 75.0,
    'totalSessions': 24,
    'completedSessions': 22,
  },
  {
    'name': '정하늘',
    'email': 'member5@test.com',
    'gender': 'female',
    'birthDate': DateTime(2000, 1, 20),
    'height': 168.0,
    'goal': 'fitness',
    'experience': 'beginner',
    'scenario': 'new_member',
    'startWeight': 60.0,
    'currentWeight': 60.0,
    'targetWeight': 55.0,
    'totalSessions': 24,
    'completedSessions': 2,
  },
];

// ============================================================
// 메인 함수
// ============================================================

Future<void> main() async {
  print('🚀 PAL 데모 데이터 생성 스크립트');
  print('=' * 50);

  // Firebase 초기화
  Firestore.initialize(firebaseProjectId);
  FirebaseAuth.initialize(firebaseApiKey, VolatileStore());

  final firestore = Firestore.instance;
  final auth = FirebaseAuth.instance;

  try {
    print('\n👨‍🏫 트레이너 계정 생성 중...');
    final trainerData = await _createTrainer(firestore, auth);
    print('   ✅ 트레이너: ${trainerData['email']} (ID: ${trainerData['id']})');

    print('\n👥 회원 계정 생성 중...');
    final members = await _createMembers(firestore, auth, trainerData['id']!);
    for (final member in members) {
      print('   ✅ ${member['name']} (${member['scenario']})');
    }

    // 각 회원별 데이터 생성
    for (final member in members) {
      print('\n📊 ${member['name']} 데이터 생성 중...');

      await _createBodyRecords(firestore, member);
      print('   - 체중 기록 8주치 ✓');

      await _createInbodyRecords(firestore, member);
      print('   - 인바디 기록 2회 ✓');

      await _createWorkoutRecords(firestore, trainerData['id']!, member);
      print('   - 운동 기록 4주치 ✓');

      await _createSchedules(firestore, trainerData['id']!, member);
      print('   - PT 스케줄 ✓');

      await _createDietRecords(firestore, member);
      print('   - 식단 기록 1주치 ✓');

      await _createChatRoom(firestore, trainerData, member);
      print('   - 채팅 메시지 10개 ✓');
    }

    // AI 인사이트 생성
    print('\n🤖 AI 인사이트 생성 중...');
    await _createInsights(firestore, trainerData['id']!, members);
    print('   ✅ AI 인사이트 생성 완료');

    print('\n${'=' * 50}');
    print('🎉 데모 데이터 생성 완료!\n');
    print('📋 로그인 정보:');
    print('   이메일: $trainerEmail');
    print('   비밀번호: $trainerPassword');
    print('=' * 50);
  } catch (e, st) {
    print('❌ 오류 발생: $e');
    print(st);
  }
}

// ============================================================
// 데이터 생성 함수들
// ============================================================

Future<Map<String, String>> _createTrainer(
  Firestore firestore,
  FirebaseAuth auth,
) async {
  String uid;

  try {
    // Firebase Auth로 트레이너 계정 생성
    final user = await auth.signUp(trainerEmail, trainerPassword);
    uid = user.id;
  } catch (e) {
    // 이미 존재하면 로그인 시도
    try {
      final user = await auth.signIn(trainerEmail, trainerPassword);
      uid = user.id;
    } catch (e2) {
      // 둘 다 실패하면 UUID 사용
      uid = uuid.v4();
      print('   ⚠️ Auth 실패, UUID 사용: $uid');
    }
  }

  // users 컬렉션에 저장
  await firestore.collection('users').document(uid).set({
    'uid': uid,
    'email': trainerEmail,
    'name': trainerName,
    'role': 'trainer',
    'phone': trainerPhone,
    'profileImageUrl': null,
    'memberCode': null,
    'createdAt': DateTime.now(),
    'updatedAt': DateTime.now(),
  });

  // trainers 컬렉션에 저장
  final trainerId = uuid.v4();
  await firestore.collection('trainers').document(trainerId).set({
    'id': trainerId,
    'userId': uid,
    'subscriptionTier': 'pro',
    'memberIds': <String>[],
    'aiUsage': {
      'curriculumCount': 3,
      'predictionCount': 5,
      'resetDate': DateTime(DateTime.now().year, DateTime.now().month, 1),
    },
  });

  return {
    'id': trainerId,
    'uid': uid,
    'email': trainerEmail,
    'name': trainerName,
  };
}

Future<List<Map<String, dynamic>>> _createMembers(
  Firestore firestore,
  FirebaseAuth auth,
  String trainerId,
) async {
  final List<Map<String, dynamic>> members = [];
  final List<String> memberIds = [];

  for (final scenario in memberScenarios) {
    String uid;
    final email = scenario['email'] as String;

    try {
      final user = await auth.signUp(email, 'member123');
      uid = user.id;
    } catch (e) {
      // 실패 시 UUID 사용
      uid = uuid.v4();
    }

    final startDate = DateTime.now().subtract(Duration(
      days: (scenario['completedSessions'] as int) * 3,
    ));

    // users 컬렉션에 저장
    await firestore.collection('users').document(uid).set({
      'uid': uid,
      'email': scenario['email'],
      'name': scenario['name'],
      'role': 'member',
      'phone':
          '010-${random.nextInt(9000) + 1000}-${random.nextInt(9000) + 1000}',
      'profileImageUrl': null,
      'memberCode': _generateMemberCode(),
      'createdAt': startDate,
      'updatedAt': DateTime.now(),
    });

    // members 컬렉션에 저장
    final memberId = uuid.v4();
    await firestore.collection('members').document(memberId).set({
      'id': memberId,
      'userId': uid,
      'trainerId': trainerId,
      'goal': scenario['goal'],
      'experience': scenario['experience'],
      'targetWeight': scenario['targetWeight'],
      'memo': _generateMemo(scenario['scenario'] as String),
      'ptInfo': {
        'totalSessions': scenario['totalSessions'],
        'completedSessions': scenario['completedSessions'],
        'startDate': startDate,
      },
      'createdAt': startDate,
      'updatedAt': DateTime.now(),
    });

    memberIds.add(memberId);
    members.add({
      ...scenario,
      'id': memberId,
      'uid': uid,
      'startDate': startDate,
    });
  }

  // 트레이너의 memberIds 업데이트
  await firestore.collection('trainers').document(trainerId).update({
    'memberIds': memberIds,
  });

  return members;
}

Future<void> _createBodyRecords(
  Firestore firestore,
  Map<String, dynamic> member,
) async {
  final startWeight = member['startWeight'] as double;
  final currentWeight = member['currentWeight'] as double;
  final startDate = member['startDate'] as DateTime;
  const weeks = 8;

  for (int i = 0; i < weeks * 2; i++) {
    final date = startDate.add(Duration(days: i * 3 + random.nextInt(2)));
    if (date.isAfter(DateTime.now())) continue;

    final progress = i / (weeks * 2);
    final weight = _calculateWeight(startWeight, currentWeight, progress);

    final recordId = uuid.v4();
    await firestore.collection('bodyRecords').document(recordId).set({
      'id': recordId,
      'memberId': member['id'],
      'date': date,
      'weight': weight,
      'bodyFatPercent': _generateBodyFatPercent(member, progress),
      'muscleMass': _generateMuscleMass(member, progress),
      'createdAt': date,
    });
  }
}

Future<void> _createInbodyRecords(
  Firestore firestore,
  Map<String, dynamic> member,
) async {
  final startDate = member['startDate'] as DateTime;
  final now = DateTime.now();

  // 첫 번째 인바디 (PT 시작 시)
  final record1Id = uuid.v4();
  await firestore.collection('inbodyRecords').document(record1Id).set({
    'id': record1Id,
    'memberId': member['id'],
    'measuredAt': startDate.add(const Duration(days: 1)),
    'weight': member['startWeight'],
    'skeletalMuscleMass': _generateMuscleMass(member, 0.0),
    'bodyFatMass': _generateBodyFatMass(member, 0.0),
    'bodyFatPercent': _generateBodyFatPercent(member, 0.0),
    'bmi': (member['startWeight'] as double) /
        ((member['height'] as double) / 100 *
            (member['height'] as double) / 100),
    'basalMetabolicRate': 1400 + random.nextInt(400),
    'totalBodyWater': 30.0 + random.nextDouble() * 10,
    'protein': 8.0 + random.nextDouble() * 4,
    'minerals': 3.0 + random.nextDouble() * 1,
    'visceralFatLevel': 5 + random.nextInt(5),
    'inbodyScore': 65 + random.nextInt(10),
    'source': 'manual',
    'createdAt': startDate.add(const Duration(days: 1)),
  });

  // 두 번째 인바디 (최근)
  final weeksElapsed = now.difference(startDate).inDays ~/ 7;
  if (weeksElapsed >= 4) {
    final record2Date = startDate.add(Duration(days: weeksElapsed * 7 - 7));
    final record2Id = uuid.v4();
    await firestore.collection('inbodyRecords').document(record2Id).set({
      'id': record2Id,
      'memberId': member['id'],
      'measuredAt': record2Date,
      'weight': member['currentWeight'],
      'skeletalMuscleMass': _generateMuscleMass(member, 1.0),
      'bodyFatMass': _generateBodyFatMass(member, 1.0),
      'bodyFatPercent': _generateBodyFatPercent(member, 1.0),
      'bmi': (member['currentWeight'] as double) /
          ((member['height'] as double) / 100 *
              (member['height'] as double) / 100),
      'basalMetabolicRate': 1400 + random.nextInt(400),
      'totalBodyWater': 30.0 + random.nextDouble() * 10,
      'protein': 8.0 + random.nextDouble() * 4,
      'minerals': 3.0 + random.nextDouble() * 1,
      'visceralFatLevel': 4 + random.nextInt(4),
      'inbodyScore': 70 + random.nextInt(15),
      'source': 'manual',
      'createdAt': record2Date,
    });
  }
}

Future<void> _createWorkoutRecords(
  Firestore firestore,
  String trainerId,
  Map<String, dynamic> member,
) async {
  final startDate = member['startDate'] as DateTime;
  final goal = member['goal'] as String;

  for (int week = 0; week < 4; week++) {
    for (int day = 0; day < 3; day++) {
      final date = startDate.add(Duration(days: week * 7 + day * 2));
      if (date.isAfter(DateTime.now())) continue;

      final exercises = _generateExercises(goal, week, day);
      final recordId = uuid.v4();

      await firestore.collection('curriculums').document(recordId).set({
        'id': recordId,
        'memberId': member['id'],
        'trainerId': trainerId,
        'date': date,
        'title': '${week + 1}주차 ${day + 1}회차',
        'exercises': exercises,
        'notes': week == 0 ? '첫 주 적응 기간' : null,
        'isCompleted': true,
        'createdAt': date,
      });
    }
  }
}

List<Map<String, dynamic>> _generateExercises(String goal, int week, int day) {
  final exercises = <Map<String, dynamic>>[];

  if (goal == 'diet') {
    final dietExercises = day % 2 == 0
        ? ['스쿼트', '런지', '레그프레스', '레그컬', '카프레이즈']
        : ['러닝머신', '버피', '마운틴클라이머', '플랭크', '크런치'];

    for (final name in dietExercises) {
      exercises.add({
        'name': name,
        'sets': 3 + (week ~/ 2),
        'reps': name == '러닝머신' ? null : 12 + week,
        'weight':
            name.contains('머신') || name == '플랭크' ? null : 10.0 + week * 2.5,
        'duration': name == '러닝머신'
            ? 20 + week * 5
            : (name == '플랭크' ? 30 + week * 10 : null),
        'isCompleted': true,
      });
    }
  } else if (goal == 'bulk') {
    final bulkExercises = day == 0
        ? ['벤치프레스', '인클라인 덤벨프레스', '케이블 플라이', '딥스', '푸쉬업']
        : day == 1
            ? ['데드리프트', '바벨로우', '랫풀다운', '시티드로우', '페이스풀']
            : ['스쿼트', '레그프레스', '레그익스텐션', '레그컬', '카프레이즈'];

    for (final name in bulkExercises) {
      exercises.add({
        'name': name,
        'sets': 4 + (week ~/ 2),
        'reps': 8 + (week % 2) * 2,
        'weight': 20.0 + week * 5,
        'isCompleted': true,
      });
    }
  } else {
    final fitnessExercises = [
      '케틀벨 스윙',
      '박스점프',
      '버피',
      '배틀로프',
      'TRX 로우'
    ];

    for (final name in fitnessExercises) {
      exercises.add({
        'name': name,
        'sets': 3,
        'reps': name == '배틀로프' ? null : 15,
        'duration': name == '배틀로프' ? 30 : null,
        'isCompleted': true,
      });
    }
  }

  return exercises;
}

Future<void> _createSchedules(
  Firestore firestore,
  String trainerId,
  Map<String, dynamic> member,
) async {
  final now = DateTime.now();

  // 과거 스케줄 (완료됨)
  for (int i = 6; i >= 1; i--) {
    final date = now.subtract(Duration(days: i * 3));
    final scheduleId = uuid.v4();

    await firestore.collection('schedules').document(scheduleId).set({
      'id': scheduleId,
      'trainerId': trainerId,
      'memberId': member['id'],
      'memberName': member['name'],
      'date': date,
      'startTime': '${10 + random.nextInt(8)}:00',
      'endTime': '${11 + random.nextInt(8)}:00',
      'status': 'completed',
      'notes': null,
      'createdAt': date.subtract(const Duration(days: 7)),
    });
  }

  // 미래 스케줄 (예정됨)
  for (int i = 1; i <= 6; i++) {
    final date = now.add(Duration(days: i * 3));
    final scheduleId = uuid.v4();

    await firestore.collection('schedules').document(scheduleId).set({
      'id': scheduleId,
      'trainerId': trainerId,
      'memberId': member['id'],
      'memberName': member['name'],
      'date': date,
      'startTime': '${10 + random.nextInt(8)}:00',
      'endTime': '${11 + random.nextInt(8)}:00',
      'status': 'scheduled',
      'notes': null,
      'createdAt': DateTime.now(),
    });
  }
}

Future<void> _createDietRecords(
  Firestore firestore,
  Map<String, dynamic> member,
) async {
  final now = DateTime.now();
  final mealTypes = ['breakfast', 'lunch', 'dinner'];
  final mealNames = ['아침', '점심', '저녁'];

  for (int day = 6; day >= 0; day--) {
    final date = now.subtract(Duration(days: day));

    for (int i = 0; i < 3; i++) {
      final recordId = uuid.v4();

      await firestore.collection('dietRecords').document(recordId).set({
        'id': recordId,
        'memberId': member['id'],
        'date': date,
        'mealType': mealTypes[i],
        'mealName': mealNames[i],
        'foods': _generateFoods(mealTypes[i]),
        'calories': 300 + random.nextInt(500),
        'protein': 15 + random.nextInt(25),
        'carbs': 30 + random.nextInt(50),
        'fat': 10 + random.nextInt(20),
        'photoUrl': null,
        'aiAnalysis': {
          'score': 60 + random.nextInt(35),
          'feedback': '균형 잡힌 식단입니다.',
          'suggestions': ['단백질 섭취를 조금 더 늘려보세요.'],
        },
        'createdAt': date,
      });
    }
  }
}

List<Map<String, dynamic>> _generateFoods(String mealType) {
  if (mealType == 'breakfast') {
    return [
      {'name': '현미밥', 'amount': '1공기', 'calories': 300},
      {'name': '계란', 'amount': '2개', 'calories': 140},
      {'name': '김치', 'amount': '1접시', 'calories': 30},
    ];
  } else if (mealType == 'lunch') {
    return [
      {'name': '닭가슴살', 'amount': '150g', 'calories': 165},
      {'name': '샐러드', 'amount': '1접시', 'calories': 50},
      {'name': '고구마', 'amount': '1개', 'calories': 130},
    ];
  } else {
    return [
      {'name': '연어', 'amount': '100g', 'calories': 200},
      {'name': '퀴노아', 'amount': '1컵', 'calories': 220},
      {'name': '아보카도', 'amount': '반개', 'calories': 120},
    ];
  }
}

Future<void> _createChatRoom(
  Firestore firestore,
  Map<String, String> trainer,
  Map<String, dynamic> member,
) async {
  final chatRoomId = uuid.v4();
  final now = DateTime.now();

  await firestore.collection('chatRooms').document(chatRoomId).set({
    'id': chatRoomId,
    'trainerId': trainer['id'],
    'memberId': member['id'],
    'participants': [trainer['uid'], member['uid']],
    'lastMessage': '오늘 운동 수고하셨습니다!',
    'lastMessageAt': DateTime.now(),
    'createdAt': member['startDate'],
  });

  final messages = _generateConversations(member['scenario'] as String);

  for (int i = 0; i < messages.length; i++) {
    final msg = messages[i];
    final messageId = uuid.v4();
    final messageDate = now.subtract(Duration(hours: (messages.length - i) * 4));

    await firestore
        .collection('chatRooms')
        .document(chatRoomId)
        .collection('messages')
        .document(messageId)
        .set({
      'id': messageId,
      'senderId': msg['isTrainer'] == true ? trainer['uid'] : member['uid'],
      'senderName':
          msg['isTrainer'] == true ? trainer['name'] : member['name'],
      'content': msg['content'],
      'type': 'text',
      'createdAt': messageDate,
      'readBy': [trainer['uid'], member['uid']],
    });
  }
}

Future<void> _createInsights(
  Firestore firestore,
  String trainerId,
  List<Map<String, dynamic>> members,
) async {
  final now = DateTime.now();

  final insights = [
    {
      'type': 'attendance_alert',
      'title': '출석률 하락 회원 알림',
      'content': '${members[2]['name']} 회원의 최근 2주 출석률이 40%로 하락했습니다.',
      'memberId': members[2]['id'],
      'priority': 'high',
    },
    {
      'type': 'goal_achievement',
      'title': '목표 달성 임박',
      'content': '${members[0]['name']} 회원이 목표 체중까지 3.5kg 남았습니다.',
      'memberId': members[0]['id'],
      'priority': 'medium',
    },
    {
      'type': 'pt_ending',
      'title': 'PT 종료 임박',
      'content': '${members[3]['name']} 회원의 PT가 2회 남았습니다. 재등록 권유가 필요합니다.',
      'memberId': members[3]['id'],
      'priority': 'high',
    },
    {
      'type': 'progress_update',
      'title': '벌크업 진행 상황',
      'content':
          '${members[1]['name']} 회원이 6.5kg 증량에 성공했습니다. 목표까지 3.5kg 남았습니다.',
      'memberId': members[1]['id'],
      'priority': 'low',
    },
    {
      'type': 'new_member',
      'title': '신규 회원 적응 기간',
      'content':
          '${members[4]['name']} 회원이 PT를 시작한 지 1주가 되었습니다. 적응 상태를 확인해주세요.',
      'memberId': members[4]['id'],
      'priority': 'medium',
    },
    {
      'type': 'weekly_summary',
      'title': '주간 요약',
      'content': '이번 주 총 15회 PT 진행, 평균 출석률 85%, 3명의 회원이 목표에 근접했습니다.',
      'memberId': null,
      'priority': 'low',
    },
  ];

  for (int i = 0; i < insights.length; i++) {
    final insight = insights[i];
    final insightId = uuid.v4();

    await firestore.collection('insights').document(insightId).set({
      'id': insightId,
      'trainerId': trainerId,
      'type': insight['type'],
      'title': insight['title'],
      'content': insight['content'],
      'memberId': insight['memberId'],
      'priority': insight['priority'],
      'isRead': false,
      'createdAt': now.subtract(Duration(hours: i * 6)),
    });
  }
}

// ============================================================
// 헬퍼 함수들
// ============================================================

String _generateMemberCode() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  return List.generate(4, (_) => chars[random.nextInt(chars.length)]).join();
}

String _generateMemo(String scenario) {
  switch (scenario) {
    case 'diet_success':
      return '꾸준히 운동하고 식단 관리도 잘 하는 모범적인 회원. 목표까지 얼마 남지 않음.';
    case 'bulking':
      return '벌크업 중. 단백질 섭취량 신경 쓸 것. 무게 점진적으로 증가 중.';
    case 'attendance_drop':
      return '최근 출석률 저조. 동기부여 필요. 개인 사정 확인 필요.';
    case 'ending_soon':
      return 'PT 종료 임박. 재등록 상담 필요. 만족도 높은 편.';
    case 'new_member':
      return '신규 회원. 운동 초보라 자세 교정에 집중. 체력 기초부터 쌓는 중.';
    default:
      return '';
  }
}

double _calculateWeight(double start, double end, double progress) {
  final base = start + (end - start) * progress;
  return base + (random.nextDouble() - 0.5) * 0.5;
}

double _generateBodyFatPercent(Map<String, dynamic> member, double progress) {
  final scenario = member['scenario'] as String;
  final gender = member['gender'] as String;

  double basePercent = gender == 'female' ? 28.0 : 22.0;

  switch (scenario) {
    case 'diet_success':
      return basePercent - 8 * progress + (random.nextDouble() - 0.5);
    case 'bulking':
      return basePercent - 5 + 2 * progress + (random.nextDouble() - 0.5);
    case 'attendance_drop':
      return basePercent + 2 * progress + (random.nextDouble() - 0.5);
    case 'ending_soon':
      return basePercent - 6 * progress + (random.nextDouble() - 0.5);
    case 'new_member':
      return basePercent + (random.nextDouble() - 0.5);
    default:
      return basePercent;
  }
}

double _generateMuscleMass(Map<String, dynamic> member, double progress) {
  final scenario = member['scenario'] as String;
  final gender = member['gender'] as String;

  double baseMass = gender == 'female' ? 22.0 : 32.0;

  switch (scenario) {
    case 'diet_success':
      return baseMass + 1 * progress + (random.nextDouble() - 0.5);
    case 'bulking':
      return baseMass + 5 * progress + (random.nextDouble() - 0.5);
    case 'attendance_drop':
      return baseMass - 0.5 * progress + (random.nextDouble() - 0.5);
    case 'ending_soon':
      return baseMass + 2 * progress + (random.nextDouble() - 0.5);
    case 'new_member':
      return baseMass + (random.nextDouble() - 0.5);
    default:
      return baseMass;
  }
}

double _generateBodyFatMass(Map<String, dynamic> member, double progress) {
  final scenario = member['scenario'] as String;
  final gender = member['gender'] as String;

  double baseMass = gender == 'female' ? 18.0 : 15.0;

  switch (scenario) {
    case 'diet_success':
      return baseMass - 6 * progress + (random.nextDouble() - 0.5);
    case 'bulking':
      return baseMass + 2 * progress + (random.nextDouble() - 0.5);
    case 'attendance_drop':
      return baseMass + 1 * progress + (random.nextDouble() - 0.5);
    case 'ending_soon':
      return baseMass - 4 * progress + (random.nextDouble() - 0.5);
    case 'new_member':
      return baseMass + (random.nextDouble() - 0.5);
    default:
      return baseMass;
  }
}

List<Map<String, dynamic>> _generateConversations(String scenario) {
  switch (scenario) {
    case 'diet_success':
      return [
        {'isTrainer': true, 'content': '오늘 운동 수고하셨어요! 체중이 많이 줄었네요'},
        {'isTrainer': false, 'content': '감사합니다 트레이너님! 식단도 열심히 지키고 있어요'},
        {'isTrainer': true, 'content': '잘하고 계세요. 이번 주 식단 사진도 잘 올려주시고요'},
        {'isTrainer': false, 'content': '네! 목표까지 얼마 안 남았죠?'},
        {'isTrainer': true, 'content': '3.5kg 남았어요. 이 페이스면 다음 달에 달성할 수 있을 거예요'},
        {'isTrainer': false, 'content': '열심히 할게요!'},
        {'isTrainer': true, 'content': '다음 PT는 수요일 2시입니다'},
        {'isTrainer': false, 'content': '네 알겠습니다~'},
        {'isTrainer': true, 'content': '그리고 물 많이 드세요. 하루 2L 이상!'},
        {'isTrainer': false, 'content': '네! 오늘도 감사합니다'},
      ];
    case 'bulking':
      return [
        {'isTrainer': true, 'content': '오늘 벤치프레스 무게 잘 올랐어요!'},
        {'isTrainer': false, 'content': '확실히 힘이 붙는 게 느껴져요'},
        {'isTrainer': true, 'content': '단백질 보충제는 잘 드시고 계시죠?'},
        {'isTrainer': false, 'content': '네 운동 후에 꼭 챙겨먹고 있어요'},
        {'isTrainer': true, 'content': '좋아요. 다음 주부터는 데드리프트 무게도 올려볼게요'},
        {'isTrainer': false, 'content': '기대됩니다!'},
        {'isTrainer': true, 'content': '식사량은 어때요? 탄수화물도 충분히 드시고요?'},
        {'isTrainer': false, 'content': '아 그게 좀 부족한 것 같아요'},
        {'isTrainer': true, 'content': '밥을 1.5공기씩 드세요. 벌크업엔 탄수화물도 중요해요'},
        {'isTrainer': false, 'content': '네 알겠습니다!'},
      ];
    case 'attendance_drop':
      return [
        {'isTrainer': true, 'content': '요즘 어떠세요? 지난주 PT를 못 오셨네요'},
        {'isTrainer': false, 'content': '죄송해요... 회사 일이 너무 바빠서요'},
        {'isTrainer': true, 'content': '괜찮아요. 건강이 우선이에요. 이번 주는 가능하세요?'},
        {'isTrainer': false, 'content': '이번 주 금요일은 될 것 같아요'},
        {'isTrainer': true, 'content': '좋아요! 금요일 6시로 잡을게요'},
        {'isTrainer': false, 'content': '감사합니다'},
        {'isTrainer': true, 'content': '집에서 간단한 스트레칭이라도 해주세요'},
        {'isTrainer': false, 'content': '네 노력해볼게요'},
        {'isTrainer': true, 'content': '화이팅! 금요일에 봐요'},
        {'isTrainer': false, 'content': '네 감사합니다~'},
      ];
    case 'ending_soon':
      return [
        {'isTrainer': true, 'content': '오늘 운동 정말 잘하셨어요!'},
        {'isTrainer': false, 'content': '감사합니다. 확실히 체력이 많이 좋아졌어요'},
        {'isTrainer': true, 'content': 'PT 2회 남았는데, 연장 생각 있으세요?'},
        {'isTrainer': false, 'content': '음... 일단 이번 달 마무리하고 생각해볼게요'},
        {'isTrainer': true, 'content': '네 천천히 생각해보세요. 궁금한 거 있으면 말씀해주시고요'},
        {'isTrainer': false, 'content': '연장하면 할인 있나요?'},
        {'isTrainer': true, 'content': '재등록 시 10% 할인 있어요. 자세한 건 상담 때 말씀드릴게요'},
        {'isTrainer': false, 'content': '네 알겠습니다'},
        {'isTrainer': true, 'content': '다음 PT는 토요일 11시입니다'},
        {'isTrainer': false, 'content': '네! 토요일에 봐요~'},
      ];
    case 'new_member':
      return [
        {'isTrainer': true, 'content': '첫 주 적응은 어떠셨어요?'},
        {'isTrainer': false, 'content': '생각보다 힘들었지만 재미있었어요!'},
        {'isTrainer': true, 'content': '처음엔 다들 그래요. 근육통은 좀 있으세요?'},
        {'isTrainer': false, 'content': '네 다리가 좀 아파요'},
        {'isTrainer': true, 'content': '정상이에요. 스트레칭 잘 해주시고 푹 쉬세요'},
        {'isTrainer': false, 'content': '네 알겠습니다'},
        {'isTrainer': true, 'content': '혹시 집에서 쓸 폼롤러 있으세요?'},
        {'isTrainer': false, 'content': '아니요 없어요'},
        {'isTrainer': true, 'content': '하나 구매하시는 거 추천드려요. 근육 풀어주는 데 좋아요'},
        {'isTrainer': false, 'content': '네 알아볼게요! 감사합니다'},
      ];
    default:
      return [];
  }
}
