import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {db} from "./utils/firestore";
import {Collections} from "./constants/collections";
import {requireAuth} from "./middleware/auth";
import {getGoogleAIClient, callGPT} from "./services/ai-service";

// Firebase Admin 초기화
admin.initializeApp();

// AI 모델 설정 (모든 사용자 동일)
const AI_CONFIG = {
  provider: "openai" as const,
  model: "gpt-4o-mini",
};

// 목표 한글 변환
const GOAL_LABELS: Record<string, string> = {
  diet: "체중감량",
  bulk: "근육증가",
  fitness: "체력향상",
  rehab: "재활/회복",
};

// 경력 한글 변환
const EXPERIENCE_LABELS: Record<string, string> = {
  beginner: "입문자 (0~6개월)",
  intermediate: "중급자 (6개월~2년)",
  advanced: "상급자 (2년 이상)",
};

// AI 클라이언트는 ./services/ai-service에서 import

// 프롬프트 빌더
function buildCurriculumPrompt(
  goal: string,
  experience: string,
  sessionCount: number,
  restrictions: string | null
): string {
  const goalLabel = GOAL_LABELS[goal] || goal;
  const experienceLabel = EXPERIENCE_LABELS[experience] || experience;

  return `당신은 15년 경력의 전문 피트니스 트레이너입니다.
다음 회원 정보를 바탕으로 ${sessionCount}회차 PT 커리큘럼을 만들어주세요.

[회원 정보]
- 운동 목표: ${goalLabel}
- 운동 경력: ${experienceLabel}
- 제한사항/부상: ${restrictions || "없음"}

[요구사항]
1. 각 회차는 다양한 부위를 골고루 훈련
2. 점진적 과부하 원칙 적용
3. 목표에 맞는 운동 선택
4. 각 운동당 세트수, 횟수, 권장 무게 포함

반드시 아래 JSON 형식으로만 응답하세요:
{
  "curriculums": [
    {
      "sessionNumber": 1,
      "title": "상체 근력 기초",
      "description": "상체 주요 근육군 활성화",
      "exercises": [
        {
          "name": "벤치프레스",
          "sets": 4,
          "reps": 12,
          "weight": "20kg",
          "rest": "60초",
          "notes": "견갑골 고정"
        }
      ]
    }
  ]
}`;
}

// Gemini로 생성 (예비용 - 향후 사용)
export async function generateWithGemini(
  prompt: string,
  modelName: string
): Promise<{curriculums: unknown[]}> {
  const genAI = getGoogleAIClient();
  const model = genAI.getGenerativeModel({
    model: modelName,
    generationConfig: {
      responseMimeType: "application/json",
      temperature: 0.7,
    },
  });

  const result = await model.generateContent(prompt);
  const text = result.response.text();
  return JSON.parse(text);
}

// OpenAI로 생성 (유료 티어)
async function generateWithOpenAI(
  prompt: string,
  modelName: string
): Promise<{curriculums: unknown[]}> {
  const content = await callGPT(prompt, {
    model: modelName,
    maxTokens: 4000,
    temperature: 0.7,
    jsonMode: true,
  });
  return JSON.parse(content);
}

/**
 * AI 커리큘럼 생성 Cloud Function
 */
export const generateCurriculum = functions
  .region("asia-northeast3")
  .https.onCall(async (data, context) => {
    // 1. 인증 확인
    const userId = requireAuth(context);

    // 2. 입력 데이터 검증
    const {memberId, goal, experience, sessionCount, restrictions} = data;

    if (!memberId || !goal || !experience || !sessionCount) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "필수 입력값이 누락되었습니다."
      );
    }

    if (sessionCount < 1 || sessionCount > 50) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "회차 수는 1~50 사이여야 합니다."
      );
    }

    try {
      // 3. 트레이너 정보 확인
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

      // 4. 회원 정보 확인
      const memberDoc = await db.collection(Collections.MEMBERS).doc(memberId).get();
      if (!memberDoc.exists) {
        throw new functions.https.HttpsError(
          "not-found",
          "회원 정보를 찾을 수 없습니다."
        );
      }

      // 6. 프롬프트 생성
      const prompt = buildCurriculumPrompt(
        goal,
        experience,
        sessionCount,
        restrictions
      );

      // 7. AI 호출 (OpenAI 사용)
      const result = await generateWithOpenAI(prompt, AI_CONFIG.model);

      // 8. 결과 반환
      return {
        success: true,
        curriculums: result.curriculums,
      };
    } catch (error) {
      console.error("generateCurriculum error:", error);

      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      const errorMessage = error instanceof Error ? error.message : "알 수 없는 오류";
      throw new functions.https.HttpsError(
        "internal",
        `커리큘럼 생성 중 오류가 발생했습니다: ${errorMessage}`
      );
    }
  });

