// functions/src/pushNotification.ts
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {db} from "./utils/firestore";
import {Collections} from "./constants/collections";
import {requireAuth} from "./middleware/auth";

/**
 * 알림 타입 정의
 */
type NotificationType =
  | "dmMessages"
  | "ptReminders"
  | "aiInsights"
  | "trainerTransfer"
  | "weeklyReport"
  | "general";

/**
 * 사용자에게 푸시 알림 전송 (유틸리티 함수)
 * @param userId 수신자 userId
 * @param title 알림 제목
 * @param body 알림 본문
 * @param data 추가 데이터
 * @param notificationType 알림 타입 (설정 체크용)
 * @returns 전송 성공 여부
 */
export async function sendPushToUser(
  userId: string,
  title: string,
  body: string,
  data: Record<string, string>,
  notificationType: NotificationType
): Promise<boolean> {
  try {
    // 1. 사용자의 알림 설정 확인
    const settingsDoc = await db.collection(Collections.NOTIFICATION_SETTINGS).doc(userId).get();

    if (settingsDoc.exists) {
      const settings = settingsDoc.data()!;

      // 해당 알림 타입이 비활성화되어 있으면 전송하지 않음
      if (notificationType !== "general" && settings[notificationType] === false) {
        console.log(`알림 전송 스킵 (비활성화됨): userId=${userId}, type=${notificationType}`);
        return false;
      }
    }

    // 2. 사용자 정보에서 FCM 토큰 가져오기
    const userDoc = await db.collection(Collections.USERS).doc(userId).get();
    if (!userDoc.exists) {
      console.log("사용자를 찾을 수 없음:", userId);
      return false;
    }

    const userData = userDoc.data()!;
    const fcmToken = userData.fcmToken;

    if (!fcmToken) {
      console.log("FCM 토큰 없음:", userId);
      return false;
    }

    // 3. FCM 메시지 구성
    const message: admin.messaging.Message = {
      token: fcmToken,
      notification: {
        title,
        body: body.length > 200 ? body.substring(0, 200) + "..." : body,
      },
      data: {
        ...data,
        notificationType,
      },
      android: {
        notification: {
          channelId: "high_importance_channel",
          priority: "high",
          sound: "default",
        },
      },
      apns: {
        payload: {
          aps: {
            alert: {
              title,
              body,
            },
            badge: 1,
            sound: "default",
          },
        },
      },
    };

    // 4. 푸시 알림 전송
    await admin.messaging().send(message);
    console.log(`푸시 알림 전송 성공: userId=${userId}, type=${notificationType}`);

    return true;
  } catch (error) {
    console.error("sendPushToUser 실패:", error);
    return false;
  }
}

/**
 * 푸시 알림 전송 Cloud Function (onCall)
 * 내부 시스템 또는 클라이언트에서 직접 호출 가능
 */
export const sendPushNotification = functions
  .region("asia-northeast3")
  .https.onCall(async (data, context) => {
    // 1. 인증 확인 (선택적 - 내부 호출도 허용하려면 주석 처리)
    requireAuth(context);

    // 2. 입력 데이터 검증
    const {userId, title, body, data: customData, notificationType} = data;

    if (!userId || !title || !body || !notificationType) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "필수 입력값(userId, title, body, notificationType)이 누락되었습니다."
      );
    }

    const validTypes: NotificationType[] = [
      "dmMessages",
      "ptReminders",
      "aiInsights",
      "trainerTransfer",
      "weeklyReport",
      "general",
    ];

    if (!validTypes.includes(notificationType)) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        `notificationType은 다음 중 하나여야 합니다: ${validTypes.join(", ")}`
      );
    }

    try {
      // 3. 푸시 알림 전송
      const success = await sendPushToUser(
        userId,
        title,
        body,
        customData || {},
        notificationType
      );

      // 4. 결과 반환
      return {
        success,
      };
    } catch (error) {
      console.error("sendPushNotification error:", error);

      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      const errorMessage = error instanceof Error ? error.message : "알 수 없는 오류";
      throw new functions.https.HttpsError(
        "internal",
        `푸시 알림 전송 중 오류가 발생했습니다: ${errorMessage}`
      );
    }
  });
