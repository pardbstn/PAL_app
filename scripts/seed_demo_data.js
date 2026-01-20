/**
 * PAL 심사용 데모 데이터 생성 스크립트 (Firebase Admin SDK)
 *
 * 실행 방법:
 * 1. Firebase Console에서 서비스 계정 키 다운로드 (프로젝트 설정 > 서비스 계정)
 * 2. 파일을 scripts/serviceAccountKey.json으로 저장
 * 3. node scripts/seed_demo_data.js
 *
 * 또는 환경변수로 설정:
 * GOOGLE_APPLICATION_CREDENTIALS=./scripts/serviceAccountKey.json node scripts/seed_demo_data.js
 */

const admin = require('firebase-admin');
const path = require('path');

// ============================================================
// Firebase 초기화
// ============================================================

const serviceAccountPath = path.join(__dirname, 'serviceAccountKey.json');

try {
  const serviceAccount = require(serviceAccountPath);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
} catch (e) {
  console.error('❌ serviceAccountKey.json 파일을 찾을 수 없습니다.');
  console.error('   Firebase Console에서 서비스 계정 키를 다운로드하세요.');
  console.error('   프로젝트 설정 > 서비스 계정 > 새 비공개 키 생성');
  process.exit(1);
}

const db = admin.firestore();
const auth = admin.auth();

// ============================================================
// 상수 정의
// ============================================================

const TRAINER_EMAIL = 'test@pal.com';
const TRAINER_PASSWORD = 'password123';
const TRAINER_NAME = '김태훈';
const TRAINER_PHONE = '010-1234-5678';

// 회원 시나리오별 데이터
const MEMBER_SCENARIOS = [
  {
    name: '박민지',
    email: 'minji@test.com',
    phone: '010-1111-1111',
    goal: 'diet',
    experience: 'intermediate',
    scenario: 'dietSuccess',
    startWeight: 68.0,
    targetWeight: 58.0,
    totalSessions: 24,
    completedSessions: 20,
    weeksActive: 8,
  },
  {
    name: '이준혁',
    email: 'junhyuk@test.com',
    phone: '010-2222-2222',
    goal: 'bulk',
    experience: 'advanced',
    scenario: 'bulkingUp',
    startWeight: 72.0,
    targetWeight: 80.0,
    totalSessions: 36,
    completedSessions: 16,
    weeksActive: 8,
  },
  {
    name: '최서연',
    email: 'seoyeon@test.com',
    phone: '010-3333-3333',
    goal: 'fitness',
    experience: 'beginner',
    scenario: 'attendanceDropping',
    startWeight: 55.0,
    targetWeight: 52.0,
    totalSessions: 20,
    completedSessions: 8,
    weeksActive: 6,
  },
  {
    name: '정우성',
    email: 'woosung@test.com',
    phone: '010-4444-4444',
    goal: 'diet',
    experience: 'intermediate',
    scenario: 'ptEndingSoon',
    startWeight: 85.0,
    targetWeight: 75.0,
    totalSessions: 12,
    completedSessions: 10,
    weeksActive: 5,
  },
  {
    name: '한소희',
    email: 'sohee@test.com',
    phone: '010-5555-5555',
    goal: 'fitness',
    experience: 'beginner',
    scenario: 'newMember',
    startWeight: 58.0,
    targetWeight: 55.0,
    totalSessions: 24,
    completedSessions: 2,
    weeksActive: 1,
  },
];

// ============================================================
// 메인 함수
// ============================================================

