// functions/src/deleteUserTrainerData.ts
import * as functions from "firebase-functions";
import {db} from "./utils/firestore";
import {Collections} from "./constants/collections";
import {requireAuth} from "./middleware/auth";

/**
 * 회원이 특정 트레이너와 관련된 데이터 삭제
 * (커리큘럼, 스케줄만 삭제 - 개인 기록은 유지)
 */
export const deleteUserTrainerData = functions
  .region("asia-northeast3")
  .https.onCall(async (data, context) => {
    // 1. 인증 확인 (회원 본인)
    const userId = requireAuth(context);

    // 2. 입력 데이터 검증
    const {memberId, trainerId} = data;

    if (!memberId || !trainerId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "필수 입력값(memberId, trainerId)이 누락되었습니다."
      );
    }

    try {
      // 3. 회원 정보 확인 및 권한 검증
      const memberDoc = await db.collection(Collections.MEMBERS).doc(memberId).get();
      if (!memberDoc.exists) {
        throw new functions.https.HttpsError(
          "not-found",
          "회원 정보를 찾을 수 없습니다."
        );
      }

      const memberData = memberDoc.data()!;
      if (memberData.userId !== userId) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "본인의 데이터만 삭제할 수 있습니다."
        );
      }

      // 4. 트레이너 존재 확인
      const trainerDoc = await db.collection(Collections.TRAINERS).doc(trainerId).get();
      if (!trainerDoc.exists) {
        throw new functions.https.HttpsError(
          "not-found",
          "트레이너 정보를 찾을 수 없습니다."
        );
      }

      // 5. 커리큘럼 삭제 (memberId + trainerId 조건)
      const curriculumSnapshot = await db
        .collection(Collections.CURRICULUMS)
        .where("memberId", "==", memberId)
        .where("trainerId", "==", trainerId)
        .get();

      const batch1 = db.batch();
      let deletedCurriculums = 0;

      curriculumSnapshot.docs.forEach((doc) => {
        batch1.delete(doc.ref);
        deletedCurriculums++;
      });

      await batch1.commit();

      // 6. 스케줄 삭제 (memberId + trainerId 조건)
      const scheduleSnapshot = await db
        .collection(Collections.SCHEDULES)
        .where("memberId", "==", memberId)
        .where("trainerId", "==", trainerId)
        .get();

      const batch2 = db.batch();
      let deletedSchedules = 0;

      scheduleSnapshot.docs.forEach((doc) => {
        batch2.delete(doc.ref);
        deletedSchedules++;
      });

      await batch2.commit();

      // 7. 결과 반환
      console.log(
        `deleteUserTrainerData 완료: memberId=${memberId}, trainerId=${trainerId}, ` +
        `커리큘럼 ${deletedCurriculums}개, 스케줄 ${deletedSchedules}개 삭제`
      );

      return {
        success: true,
        deletedCurriculums,
        deletedSchedules,
      };
    } catch (error) {
      console.error("deleteUserTrainerData error:", error);

      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      const errorMessage = error instanceof Error ? error.message : "알 수 없는 오류";
      throw new functions.https.HttpsError(
        "internal",
        `트레이너 데이터 삭제 중 오류가 발생했습니다: ${errorMessage}`
      );
    }
  });
