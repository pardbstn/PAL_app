# PAL 코드 리팩토링 - Ralph PRD

## 프로젝트 개요

PAL 플랫폼의 기존 코드를 분석하고 리팩토링한다. 기능은 그대로 유지하면서 코드 구조를 개선하여 유지보수성, 가독성, 확장성을 높인다.

## 기술 스택

- **Flutter**: Dart, Riverpod, GoRouter
- **Backend**: Firebase Cloud Functions (Node.js 18, TypeScript)
- **Database**: Firestore

---

## Phase 1: 코드 분석

### Story 1: 프로젝트 구조 파악
- [ ] `lib/` 폴더 전체 구조 확인 (`find lib -type f -name "*.dart" | head -50`)
- [ ] `functions/src/` 폴더 전체 구조 확인
- [ ] 현재 폴더 구조를 `REFACTOR_ANALYSIS.md`에 기록
- [ ] 파일 개수, 총 라인 수 파악

### Story 2: 중복 코드 탐지
- [ ] 모든 `.dart` 파일에서 중복 패턴 찾기:
  - 동일한 Firestore 쿼리 코드
  - 동일한 에러 처리 패턴
  - 동일한 UI 위젯 코드
  - 동일한 유틸리티 함수
- [ ] 모든 `.ts` 파일에서 중복 패턴 찾기:
  - 동일한 API 응답 포맷
  - 동일한 인증 체크 로직
  - 동일한 Firestore 헬퍼 코드
- [ ] 중복 코드 목록을 `REFACTOR_ANALYSIS.md`에 기록

### Story 3: 코드 품질 이슈 탐지
- [ ] 다음 이슈 찾기:
  - 한 파일에 300줄 이상인 파일
  - 한 함수에 50줄 이상인 함수
  - any 타입 사용 (TypeScript)
  - dynamic 타입 사용 (Dart)
  - 하드코딩된 문자열/숫자
  - console.log / print 디버그 코드
  - 주석 처리된 코드 블록
  - TODO/FIXME 주석
- [ ] 이슈 목록을 `REFACTOR_ANALYSIS.md`에 기록

### Story 4: 네이밍 컨벤션 분석
- [ ] 파일명 패턴 분석 (snake_case vs camelCase vs PascalCase)
- [ ] 변수명 패턴 분석
- [ ] 함수명 패턴 분석
- [ ] 불일치 항목을 `REFACTOR_ANALYSIS.md`에 기록

---

## Phase 2: Flutter 코드 리팩토링

### Story 5: 공통 유틸리티 추출
- [ ] `lib/core/utils/` 폴더 생성 (없으면)
- [ ] 중복 코드에서 공통 함수 추출:
  ```dart
  // lib/core/utils/date_utils.dart
  // lib/core/utils/string_utils.dart
  // lib/core/utils/validator_utils.dart
  ```
- [ ] 기존 코드에서 추출한 함수로 교체
- [ ] 테스트 실행하여 기능 동작 확인

### Story 6: Firestore 헬퍼 통합
- [ ] `lib/core/services/firestore_service.dart` 생성 (없으면)
- [ ] 공통 Firestore 작업 메서드 추출:
  ```dart
  class FirestoreService {
    Future<T?> getDocument<T>(String collection, String id);
    Future<void> setDocument<T>(String collection, String id, T data);
    Future<List<T>> queryDocuments<T>(String collection, Query query);
    Stream<List<T>> streamDocuments<T>(String collection, Query query);
  }
  ```
- [ ] 기존 직접 Firestore 호출을 FirestoreService로 교체

### Story 7: 에러 처리 통일
- [ ] `lib/core/errors/` 폴더 생성
- [ ] 커스텀 Exception 클래스 정의:
  ```dart
  // lib/core/errors/app_exception.dart
  class AppException implements Exception {
    final String code;
    final String message;
    AppException(this.code, this.message);
  }
  
  class NetworkException extends AppException {}
  class AuthException extends AppException {}
  class ValidationException extends AppException {}
  ```
- [ ] 기존 try-catch 블록을 통일된 패턴으로 교체

### Story 8: 공통 위젯 추출
- [ ] `lib/core/widgets/` 폴더 정리
- [ ] 중복 UI 패턴을 공통 위젯으로 추출:
  ```dart
  // lib/core/widgets/loading_widget.dart
  // lib/core/widgets/error_widget.dart
  // lib/core/widgets/empty_state_widget.dart
  // lib/core/widgets/custom_button.dart
  // lib/core/widgets/custom_text_field.dart
  ```