async function main() {
  console.log('🚀 PAL 데모 데이터 생성 시작...\n');

  try {
    // 1. 트레이너 생성
    console.log('👨‍🏫 트레이너 계정 생성 중...');
    const trainerId = await createTrainer();
    console.log(`   ✅ 트레이너 생성 완료: ${trainerId}\n`);

    // 2. 회원 생성
    console.log('👥 회원 데이터 생성 중...');
    const memberIds = [];
    for (const scenario of MEMBER_SCENARIOS) {
      const memberId = await createMember(trainerId, scenario);
      memberIds.push(memberId);
      console.log(`   ✅ ${scenario.name} (${getScenarioLabel(scenario.scenario)})`);
    }
    console.log('');

    // 3. 트레이너의 memberIds 업데이트
    await db.collection('trainers').doc(trainerId).update({
      memberIds: memberIds,
    });

    // 4. 각 회원별 상세 데이터 생성
    for (let i = 0; i < MEMBER_SCENARIOS.length; i++) {
      const scenario = MEMBER_SCENARIOS[i];
      const memberId = memberIds[i];

      console.log(`📊 ${scenario.name} 데이터 생성 중...`);

      // 체중 기록 (8주치)
      await createWeightRecords(memberId, scenario);
      console.log('   - 체중 기록 완료');

      // 운동 기록 (4주치)
      await createCurriculums(memberId, trainerId, scenario);
      console.log('   - 운동 기록 완료');

      // 식단 기록 (1주치)
      await createDietRecords(memberId, scenario);
      console.log('   - 식단 기록 완료');

      // 인바디 기록 (2회)
      await createInbodyRecords(memberId, scenario);
      console.log('   - 인바디 기록 완료');

      // 채팅 메시지 (10개)
      await createChatMessages(memberId, trainerId, scenario);
      console.log('   - 채팅 메시지 완료');

      console.log('');
    }

    console.log('🎉 모든 데모 데이터 생성 완료!');
    console.log('');
    console.log('📋 생성된 데이터 요약:');
    console.log(`   - 트레이너: 1명 (${TRAINER_EMAIL})`);
    console.log(`   - 회원: ${memberIds.length}명`);
    console.log('   - 체중 기록: 각 회원 8주치');
    console.log('   - 운동 기록: 각 회원 4주치');
    console.log('   - 식단 기록: 각 회원 1주치');
    console.log('   - 인바디: 각 회원 2회');
    console.log('   - 채팅: 각 회원 10개 메시지');

  } catch (e) {
    console.error('❌ 오류 발생:', e);
    process.exit(1);
  }
}

// ============================================================
// 트레이너 생성
// ============================================================

async function createTrainer() {
  let trainerId;

  // Firebase Auth 계정 생성
  try {
    const userRecord = await auth.createUser({
      email: TRAINER_EMAIL,
      password: TRAINER_PASSWORD,
      displayName: TRAINER_NAME,
    });
    trainerId = userRecord.uid;
  } catch (e) {
    if (e.code === 'auth/email-already-exists') {
      // 이미 존재하면 조회
      const userRecord = await auth.getUserByEmail(TRAINER_EMAIL);
      trainerId = userRecord.uid;
    } else {
      throw e;
    }
  }

  const now = admin.firestore.Timestamp.now();

  // users 컬렉션
  await db.collection('users').doc(trainerId).set({
    uid: trainerId,
    email: TRAINER_EMAIL,
    name: TRAINER_NAME,
    phone: TRAINER_PHONE,
    role: 'trainer',
    profileImageUrl: null,
    memberCode: generateMemberCode(),
    createdAt: now,
    updatedAt: now,
  });

  // trainers 컬렉션
  await db.collection('trainers').doc(trainerId).set({
    userId: trainerId,
    subscriptionTier: 'pro',
    memberIds: [],
    aiUsage: {
      curriculumCount: 5,
      predictionCount: 12,
      resetDate: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 15 * 24 * 60 * 60 * 1000)
      ),
    },
    createdAt: now,
    updatedAt: now,
  });

  return trainerId;
}

// ============================================================
// 회원 생성
// ============================================================

