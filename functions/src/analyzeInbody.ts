/**
 * analyzeInbody.ts
 *
 * 인바디 결과지 사진을 AI로 분석하여 수치를 추출하는 Cloud Function
 * GPT-4o-mini Vision API 사용
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import OpenAI from "openai";

const db = admin.firestore();

// OpenAI 클라이언트 (lazy initialization)
let openaiClient: OpenAI | null = null;

function getOpenAIClient(): OpenAI {
  if (!openaiClient) {
    const apiKey = process.env.OPENAI_API_KEY;
    if (!apiKey) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "OpenAI API 키가 설정되지 않았습니다."
      );
    }
    openaiClient = new OpenAI({ apiKey });
  }
  return openaiClient;
}

// 인바디 분석 결과 인터페이스
interface InbodyAnalysisResult {
  weight: number | null;
  skeletalMuscleMass: number | null;
  bodyFatMass: number | null;
  bodyFatPercent: number | null;
  bmi: number | null;
  basalMetabolicRate: number | null;
  totalBodyWater: number | null;
  protein: number | null;
  minerals: number | null;
  visceralFatLevel: number | null;
  inbodyScore: number | null;
}

// 요청 파라미터 인터페이스
interface AnalyzeInbodyRequest {
  memberId: string;
  imageUrl: string;
}

/**
 * 인바디 결과지 사진 분석 Cloud Function
 *
 * @param memberId - 회원 ID
 * @param imageUrl - 인바디 결과지 이미지 URL (Supabase Storage)
 * @returns 분석 결과 및 저장된 레코드 ID
 */
export const analyzeInbody = functions
  .region("asia-northeast3")
  .runWith({
    timeoutSeconds: 60,
    memory: "512MB",
    secrets: ["OPENAI_API_KEY"],
  })
  .https.onCall(async (data: AnalyzeInbodyRequest, context) => {
    // 1. 인증 확인
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "로그인이 필요합니다."
      );
    }

    const { memberId, imageUrl } = data;

    // 2. 파라미터 검증
    if (!memberId || typeof memberId !== "string") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "회원 ID가 필요합니다."
      );
    }

    if (!imageUrl || typeof imageUrl !== "string") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "이미지 URL이 필요합니다."
      );
    }

    // 3. 회원 존재 확인
    const memberDoc = await db.collection("members").doc(memberId).get();
    if (!memberDoc.exists) {
      throw new functions.https.HttpsError(
        "not-found",
        "회원을 찾을 수 없습니다."
      );
    }

    try {
      // 4. GPT-4o-mini Vision API 호출
      const openai = getOpenAIClient();

      const prompt = `이 이미지는 인바디(InBody) 체성분 분석 결과지입니다.
결과지에서 다음 수치들을 추출해주세요.
읽을 수 없거나 해당 항목이 없으면 null로 표시하세요.
반드시 JSON 형식으로만 응답하세요. 다른 텍스트 없이 JSON만 반환하세요.

추출할 항목:
- weight: 체중 (kg)
- skeletalMuscleMass: 골격근량 (kg)
- bodyFatMass: 체지방량 (kg)
- bodyFatPercent: 체지방률 (%)
- bmi: BMI (kg/m²)
- basalMetabolicRate: 기초대사량 (kcal)
- totalBodyWater: 체수분 (L 또는 kg)
- protein: 단백질 (kg)
- minerals: 무기질 (kg)
- visceralFatLevel: 내장지방레벨 (숫자)
- inbodyScore: 인바디 점수 (숫자)

응답 형식:
{"weight": 70.5, "skeletalMuscleMass": 32.1, "bodyFatMass": 15.2, "bodyFatPercent": 21.5, "bmi": 23.4, "basalMetabolicRate": 1650, "totalBodyWater": 40.2, "protein": 11.5, "minerals": 3.8, "visceralFatLevel": 8, "inbodyScore": 75}`;

      const response = await openai.chat.completions.create({
        model: "gpt-4o-mini",
        messages: [
          {
            role: "user",
            content: [
              { type: "text", text: prompt },
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
        max_tokens: 500,
        temperature: 0.1,
      });

      const content = response.choices[0]?.message?.content;
      if (!content) {
        throw new functions.https.HttpsError(
          "internal",
          "AI 응답을 받지 못했습니다."
        );
      }

      // 5. JSON 파싱
      let analysis: InbodyAnalysisResult;
      try {
        // JSON 블록 추출 (```json ... ``` 형태일 수 있음)
        const jsonMatch = content.match(/\{[\s\S]*\}/);
        if (!jsonMatch) {
          throw new Error("JSON not found in response");
        }
        analysis = JSON.parse(jsonMatch[0]);
      } catch {
        console.error("JSON parse error:", content);
        throw new functions.https.HttpsError(
          "internal",
          "AI 응답을 파싱할 수 없습니다."
        );
      }

      // 6. 필수 필드 확인 (최소한 체중은 있어야 함)
      if (analysis.weight === null || analysis.weight === undefined) {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "인바디 결과지에서 체중을 읽을 수 없습니다. 선명한 사진을 업로드해주세요."
        );
      }

      // 7. Firestore에 저장
      const now = admin.firestore.Timestamp.now();
      const inbodyRecord = {
        memberId,
        measuredAt: now,
        weight: analysis.weight,
        skeletalMuscleMass: analysis.skeletalMuscleMass ?? 0,
        bodyFatMass: analysis.bodyFatMass,
        bodyFatPercent: analysis.bodyFatPercent ?? 0,
        bmi: analysis.bmi,
        basalMetabolicRate: analysis.basalMetabolicRate,
        totalBodyWater: analysis.totalBodyWater,
        protein: analysis.protein,
        minerals: analysis.minerals,
        visceralFatLevel: analysis.visceralFatLevel,
        inbodyScore: analysis.inbodyScore,
        source: "ai_analysis",
        imageUrl,
        analyzedAt: now,
        createdAt: now,
      };

      const docRef = await db.collection("inbody_records").add(inbodyRecord);

      console.log(
        `InBody analysis saved for member ${memberId}, record ID: ${docRef.id}`
      );

      return {
        success: true,
        recordId: docRef.id,
        analysis: {
          weight: analysis.weight,
          skeletalMuscleMass: analysis.skeletalMuscleMass,
          bodyFatMass: analysis.bodyFatMass,
          bodyFatPercent: analysis.bodyFatPercent,
          bmi: analysis.bmi,
          basalMetabolicRate: analysis.basalMetabolicRate,
          totalBodyWater: analysis.totalBodyWater,
          protein: analysis.protein,
          minerals: analysis.minerals,
          visceralFatLevel: analysis.visceralFatLevel,
          inbodyScore: analysis.inbodyScore,
        },
      };
    } catch (error) {
      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      console.error("InBody analysis error:", error);
      throw new functions.https.HttpsError(
        "internal",
        "인바디 분석 중 오류가 발생했습니다."
      );
    }
  });
