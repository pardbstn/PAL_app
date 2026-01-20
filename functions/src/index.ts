import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import OpenAI from "openai";
import {GoogleGenerativeAI} from "@google/generative-ai";

// Firebase Admin 초기화
admin.initializeApp();

// Firestore 인스턴스
const db = admin.firestore();

// 티어별 설정
interface TierConfig {
  provider: "google" | "openai";
  model: string;
  monthlyLimit: number;
}

const TIER_CONFIG: Record<string, TierConfig> = {
  free: {
    provider: "google",
    model: "gemini-2.5-flash-lite",
    monthlyLimit: 3,
  },
  basic: {
    provider: "openai",
    model: "gpt-4o-mini",
    monthlyLimit: 30,
  },
  pro: {
    provider: "openai",
    model: "gpt-4o",
    monthlyLimit: -1, // 무제한
  },
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

// OpenAI 클라이언트 (지연 초기화)
const getOpenAIClient = (): OpenAI => {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    throw new Error("OPENAI_API_KEY is not configured");
  }
  return new OpenAI({apiKey});
};

// Google AI 클라이언트 (지연 초기화)
const getGoogleAIClient = (): GoogleGenerativeAI => {
  const apiKey = process.env.GOOGLE_AI_API_KEY;
  if (!apiKey) {
    throw new Error("GOOGLE_AI_API_KEY is not configured");
  }
  return new GoogleGenerativeAI(apiKey);
};

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

// Gemini로 생성 (무료 티어)
async function generateWithGemini(
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
  const openai = getOpenAIClient();
  const response = await openai.chat.completions.create({
    model: modelName,
    messages: [{role: "user", content: prompt}],
    response_format: {type: "json_object"},
    temperature: 0.7,
    max_tokens: 4000,
  });

  const content = response.choices[0].message.content;
  if (!content) {
    throw new Error("AI 응답이 비어있습니다.");
  }
  return JSON.parse(content);
}

/**
 * AI 커리큘럼 생성 Cloud Function
 */