/**
 * AI 사용량 조회 Cloud Function (무제한 - 호환성 유지용)
 */
export const getAIUsage = functions
  .region("asia-northeast3")
  .https.onCall(async (data, context) => {
    requireAuth(context);

    // 모든 기능 무제한 (-1)
    return {
      curriculumCount: 0,
      curriculumLimit: -1,
      predictionCount: 0,
      predictionLimit: -1,
      subscriptionTier: "unlimited",
      model: AI_CONFIG.model,
      provider: AI_CONFIG.provider,
      resetDate: new Date().toISOString(),
    };
  });

// ============================================
// FCM 푸시 알림 Functions
// ============================================

/**
 * 새 메시지 발송 시 푸시 알림 전송
 * Firestore 트리거로 messages 컬렉션 감시
 */
export const sendMessageNotification = functions
  .region("asia-northeast3")
  .firestore.document("messages/{messageId}")
  .onCreate(async (snapshot) => {
    const message = snapshot.data();
    const {chatRoomId, senderId, senderRole, content, imageUrl} = message;

    try {
      // 1. 채팅방 정보 가져오기
      const chatRoomDoc = await db.collection(Collections.CHAT_ROOMS).doc(chatRoomId).get();
      if (!chatRoomDoc.exists) {
        console.log("채팅방을 찾을 수 없음:", chatRoomId);
        return null;
      }

      const chatRoom = chatRoomDoc.data()!;

      // 2. 수신자 ID 결정 (발신자가 트레이너면 회원에게, 회원이면 트레이너에게)
      const receiverId = senderRole === "trainer"
        ? chatRoom.memberId
        : chatRoom.trainerId;

      // 3. 수신자의 FCM 토큰 가져오기
      const userDoc = await db.collection(Collections.USERS).doc(receiverId).get();
      if (!userDoc.exists) {
        console.log("수신자를 찾을 수 없음:", receiverId);
        return null;
      }

      const userData = userDoc.data()!;
      const fcmToken = userData.fcmToken;

      if (!fcmToken) {
        console.log("FCM 토큰 없음:", receiverId);
        return null;
      }

      // 4. 발신자 이름 결정
      const senderName = senderRole === "trainer"
        ? chatRoom.trainerName
        : chatRoom.memberName;

      // 5. 푸시 알림 전송
      const notificationBody = imageUrl ? "사진을 보냈습니다." : content;

      const notificationMessage: admin.messaging.Message = {
        token: fcmToken,
        notification: {
          title: senderName,
          body: notificationBody.length > 100
            ? notificationBody.substring(0, 100) + "..."
            : notificationBody,
        },
        data: {
          type: "chat",
          chatRoomId: chatRoomId,
          senderId: senderId,
          senderRole: senderRole,
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
                title: senderName,
                body: notificationBody,
              },
              badge: 1,
              sound: "default",
            },
          },
        },
      };

      await admin.messaging().send(notificationMessage);
      console.log("푸시 알림 전송 성공:", receiverId);

      return null;
    } catch (error) {
      console.error("푸시 알림 전송 실패:", error);
      return null;
    }
  });

/**
 * PT 이용권 만료 알림 (7일, 3일, 1일 전)
 * 매일 오전 9시에 실행되는 스케줄 함수
 */