- [ ] 기존 코드에서 공통 위젯으로 교체

### Story 9: 상수 및 설정 정리
- [ ] `lib/core/constants/` 폴더 생성
- [ ] 하드코딩된 값 추출:
  ```dart
  // lib/core/constants/app_constants.dart
  class AppConstants {
    static const int maxExerciseCount = 10;
    static const int maxSetCount = 10;
    static const int sessionDurationMinutes = 50;
  }
  
  // lib/core/constants/api_constants.dart
  class ApiConstants {
    static const String generateCurriculum = 'generateCurriculum';
    static const String analyzeDiet = 'analyzeDiet';
  }
  
  // lib/core/constants/firestore_constants.dart
  class FirestoreCollections {
    static const String users = 'users';
    static const String members = 'members';
    static const String trainers = 'trainers';
    static const String curriculums = 'curriculums';
  }
  ```
- [ ] 기존 하드코딩 값을 상수로 교체

### Story 10: Provider 정리
- [ ] 모든 Provider 파일 확인
- [ ] 중복 로직 통합
- [ ] Provider 네이밍 일관성 확보 (xxxProvider, xxxNotifier)
- [ ] 사용하지 않는 Provider 제거

---

## Phase 3: Cloud Functions 리팩토링

### Story 11: 공통 응답 포맷 통일
- [ ] `functions/src/utils/response.ts` 생성:
  ```typescript
  export interface ApiResponse<T> {
    success: boolean;
    data: T | null;
    error: { code: string; message: string } | null;
    timestamp: string;
  }

  export const success = <T>(data: T): ApiResponse<T> => ({
    success: true,
    data,
    error: null,
    timestamp: new Date().toISOString(),
  });

  export const error = (code: string, message: string): ApiResponse<null> => ({
    success: false,
    data: null,
    error: { code, message },
    timestamp: new Date().toISOString(),
  });
  ```
- [ ] 모든 Cloud Function에서 통일된 응답 포맷 사용

### Story 12: 에러 코드 통합
- [ ] `functions/src/constants/error-codes.ts` 생성:
  ```typescript
  export const ErrorCodes = {
    // Auth
    AUTH_REQUIRED: 'auth_required',
    INVALID_TOKEN: 'invalid_token',
    
    // Validation
    INVALID_INPUT: 'invalid_input',
    MISSING_FIELD: 'missing_field',
    
    // Resource
    NOT_FOUND: 'not_found',
    ALREADY_EXISTS: 'already_exists',
    
    // Quota
    QUOTA_EXCEEDED: 'quota_exceeded',
    
    // External
    AI_SERVICE_ERROR: 'ai_service_error',
    FIRESTORE_ERROR: 'firestore_error',
  } as const;
  ```
- [ ] 기존 에러 코드를 상수로 교체

### Story 13: 인증 미들웨어 통합
- [ ] `functions/src/middleware/auth.ts` 생성:
  ```typescript
  export const requireAuth = async (context: functions.https.CallableContext) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', ErrorCodes.AUTH_REQUIRED);
    }
    return context.auth.uid;
  };

  export const requireTrainer = async (uid: string) => {
    const trainer = await getDoc('trainers', uid);
    if (!trainer) {
      throw new functions.https.HttpsError('permission-denied', 'trainer_only');
    }
    return trainer;
  };

  export const requireProTier = async (trainer: Trainer) => {
    if (trainer.subscriptionTier !== 'pro') {
      throw new functions.https.HttpsError('permission-denied', 'pro_tier_required');
    }
  };
  ```
- [ ] 모든 Cloud Function에서 통일된 인증 체크 사용

### Story 14: Firestore 헬퍼 통합
- [ ] `functions/src/utils/firestore.ts` 생성:
  ```typescript
  import { getFirestore } from 'firebase-admin/firestore';
  
  const db = getFirestore();

  export const getDoc = async <T>(collection: string, id: string): Promise<T | null> => {
    const doc = await db.collection(collection).doc(id).get();
    return doc.exists ? ({ id: doc.id, ...doc.data() } as T) : null;
  };

  export const setDoc = async <T extends object>(
    collection: string, 
    id: string, 
    data: T
  ): Promise<void> => {
    await db.collection(collection).doc(id).set(data, { merge: true });
  };

  export const addDoc = async <T extends object>(
    collection: string, 
    data: T
  ): Promise<string> => {
    const ref = await db.collection(collection).add(data);
    return ref.id;
  };

  export const queryDocs = async <T>(
    collection: string,
    ...conditions: [string, FirebaseFirestore.WhereFilterOp, any][]
  ): Promise<T[]> => {
    let query: FirebaseFirestore.Query = db.collection(collection);
    for (const [field, op, value] of conditions) {
      query = query.where(field, op, value);
    }
    const snapshot = await query.get();
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as T));
  };
  ```