export const generateCurriculum = functions
  .region("asia-northeast3")
  .https.onCall(async (data, context) => {
    // 1. 인증 확인
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "로그인이 필요합니다."
      );
    }

    const userId = context.auth.uid;

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
      // 3. 트레이너 정보 확인 및 티어 가져오기
      const trainerSnapshot = await db
        .collection("trainers")
        .where("userId", "==", userId)
        .limit(1)
        .get();

      if (trainerSnapshot.empty) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "트레이너 정보를 찾을 수 없습니다."
        );
      }

      const trainerDoc = trainerSnapshot.docs[0];
      const trainerData = trainerDoc.data();
      const tier = trainerData.subscriptionTier || "free";
      const tierConfig = TIER_CONFIG[tier] || TIER_CONFIG.free;

      // 4. 월간 사용량 체크 (Flutter 모델 구조와 호환)
      const aiUsage = trainerData.aiUsage || {
        curriculumCount: 0,
        predictionCount: 0,
        resetDate: new Date(),
      };

      // resetDate 처리 (Firestore Timestamp 또는 Date)
      let resetDate: Date;
      if (aiUsage.resetDate?.toDate) {
        resetDate = aiUsage.resetDate.toDate();
      } else if (aiUsage.resetDate) {
        resetDate = new Date(aiUsage.resetDate);
      } else {
        resetDate = new Date();
      }

      const now = new Date();
      const shouldReset =
        now.getMonth() !== resetDate.getMonth() ||
        now.getFullYear() !== resetDate.getFullYear();

      let currentUsage = shouldReset ? 0 : (aiUsage.curriculumCount || 0);

      if (tierConfig.monthlyLimit !== -1 &&
          currentUsage >= tierConfig.monthlyLimit) {
        throw new functions.https.HttpsError(
          "resource-exhausted",
          `월간 AI 생성 한도(${tierConfig.monthlyLimit}회)를 초과했습니다. ` +
          "플랜을 업그레이드해주세요."
        );
      }

      // 5. 회원 정보 확인
      const memberDoc = await db.collection("members").doc(memberId).get();
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

      // 7. 티어별 AI 호출
      let result: {curriculums: unknown[]};
      if (tierConfig.provider === "google") {
        result = await generateWithGemini(prompt, tierConfig.model);
      } else {
        result = await generateWithOpenAI(prompt, tierConfig.model);
      }

      // 8. 사용량 업데이트 (Flutter 모델과 호환되는 구조)
      currentUsage += 1;
      const updateData: Record<string, unknown> = {
        "aiUsage.curriculumCount": currentUsage,
      };

      // 월이 바뀌었으면 resetDate도 업데이트
      if (shouldReset) {
        updateData["aiUsage.resetDate"] = admin.firestore.Timestamp.now();
      }

      await trainerDoc.ref.update(updateData);

      // 9. 결과 반환
      return {
        success: true,
        curriculums: result.curriculums,
        usage: {
          current: currentUsage,
          limit: tierConfig.monthlyLimit,
          tier: tier,
          model: tierConfig.model,
        },
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
 * AI 사용량 조회 Cloud Function
 */
export const getAIUsage = functions
  .region("asia-northeast3")
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "로그인이 필요합니다."
      );
    }

    const userId = context.auth.uid;

    try {
      const trainerSnapshot = await db
        .collection("trainers")
        .where("userId", "==", userId)
        .limit(1)
        .get();

      if (trainerSnapshot.empty) {
        throw new functions.https.HttpsError(
          "not-found",
          "트레이너 정보를 찾을 수 없습니다."
        );
      }

      const trainerData = trainerSnapshot.docs[0].data();
      const tier = trainerData.subscriptionTier || "free";
      const tierConfig = TIER_CONFIG[tier] || TIER_CONFIG.free;

      // aiUsage 처리 (Flutter 모델 구조와 호환)
      const aiUsage = trainerData.aiUsage || {
        curriculumCount: 0,
        predictionCount: 0,
        resetDate: new Date(),
      };

      // resetDate 처리
      let resetDate: Date;
      if (aiUsage.resetDate?.toDate) {
        resetDate = aiUsage.resetDate.toDate();
      } else if (aiUsage.resetDate) {
        resetDate = new Date(aiUsage.resetDate);
      } else {
        resetDate = new Date();
      }

      const now = new Date();
      const shouldReset =
        now.getMonth() !== resetDate.getMonth() ||
        now.getFullYear() !== resetDate.getFullYear();

      const currentUsage = shouldReset ? 0 : (aiUsage.curriculumCount || 0);

      return {
        curriculumCount: currentUsage,
        curriculumLimit: tierConfig.monthlyLimit,
        subscriptionTier: tier,
        model: tierConfig.model,
        provider: tierConfig.provider,
        resetDate: resetDate.toISOString(),
      };
    } catch (error) {
      console.error("getAIUsage error:", error);

      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      throw new functions.https.HttpsError(
        "internal",
        "사용량 조회 중 오류가 발생했습니다."
      );
    }
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
  .onCreate(async (snapshot, context) => {
    const message = snapshot.data();
    const {chatRoomId, senderId, senderRole, content, imageUrl} = message;

    try {
      // 1. 채팅방 정보 가져오기
      const chatRoomDoc = await db.collection("chat_rooms").doc(chatRoomId).get();
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
      const userDoc = await db.collection("users").doc(receiverId).get();
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
  .onRun(async (context) => {
    const now = new Date();
    const targetDays = [7, 3, 1]; // 알림 대상 일수

    try {
      for (const days of targetDays) {
        // 만료 날짜 계산
        const targetDate = new Date(now);
        targetDate.setDate(targetDate.getDate() + days);
        const targetDateStr = targetDate.toISOString().split("T")[0];

        // 해당 날짜에 만료되는 회원 조회
        const membersSnapshot = await db.collection("members")
          .where("endDate", ">=", new Date(targetDateStr + "T00:00:00"))
          .where("endDate", "<", new Date(targetDateStr + "T23:59:59"))
          .get();

        for (const memberDoc of membersSnapshot.docs) {
          const member = memberDoc.data();
          const memberId = member.userId;

          if (!memberId) continue;

          // 회원의 FCM 토큰 가져오기
          const userDoc = await db.collection("users").doc(memberId).get();
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
