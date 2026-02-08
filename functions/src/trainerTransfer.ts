// functions/src/trainerTransfer.ts
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {db} from "./utils/firestore";
import {Collections} from "./constants/collections";
import {requireAuth} from "./middleware/auth";

/**
 * 트레이너 이관 요청 시작
 */
export const initiateTrainerTransfer = functions
  .region("asia-northeast3")
  .https.onCall(async (data, context) => {
    // 1. 인증 확인 (현재 트레이너)
    const userId = requireAuth(context);

    // 2. 입력 데이터 검증
    const {memberId, memberName, toTrainerId, toTrainerName} = data;

    if (!memberId || !memberName || !toTrainerId || !toTrainerName) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "필수 입력값(memberId, memberName, toTrainerId, toTrainerName)이 누락되었습니다."
      );
    }

    try {
      // 3. 현재 트레이너 정보 확인
      const currentTrainerSnapshot = await db
        .collection(Collections.TRAINERS)
        .where("userId", "==", userId)
        .limit(1)
        .get();

      if (currentTrainerSnapshot.empty) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "트레이너 정보를 찾을 수 없습니다."
        );
      }

      const currentTrainerDoc = currentTrainerSnapshot.docs[0];
      const currentTrainerId = currentTrainerDoc.id;
      const currentTrainerData = currentTrainerDoc.data();
      const currentTrainerName = currentTrainerData.name || "트레이너";

      // 4. 회원 정보 확인 및 현재 트레이너 검증
      const memberDoc = await db.collection(Collections.MEMBERS).doc(memberId).get();
      if (!memberDoc.exists) {
        throw new functions.https.HttpsError(
          "not-found",
          "회원 정보를 찾을 수 없습니다."
        );
      }

      const memberData = memberDoc.data()!;
      if (memberData.trainerId !== currentTrainerId) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "해당 회원은 귀하의 회원이 아닙니다."
        );
      }

      // 5. 대상 트레이너 존재 확인
      const toTrainerDoc = await db.collection(Collections.TRAINERS).doc(toTrainerId).get();
      if (!toTrainerDoc.exists) {
        throw new functions.https.HttpsError(
          "not-found",
          "이관 대상 트레이너를 찾을 수 없습니다."
        );
      }

      // 6. 트레이너 이관 문서 생성
      const transferData = {
        memberId,
        memberName,
        fromTrainerId: currentTrainerId,
        fromTrainerName: currentTrainerName,
        toTrainerId,
        toTrainerName,
        status: "pending",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        respondedAt: null,
      };

      const transferRef = await db.collection(Collections.TRAINER_TRANSFERS).add(transferData);

      // 7. 회원에게 이관 요청 알림 생성
      await db.collection(Collections.NOTIFICATIONS).add({
        userId: memberData.userId,
        type: "trainer_transfer",
        title: "트레이너 이관 요청",
        body: `${currentTrainerName} → ${toTrainerName}으로 트레이너 이관 요청이 도착했습니다.`,
        data: {
          transferId: transferRef.id,
          fromTrainerId: currentTrainerId,
          fromTrainerName: currentTrainerName,
          toTrainerId,
          toTrainerName,
        },
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 8. 결과 반환
      return {
        success: true,
        transferId: transferRef.id,
      };
    } catch (error) {
      console.error("initiateTrainerTransfer error:", error);

      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      const errorMessage = error instanceof Error ? error.message : "알 수 없는 오류";
      throw new functions.https.HttpsError(
        "internal",
        `트레이너 이관 요청 중 오류가 발생했습니다: ${errorMessage}`
      );
    }
  });

/**
 * 트레이너 이관 요청 응답 (회원이 수락/거절)
 */