async function createMember(trainerId, scenario) {
  const memberId = db.collection('members').doc().id;
  const startDate = new Date(Date.now() - scenario.weeksActive * 7 * 24 * 60 * 60 * 1000);
  const now = admin.firestore.Timestamp.now();

  // users 컬렉션
  await db.collection('users').doc(memberId).set({
    uid: memberId,
    email: scenario.email,
    name: scenario.name,
    phone: scenario.phone,
    role: 'member',
    profileImageUrl: null,
    memberCode: null,
    createdAt: admin.firestore.Timestamp.fromDate(startDate),
    updatedAt: now,
  });

  // members 컬렉션
  await db.collection('members').doc(memberId).set({
    userId: memberId,
    trainerId: trainerId,
    goal: scenario.goal,
    experience: scenario.experience,
    ptInfo: {
      totalSessions: scenario.totalSessions,
      completedSessions: scenario.completedSessions,
      startDate: admin.firestore.Timestamp.fromDate(startDate),
    },
    targetWeight: scenario.targetWeight,
    memo: getMemoForScenario(scenario.scenario),
    createdAt: admin.firestore.Timestamp.fromDate(startDate),
    updatedAt: now,
  });

  return memberId;
}

// ============================================================
// 체중 기록 생성 (8주치)
// ============================================================

async function createWeightRecords(memberId, scenario) {
  const now = new Date();
  const weights = generateWeightPattern(scenario);
  const batch = db.batch();

  for (let week = 0; week < 8; week++) {
    // 주 2회 기록 (월, 금)
    for (const dayOffset of [0, 4]) {
      const recordDate = new Date(now.getTime() - (7 - week) * 7 * 24 * 60 * 60 * 1000 + dayOffset * 24 * 60 * 60 * 1000);

      if (recordDate > now) continue;

      const weight = weights[week] + (Math.random() - 0.5) * 0.3;

      const docRef = db.collection('body_records').doc();
      batch.set(docRef, {
        memberId: memberId,
        recordDate: admin.firestore.Timestamp.fromDate(recordDate),
        weight: parseFloat(weight.toFixed(1)),
        bodyFatPercent: null,
        muscleMass: null,
        bmi: null,
        bmr: null,
        source: 'manual',
        note: null,
        createdAt: admin.firestore.Timestamp.fromDate(recordDate),
      });
    }
  }

  await batch.commit();
}

function generateWeightPattern(scenario) {
  const weights = [];
  let currentWeight = scenario.startWeight;

  switch (scenario.scenario) {
    case 'dietSuccess':
      // 꾸준한 감량 (-1.2kg/주 평균)
      for (let i = 0; i < 8; i++) {
        weights.push(currentWeight);
        currentWeight -= 0.8 + Math.random() * 0.8;
      }
      break;
    case 'bulkingUp':
      // 점진적 증량 (+0.5kg/주 평균)
      for (let i = 0; i < 8; i++) {
        weights.push(currentWeight);
        currentWeight += 0.3 + Math.random() * 0.4;
      }
      break;
    case 'attendanceDropping':
      // 초반 감량 후 정체/요요
      for (let i = 0; i < 8; i++) {
        weights.push(currentWeight);
        if (i < 3) {
          currentWeight -= 0.5 + Math.random() * 0.3;
        } else {
          currentWeight += Math.random() * 0.4 - 0.1;
        }
      }
      break;
    case 'ptEndingSoon':
      // 꾸준한 감량
      for (let i = 0; i < 8; i++) {
        weights.push(currentWeight);
        currentWeight -= 0.6 + Math.random() * 0.6;
      }
      break;
    case 'newMember':
      // 아직 변화 미미
      for (let i = 0; i < 8; i++) {
        weights.push(currentWeight + (Math.random() - 0.5) * 0.5);
      }
      break;
  }

  return weights;
}

// ============================================================
// 운동 기록 (커리큘럼) 생성 (4주치)
// ============================================================

