import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {db} from "../utils/firestore";
import {Collections} from "../constants/collections";

/**
 * 메시지 생성 시 트레이너 응답시간 및 능동 메시지 통계 업데이트
 */
export const onMessageCreatedForStats = functions
  .region("asia-northeast3")
  .firestore.document("messages/{messageId}")
  .onCreate(async (snapshot) => {
    const message = snapshot.data();
    const { chatRoomId, senderRole } = message;

    // 트레이너가 보낸 메시지만 처리
    if (senderRole !== "trainer") return null;

    try {
      // 채팅방에서 트레이너 ID 확인
      const chatRoomDoc = await db.collection(Collections.CHAT_ROOMS).doc(chatRoomId).get();
      if (!chatRoomDoc.exists) return null;

      const chatRoom = chatRoomDoc.data()!;
      const trainerId = chatRoom.trainerId;
      if (!trainerId) return null;

      // 트레이너 문서 찾기
      const trainerSnapshot = await db
        .collection(Collections.TRAINERS)
        .where("userId", "==", trainerId)
        .limit(1)
        .get();

      if (trainerSnapshot.empty) return null;
      const trainerDocId = trainerSnapshot.docs[0].id;

      // 마지막 회원 메시지 시간 조회 (응답시간 계산용)
      const lastMemberMessage = await db
        .collection(Collections.MESSAGES)
        .where("chatRoomId", "==", chatRoomId)
        .where("senderRole", "==", "member")
        .orderBy("createdAt", "desc")
        .limit(1)
        .get();

      const statsRef = db
        .collection(Collections.TRAINERS)
        .doc(trainerDocId)
        .collection("stats")
        .doc("current");

      const statsDoc = await statsRef.get();
      const currentStats = statsDoc.exists ? statsDoc.data()! : {};

      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const updates: any = {
        lastCalculated: admin.firestore.FieldValue.serverTimestamp(),
      };

      // 응답시간 계산 (회원 마지막 메시지 → 트레이너 응답)
      if (!lastMemberMessage.empty) {
        const memberMsgTime = lastMemberMessage.docs[0].data().createdAt?.toDate();
        const trainerMsgTime = message.createdAt?.toDate() || new Date();

        if (memberMsgTime) {
          const responseMinutes = (trainerMsgTime.getTime() - memberMsgTime.getTime()) / 60000;

          // 이동평균 계산 (기존 평균과 새 값의 가중평균)
          const prevAvg = currentStats.avgResponseTimeMinutes || responseMinutes;
          const newAvg = prevAvg * 0.8 + responseMinutes * 0.2; // 지수이동평균
          updates.avgResponseTimeMinutes = Math.round(newAvg * 10) / 10;
        }
      }

      // 이전 메시지가 회원 것이 아니면 → 능동적 메시지
      if (lastMemberMessage.empty) {
        updates.proactiveMessageCount = admin.firestore.FieldValue.increment(1);
      }

      await statsRef.set(updates, { merge: true });
      return null;
    } catch (error) {
      console.error("트레이너 통계 업데이트 실패:", error);
      return null;
    }
  });

/**
 * 스케줄 완료 시 출석률 업데이트
 */
export const onScheduleCompletedForStats = functions
  .region("asia-northeast3")
  .firestore.document("schedules/{scheduleId}")
  .onUpdate(async (change) => {
    const before = change.before.data();
    const after = change.after.data();

    // status가 'completed'로 변경된 경우만
    if (before.status === after.status || after.status !== "completed") return null;
    if (after.type !== "pt") return null;

    const trainerId = after.trainerId;
    if (!trainerId) return null;

    try {
      // 트레이너의 전체 PT 스케줄 통계 계산
      const allSchedules = await db
        .collection(Collections.SCHEDULES)
        .where("trainerId", "==", trainerId)
        .where("type", "==", "pt")
        .get();

      let total = 0;
      let completed = 0;
      let noShow = 0;

      for (const doc of allSchedules.docs) {
        const schedule = doc.data();
        total++;
        if (schedule.status === "completed") completed++;
        if (schedule.status === "no_show") noShow++;
      }

      const attendanceRate = total > 0 ? (completed / total) * 100 : 0;
      const noShowRate = total > 0 ? (noShow / total) * 100 : 0;

      await db
        .collection(Collections.TRAINERS)
        .doc(trainerId)
        .collection("stats")
        .doc("current")
        .set(
          {
            avgMemberAttendanceRate: Math.round(attendanceRate * 10) / 10,
            trainerNoShowRate: Math.round(noShowRate * 10) / 10,
            lastCalculated: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true }
        );

      return null;
    } catch (error) {
      console.error("출석률 통계 업데이트 실패:", error);
      return null;
    }
  });

/**
 * 회원 등록/연장 시 재등록률 및 장기회원 수 업데이트
 */
export const onMemberUpdatedForStats = functions
  .region("asia-northeast3")
  .firestore.document("members/{memberId}")
  .onUpdate(async (change) => {
    const after = change.after.data();
    const trainerId = after.trainerId;
    if (!trainerId) return null;

    try {
      // 해당 트레이너의 전체 회원 조회
      const membersSnapshot = await db
        .collection(Collections.MEMBERS)
        .where("trainerId", "==", trainerId)
        .get();

      let totalMembers = 0;
      let reRegistered = 0;
      let longTermCount = 0;
      const sixMonthsAgo = new Date();
      sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6);

      for (const doc of membersSnapshot.docs) {
        const member = doc.data();
        totalMembers++;

        // 재등록 여부 (registrationCount > 1)
        if ((member.registrationCount || 0) > 1) {
          reRegistered++;
        }

        // 6개월 이상 회원
        const startDate = member.startDate?.toDate();
        if (startDate && startDate <= sixMonthsAgo) {
          longTermCount++;
        }
      }

      const reRegistrationRate = totalMembers > 0
        ? (reRegistered / totalMembers) * 100
        : 0;

      await db
        .collection(Collections.TRAINERS)
        .doc(trainerId)
        .collection("stats")
        .doc("current")
        .set(
          {
            reRegistrationRate: Math.round(reRegistrationRate * 10) / 10,
            longTermMemberCount: longTermCount,
            lastCalculated: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true }
        );

      return null;
    } catch (error) {
      console.error("회원 통계 업데이트 실패:", error);
      return null;
    }
  });