- [ ] 기존 직접 Firestore 호출을 헬퍼 함수로 교체

### Story 15: AI API 호출 통합
- [ ] `functions/src/services/ai-service.ts` 생성:
  ```typescript
  import OpenAI from 'openai';

  const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

  export const callGPT = async (
    prompt: string,
    options?: {
      model?: string;
      maxTokens?: number;
      temperature?: number;
    }
  ): Promise<string> => {
    const response = await openai.chat.completions.create({
      model: options?.model || 'gpt-4o-mini',
      max_tokens: options?.maxTokens || 2000,
      temperature: options?.temperature || 0.7,
      messages: [{ role: 'user', content: prompt }],
    });
    return response.choices[0].message.content || '';
  };

  export const callVision = async (
    prompt: string,
    imageUrl: string
  ): Promise<string> => {
    const response = await openai.chat.completions.create({
      model: 'gpt-4o',
      messages: [{
        role: 'user',
        content: [
          { type: 'text', text: prompt },
          { type: 'image_url', image_url: { url: imageUrl } },
        ],
      }],
    });
    return response.choices[0].message.content || '';
  };
  ```
- [ ] 기존 OpenAI 호출을 ai-service로 교체

### Story 16: 타입 정의 정리
- [ ] `functions/src/types/` 폴더 정리
- [ ] 모든 모델 타입 정의 확인:
  ```typescript
  // functions/src/types/models.ts
  export interface User { ... }
  export interface Trainer { ... }
  export interface Member { ... }
  export interface Curriculum { ... }
  // ...
  ```
- [ ] 요청/응답 타입 정의:
  ```typescript
  // functions/src/types/requests.ts
  export interface GenerateCurriculumRequest { ... }
  export interface AnalyzeDietRequest { ... }
  // ...
  ```
- [ ] any 타입 사용 제거, 명시적 타입으로 교체

---

## Phase 4: 정리 및 검증

### Story 17: 사용하지 않는 코드 제거
- [ ] 사용하지 않는 import 제거
- [ ] 사용하지 않는 함수/클래스 제거
- [ ] 사용하지 않는 파일 제거
- [ ] 주석 처리된 코드 블록 제거

### Story 18: 코드 포매팅
- [ ] Flutter: `dart format lib/` 실행
- [ ] Functions: `npm run lint -- --fix` 실행
- [ ] 모든 파일 포매팅 일관성 확인

### Story 19: 빌드 및 테스트
- [ ] Flutter 빌드 확인: `flutter build apk --debug`
- [ ] Flutter 테스트 실행: `flutter test`
- [ ] Functions 빌드 확인: `cd functions && npm run build`
- [ ] Functions 테스트 실행: `cd functions && npm test`
- [ ] 에러 없이 모두 통과 확인

### Story 20: 문서화
- [ ] `REFACTOR_ANALYSIS.md` 최종 정리:
  - 변경 전 구조
  - 변경 후 구조
  - 주요 변경 사항 목록
  - 삭제된 파일 목록
  - 새로 생성된 파일 목록
- [ ] 코드 주석 정리 (JSDoc / DartDoc 형식)

---

## 리팩토링 원칙

1. **기능 변경 금지**: 리팩토링 중 기능 추가/수정하지 않음
2. **작은 단위로 커밋**: 각 Story 완료 시 커밋
3. **테스트 우선**: 변경 후 반드시 테스트 실행
4. **점진적 변경**: 한 번에 많이 바꾸지 않음
5. **롤백 가능**: 문제 발생 시 git reset으로 복구

---

## Acceptance Criteria

1. `flutter build apk --debug` 성공
2. `flutter test` 통과
3. `npm run build` 성공 (functions)
4. `npm test` 통과 (functions)
5. 기존 기능 모두 동작 확인
6. 중복 코드 50% 이상 감소
7. any/dynamic 타입 사용 제거
8. 모든 하드코딩 값 상수화
9. 일관된 네이밍 컨벤션 적용
10. `REFACTOR_ANALYSIS.md` 작성 완료

---

## 완료 조건

모든 Story의 체크박스가 완료되고, 빌드/테스트가 통과하면 `<promise>COMPLETE</promise>` 출력