async function createCurriculums(memberId, trainerId, scenario) {
  const now = new Date();
  const exerciseTemplates = getExerciseTemplates(scenario.goal);
  let sessionNumber = Math.max(1, scenario.completedSessions - 8);
  const batch = db.batch();

  for (let week = 0; week < 4; week++) {
    // 주 2회 운동
    for (let sessionInWeek = 0; sessionInWeek < 2; sessionInWeek++) {
      const dayOffset = sessionInWeek === 0 ? 1 : 4; // 화, 금
      const scheduledDate = new Date(now.getTime() - (3 - week) * 7 * 24 * 60 * 60 * 1000 + dayOffset * 24 * 60 * 60 * 1000);

      if (scheduledDate > now) continue;

      const isCompleted = scheduledDate < new Date(now.getTime() - 24 * 60 * 60 * 1000);
      const exercises = generateExercises(exerciseTemplates, sessionNumber);

      const docRef = db.collection('curriculums').doc();
      batch.set(docRef, {
        memberId: memberId,
        trainerId: trainerId,
        sessionNumber: sessionNumber,
        title: getSessionTitle(sessionNumber, scenario.goal),
        exercises: exercises,
        isCompleted: isCompleted,
        scheduledDate: admin.firestore.Timestamp.fromDate(scheduledDate),
        completedDate: isCompleted ? admin.firestore.Timestamp.fromDate(scheduledDate) : null,
        isAiGenerated: Math.random() > 0.5,
        createdAt: admin.firestore.Timestamp.fromDate(
          new Date(scheduledDate.getTime() - 3 * 24 * 60 * 60 * 1000)
        ),
      });

      sessionNumber++;
    }
  }

  await batch.commit();
}

function getExerciseTemplates(goal) {
  if (goal === 'diet' || goal === 'fitness') {
    return [
      { name: '트레드밀', sets: 1, reps: 20, weight: null },
      { name: '스쿼트', sets: 4, reps: 12, weight: 40 },
      { name: '레그프레스', sets: 4, reps: 15, weight: 80 },
      { name: '런지', sets: 3, reps: 12, weight: 10 },
      { name: '벤치프레스', sets: 4, reps: 10, weight: 30 },
      { name: '랫풀다운', sets: 4, reps: 12, weight: 35 },
      { name: '덤벨 숄더프레스', sets: 3, reps: 12, weight: 8 },
      { name: '플랭크', sets: 3, reps: 60, weight: null },
    ];
  } else {
    // bulk
    return [
      { name: '벤치프레스', sets: 5, reps: 5, weight: 80 },
      { name: '데드리프트', sets: 5, reps: 5, weight: 100 },
      { name: '스쿼트', sets: 5, reps: 5, weight: 90 },
      { name: '바벨로우', sets: 4, reps: 8, weight: 60 },
      { name: '오버헤드프레스', sets: 4, reps: 8, weight: 40 },
      { name: '바벨컬', sets: 3, reps: 10, weight: 25 },
      { name: '트라이셉스 익스텐션', sets: 3, reps: 10, weight: 20 },
      { name: '레그컬', sets: 4, reps: 12, weight: 40 },
    ];
  }
}

function generateExercises(templates, sessionNumber) {
  // 5-6개 운동 선택
  const shuffled = [...templates].sort(() => Math.random() - 0.5);
  const selected = shuffled.slice(0, 5 + Math.floor(Math.random() * 2));

  return selected.map(template => ({
    name: template.name,
    sets: template.sets,
    reps: template.reps,
    weight: template.weight !== null
      ? template.weight + Math.round(sessionNumber * 0.5) // 점진적 증량
      : null,
    restSeconds: 60 + Math.floor(Math.random() * 60),
    note: null,
  }));
}

function getSessionTitle(sessionNumber, goal) {
  const isUpper = sessionNumber % 2 === 1;
  if (goal === 'bulk') {
    return isUpper ? '상체 근비대' : '하체 근비대';
  } else {
    return isUpper ? '상체 + 코어' : '하체 + 유산소';
  }
}

// ============================================================
// 식단 기록 생성 (1주치)
// ============================================================

async function createDietRecords(memberId, scenario) {
  const now = new Date();
  const mealTypes = ['breakfast', 'lunch', 'dinner'];
  const meals = getMealTemplates(scenario.goal);
  const batch = db.batch();

  for (let day = 0; day < 7; day++) {
    const recordDate = new Date(now.getTime() - (6 - day) * 24 * 60 * 60 * 1000);

    // 하루 2-3끼 기록
    const mealsToday = Math.floor(Math.random() * 2) + 2;
    const shuffledMeals = [...mealTypes].sort(() => Math.random() - 0.5);

    for (let i = 0; i < mealsToday; i++) {
      const mealType = shuffledMeals[i];
      const mealList = meals[mealType];
      const meal = mealList[Math.floor(Math.random() * mealList.length)];

      const docRef = db.collection('diet_records').doc();
      batch.set(docRef, {
        memberId: memberId,
        recordDate: admin.firestore.Timestamp.fromDate(recordDate),
        mealType: mealType,
        imageUrl: null,
        description: meal.name,
        aiAnalysis: {
          foodName: meal.name,
          calories: meal.calories,
          protein: meal.protein,
          carbs: meal.carbs,
          fat: meal.fat,
          confidence: 0.85 + Math.random() * 0.1,
          feedback: meal.feedback,
        },
        note: null,
        createdAt: admin.firestore.Timestamp.fromDate(recordDate),
        updatedAt: admin.firestore.Timestamp.fromDate(recordDate),
      });
    }
  }

  await batch.commit();
}

