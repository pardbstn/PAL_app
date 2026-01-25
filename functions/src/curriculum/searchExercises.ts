import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

/**
 * 운동 검색 Cloud Function
 * 키워드로 운동 DB 검색
 */
export const searchExercises = functions
  .region("asia-northeast3")
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "로그인이 필요합니다.");
    }

    const { keyword, limit = 10 } = data;

    if (!keyword || keyword.trim().length === 0) {
      return { success: true, exercises: [] };
    }

    const searchTerm = keyword.trim();

    try {
      // 1. nameKo 접두사 검색 (Firestore range query)
      const prefixSnapshot = await db.collection("exercises")
        .where("nameKo", ">=", searchTerm)
        .where("nameKo", "<=", searchTerm + "\uf8ff")
        .limit(limit)
        .get();

      const results: Array<Record<string, unknown> & {id: string}> = [];
      const seenIds = new Set<string>();

      prefixSnapshot.docs.forEach(doc => {
        if (!seenIds.has(doc.id)) {
          seenIds.add(doc.id);
          results.push({ id: doc.id, ...doc.data() });
        }
      });

      // 2. tags array-contains 검색 (보충)
      if (results.length < limit) {
        const tagsSnapshot = await db.collection("exercises")
          .where("tags", "array-contains", searchTerm)
          .limit(limit - results.length)
          .get();

        tagsSnapshot.docs.forEach(doc => {
          if (!seenIds.has(doc.id)) {
            seenIds.add(doc.id);
            results.push({ id: doc.id, ...doc.data() });
          }
        });
      }

      return {
        success: true,
        exercises: results.slice(0, limit).map(ex => ({
          id: ex.id,
          nameKo: ex.nameKo || "",
          nameEn: ex.nameEn || "",
          equipment: ex.equipment || "",
          primaryMuscle: ex.primaryMuscle || "",
          secondaryMuscles: ex.secondaryMuscles || [],
          level: ex.level || "",
        })),
      };
    } catch (error) {
      console.error("searchExercises error:", error);
      throw new functions.https.HttpsError("internal", "운동 검색에 실패했습니다.");
    }
  });