export const respondTrainerTransfer = functions
  .region("asia-northeast3")
  .https.onCall(async (data, context) => {
    // 1. 인증 확인 (회원)
    const userId = requireAuth(context);

    // 2. 입력 데이터 검증
    const {transferId, action} = data;

    if (!transferId || !action) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "필수 입력값(transferId, action)이 누락되었습니다."
      );
    }

    if (action !== "accept" && action !== "reject") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "action은 'accept' 또는 'reject'여야 합니다."
      );
    }

    try {
      // 3. 이관 요청 문서 조회
      const transferDoc = await db.collection(Collections.TRAINER_TRANSFERS).doc(transferId).get();
      if (!transferDoc.exists) {
        throw new functions.https.HttpsError(
          "not-found",
          "이관 요청을 찾을 수 없습니다."
        );
      }

      const transferData = transferDoc.data()!;

      // 4. 이관 요청 상태 확인
      if (transferData.status !== "pending") {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "이미 처리된 이관 요청입니다."
        );
      }

      // 5. 회원 정보 확인 및 권한 검증
      const memberDoc = await db.collection(Collections.MEMBERS).doc(transferData.memberId).get();
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
          "본인의 이관 요청만 처리할 수 있습니다."
        );
      }

      // 6. 이관 수락 처리
      if (action === "accept") {
        // 회원의 trainerId 업데이트
        await db.collection(Collections.MEMBERS).doc(transferData.memberId).update({
          trainerId: transferData.toTrainerId,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // 이관 요청 상태 업데이트
        await db.collection(Collections.TRAINER_TRANSFERS).doc(transferId).update({
          status: "accepted",
          respondedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // 기존 트레이너에게 알림
        const fromTrainerDoc = await db.collection(Collections.TRAINERS)
          .doc(transferData.fromTrainerId)
          .get();
        if (fromTrainerDoc.exists) {
          const fromTrainerData = fromTrainerDoc.data()!;
          await db.collection(Collections.NOTIFICATIONS).add({
            userId: fromTrainerData.userId,
            type: "trainer_transfer",
            title: "회원 이관 완료",
            body: `${transferData.memberName} 회원이 ${transferData.toTrainerName} 트레이너로 이관되었습니다.`,
            data: {
              transferId,
              memberId: transferData.memberId,
              memberName: transferData.memberName,
            },
            isRead: false,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        }

        // 새 트레이너에게 알림
        const toTrainerDoc = await db.collection(Collections.TRAINERS)
          .doc(transferData.toTrainerId)
          .get();
        if (toTrainerDoc.exists) {
          const toTrainerData = toTrainerDoc.data()!;
          await db.collection(Collections.NOTIFICATIONS).add({
            userId: toTrainerData.userId,
            type: "trainer_transfer",
            title: "새 회원 배정",
            body: `${transferData.memberName} 회원이 귀하에게 배정되었습니다.`,
            data: {
              transferId,
              memberId: transferData.memberId,
              memberName: transferData.memberName,
            },
            isRead: false,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
      } else {
        // 이관 거절 처리
        await db.collection(Collections.TRAINER_TRANSFERS).doc(transferId).update({
          status: "rejected",
          respondedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // 새 트레이너에게 거절 알림
        const toTrainerDoc = await db.collection(Collections.TRAINERS)
          .doc(transferData.toTrainerId)
          .get();
        if (toTrainerDoc.exists) {
          const toTrainerData = toTrainerDoc.data()!;
          await db.collection(Collections.NOTIFICATIONS).add({
            userId: toTrainerData.userId,
            type: "trainer_transfer",
            title: "회원 이관 거절",
            body: `${transferData.memberName} 회원이 이관 요청을 거절했습니다.`,
            data: {
              transferId,
              memberId: transferData.memberId,
              memberName: transferData.memberName,
            },
            isRead: false,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
      }

      // 7. 결과 반환
      return {
        success: true,
        action,
      };
    } catch (error) {
      console.error("respondTrainerTransfer error:", error);

      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      const errorMessage = error instanceof Error ? error.message : "알 수 없는 오류";
      throw new functions.https.HttpsError(
        "internal",
        `트레이너 이관 응답 중 오류가 발생했습니다: ${errorMessage}`
      );
    }
  });