function getMealTemplates(goal) {
  if (goal === 'diet' || goal === 'fitness') {
    return {
      breakfast: [
        {
          name: '그릭요거트 + 그래놀라',
          calories: 280,
          protein: 18,
          carbs: 35,
          fat: 8,
          feedback: '단백질 함량이 좋습니다!',
        },
        {
          name: '삶은 계란 2개 + 통밀빵',
          calories: 320,
          protein: 20,
          carbs: 28,
          fat: 14,
          feedback: '균형 잡힌 아침식사입니다.',
        },
        {
          name: '오트밀 + 바나나',
          calories: 350,
          protein: 10,
          carbs: 65,
          fat: 6,
          feedback: '단백질을 추가하면 더 좋겠어요.',
        },
      ],
      lunch: [
        {
          name: '닭가슴살 샐러드',
          calories: 380,
          protein: 35,
          carbs: 20,
          fat: 18,
          feedback: '훌륭한 고단백 점심입니다!',
        },
        {
          name: '연어 포케볼',
          calories: 520,
          protein: 30,
          carbs: 55,
          fat: 20,
          feedback: '오메가3가 풍부합니다.',
        },
        {
          name: '제육볶음 정식 (밥 반공기)',
          calories: 580,
          protein: 28,
          carbs: 60,
          fat: 25,
          feedback: '밥 양 조절 잘 하셨어요.',
        },
      ],
      dinner: [
        {
          name: '두부 스테이크 + 야채',
          calories: 320,
          protein: 22,
          carbs: 18,
          fat: 18,
          feedback: '저녁으로 가볍고 좋습니다.',
        },
        {
          name: '닭가슴살 + 고구마',
          calories: 420,
          protein: 40,
          carbs: 45,
          fat: 8,
          feedback: '운동 후 식사로 적합합니다.',
        },
        {
          name: '소고기 샤브샤브',
          calories: 380,
          protein: 32,
          carbs: 15,
          fat: 22,
          feedback: '단백질 섭취 굿!',
        },
      ],
    };
  } else {
    // bulk - 더 많은 칼로리
    return {
      breakfast: [
        {
          name: '계란 프라이 3개 + 베이컨 + 토스트',
          calories: 650,
          protein: 35,
          carbs: 40,
          fat: 40,
          feedback: '벌크업에 적합한 아침입니다.',
        },
        {
          name: '프로틴 팬케이크 + 바나나 + 땅콩버터',
          calories: 720,
          protein: 45,
          carbs: 75,
          fat: 28,
          feedback: '훌륭한 탄단지 비율!',
        },
      ],
      lunch: [
        {
          name: '소고기 덮밥 곱빼기',
          calories: 850,
          protein: 45,
          carbs: 95,
          fat: 30,
          feedback: '근성장에 필요한 칼로리 확보!',
        },
        {
          name: '치킨 마요 덮밥 + 계란',
          calories: 920,
          protein: 50,
          carbs: 90,
          fat: 38,
          feedback: '단백질 섭취량 훌륭합니다.',
        },
      ],
      dinner: [
        {
          name: '삼겹살 200g + 쌈 + 밥',
          calories: 950,
          protein: 40,
          carbs: 60,
          fat: 60,
          feedback: '지방 섭취가 많지만 벌크업엔 OK.',
        },
        {
          name: '스테이크 300g + 감자 + 야채',
          calories: 880,
          protein: 65,
          carbs: 50,
          fat: 45,
          feedback: '완벽한 벌크업 저녁입니다!',
        },
      ],
    };
  }
}

