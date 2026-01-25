import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {db} from "../utils/firestore";
import {Collections} from "../constants/collections";

/**
 * 매일 12시/18시 식단 기록 리마인더
 * Cloud Scheduler로 실행
 * 오늘 식단 기록이 없는 활성 회원에게 알림 발송
 */

/**
 * 점심 식단 리마인더 (매일 12시)
 */
export const sendDietReminderLunch = functions
  .region("asia-northeast3")
  .pubsub.schedule("0 12 * * *") // 매일 오후 12시
  .timeZone("Asia/Seoul")
  .onRun(async () => {
    await sendDietReminder("lunch");
    return null;
  });

/**
 * 저녁 식단 리마인더 (매일 18시)
 */
export const sendDietReminderDinner = functions
  .region("asia-northeast3")
  .pubsub.schedule("0 18 * * *") // 매일 오후 6시
  .timeZone("Asia/Seoul")
  .onRun(async () => {
    await sendDietReminder("dinner");
    return null;
  });

/**
 * 식단 리마인더 공통 로직
 */
async function sendDietReminder(mealType: "lunch" | "dinner"): Promise<void> {
  const now = new Date();
  const todayStr = now.toISOString().split("T")[0]; // YYYY-MM-DD

  try {
    // 1. 활성 회원 조회 (endDate가 오늘 이후인 회원)
    const membersSnapshot = await db.collection(Collections.MEMBERS)
      .where("endDate", ">=", new Date())
      .get();

    console.log(`활성 회원 수: ${membersSnapshot.size}`);

    for (const memberDoc of membersSnapshot.docs) {
      const member = memberDoc.data();
      const memberId = member.userId;

      if (!memberId) continue;

      // 2. 오늘 해당 시간대 식단 기록 확인
      const dietsSnapshot = await db.collection(Collections.DIETS)
        .where("memberId", "==", memberDoc.id)
        .where("date", "==", todayStr)
        .where("mealType", "==", mealType)
        .limit(1)
        .get();

      // 이미 기록이 있으면 스킵
      if (!dietsSnapshot.empty) {
        continue;
      }

      // 3. 회원의 FCM 토큰 가져오기
      const userDoc = await db.collection(Collections.USERS).doc(memberId).get();
      if (!userDoc.exists) continue;

      const userData = userDoc.data()!;
      const fcmToken = userData.fcmToken;

      if (!fcmToken) continue;

      // 4. 알림 메시지 작성
      const isLunch = mealType === "lunch";
      const title = isLunch ? "🍱 점심 식단을 기록해주세요!" : "🍽️ 저녁 식단을 기록해주세요!";
      const body = isLunch
        ? "점심 식사는 맛있게 하셨나요? 식단을 기록하면 트레이너가 피드백을 드려요."
        : "저녁 식사 후 식단을 기록해주세요. 꾸준한 기록이 성공의 비결입니다!";

      const notificationMessage: admin.messaging.Message = {
        token: fcmToken,
        notification: {
          title: title,
          body: body,
        },
        data: {
          type: "diet_reminder",
          targetScreen: "/member/diet",
          targetId: todayStr,
          mealType: mealType,
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

      try {
        await admin.messaging().send(notificationMessage);
        console.log(`식단 리마인더 전송 (${mealType}):`, memberId);
      } catch (sendError) {
        console.error("개별 알림 전송 실패:", memberId, sendError);
      }
    }

    console.log(`식단 리마인더 스케줄 완료 (${mealType})`);
  } catch (error) {
    console.error("식단 리마인더 스케줄 실패:", error);
  }
}
