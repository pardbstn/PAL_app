import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

/**
 * 인사이트 생성 시 트레이너에게 푸시 알림 전송
 * HIGH priority 인사이트만 알림 발송
 * Firestore 트리거로 insights 컬렉션 감시
 */
export const sendInsightNotification = functions
  .region("asia-northeast3")
  .firestore.document("insights/{insightId}")
  .onCreate(async (snapshot, context) => {
    const insight = snapshot.data();
    const {trainerId, memberId, priority, type, title, summary} = insight;

    // HIGH priority 인사이트만 알림 발송
    if (priority !== "high") {
      console.log("LOW/MEDIUM priority 인사이트 - 알림 스킵:", context.params.insightId);
      return null;
    }

    try {
      // 1. 트레이너의 FCM 토큰 가져오기
      const trainerDoc = await db.collection("users").doc(trainerId).get();
      if (!trainerDoc.exists) {
        console.log("트레이너를 찾을 수 없음:", trainerId);
        return null;
      }

      const trainerData = trainerDoc.data()!;
      const fcmToken = trainerData.fcmToken;

      if (!fcmToken) {
        console.log("FCM 토큰 없음:", trainerId);
        return null;
      }

      // 2. 회원 이름 가져오기
      let memberName = "회원";
      if (memberId) {
        const memberDoc = await db.collection("members").doc(memberId).get();
        if (memberDoc.exists) {
          const memberData = memberDoc.data()!;
          memberName = memberData.name || "회원";
        }
      }

      // 3. 인사이트 타입별 알림 제목 설정
      let notificationTitle = "새로운 인사이트";
      switch (type) {
      case "weight_change":
        notificationTitle = "🏋️ 체중 변화 알림";
        break;
      case "diet_pattern":
        notificationTitle = "🍽️ 식단 패턴 알림";
        break;
      case "attendance":
        notificationTitle = "📅 출석 패턴 알림";
        break;
      case "performance":
        notificationTitle = "💪 운동 성과 알림";
        break;
      default:
        notificationTitle = "📊 새로운 인사이트";
      }

      // 4. 알림 본문 구성
      const notificationBody = `[${memberName}] ${title || summary}`;

      // 5. 푸시 알림 전송
      const notificationMessage: admin.messaging.Message = {
        token: fcmToken,
        notification: {
          title: notificationTitle,
          body: notificationBody.length > 100
            ? notificationBody.substring(0, 100) + "..."
            : notificationBody,
        },
        data: {
          type: "insight",
          targetScreen: "/trainer/insights",
          targetId: context.params.insightId,
          memberId: memberId || "",
          insightType: type || "",
          priority: priority,
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
                title: notificationTitle,
                body: notificationBody,
              },
              badge: 1,
              sound: "default",
            },
          },
        },
      };

      await admin.messaging().send(notificationMessage);
      console.log("인사이트 알림 전송 성공:", trainerId, context.params.insightId);

      return null;
    } catch (error) {
      console.error("인사이트 알림 전송 실패:", error);
      return null;
    }
  });
