// functions/src/analyzeDiet.ts
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import OpenAI from "openai";

const db = admin.firestore();

// 식단 분석 티어별 제한 (Free: 사용불가, Basic: 월 50회, Pro: 무제한)
const DIET_TIER_LIMITS: Record<string, number> = {
  free: 0,        // 사용 불가
  basic: 50,      // 월 50회
  pro: -1,        // 무제한
};

// MealType 타입
type MealType = "breakfast" | "lunch" | "dinner" | "snack";

// OpenAI 클라이언트
const getOpenAIClient = (): OpenAI => {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    throw new Error("OPENAI_API_KEY is not configured");
  }
  return new OpenAI({apiKey});
};

export const analyzeDiet = functions
  .region("asia-northeast3")
  .https.onCall(async (data, context) => {
    // 1. 인증 확인
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "로그인이 필요합니다."
      );
    }

    // 2. 입력 데이터 검증
    const {memberId, imageUrl, mealType} = data;

    if (!memberId || !imageUrl || !mealType) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "필수 입력값(memberId, imageUrl, mealType)이 누락되었습니다."
      );
    }

    const validMealTypes: MealType[] = ["breakfast", "lunch", "dinner", "snack"];
    if (!validMealTypes.includes(mealType)) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "mealType은 breakfast, lunch, dinner, snack 중 하나여야 합니다."
      );
    }

    try {
      // 3. 회원의 트레이너 ID 가져오기
      const memberDoc = await db.collection("members").doc(memberId).get();
      if (!memberDoc.exists) {
        throw new functions.https.HttpsError(
          "not-found",
          "회원 정보를 찾을 수 없습니다."
        );
      }
      const memberData = memberDoc.data()!;
      const trainerId = memberData.trainerId;

      // 4. 트레이너 정보 확인 및 티어 체크
      const trainerDoc = await db.collection("trainers").doc(trainerId).get();
      if (!trainerDoc.exists) {
        throw new functions.https.HttpsError(
          "not-found",
          "트레이너 정보를 찾을 수 없습니다."
        );
      }

      const trainerData = trainerDoc.data()!;
      const tier = trainerData.subscriptionTier || "free";
      const tierLimit = DIET_TIER_LIMITS[tier] ?? 0;

      // Free 티어는 사용 불가
      if (tierLimit === 0) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "무료 플랜에서는 식단 분석 기능을 사용할 수 없습니다. 플랜을 업그레이드해주세요."
        );
      }

      // 5. 월간 사용량 체크
      const aiUsage = trainerData.aiUsage || {
        dietAnalysisCount: 0,
        resetDate: new Date(),
      };

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

      let currentUsage = shouldReset ? 0 : (aiUsage.dietAnalysisCount || 0);

      if (tierLimit !== -1 && currentUsage >= tierLimit) {
        throw new functions.https.HttpsError(
          "resource-exhausted",
          `월간 식단 분석 한도(${tierLimit}회)를 초과했습니다. 플랜을 업그레이드해주세요.`
        );
      }

      // 6. GPT-4o Vision으로 이미지 분석
      const openai = getOpenAIClient();

      const response = await openai.chat.completions.create({
        model: "gpt-4o",
        messages: [
          {
            role: "user",
            content: [
              {
                type: "text",
                text: `당신은 영양사입니다. 이 음식 사진을 분석하여 다음 JSON 형식으로만 응답해주세요:
{
  "foodName": "음식 이름 (여러 개면 쉼표로 구분)",
  "calories": 예상 칼로리(숫자만, kcal 단위),
  "protein": 단백질 그램수(숫자만),
  "carbs": 탄수화물 그램수(숫자만),
  "fat": 지방 그램수(숫자만),
  "confidence": 0.0~1.0 사이의 신뢰도
}

일반적인 1인분 기준으로 추정해주세요. 음식을 인식하지 못하면 confidence를 0.3 이하로 설정하세요.`,
              },
              {
                type: "image_url",
                image_url: {
                  url: imageUrl,
                  detail: "low",
                },
              },
            ],
          },
        ],
        response_format: {type: "json_object"},
        max_tokens: 500,
      });

      const content = response.choices[0].message.content;
      if (!content) {
        throw new Error("AI 응답이 비어있습니다.");
      }

      const analysisResult = JSON.parse(content);

      // 7. diet_records 컬렉션에 저장
      const dietRecord = {
        memberId,
        mealType,
        imageUrl,
        foodName: analysisResult.foodName || "알 수 없는 음식",
        calories: Number(analysisResult.calories) || 0,
        protein: Number(analysisResult.protein) || 0,
        carbs: Number(analysisResult.carbs) || 0,
        fat: Number(analysisResult.fat) || 0,
        confidence: Number(analysisResult.confidence) || 0.5,
        analyzedAt: admin.firestore.Timestamp.now(),
        createdAt: admin.firestore.Timestamp.now(),
      };

      const docRef = await db.collection("diet_records").add(dietRecord);

      // 8. 사용량 업데이트
      currentUsage += 1;
      const updateData: Record<string, unknown> = {
        "aiUsage.dietAnalysisCount": currentUsage,
      };

      if (shouldReset) {
        updateData["aiUsage.resetDate"] = admin.firestore.Timestamp.now();
      }

      await trainerDoc.ref.update(updateData);

      // 9. 결과 반환
      return {
        success: true,
        id: docRef.id,
        ...dietRecord,
        analyzedAt: dietRecord.analyzedAt.toDate().toISOString(),
        createdAt: dietRecord.createdAt.toDate().toISOString(),
        usage: {
          current: currentUsage,
          limit: tierLimit,
          tier: tier,
        },
      };
    } catch (error) {
      console.error("analyzeDiet error:", error);

      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      const errorMessage = error instanceof Error ? error.message : "알 수 없는 오류";
      throw new functions.https.HttpsError(
        "internal",
        `식단 분석 중 오류가 발생했습니다: ${errorMessage}`
      );
    }
  });
