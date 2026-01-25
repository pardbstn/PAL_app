import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {db} from "../utils/firestore";
import {Collections} from "../constants/collections";

/**
 * PT 1시간 전 회원/트레이너에게 알림 전송
 * 매 시간 정각에 실행되어 다음 1시간 내 예약 확인
 * Cloud Scheduler로 실행
 */
export const sendPTReminder = functions
  .region("asia-northeast3")
  .pubsub.schedule("0 * * * *") // 매 시간 정각
  .timeZone("Asia/Seoul")
  .onRun(async () => {
    const now = new Date();
    // 1시간 후 시간대 계산 (정각 기준)
    const oneHourLater = new Date(now);
    oneHourLater.setHours(oneHourLater.getHours() + 1);
    oneHourLater.setMinutes(0, 0, 0);

    const oneHourLaterEnd = new Date(oneHourLater);
    oneHourLaterEnd.setMinutes(59, 59, 999);

    try {
      // 1시간 후 시작하는 예약 조회
      const schedulesSnapshot = await db.collection(Collections.SCHEDULES)
        .where("startTime", ">=", oneHourLater)
        .where("startTime", "<=", oneHourLaterEnd)
        .where("status", "==", "confirmed")
        .get();

      functions.logger.info(`1시간 후 예약 수: ${schedulesSnapshot.size}`);

      for (const scheduleDoc of schedulesSnapshot.docs) {
        const schedule = scheduleDoc.data();
        const {trainerId, memberId, memberName, trainerName, startTime} = schedule;

        // 시작 시간 포맷
        const startDate = startTime.toDate();
        const timeStr = `${startDate.getHours().toString().padStart(2, "0")}:${startDate.getMinutes().toString().padStart(2, "0")}`;

        // 회원에게 알림 전송
        await sendReminderToUser(
          memberId,
          "🏋️ PT 시간이 다가왔어요!",
          `${timeStr}에 ${trainerName || "트레이너"}님과 PT가 예정되어 있습니다.`,
          scheduleDoc.id,
          "/member/home"
        );

        // 트레이너에게 알림 전송
        await sendReminderToUser(
          trainerId,
          "🏋️ PT 예약 알림",
          `${timeStr}에 ${memberName || "회원"}님과 PT가 예정되어 있습니다.`,
          scheduleDoc.id,
          "/trainer/home"
        );
      }

      functions.logger.info("PT 리마인더 스케줄 완료");
      return null;
    } catch (error) {
      functions.logger.error("PT 리마인더 스케줄 실패:", error);
      return null;
    }
  });

/**
 * 개별 사용자에게 PT 리마인더 전송
 */
async function sendReminderToUser(
  userId: string,
  title: string,
  body: string,
  scheduleId: string,
  targetScreen: string
): Promise<void> {
  if (!userId) return;

  try {
    // 사용자의 FCM 토큰 가져오기
    const userDoc = await db.collection(Collections.USERS).doc(userId).get();
    if (!userDoc.exists) {
      functions.logger.info("사용자를 찾을 수 없음:", userId);
      return;
    }

    const userData = userDoc.data()!;
    const fcmToken = userData.fcmToken;

    if (!fcmToken) {
      functions.logger.info("FCM 토큰 없음:", userId);
      return;
    }

    const notificationMessage: admin.messaging.Message = {
      token: fcmToken,
      notification: {
        title: title,
        body: body,
      },
      data: {
        type: "pt_reminder",
        targetScreen: targetScreen,
        targetId: scheduleId,
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
              title: title,
              body: body,
            },
            badge: 1,
            sound: "default",
          },
        },
      },
    };

    await admin.messaging().send(notificationMessage);
    functions.logger.info("PT 리마인더 전송 성공:", userId);
  } catch (error) {
    functions.logger.error("PT 리마인더 전송 실패:", userId, error);
  }
}
