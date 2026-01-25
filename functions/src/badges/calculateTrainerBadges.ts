import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {db} from "../utils/firestore";
import {Collections} from "../constants/collections";

// 배지 조건 정의
interface BadgeCondition {
  type: string;
  name: string;
  icon: string;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  check: (stats: any) => boolean;
}

const BADGE_CONDITIONS: BadgeCondition[] = [
  {
    type: "lightningResponse",
    name: "번개응답",
    icon: "⚡",
    check: (stats) => stats.avgResponseTimeMinutes > 0 && stats.avgResponseTimeMinutes <= 30,
  },
  {
    type: "fastResponse",
    name: "빠른응답",
    icon: "💬",
    check: (stats) => stats.avgResponseTimeMinutes > 0 && stats.avgResponseTimeMinutes <= 60,
  },
  {
    type: "consistentCommunication",
    name: "꾸준한소통",
    icon: "📱",
    check: (stats) => (stats.proactiveMessageCount || 0) >= 3,
  },
  {
    type: "goalAchiever",
    name: "목표달성왕",
    icon: "🎯",
    check: (stats) => (stats.memberGoalAchievementRate || 0) >= 80,
  },
  {
    type: "bodyTransformExpert",
    name: "체형변화전문가",
    icon: "💪",
    check: (stats) => (stats.avgMemberBodyFatChange || 0) <= -3,
  },
  {
    type: "consistencyPower",
    name: "꾸준함의힘",
    icon: "📅",
    check: (stats) => (stats.avgMemberAttendanceRate || 0) >= 90,
  },
  {
    type: "reRegistrationMaster",
    name: "재등록마스터",
    icon: "🔄",
    check: (stats) => (stats.reRegistrationRate || 0) >= 70,
  },
  {
    type: "longTermMemberHolder",
    name: "장기회원보유",
    icon: "🤝",
    check: (stats) => (stats.longTermMemberCount || 0) >= 3,
  },
  {
    type: "zeroNoShow",
    name: "노쇼제로",
    icon: "✅",
    check: (stats) => (stats.trainerNoShowRate || 0) === 0,
  },
  {
    type: "aiInsightPro",
    name: "AI인사이트활용왕",
    icon: "🤖",
    check: (stats) => (stats.aiInsightViewRate || 0) >= 90,
  },
  {
    type: "dataBasedCoaching",
    name: "데이터기반코칭",
    icon: "📈",
    check: (stats) => (stats.weeklyMemberDataViewCount || 0) >= 3,
  },
  {
    type: "dietFeedbackExpert",
    name: "식단피드백전문가",
    icon: "🥗",
    check: (stats) => (stats.dietFeedbackCount || 0) >= 50,
  },
];

/**
 * 매일 자정 실행: 모든 트레이너의 배지 조건 체크 및 업데이트
 */
export const calculateTrainerBadges = functions
  .region("asia-northeast3")
  .pubsub.schedule("0 0 * * *")
  .timeZone("Asia/Seoul")
  .onRun(async () => {
    console.log("배지 계산 시작");

    try {
      const trainersSnapshot = await db.collection(Collections.TRAINERS).get();
      let updatedCount = 0;
      const badgeChanges: { trainerId: string; earned: string[]; revoked: string[]; atRisk: string[] }[] = [];

      for (const trainerDoc of trainersSnapshot.docs) {
        const trainerId = trainerDoc.id;

        // stats 조회
        const statsDoc = await db
          .collection(Collections.TRAINERS)
          .doc(trainerId)
          .collection("stats")
          .doc("current")
          .get();

        if (!statsDoc.exists) continue;
        const stats = statsDoc.data()!;

        // 기존 배지 조회
        const badgesDoc = await db
          .collection(Collections.TRAINERS)
          .doc(trainerId)
          .collection("badges")
          .doc("current")
          .get();

        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const existingBadges: any[] = badgesDoc.exists
          ? (badgesDoc.data()!.activeBadges || [])
          : [];
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const badgeHistory: any[] = badgesDoc.exists
          ? (badgesDoc.data()!.badgeHistory || [])
          : [];

        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const newActiveBadges: any[] = [];
        const earned: string[] = [];
        const revoked: string[] = [];
        const atRisk: string[] = [];
        const now = admin.firestore.Timestamp.now();

        // 각 배지 조건 체크
        for (const condition of BADGE_CONDITIONS) {
          const isEarned = condition.check(stats);
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
          const existing = existingBadges.find((b: any) => b.type === condition.type);

          if (isEarned) {
            if (existing) {
              newActiveBadges.push(existing);
              // 해제 임박 체크 (조건은 충족하지만 위험 수준)
              if (checkBadgeAtRisk(condition.type, stats)) {
                atRisk.push(condition.name);
              }
            } else {
              // 새로 획득
              const newBadge = {
                type: condition.type,
                name: condition.name,
                icon: condition.icon,
                earnedAt: now,
              };
              newActiveBadges.push(newBadge);
              badgeHistory.push(newBadge);
              earned.push(condition.name);
            }
          } else if (existing) {
            // 배지 해제
            badgeHistory.push({
              ...existing,
              revokedAt: now,
            });
            revoked.push(condition.name);
          }
        }

        // 변경사항 있을 때만 업데이트
        if (earned.length > 0 || revoked.length > 0) {
          await db
            .collection(Collections.TRAINERS)
            .doc(trainerId)
            .collection("badges")
            .doc("current")
            .set({
              activeBadges: newActiveBadges,
              badgeHistory: badgeHistory,
            });

          badgeChanges.push({ trainerId, earned, revoked, atRisk });
          updatedCount++;
        } else if (atRisk.length > 0) {
          // 변경은 없지만 위험 배지가 있는 경우
          badgeChanges.push({ trainerId, earned: [], revoked: [], atRisk });
        }
      }

      // 배지 변경 알림 발송
      for (const change of badgeChanges) {
        await sendBadgeChangeNotification(change.trainerId, change.earned, change.revoked, change.atRisk);
      }

      console.log(`배지 계산 완료: ${updatedCount}명 업데이트`);
      return null;
    } catch (error) {
      console.error("배지 계산 실패:", error);
      return null;
    }
  });

