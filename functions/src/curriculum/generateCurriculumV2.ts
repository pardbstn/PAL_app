import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {GoogleGenerativeAI} from "@google/generative-ai";

const db = admin.firestore();

// Google AI 클라이언트
const getGoogleAI = (): GoogleGenerativeAI => {
  const apiKey = process.env.GOOGLE_AI_API_KEY;
  if (!apiKey) throw new Error("GOOGLE_AI_API_KEY not configured");
  return new GoogleGenerativeAI(apiKey);
};

export const generateCurriculumV2 = functions
  .region("asia-northeast3")
  .runWith({timeoutSeconds: 60, memory: "256MB"})
  .https.onCall(async (data, context) => {
    // 1. Auth check
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "로그인이 필요합니다.");
    }

    // 2. Extract input
    const {memberId, trainerId: _trainerId, settings} = data;
    const {
      exerciseCount = 5,
      setCount = 3,
      focusParts = [],
      excludedExerciseIds = [],
      excludedBodyParts = [],
      styles = [],
      additionalNotes = "",
    } = settings || {};

    if (!memberId) {
      throw new functions.https.HttpsError("invalid-argument", "memberId가 필요합니다.");
    }

    try {
      // 3. Load exercises from Firestore based on focus parts
      let exercisesQuery: admin.firestore.Query = db.collection("exercises");

      // If focusParts specified, filter by primary muscle
      let allExercises: any[] = [];

      if (focusParts.length > 0 && !focusParts.includes("전신")) {
        // Query for each focus part and merge
        for (const part of focusParts) {
          const snapshot = await exercisesQuery
            .where("primaryMuscle", "==", part)
            .limit(50)
            .get();
          snapshot.docs.forEach(doc => {
            allExercises.push({id: doc.id, ...doc.data()});
          });
        }
      } else {
        // Get all exercises (limited)
        const snapshot = await exercisesQuery.limit(200).get();
        allExercises = snapshot.docs.map(doc => ({id: doc.id, ...doc.data()}));
      }

      // 4. Filter out excluded exercises and body parts
      allExercises = allExercises.filter(ex => {
        if (excludedExerciseIds.includes(ex.id)) return false;
        if (excludedBodyParts.includes(ex.primaryMuscle)) return false;
        // Check secondary muscles too
        if (ex.secondaryMuscles?.some((m: string) => excludedBodyParts.includes(m))) return false;
        return true;
      });

      // Deduplicate by id
      const seen = new Set<string>();
      allExercises = allExercises.filter(ex => {
        if (seen.has(ex.id)) return false;
        seen.add(ex.id);
        return true;
      });

      if (allExercises.length === 0) {
        return {
          success: false,
          error: "조건에 맞는 운동이 없습니다. 설정을 변경해주세요.",
        };
      }

      // 5. Build prompt for Gemini
      const exerciseListStr = allExercises.map(ex =>
        `- ${ex.nameKo} (${ex.equipment}, ${ex.primaryMuscle}, ${ex.level})`
      ).join("\n");

      const stylesStr = styles.length > 0 ? styles.join(", ") : "일반";

      const prompt = `당신은 15년 경력의 전문 피트니스 트레이너입니다.
아래 운동 목록에서 ${exerciseCount}개의 운동을 선택하여 PT 커리큘럼을 만들어주세요.

[사용 가능한 운동 목록]
${exerciseListStr}

[설정]
- 종목 수: ${exerciseCount}개
- 세트 수: 각 운동당 ${setCount}세트
- 집중 부위: ${focusParts.length > 0 ? focusParts.join(", ") : "전신"}
- 운동 스타일: ${stylesStr}
${additionalNotes ? `- 추가 요청: ${additionalNotes}` : ""}

[스타일 가이드]
- 고중량: 6-8회, 휴식 90-120초
- 저중량: 15-20회, 휴식 30-45초
- 스트렝스: 3-5회
- 근비대: 8-12회
- 근지구력: 15회 이상
- 서킷: 휴식 최소화
- 컴파운드 위주: 다관절 운동 우선
- 고립 위주: 단관절 운동 우선

[요구사항]
1. 반드시 위 운동 목록에서만 선택하세요 (목록에 없는 운동 금지)
2. 운동 이름은 목록의 한글명을 그대로 사용하세요
3. 스타일에 맞는 반복 횟수와 휴식 시간을 설정하세요
4. 다양한 운동을 선택하세요 (같은 운동 중복 금지)

반드시 아래 JSON 형식으로만 응답하세요:
{
  "exercises": [
    {
      "name": "운동명 (목록에서 그대로)",
      "sets": ${setCount},
      "reps": 10,
      "restSeconds": 60,
      "notes": "운동 팁 (1줄)"
    }
  ],
  "aiNotes": "전체 커리큘럼에 대한 코멘트 (1-2줄)"
}`;

      // 6. Call Gemini 2.0 Flash
      const genAI = getGoogleAI();
      const model = genAI.getGenerativeModel({
        model: "gemini-2.0-flash",
        generationConfig: {
          responseMimeType: "application/json",
          temperature: 0.7,
        },
      });

      const result = await model.generateContent(prompt);
      const text = result.response.text();
      const parsed = JSON.parse(text);

      // 7. Map exercise names to IDs
      const exercises = (parsed.exercises || []).map((ex: any) => {
        const match = allExercises.find(e => e.nameKo === ex.name);
        return {
          exerciseId: match?.id || "",
          name: ex.name,
          sets: ex.sets || setCount,
          reps: ex.reps || 10,
          restSeconds: ex.restSeconds || 60,
          notes: ex.notes || "",
        };
      });

      return {
        success: true,
        curriculum: {
          exercises,
          aiNotes: parsed.aiNotes || "",
          totalSets: exercises.reduce((sum: number, ex: any) => sum + ex.sets, 0),
          estimatedDuration: exercises.reduce((sum: number, ex: any) => sum + ex.sets, 0) * 2,
        },
      };
    } catch (error) {
      console.error("generateCurriculumV2 error:", error);

      // Fallback: return random exercises from the filtered list
      try {
        // Re-query exercises for fallback
        const snapshot = await db.collection("exercises").limit(100).get();
        let fallbackExercises = snapshot.docs
          .map(doc => ({id: doc.id, ...doc.data() as any}))
          .filter(ex => !excludedExerciseIds.includes(ex.id));

        // Shuffle and take exerciseCount
        fallbackExercises = fallbackExercises
          .sort(() => Math.random() - 0.5)
          .slice(0, exerciseCount);

        const exercises = fallbackExercises.map((ex: any) => ({
          exerciseId: ex.id,
          name: ex.nameKo || ex.name || "운동",
          sets: setCount,
          reps: 10,
          restSeconds: 60,
          notes: "",
        }));

        return {
          success: true,
          curriculum: {
            exercises,
            aiNotes: "AI 생성에 실패하여 기본 템플릿으로 생성되었습니다.",
            totalSets: exercises.length * setCount,
            estimatedDuration: exercises.length * setCount * 2,
          },
        };
      } catch (fallbackError) {
        throw new functions.https.HttpsError(
          "internal",
          "커리큘럼 생성에 실패했습니다."
        );
      }
    }
  });