export const sendPTExpiryNotification = functions
  .region("asia-northeast3")
  .pubsub.schedule("0 9 * * *") // 매일 오전 9시
  .timeZone("Asia/Seoul")
  .onRun(async () => {
    const now = new Date();
    const targetDays = [7, 3, 1]; // 알림 대상 일수

    try {
      for (const days of targetDays) {
        // 만료 날짜 계산
        const targetDate = new Date(now);
        targetDate.setDate(targetDate.getDate() + days);
        const targetDateStr = targetDate.toISOString().split("T")[0];

        // 해당 날짜에 만료되는 회원 조회
        const membersSnapshot = await db.collection(Collections.MEMBERS)
          .where("endDate", ">=", new Date(targetDateStr + "T00:00:00"))
          .where("endDate", "<", new Date(targetDateStr + "T23:59:59"))
          .get();

        for (const memberDoc of membersSnapshot.docs) {
          const member = memberDoc.data();
          const memberId = member.userId;

          if (!memberId) continue;

          // 회원의 FCM 토큰 가져오기
          const userDoc = await db.collection(Collections.USERS).doc(memberId).get();
          if (!userDoc.exists) continue;

          const userData = userDoc.data()!;
          const fcmToken = userData.fcmToken;

          if (!fcmToken) continue;

          // 알림 메시지 작성
          let title: string;
          let body: string;

          if (days === 1) {
            title = "PT 이용권 만료 임박";
            body = "내일 PT 이용권이 만료됩니다. 연장을 원하시면 트레이너에게 문의해주세요.";
          } else {
            title = "PT 이용권 만료 예정";
            body = `${days}일 후 PT 이용권이 만료됩니다. 연장을 원하시면 트레이너에게 문의해주세요.`;
          }

          const notificationMessage: admin.messaging.Message = {
            token: fcmToken,
            notification: {
              title: title,
              body: body,
            },
            data: {
              type: "pt_expiry",
              daysUntilExpiry: days.toString(),
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
            console.log(`PT 만료 알림 전송 (${days}일 전):`, memberId);
          } catch (sendError) {
            console.error("개별 알림 전송 실패:", memberId, sendError);
          }
        }
      }

      console.log("PT 만료 알림 스케줄 완료");
      return null;
    } catch (error) {
      console.error("PT 만료 알림 스케줄 실패:", error);
      return null;
    }
  });

// ============================================
// AI 체중 예측 Functions
// ============================================

// 모듈화된 predictWeight 함수 re-export
export {predictWeight} from "./predictWeight";

// 체성분 예측 함수 re-export (체중, 골격근량, 체지방률)
export {predictBodyComposition} from "./predictBodyComposition";

// ============================================
// AI 인사이트 Functions
// ============================================

// 모듈화된 generateInsights 함수 re-export
export {
  generateInsights,
  generateInsightsScheduled,
  generateInsightsWeekly,
  onSessionUpdated,
  onBodyRecordCreated as onBodyRecordInsightTrigger,
  onInbodyRecordCreated,
} from "./generateInsights";

// ============================================
// AI 식단 분석 Functions
// ============================================

// 모듈화된 analyzeDiet 함수 re-export
export {analyzeDiet} from "./analyzeDiet";

// ============================================
// AI 회원 인사이트 Functions
// ============================================

// 모듈화된 generateMemberInsights 함수 re-export
export {
  generateMemberInsights,
  generateMemberInsightsScheduled,
} from "./generateMemberInsights";

// ============================================
// 푸시 알림 Functions
// ============================================

// 알림 함수 re-export
export {
  sendInsightNotification,
  sendDietReminderLunch,
  sendDietReminderDinner,
  sendPTReminder,
  sendWeeklyReport,
} from "./notifications";

// ============================================
// 회원 활동 트리거 Functions
// ============================================

// 회원 활동 감지 시 인사이트 자동 생성
export {
  onBodyRecordCreated,
  onDietRecordCreated,
  onCurriculumCompleted,
} from "./triggers/onMemberActivity";

// ============================================
// LookinBody InBody 웹훅
// ============================================

// LookinBody에서 인바디 측정 데이터 수신
export {inbodyWebhook} from "./inbodyWebhook";

// LookinBody API를 통한 인바디 데이터 조회
export {fetchInbodyByPhone} from "./fetchInbodyByPhone";

// ============================================
// AI 인바디 분석 Functions
// ============================================

// 인바디 결과지 사진 AI 분석
export {analyzeInbody} from "./analyzeInbody";

// ============================================
// 스케줄러 Functions (별도 폴더)
// ============================================

// 매일/매주 인사이트 자동 생성 스케줄러
export {
  dailyInsightGenerator,
  weeklyInsightGenerator,
} from "./schedulers";

// ============================================
// AI 커리큘럼 V2 Functions
// ============================================

export {generateCurriculumV2} from "./curriculum/generateCurriculumV2";
export {getAlternativeExercises} from "./curriculum/getAlternativeExercises";
export {searchExercises} from "./curriculum/searchExercises";

// ============================================
// 트레이너 배지 시스템 Functions
// ============================================

// 매일 자정 배지 조건 체크 + 이벤트 기반 stats 업데이트
export {
  calculateTrainerBadges,
  onMessageCreatedForStats,
  onScheduleCompletedForStats,
  onMemberUpdatedForStats,
} from "./badges";
