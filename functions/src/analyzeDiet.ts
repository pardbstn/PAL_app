// functions/src/analyzeDiet.ts
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {db} from "./utils/firestore";
import {Collections} from "./constants/collections";
import {requireAuth} from "./middleware/auth";
import {getOpenAIClient} from "./services/ai-service";

// MealType 타입
type MealType = "breakfast" | "lunch" | "dinner" | "snack";

export const analyzeDiet = functions
  .region("asia-northeast3")
  .https.onCall(async (data, context) => {
    // 1. 인증 확인
    requireAuth(context);

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
      // 3. 회원 정보 확인
      const memberDoc = await db.collection(Collections.MEMBERS).doc(memberId).get();
      if (!memberDoc.exists) {
        throw new functions.https.HttpsError(
          "not-found",
          "회원 정보를 찾을 수 없습니다."
        );
      }

      // 4. GPT-4o Vision으로 이미지 분석
      const openai = getOpenAIClient();

      const response = await openai.chat.completions.create({
        model: "gpt-4o",
        messages: [
          {
            role: "system",
            content: `당신은 10년 경력의 스포츠 영양사입니다. 음식 사진을 보고 각 음식을 개별로 인식하고 실제 양(portion)을 정밀하게 추정하는 전문가입니다.

## 핵심 규칙
- 사진 속 보이는 모든 음식을 개별 항목으로 분리하세요
- 절대 "1인분"으로 기본 추정하지 마세요
- 사진 속 실제 보이는 양을 기준으로 추정하세요
- 그릇/접시/숟가락/젓가락 등을 크기 비교 기준으로 활용하세요

## 양 추정 가이드
- 밥: 일반 공기밥=210g, 큰 그릇=300~400g, 작은 그릇=150g
- 국/찌개: 1인 뚝배기=300ml, 큰 냄비=500ml+
- 고기: 손바닥 크기=100g, 접시 가득=200~300g
- 면류: 1인분=200g, 곱빼기=300g+
- 반찬: 종지 1개=30~50g

## 음식 이름 규칙
- 한국 일반명을 사용하세요 (예: "흰쌀밥", "김치찌개", "배추김치")
- 브랜드명이나 식당명은 제외하세요`,
          },
          {
            role: "user",
            content: [
              {
                type: "text",
                text: `이 음식 사진을 분석해주세요. 보이는 모든 음식을 개별로 분리하여 각각의 양과 영양소를 추정하세요.

다음 JSON 형식으로만 응답:
{
  "foods": [
    {
      "foodName": "음식 이름",
      "estimatedWeight": 추정 중량(g, 숫자만),
      "calories": 칼로리(kcal, 숫자만),
      "protein": 단백질(g, 숫자만),
      "carbs": 탄수화물(g, 숫자만),
      "fat": 지방(g, 숫자만),
      "portionNote": "양 추정 근거"
    }
  ],
  "confidence": 0.0~1.0 전체 신뢰도
}

- foods 배열에 각 음식을 개별 항목으로 넣으세요
- 밥, 국, 반찬이 각각 보이면 각각 별도 항목으로 분리하세요
- 음식을 인식하지 못하면 confidence를 0.3 이하로 설정하세요`,
              },
              {
                type: "image_url",
                image_url: {
                  url: imageUrl,
                  detail: "high",
                },
              },
            ],
          },
        ],
        response_format: {type: "json_object"},
        max_tokens: 1200,
      });

      const content = response.choices[0].message.content;
      if (!content) {
        throw new Error("AI 응답이 비어있습니다.");
      }

      const analysisResult = JSON.parse(content);

      // 5. 신뢰도 확인 - 음식이 아닌 이미지 처리
      const confidence = Number(analysisResult.confidence) || 0;

      // foods 배열 파싱 (개별 음식 항목)
      const rawFoods = Array.isArray(analysisResult.foods)
        ? analysisResult.foods : [];

      const foods = rawFoods.map((f: Record<string, unknown>) => ({
        foodName: String(f.foodName || "알 수 없는 음식"),
        estimatedWeight: Number(f.estimatedWeight) || 0,
        calories: Number(f.calories) || 0,
        protein: Number(f.protein) || 0,
        carbs: Number(f.carbs) || 0,
        fat: Number(f.fat) || 0,
        portionNote: String(f.portionNote || ""),
      }));

      // 총합 계산
      const totalCalories = foods.reduce(
        (sum: number, f: {calories: number}) => sum + f.calories, 0
      );
      const totalProtein = foods.reduce(
        (sum: number, f: {protein: number}) => sum + f.protein, 0
      );
      const totalCarbs = foods.reduce(
        (sum: number, f: {carbs: number}) => sum + f.carbs, 0
      );
      const totalFat = foods.reduce(
        (sum: number, f: {fat: number}) => sum + f.fat, 0
      );

      // 신뢰도가 낮거나 음식이 없으면 음식이 아닌 것으로 판단
      if (confidence < 0.3 || (totalCalories === 0 && confidence < 0.5)) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "음식을 인식할 수 없습니다. 음식 사진을 다시 촬영해주세요."
        );
      }

      const foodNames = foods.map(
        (f: {foodName: string}) => f.foodName
      ).join(", ");

      // 6. diet_records 컬렉션에 저장
      const dietRecord = {
        memberId,
        mealType,
        imageUrl,
        foodName: foodNames || "알 수 없는 음식",
        calories: totalCalories,
        protein: totalProtein,
        carbs: totalCarbs,
        fat: totalFat,
        confidence: confidence,
        foods: foods,
        analyzedAt: admin.firestore.Timestamp.now(),
        createdAt: admin.firestore.Timestamp.now(),
      };

      const docRef = await db.collection(Collections.DIET_RECORDS).add(dietRecord);

      // 7. 결과 반환
      return {
        success: true,
        id: docRef.id,
        ...dietRecord,
        analyzedAt: dietRecord.analyzedAt.toDate().toISOString(),
        createdAt: dietRecord.createdAt.toDate().toISOString(),
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
