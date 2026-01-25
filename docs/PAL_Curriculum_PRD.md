# PAL AI 커리큘럼 생성 v2 - Ralph PRD

## 프로젝트 개요

PAL 플랫폼의 AI 커리큘럼 생성 기능을 고도화한다. 트레이너가 사전 조건을 설정하면 AI가 초안을 생성하고, 트레이너가 운동을 수정/대체하여 최종 확정하는 플로우를 구현한다.

## 핵심 변경 사항

1. **사전 조건 설정 UI** - 종목 수, 세트 수, 집중 부위, 제외 운동, 운동 스타일 선택
2. **운동 DB 한국어화** - free-exercise-db 800개 운동을 한국어로 번역하여 Firestore에 저장
3. **AI 대체 추천** - 트레이너가 운동 대체 시 AI가 유사 운동 3개 추천
4. **헬스장 프리셋** - 자주 제외하는 운동을 저장하여 자동 적용

## 기술 스택

- **Frontend**: Flutter (웹 + 앱)
- **Backend**: Firebase Cloud Functions (Node.js 18)
- **Database**: Firestore
- **AI Model**: Gemini 2.0 Flash (커리큘럼 생성), GPT-4o-mini (대체 추천)
- **운동 DB**: free-exercise-db 기반 한국어 커스텀 DB

---

## Stories

### Story 1: exercises 컬렉션 생성 및 한국어 데이터 구축
- [ ] Firestore에 `/exercises/{exerciseId}` 컬렉션 생성
- [ ] 스키마 정의:
  ```typescript
  interface Exercise {
    id: string;
    nameKo: string;              // 한국어 이름 (바벨 벤치프레스)
    nameEn: string;              // 영어 이름 (Barbell Bench Press)
    equipment: string;           // 장비 (바벨, 덤벨, 케이블, 머신, 맨몸)
    equipmentEn: string;         // 영어 장비명
    primaryMuscle: string;       // 주 타겟 (가슴, 등, 하체, 어깨, 팔, 복근)
    secondaryMuscles: string[];  // 보조 타겟
    level: string;               // 난이도 (초급, 중급, 고급)
    force: string;               // 힘 방향 (push, pull, static)
    mechanic: string;            // 운동 유형 (compound, isolation)
    instructions: string[];      // 운동 방법 (한국어)
    imageUrl?: string;           // 운동 이미지 URL
    tags: string[];              // 검색용 태그
    createdAt: Timestamp;
  }
  ```
- [ ] free-exercise-db에서 800개 운동 데이터 가져오기
- [ ] GPT-4o로 일괄 한국어 번역 스크립트 작성
- [ ] 번역된 데이터 Firestore에 업로드
- [ ] 검색용 복합 인덱스 생성: `primaryMuscle + equipment`

### Story 2: trainer_presets 컬렉션 생성
- [ ] Firestore에 `/trainer_presets/{trainerId}` 컬렉션 생성
- [ ] 스키마 정의:
  ```typescript
  interface TrainerPreset {
    trainerId: string;
    gymName?: string;                    // 헬스장 이름 (선택)
    excludedExerciseIds: string[];       // 자주 제외하는 운동 ID 목록
    defaultExerciseCount: number;        // 기본 종목 수 (1-10)
    defaultSetCount: number;             // 기본 세트 수 (1-10)
    preferredStyles: string[];           // 선호 운동 스타일
    createdAt: Timestamp;
    updatedAt: Timestamp;
  }
  ```

### Story 3: 커리큘럼 사전 조건 설정 UI (Flutter)
- [ ] `/lib/features/curriculum/presentation/pages/curriculum_settings_page.dart` 생성
- [ ] 종목 수 선택 위젯 (휠 피커, 1-10)
- [ ] 세트 수 선택 위젯 (휠 피커, 1-10)
- [ ] 집중 부위 칩 버튼 (가슴, 등, 하체, 어깨, 팔, 복근, 전신)
- [ ] 제외 운동 검색 컴포넌트:
  - 검색창에 입력하면 exercises 컬렉션에서 실시간 검색
  - 선택하면 칩으로 추가 (X 버튼으로 삭제)
- [ ] 제외 부위(부상/통증) 칩 버튼 (어깨, 허리, 무릎, 손목, 발목, 목, 팔꿈치, 고관절)
- [ ] 운동 스타일 칩 버튼:
  - 강도: 고중량, 저중량
  - 반복: 고반복, 저반복
  - 방식: 서킷, 슈퍼세트, 드롭세트, 피라미드, 자이언트세트
  - 유형: 컴파운드 위주, 고립 위주
  - 목적: 스트렝스, 근비대, 근지구력