/**
 * 배지 해제 임박 체크 (조건 충족하지만 위험 수준)
 */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
function checkBadgeAtRisk(type: string, stats: any): boolean {
  switch (type) {
  case "lightningResponse":
    // 30분 이내인데 25~30분이면 위험
    return stats.avgResponseTimeMinutes >= 25 && stats.avgResponseTimeMinutes <= 30;
  case "fastResponse":
    // 60분 이내인데 50~60분이면 위험
    return stats.avgResponseTimeMinutes >= 50 && stats.avgResponseTimeMinutes <= 60;
  case "consistentCommunication":
    return (stats.proactiveMessageCount || 0) === 3;
  case "goalAchiever":
    return (stats.memberGoalAchievementRate || 0) >= 80 && (stats.memberGoalAchievementRate || 0) < 85;
  case "consistencyPower":
    return (stats.avgMemberAttendanceRate || 0) >= 90 && (stats.avgMemberAttendanceRate || 0) < 92;
  case "reRegistrationMaster":
    return (stats.reRegistrationRate || 0) >= 70 && (stats.reRegistrationRate || 0) < 75;
  case "longTermMemberHolder":
    return (stats.longTermMemberCount || 0) === 3;
  case "aiInsightPro":
    return (stats.aiInsightViewRate || 0) >= 90 && (stats.aiInsightViewRate || 0) < 92;
  case "dataBasedCoaching":
    return (stats.weeklyMemberDataViewCount || 0) === 3;
  default:
    return false;
  }
}

/**
 * Firestore에 알림 저장
 */
async function saveNotification(
  userId: string,
  type: string,
  title: string,
  body: string,
  data?: Record<string, string>
) {
  await db.collection(Collections.NOTIFICATIONS).add({
    userId,
    type,
    title,
    body,
    data: data || {},
    isRead: false,
    createdAt: admin.firestore.Timestamp.now(),
  });
}

/**
 * 배지 변경 FCM 알림 + Firestore 알림 저장
 */
async function sendBadgeChangeNotification(
  trainerId: string,
  earned: string[],
  revoked: string[],
  atRisk: string[]
) {
  try {
    // 트레이너의 userId 조회
    const trainerDoc = await db.collection(Collections.TRAINERS).doc(trainerId).get();
    if (!trainerDoc.exists) return;

    const userId = trainerDoc.data()!.userId;
    if (!userId) return;

    // FCM 토큰 조회
    const userDoc = await db.collection(Collections.USERS).doc(userId).get();
    if (!userDoc.exists) return;

    const fcmToken = userDoc.data()!.fcmToken;

    // 획득 알림
    for (const badgeName of earned) {
      const title = "🎉 새 배지 획득!";
      const body = `'${badgeName}' 배지를 획득했습니다!`;

      // Firestore 저장
      await saveNotification(userId, "badgeEarned", title, body, {
        badgeName,
        trainerId,
      });

      // FCM 발송
      if (fcmToken) {
        const message: admin.messaging.Message = {
          token: fcmToken,
          notification: { title, body },
          data: { type: "badge_earned", badgeName },
          android: {
            notification: {
              channelId: "high_importance_channel",
              priority: "high",
              sound: "default",
            },
          },
          apns: {
            payload: {
              aps: { alert: { title, body }, badge: 1, sound: "default" },
            },
          },
        };
        await admin.messaging().send(message);
      }
    }

    // 해제 임박 알림
    for (const badgeName of atRisk) {
      const title = "⚠️ 배지 유지 위험";
      const body = `'${badgeName}' 배지 조건이 위험 수준입니다. 유지하려면 더 노력해주세요!`;

      // Firestore 저장
      await saveNotification(userId, "badgeAtRisk", title, body, {
        badgeName,
        trainerId,
      });

      // FCM 발송
      if (fcmToken) {
        const message: admin.messaging.Message = {
          token: fcmToken,
          notification: { title, body },
          data: { type: "badge_at_risk", badgeName },
          android: {
            notification: {
              channelId: "high_importance_channel",
              sound: "default",
            },
          },
          apns: {
            payload: {
              aps: { alert: { title, body }, sound: "default" },
            },
          },
        };
        await admin.messaging().send(message);
      }
    }

    // 해제 알림
    for (const badgeName of revoked) {
      const title = "😢 배지가 해제되었어요";
      const body = `'${badgeName}' 배지 조건을 더 이상 충족하지 못합니다.`;

      // Firestore 저장
      await saveNotification(userId, "badgeRevoked", title, body, {
        badgeName,
        trainerId,
      });

      // FCM 발송
      if (fcmToken) {
        const message: admin.messaging.Message = {
          token: fcmToken,
          notification: { title, body },
          data: { type: "badge_revoked", badgeName },
          android: {
            notification: {
              channelId: "high_importance_channel",
              sound: "default",
            },
          },
          apns: {
            payload: {
              aps: { alert: { title, body }, sound: "default" },
            },
          },
        };
        await admin.messaging().send(message);
      }
    }
  } catch (error) {
    console.error("배지 알림 발송 실패:", trainerId, error);
  }
}
