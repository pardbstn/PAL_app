import * as functions from "firebase-functions";
import {db} from "../utils/firestore";
import {Collections} from "../constants/collections";
import {requireAuth} from "../middleware/auth";
import {callGPT} from "../services/ai-service";

/**
 * 대체 운동 추천 Cloud Function
 * 현재 운동과 같은 근육군의 대체 운동 3개 추천
 */
export const getAlternativeExercises = functions
  .region("asia-northeast3")
  .https.onCall(async (data, context) => {
    requireAuth(context);

    const { exerciseId, excludedIds = [] } = data;

    if (!exerciseId) {
      throw new functions.https.HttpsError("invalid-argument", "exerciseId가 필요합니다.");
    }

    try {
      // 1. 현재 운동 정보 가져오기
      const exerciseDoc = await db.collection(Collections.EXERCISES).doc(exerciseId).get();
      if (!exerciseDoc.exists) {
        throw new functions.https.HttpsError("not-found", "운동을 찾을 수 없습니다.");
      }

      const currentExercise = exerciseDoc.data()!;
      const primaryMuscle = currentExercise.primaryMuscle;

      // 2. 같은 근육군 운동 조회 (제외 목록 필터링)
      const allExcluded = [exerciseId, ...excludedIds];
      const snapshot = await db.collection(Collections.EXERCISES)
        .where("primaryMuscle", "==", primaryMuscle)
        .limit(20)
        .get();

      let candidates = snapshot.docs
        .filter(doc => !allExcluded.includes(doc.id))
        .map(doc => ({id: doc.id, ...doc.data() as Record<string, unknown>}));

      // 3. 다양한 장비 타입 우선 선택
      type ExerciseCandidate = Record<string, unknown> & {id: string};
      const equipmentGroups = new Map<string, ExerciseCandidate[]>();
      (candidates as ExerciseCandidate[]).forEach(ex => {
        const equipment = ex.equipment as string;
        const group = equipmentGroups.get(equipment) || [];
        group.push(ex);
        equipmentGroups.set(equipment, group);
      });

      // 각 장비군에서 1개씩 선택, 부족하면 추가
      let selected: ExerciseCandidate[] = [];
      for (const [, group] of equipmentGroups) {
        if (selected.length >= 3) break;
        selected.push(group[0]);
      }
      if (selected.length < 3) {
        const remaining = candidates.filter(c => !selected.includes(c));
        selected = [...selected, ...remaining.slice(0, 3 - selected.length)];
      }
      selected = selected.slice(0, 3);

      if (selected.length === 0) {
        return { success: true, alternatives: [] };
      }

      // 4. GPT-4o-mini로 추천 이유 생성
      interface AlternativeExercise {
        exerciseId: string;
        name: string;
        equipment: string;
        primaryMuscle: string;
        reason: string;
      }
      let alternatives: AlternativeExercise[];
      try {
        const exerciseNames = selected.map(ex => ex.nameKo as string).join(", ");

        const gptPrompt = `현재 운동 "${currentExercise.nameKo}" (${currentExercise.equipment}, ${primaryMuscle})의 대체 운동으로 다음을 추천합니다: ${exerciseNames}

각 운동에 대해 왜 좋은 대체 운동인지 한 줄로 설명해주세요.
JSON 형식으로 응답: { "reasons": ["이유1", "이유2", "이유3"] }`;

        const content = await callGPT(gptPrompt, {
          model: "gpt-4o-mini",
          jsonMode: true,
          temperature: 0.5,
          maxTokens: 300,
        });

        const parsed = content ? JSON.parse(content) : {reasons: []};
        const reasons: string[] = parsed.reasons || [];

        alternatives = selected.map((ex, i) => ({
          exerciseId: ex.id,
          name: ex.nameKo as string,
          equipment: ex.equipment as string,
          primaryMuscle: ex.primaryMuscle as string,
          reason: reasons[i] || `같은 ${primaryMuscle} 운동`,
        }));
      } catch (aiError) {
        // AI 실패 시 이유 없이 반환
        console.error("AI reason generation failed:", aiError);
        alternatives = selected.map(ex => ({
          exerciseId: ex.id,
          name: ex.nameKo as string,
          equipment: ex.equipment as string,
          primaryMuscle: ex.primaryMuscle as string,
          reason: `같은 ${primaryMuscle} 타겟 운동 (${ex.equipment})`,
        }));
      }

      return { success: true, alternatives };
    } catch (error) {
      console.error("getAlternativeExercises error:", error);
      if (error instanceof functions.https.HttpsError) throw error;
      throw new functions.https.HttpsError("internal", "대체 운동 추천에 실패했습니다.");
    }
  });