- [ ] 기타 요청 텍스트 필드 (1줄)
- [ ] "스킵하고 바로 생성" / "설정 적용 후 생성" 버튼

### Story 4: generateCurriculumV2 Cloud Function 구현
- [ ] `/functions/src/curriculum/generateCurriculumV2.ts` 생성
- [ ] 입력:
  ```typescript
  interface GenerateCurriculumV2Request {
    memberId: string;
    trainerId: string;
    settings: {
      exerciseCount: number;       // 1-10
      setCount: number;            // 1-10
      focusParts: string[];        // 집중 부위
      excludedExerciseIds: string[]; // 제외 운동 ID
      excludedBodyParts: string[]; // 제외 부위 (부상)
      styles: string[];            // 운동 스타일
      additionalNotes?: string;    // 기타 요청
    };
    memberInfo: {
      goal: string;                // diet | bulk | fitness | rehab
      experience: string;          // beginner | intermediate | advanced
      restrictions?: string;       // 기존 제한사항
    };
  }
  ```
- [ ] 출력:
  ```typescript
  interface GenerateCurriculumV2Response {
    success: boolean;
    curriculum: {
      exercises: Array<{
        exerciseId: string;
        name: string;
        sets: number;
        reps: number;
        restSeconds?: number;
        notes?: string;
      }>;
      totalSets: number;
      estimatedDuration: number;  // 예상 소요 시간 (분)
      aiNotes: string;            // AI 코멘트
    };
  }
  ```
- [ ] AI 프롬프트 로직:
  ```typescript
  const buildPrompt = (request: GenerateCurriculumV2Request, exercises: Exercise[]) => {
    // 제외 운동 필터링된 운동 목록 전달
    const availableExercises = exercises.filter(ex => 
      !request.settings.excludedExerciseIds.includes(ex.id) &&
      !request.settings.excludedBodyParts.some(part => 
        ex.primaryMuscle.includes(part) || ex.secondaryMuscles.includes(part)
      )
    );
    
    return `
당신은 전문 피트니스 트레이너입니다.
아래 조건에 맞는 PT 커리큘럼을 생성해주세요.

## 회원 정보
- 운동 목표: ${request.memberInfo.goal}
- 운동 경력: ${request.memberInfo.experience}
- 제한사항: ${request.memberInfo.restrictions || '없음'}

## 커리큘럼 설정
- 종목 수: ${request.settings.exerciseCount}개
- 세트 수: 종목당 ${request.settings.setCount}세트
- 집중 부위: ${request.settings.focusParts.join(', ') || '전신'}
- 운동 스타일: ${request.settings.styles.join(', ') || '일반'}
- 추가 요청: ${request.settings.additionalNotes || '없음'}

## 사용 가능한 운동 목록
${availableExercises.map(ex => `- ${ex.nameKo} (${ex.primaryMuscle}, ${ex.equipment})`).join('\n')}

## 응답 형식 (JSON)
{
  "exercises": [
    {
      "exerciseId": "운동ID",
      "name": "운동명",
      "sets": 세트수,
      "reps": 반복횟수,
      "restSeconds": 휴식시간(초),
      "notes": "운동 팁"
    }
  ],
  "aiNotes": "전체 커리큘럼에 대한 코멘트"
}

주의사항:
1. 반드시 사용 가능한 운동 목록에서만 선택하세요
2. 집중 부위 운동을 우선 배치하세요
3. 운동 스타일에 맞게 세트/반복/휴식을 조정하세요
4. 복합운동(컴파운드)을 먼저, 고립운동을 나중에 배치하세요
    `;
  };
  ```

### Story 5: getAlternativeExercises Cloud Function 구현
- [ ] `/functions/src/curriculum/getAlternativeExercises.ts` 생성
- [ ] 트레이너가 "대체" 버튼 누르면 호출
- [ ] 입력:
  ```typescript
  interface GetAlternativesRequest {
    exerciseId: string;         // 현재 운동 ID
    excludedExerciseIds: string[]; // 이미 커리큘럼에 있는 운동들
  }
  ```
- [ ] 출력:
  ```typescript
  interface GetAlternativesResponse {
    success: boolean;
    alternatives: Array<{
      exerciseId: string;
      name: string;
      equipment: string;
      reason: string;  // 왜 대체로 적합한지
    }>;
  }
  ```
- [ ] 로직:
  1. 현재 운동의 primaryMuscle 조회
  2. 같은 primaryMuscle을 가진 운동 중 제외 목록에 없는 것 필터
  3. equipment가 다양하게 3개 선택 (바벨 → 덤벨, 머신, 맨몸 등)
  4. GPT-4o-mini로 각 대체 운동이 적합한 이유 생성

