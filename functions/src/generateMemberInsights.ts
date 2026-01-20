import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import OpenAI from "openai";

const db = admin.firestore();

// OpenAI 클라이언트
const getOpenAIClient = (): OpenAI => {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    throw new Error("OPENAI_API_KEY is not configured");
  }
  return new OpenAI({apiKey});
};

interface MemberInsight {
  type: "weight" | "workout" | "attendance" | "nutrition" | "motivation";
  title: string;
  message: string;
  priority: "high" | "medium" | "low";
}

export const generateMemberInsights = functions
  .region("asia-northeast3")
  .https.onCall(async (data, context) => {
    // 1. 인증 확인
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "로그인이 필요합니다."
      );
    }

    const {memberId} = data;

    if (!memberId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "memberId가 필요합니다."
      );
    }

    try {
      // 2. 회원 정보 가져오기
      const memberDoc = await db.collection("members").doc(memberId).get();
      if (!memberDoc.exists) {
        throw new functions.https.HttpsError(
          "not-found",
          "회원 정보를 찾을 수 없습니다."
        );
      }
      const memberData = memberDoc.data()!;
      const memberName = memberData.name || "회원";

      // 3. 최근 30일 데이터 수집
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

      // 3-1. 체중 기록
      const bodyRecordsSnapshot = await db
        .collection("body_records")
        .where("memberId", "==", memberId)
        .where("measuredAt", ">=", admin.firestore.Timestamp.fromDate(thirtyDaysAgo))
        .orderBy("measuredAt", "desc")
        .get();

      const bodyRecords = bodyRecordsSnapshot.docs.map(doc => ({
        weight: doc.data().weight,
        measuredAt: doc.data().measuredAt?.toDate?.() || new Date(),
      }));

      // 3-2. 운동 기록
      const workoutRecordsSnapshot = await db
        .collection("workout_records")
        .where("memberId", "==", memberId)
        .where("createdAt", ">=", admin.firestore.Timestamp.fromDate(thirtyDaysAgo))
        .orderBy("createdAt", "desc")
        .get();

      const workoutRecords = workoutRecordsSnapshot.docs.map(doc => {
        const data = doc.data();
        return {
          exerciseName: data.exerciseName,
          weight: data.weight,
          reps: data.reps,
          sets: data.sets,
          createdAt: data.createdAt?.toDate?.() || new Date(),
        };
      });

      // 3-3. 출석 기록 (세션/예약)
      const sessionsSnapshot = await db
        .collection("sessions")
        .where("memberId", "==", memberId)
        .where("date", ">=", admin.firestore.Timestamp.fromDate(thirtyDaysAgo))
        .get();

      const sessions = sessionsSnapshot.docs.map(doc => ({
        status: doc.data().status,
        date: doc.data().date?.toDate?.() || new Date(),
      }));

      // 3-4. 식단 기록
      const dietRecordsSnapshot = await db
        .collection("diet_records")
        .where("memberId", "==", memberId)
        .where("createdAt", ">=", admin.firestore.Timestamp.fromDate(thirtyDaysAgo))
        .orderBy("createdAt", "desc")
        .get();

      const dietRecords = dietRecordsSnapshot.docs.map(doc => ({
        calories: doc.data().calories,
        protein: doc.data().protein,
        carbs: doc.data().carbs,
        fat: doc.data().fat,
        createdAt: doc.data().createdAt?.toDate?.() || new Date(),
      }));

      // 4. 데이터 요약
      const dataSummary = {
        memberName,
        goal: memberData.goal || "fitness",
        weightRecords: bodyRecords.slice(0, 10),
        workoutHighlights: workoutRecords.slice(0, 20),
        attendanceRate: sessions.length > 0
          ? (sessions.filter(s => s.status === "completed").length / sessions.length * 100).toFixed(1)
          : 0,
        totalSessions: sessions.length,
        completedSessions: sessions.filter(s => s.status === "completed").length,
        avgDailyProtein: dietRecords.length > 0
          ? (dietRecords.reduce((sum, r) => sum + (r.protein || 0), 0) / dietRecords.length).toFixed(1)
          : null,
        avgDailyCalories: dietRecords.length > 0
          ? (dietRecords.reduce((sum, r) => sum + (r.calories || 0), 0) / dietRecords.length).toFixed(0)
          : null,
      };

      // 5. GPT-4o로 인사이트 생성
      const openai = getOpenAIClient();

      const prompt = `당신은 개인 트레이너 AI 어시스턴트입니다.
아래 회원의 최근 30일 데이터를 분석하여 3-5개의 개인화된 인사이트를 생성해주세요.

[회원 정보]
이름: ${dataSummary.memberName}
목표: ${dataSummary.goal}

[체중 기록]
${JSON.stringify(dataSummary.weightRecords)}

[운동 기록 하이라이트]
${JSON.stringify(dataSummary.workoutHighlights)}

[출석 현황]
- 총 세션: ${dataSummary.totalSessions}회
- 완료: ${dataSummary.completedSessions}회
- 출석률: ${dataSummary.attendanceRate}%

[영양 섭취 (일평균)]
- 칼로리: ${dataSummary.avgDailyCalories || "기록 없음"} kcal
- 단백질: ${dataSummary.avgDailyProtein || "기록 없음"} g

다음 JSON 형식으로 응답해주세요:
{
  "insights": [
    {
      "type": "weight" | "workout" | "attendance" | "nutrition" | "motivation",
      "title": "짧은 제목 (예: 체중 감량 순항 중!)",
      "message": "구체적인 피드백 메시지 (예: 지난 4주간 2.5kg 감량했어요. 이 페이스면 목표까지 8주 정도 남았어요!)",
      "priority": "high" | "medium" | "low"
    }
  ]
}

규칙:
1. 긍정적이고 동기부여가 되는 톤 사용
2. 구체적인 숫자와 비교 데이터 활용
3. 실행 가능한 조언 포함
4. 데이터가 부족하면 격려 메시지 생성
5. 한국어로 작성`;

      const response = await openai.chat.completions.create({
        model: "gpt-4o",
        messages: [{role: "user", content: prompt}],
        response_format: {type: "json_object"},
        temperature: 0.7,
        max_tokens: 1500,
      });

      const content = response.choices[0].message.content;
      if (!content) {
        throw new Error("AI 응답이 비어있습니다.");
      }

      const result = JSON.parse(content);
      const insights: MemberInsight[] = result.insights || [];

      // 6. member_insights 컬렉션에 저장
      const insightDocs = insights.map(insight => ({
        memberId,
        type: insight.type,
        title: insight.title,
        message: insight.message,
        priority: insight.priority,
        isRead: false,
        createdAt: admin.firestore.Timestamp.now(),
        expiresAt: admin.firestore.Timestamp.fromDate(
          new Date(Date.now() + 7 * 24 * 60 * 60 * 1000) // 7일 후 만료
        ),
      }));

      // 기존 인사이트 삭제 후 새로 저장
      const existingSnapshot = await db
        .collection("member_insights")
        .where("memberId", "==", memberId)
        .get();

      const batch = db.batch();
      existingSnapshot.docs.forEach(doc => {
        batch.delete(doc.ref);
      });

      const savedInsights: Array<{id: string} & typeof insightDocs[0]> = [];
      for (const doc of insightDocs) {
        const docRef = db.collection("member_insights").doc();
        batch.set(docRef, doc);
        savedInsights.push({id: docRef.id, ...doc});
      }

      await batch.commit();

      // 7. 결과 반환
      return {
        success: true,
        insights: savedInsights.map(insight => ({
          ...insight,
          createdAt: insight.createdAt.toDate().toISOString(),
          expiresAt: insight.expiresAt.toDate().toISOString(),
        })),
      };
    } catch (error) {
      console.error("generateMemberInsights error:", error);

      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      const errorMessage = error instanceof Error ? error.message : "알 수 없는 오류";
      throw new functions.https.HttpsError(
        "internal",
        `인사이트 생성 중 오류가 발생했습니다: ${errorMessage}`
      );
    }
  });