// ============================================================
// 인바디 기록 생성 (2회)
// ============================================================

async function createInbodyRecords(memberId, scenario) {
  const now = new Date();
  const batch = db.batch();

  // 첫 번째 측정 (등록 시)
  const firstDate = new Date(now.getTime() - scenario.weeksActive * 7 * 24 * 60 * 60 * 1000);
  const firstData = generateInbodyData(scenario, 0);

  const firstDocRef = db.collection('inbody_records').doc();
  batch.set(firstDocRef, {
    memberId: memberId,
    measuredAt: admin.firestore.Timestamp.fromDate(firstDate),
    ...firstData,
    source: 'manual',
    memo: '등록 시 측정',
    createdAt: admin.firestore.Timestamp.fromDate(firstDate),
  });

  // 두 번째 측정 (4주 후)
  if (scenario.weeksActive >= 4) {
    const secondDate = new Date(now.getTime() - (scenario.weeksActive - 4) * 7 * 24 * 60 * 60 * 1000);
    const secondData = generateInbodyData(scenario, 4);

    const secondDocRef = db.collection('inbody_records').doc();
    batch.set(secondDocRef, {
      memberId: memberId,
      measuredAt: admin.firestore.Timestamp.fromDate(secondDate),
      ...secondData,
      source: 'manual',
      memo: '4주차 측정',
      createdAt: admin.firestore.Timestamp.fromDate(secondDate),
    });
  }

  await batch.commit();
}

function generateInbodyData(scenario, weeksPassed) {
  let weight = scenario.startWeight;
  let bodyFatPercent;
  let skeletalMuscleMass;

  // 초기 체성분 설정
  switch (scenario.scenario) {
    case 'dietSuccess':
      bodyFatPercent = 32.0;
      skeletalMuscleMass = 22.0;
      if (weeksPassed > 0) {
        weight -= weeksPassed * 1.0;
        bodyFatPercent -= weeksPassed * 0.8;
        skeletalMuscleMass += weeksPassed * 0.1;
      }
      break;
    case 'bulkingUp':
      bodyFatPercent = 15.0;
      skeletalMuscleMass = 35.0;
      if (weeksPassed > 0) {
        weight += weeksPassed * 0.5;
        bodyFatPercent += weeksPassed * 0.2;
        skeletalMuscleMass += weeksPassed * 0.4;
      }
      break;
    case 'attendanceDropping':
      bodyFatPercent = 28.0;
      skeletalMuscleMass = 20.0;
      if (weeksPassed > 0) {
        weight -= weeksPassed * 0.3;
        bodyFatPercent -= weeksPassed * 0.3;
      }
      break;
    case 'ptEndingSoon':
      bodyFatPercent = 30.0;
      skeletalMuscleMass = 28.0;
      if (weeksPassed > 0) {
        weight -= weeksPassed * 0.8;
        bodyFatPercent -= weeksPassed * 0.6;
        skeletalMuscleMass += weeksPassed * 0.2;
      }
      break;
    case 'newMember':
      bodyFatPercent = 26.0;
      skeletalMuscleMass = 21.0;
      break;
  }

  const bodyFatMass = weight * bodyFatPercent / 100;
  const height = 165 + Math.floor(Math.random() * 20); // 165-185cm
  const bmi = weight / ((height / 100) * (height / 100));

  return {
    weight: parseFloat(weight.toFixed(1)),
    skeletalMuscleMass: parseFloat(skeletalMuscleMass.toFixed(1)),
    bodyFatMass: parseFloat(bodyFatMass.toFixed(1)),
    bodyFatPercent: parseFloat(bodyFatPercent.toFixed(1)),
    bmi: parseFloat(bmi.toFixed(1)),
    basalMetabolicRate: Math.round(1200 + skeletalMuscleMass * 15),
    totalBodyWater: parseFloat((weight * 0.55).toFixed(1)),
    protein: parseFloat((weight * 0.16).toFixed(1)),
    minerals: parseFloat((weight * 0.05).toFixed(1)),
    visceralFatLevel: Math.round(bodyFatPercent / 3),
    inbodyScore: Math.round(75 + (100 - bodyFatPercent) * 0.3),
  };
}