### Story 6: 커리큘럼 수정 UI (Flutter)
- [ ] `/lib/features/curriculum/presentation/pages/curriculum_edit_page.dart` 생성
- [ ] 생성된 커리큘럼 리스트 표시
- [ ] 각 운동 카드:
  - 운동명, 세트 × 반복 표시
  - "대체" 버튼 → getAlternativeExercises 호출 → 3개 옵션 표시
  - "수정" 버튼 → 세트/반복/휴식시간 직접 수정
  - 드래그로 순서 변경
- [ ] "커리큘럼 확정" 버튼 → Firestore 저장

### Story 7: 헬스장 프리셋 설정 UI
- [ ] `/lib/features/settings/presentation/pages/gym_preset_page.dart` 생성
- [ ] 헬스장 이름 입력 (선택)
- [ ] 기본 종목 수 설정 (휠 피커, 1-10)
- [ ] 기본 세트 수 설정 (휠 피커, 1-10)
- [ ] 자주 제외하는 운동 검색 및 저장
- [ ] 선호 운동 스타일 저장
- [ ] "저장" 버튼 → trainer_presets 컬렉션에 저장

### Story 8: 프리셋 자동 적용 로직
- [ ] 커리큘럼 설정 화면 진입 시:
  1. trainer_presets에서 해당 트레이너 프리셋 로드
  2. 기본값으로 종목 수, 세트 수, 제외 운동, 스타일 자동 설정
  3. 트레이너가 수정 가능
- [ ] "프리셋 불러오기" 버튼 추가 (수동 적용)

### Story 9: curriculums 컬렉션 스키마 업데이트
- [ ] 기존 curriculums 스키마에 필드 추가:
  ```typescript
  interface CurriculumV2 {
    // 기존 필드
    memberId: string;
    trainerId: string;
    sessionNumber: number;
    title: string;
    isCompleted: boolean;
    scheduledDate?: Timestamp;
    isAiGenerated: boolean;
    
    // 새 필드
    exercises: Array<{
      exerciseId: string;        // exercises 컬렉션 참조
      name: string;
      sets: number;
      reps: number;
      weight?: number;
      restSeconds?: number;
      notes?: string;
      isModifiedByTrainer: boolean;  // 트레이너가 수정했는지
    }>;
    settings: {                   // 생성 시 사용된 설정
      exerciseCount: number;
      setCount: number;
      focusParts: string[];
      styles: string[];
    };
    aiNotes?: string;
    createdAt: Timestamp;
    updatedAt: Timestamp;
  }
  ```

### Story 10: 운동 검색 API
- [ ] `/functions/src/exercises/searchExercises.ts` 생성
- [ ] 입력:
  ```typescript
  interface SearchExercisesRequest {
    query: string;              // 검색어
    filters?: {
      primaryMuscle?: string;
      equipment?: string;
      level?: string;
    };
    limit?: number;             // 기본 10개
  }
  ```
- [ ] Firestore 쿼리 최적화 (부분 문자열 검색은 tags 배열 활용)

### Story 11: 에러 처리 및 Fallback
- [ ] AI 생성 실패 시 기본 템플릿 커리큘럼 반환
- [ ] 운동 DB에 해당 조건 운동이 부족할 경우 경고 메시지
- [ ] 네트워크 에러 시 재시도 로직 (최대 3회)

### Story 12: 단위 테스트
- [ ] `/functions/src/curriculum/__tests__/generateCurriculumV2.test.ts`
- [ ] 테스트 케이스:
  - 정상 케이스: 모든 설정 적용된 커리큘럼 생성
  - 제외 운동이 결과에 포함되지 않는지 확인
  - 제외 부위 운동이 결과에 포함되지 않는지 확인
  - 종목 수/세트 수가 정확히 반영되는지 확인
  - 운동 스타일에 따른 반복 횟수 조정 확인

---

## AI 프롬프트 상세

### 커리큘럼 생성 프롬프트 (Gemini 2.0 Flash)

