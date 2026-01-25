import * as functions from "firebase-functions";
import {db} from "../utils/firestore";
import {Collections} from "../constants/collections";

/**
 * 인증 확인 - uid 반환
 */
export const requireAuth = (context: functions.https.CallableContext): string => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "로그인이 필요합니다."
    );
  }
  return context.auth.uid;
};

/**
 * 트레이너 권한 확인
 */
export const requireTrainer = async (
  userId: string
): Promise<FirebaseFirestore.DocumentData & {id: string}> => {
  const trainerSnapshot = await db
    .collection(Collections.TRAINERS)
    .where("userId", "==", userId)
    .limit(1)
    .get();

  if (trainerSnapshot.empty) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "트레이너 정보를 찾을 수 없습니다."
    );
  }

  const doc = trainerSnapshot.docs[0];
  return {id: doc.id, ...doc.data()};
};