// ============================================================
// 채팅 메시지 생성 (10개)
// ============================================================

async function createChatMessages(memberId, trainerId, scenario) {
  const now = new Date();

  // 채팅방 생성
  const chatRoomRef = db.collection('chat_rooms').doc();
  await chatRoomRef.set({
    trainerId: trainerId,
    memberId: memberId,
    trainerName: TRAINER_NAME,
    memberName: scenario.name,
    trainerProfileUrl: null,
    memberProfileUrl: null,
    lastMessage: '',
    lastMessageAt: admin.firestore.Timestamp.now(),
    unreadCountTrainer: 0,
    unreadCountMember: 0,
    createdAt: admin.firestore.Timestamp.now(),
  });

  const messages = getChatMessages(scenario);
  const batch = db.batch();

  for (let i = 0; i < messages.length; i++) {
    const message = messages[i];
    const messageDate = new Date(now.getTime() - (messages.length - i) * 8 * 60 * 60 * 1000);

    const docRef = db.collection('messages').doc();
    batch.set(docRef, {
      chatRoomId: chatRoomRef.id,
      senderId: message.isTrainer ? trainerId : memberId,
      senderRole: message.isTrainer ? 'trainer' : 'member',
      content: message.content,
      imageUrl: null,
      createdAt: admin.firestore.Timestamp.fromDate(messageDate),
      isRead: true,
    });

    // 마지막 메시지 업데이트
    if (i === messages.length - 1) {
      batch.update(chatRoomRef, {
        lastMessage: message.content,
        lastMessageAt: admin.firestore.Timestamp.fromDate(messageDate),
      });
    }
  }

  await batch.commit();
}