```
당신은 10년 경력의 전문 피트니스 트레이너입니다.
아래 조건에 맞는 50분 PT 수업용 커리큘럼을 생성해주세요.

## 회원 정보
- 운동 목표: {goal}
  - diet: 체중 감량, 유산소 + 근력 병행
  - bulk: 근육량 증가, 고중량 위주
  - fitness: 전반적 체력 향상
  - rehab: 재활, 저중량 고반복
- 운동 경력: {experience}
  - beginner: 기초 동작 위주, 머신 활용
  - intermediate: 프리웨이트 병행
  - advanced: 고급 테크닉 활용 가능
- 기존 제한사항: {restrictions}

## 커리큘럼 설정
- 종목 수: {exerciseCount}개 (정확히 이 개수로)
- 세트 수: 종목당 {setCount}세트
- 집중 부위: {focusParts}
- 운동 스타일: {styles}
- 추가 요청: {additionalNotes}

## 운동 스타일 가이드
- 고중량: 6-8회, 휴식 90-120초
- 저중량: 15-20회, 휴식 30-45초
- 고반복: 15-20회
- 저반복: 4-6회
- 서킷: 휴식 최소화, 연속 수행
- 슈퍼세트: 2개 운동 연속, 세트 간 휴식
- 드롭세트: 중량 감소하며 연속 수행
- 피라미드: 점진적 중량 증가/감소
- 컴파운드 위주: 다관절 운동 70% 이상
- 고립 위주: 단관절 운동 70% 이상
- 스트렝스: 3-5회, 고중량
- 근비대: 8-12회, 중량
- 근지구력: 15회 이상, 저중량

## 사용 가능한 운동 목록 (이 목록에서만 선택)
{availableExercises}

## 응답 규칙
1. 반드시 JSON 형식으로만 응답
2. 사용 가능한 운동 목록의 exerciseId를 정확히 사용
3. 복합운동을 먼저, 고립운동을 나중에 배치
4. 같은 부위 연속 배치 피하기 (슈퍼세트 제외)
5. 50분 수업에 맞는 현실적인 구성

## 응답 형식
{
  "exercises": [
    {
      "exerciseId": "ex_001",
      "name": "바벨 벤치프레스",
      "sets": 4,
      "reps": 10,
      "restSeconds": 90,
      "notes": "가슴을 열고 견갑골 고정"
    }
  ],
  "totalSets": 20,
  "estimatedDuration": 45,
  "aiNotes": "가슴 집중 루틴입니다. 벤치프레스로 시작해 점진적으로..."
}
```

### 대체 운동 추천 프롬프트 (GPT-4o-mini)

```
당신은 피트니스 트레이너입니다.
아래 운동의 대체 운동 3개를 추천해주세요.

## 현재 운동
- 이름: {currentExercise.name}
- 타겟 부위: {currentExercise.primaryMuscle}
- 장비: {currentExercise.equipment}

## 대체 후보
{alternativeCandidates}

## 응답 규칙
1. 같은 근육을 자극하는 운동 선택
2. 가능하면 다른 장비 사용하는 운동 포함
3. 각 운동이 왜 좋은 대체인지 한 줄로 설명

## 응답 형식 (JSON)
{
  "alternatives": [
    {
      "exerciseId": "ex_002",
      "name": "덤벨 벤치프레스",
      "equipment": "덤벨",
      "reason": "가동범위가 넓어 더 깊은 스트레칭 가능"
    }
  ]
}
```

---

## 파일 구조

```
functions/
├── src/
│   ├── curriculum/
│   │   ├── generateCurriculumV2.ts
│   │   ├── getAlternativeExercises.ts
│   │   ├── types.ts
│   │   └── prompts.ts
│   ├── exercises/
│   │   ├── searchExercises.ts
│   │   ├── importExercises.ts    # 한국어 DB 임포트 스크립트
│   │   └── types.ts
│   └── index.ts

lib/
├── features/
│   ├── curriculum/
│   │   ├── data/
│   │   │   └── curriculum_repository.dart
│   │   ├── domain/
│   │   │   └── curriculum_model.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── curriculum_settings_page.dart
│   │       │   └── curriculum_edit_page.dart
│   │       └── widgets/
│   │           ├── wheel_picker.dart
│   │           ├── chip_button.dart
│   │           ├── exercise_search.dart
│   │           └── curriculum_card.dart
│   └── settings/
│       └── presentation/
│           └── pages/
│               └── gym_preset_page.dart
```

---

## Acceptance Criteria

1. 트레이너가 종목 수(1-10), 세트 수(1-10)를 휠 피커로 설정할 수 있다
2. 제외 운동을 검색하여 선택하면 AI가 해당 운동을 추천하지 않는다
3. 집중 부위를 선택하면 해당 부위 운동이 우선 배치된다
4. 운동 스타일에 따라 반복 횟수와 휴식 시간이 자동 조정된다
5. 생성된 커리큘럼에서 "대체" 버튼을 누르면 3개 대체 운동이 추천된다
6. 트레이너가 직접 운동을 수정할 수 있다
7. 헬스장 프리셋을 저장하면 다음 생성 시 자동 적용된다
8. 모든 UI가 다크 테마로 일관되게 표시된다

---

## 완료 조건

모든 Story의 체크박스가 완료되고, `flutter test` 및 `npm test`가 통과하면 `<promise>COMPLETE</promise>` 출력