function getChatMessages(scenario) {
  switch (scenario.scenario) {
    case 'dietSuccess':
      return [
        { isTrainer: true, content: `${scenario.name}님, 이번 주 체중 변화가 정말 좋네요! 👏` },
        { isTrainer: false, content: '감사합니다 트레이너님! 식단 조절이 효과가 있는 것 같아요' },
        { isTrainer: true, content: '네! 특히 저녁 탄수화물 줄인 게 큰 도움이 됐어요' },
        { isTrainer: false, content: '근데 요즘 운동 후에 너무 배고파요ㅠㅠ' },
        { isTrainer: true, content: '운동 직후 단백질 쉐이크 한 잔 드셔보세요' },
        { isTrainer: false, content: '네 알겠습니다! 다음 PT 때 뵐게요' },
        { isTrainer: true, content: '화요일 2시 맞으시죠?' },
        { isTrainer: false, content: '네 맞아요~' },
        { isTrainer: true, content: '좋아요! 이번 주도 화이팅입니다 💪' },
        { isTrainer: false, content: '감사합니다!!' },
      ];
    case 'bulkingUp':
      return [
        { isTrainer: true, content: '준혁님, 벤치 중량이 많이 늘었네요!' },
        { isTrainer: false, content: '네! 드디어 80kg 성공했어요 ㅎㅎ' },
        { isTrainer: true, content: '대단해요! 다음 목표는 90kg으로 잡아볼까요?' },
        { isTrainer: false, content: '좋아요! 근데 어깨가 좀 뻐근한데 괜찮을까요?' },
        { isTrainer: true, content: '스트레칭 잘 하고 계시죠? 영상 보내드릴게요' },
        { isTrainer: false, content: '네 감사합니다' },
        { isTrainer: true, content: '그리고 단백질 섭취 늘려주세요. 체중 x 2g 목표로요' },
        { isTrainer: false, content: '알겠습니다! 프로틴 더 챙겨먹을게요' },
        { isTrainer: true, content: '금요일 PT 때 데드리프트 폼 다시 잡아드릴게요' },
        { isTrainer: false, content: '네! 기대됩니다 💪' },
      ];
    case 'attendanceDropping':
      return [
        { isTrainer: true, content: '서연님, 요즘 PT 참석이 어려우신가요?' },
        { isTrainer: false, content: '죄송해요ㅠㅠ 회사일이 너무 바빠서...' },
        { isTrainer: true, content: '이해해요! 혹시 시간대 조정이 필요하시면 말씀해주세요' },
        { isTrainer: false, content: '저녁 8시 이후로 바꿀 수 있을까요?' },
        { isTrainer: true, content: '네 가능해요! 월수금 8시로 변경해드릴까요?' },
        { isTrainer: false, content: '월수만 가능할 것 같아요' },
        { isTrainer: true, content: '알겠습니다. 그럼 월수 8시로 변경할게요' },
        { isTrainer: false, content: '감사합니다 트레이너님' },
        { isTrainer: true, content: '홈트 영상도 보내드릴게요. 바쁘실 때 집에서 해보세요!' },
        { isTrainer: false, content: '네 꼭 해볼게요!' },
      ];
    case 'ptEndingSoon':
      return [
        { isTrainer: true, content: '우성님, PT 2회 남았네요!' },
        { isTrainer: false, content: '벌써요? 시간 진짜 빠르네요' },
        { isTrainer: true, content: '목표 체중 거의 달성하셨어요. 75kg까지 2kg 남았네요' },
        { isTrainer: false, content: '연장 등록하면 할인 되나요?' },
        { isTrainer: true, content: '네! 연장 시 10% 할인 있어요' },
        { isTrainer: false, content: '12회 더 등록하고 싶어요' },
        { isTrainer: true, content: '좋아요! 다음 PT 때 등록 도와드릴게요' },
        { isTrainer: false, content: '이번엔 근력 강화 위주로 해보고 싶어요' },
        { isTrainer: true, content: '좋습니다! 체중 감량 성공하셨으니 근비대로 가시죠' },
        { isTrainer: false, content: '기대돼요! 감사합니다' },
      ];
    case 'newMember':
      return [
        { isTrainer: true, content: '소희님, 오늘 첫 PT 어떠셨어요?' },
        { isTrainer: false, content: '생각보다 힘들었어요ㅠㅠ 근육통 올 것 같아요' },
        { isTrainer: true, content: 'ㅎㅎ 처음엔 다 그래요! 스트레칭 영상 보내드릴게요' },
        { isTrainer: false, content: '감사합니다! 운동 진짜 처음이라 걱정돼요' },
        { isTrainer: true, content: '걱정 마세요. 차근차근 알려드릴게요' },
        { isTrainer: false, content: '식단은 어떻게 해야 할까요?' },
        { isTrainer: true, content: '일단 단백질 위주로 드시고, 식단 기록 앱에 올려주세요' },
        { isTrainer: false, content: '네 알겠습니다!' },
        { isTrainer: true, content: '목요일 PT 때 뵐게요. 화이팅! 🙌' },
        { isTrainer: false, content: '네! 감사합니다~~' },
      ];
    default:
      return [];
  }
}

// ============================================================
// 유틸리티 함수
// ============================================================

function generateMemberCode() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let result = '';
  for (let i = 0; i < 6; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
}

function getScenarioLabel(type) {
  switch (type) {
    case 'dietSuccess':
      return '다이어트 성공';
    case 'bulkingUp':
      return '벌크업 중';
    case 'attendanceDropping':
      return '출석률 하락';
    case 'ptEndingSoon':
      return 'PT 종료 임박';
    case 'newMember':
      return '신규 회원';
    default:
      return type;
  }
}

function getMemoForScenario(type) {
  switch (type) {
    case 'dietSuccess':
      return '무릎 통증 있음. 점프 운동 제외.';
    case 'bulkingUp':
      return '어깨 부상 이력. 무거운 오버헤드 주의.';
    case 'attendanceDropping':
      return '직장인. 야근 많음.';
    case 'ptEndingSoon':
      return '연장 등록 희망. 근비대 프로그램 추천.';
    case 'newMember':
      return '운동 완전 초보. 기초 체력부터.';
    default:
      return '';
  }
}

// 실행
main();
