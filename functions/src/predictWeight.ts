/**
 * AI 체중 예측 Cloud Function
 * 회원의 체중 기록을 분석하여 미래 체중을 예측
 *
 * @module predictWeight
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {db} from "./utils/firestore";
import {Collections} from "./constants/collections";
import {requireAuth} from "./middleware/auth";
import {
  WeightDataPoint,
  PredictedPoint,
  MIN_DATA_POINTS,
  MAX_WEEKS_AHEAD,
  calculateLinearRegression,
  calculateWeightedTrend,
  calculateStandardDeviation,
  removeOutliers,
  aggregateToWeekly,
  calculateConfidence,
  calculateWeeksToTarget,
  generateAnalysisMessage,
  generatePredictedWeights,
  generateDataSummary,
  generateGoalScenarios,
  generateCoachingMessages,
  generateGeminiAnalysis,
  GeminiAnalysisResult,
} from "./utils/predictionHelpers";

/**
 * AI 체중 예측 Cloud Function
 *
 * @description
 * 회원의 체중 기록을 분석하여 선형 회귀 + 가중 이동 평균 기반으로
 * 미래 체중을 예측합니다.
 *
 * @fires https.onCall
 * @region asia-northeast3
 *
 * @param {Object} data - 요청 데이터
 * @param {string} data.memberId - 회원 ID (필수)
 * @param {number} [data.weeksAhead=1] - 예측할 주 수 (1주만 지원)
 *
 * @returns {Promise<Object>} 예측 결과
 *
 * @throws {HttpsError} AUTH_REQUIRED - 로그인 필요
 * @throws {HttpsError} MEMBER_NOT_FOUND - 회원 없음
 * @throws {HttpsError} INSUFFICIENT_DATA - 데이터 부족
 * @throws {HttpsError} INVALID_PARAMETER - 잘못된 파라미터
 */
export const predictWeight = functions
  .region("asia-northeast3")
  .https.onCall(async (data, context) => {
    const startTime = Date.now();
    functions.logger.info("[predictWeight] 함수 시작", {
      memberId: data?.memberId,
      weeksAhead: data?.weeksAhead,
      callerUid: context.auth?.uid,
    });

    // 1. 인증 확인
    const userId = requireAuth(context);

    // 2. 입력 데이터 검증
    const {memberId, weeksAhead = 1} = data || {};

    if (!memberId || typeof memberId !== "string") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "회원 ID가 필요합니다."
      );
    }

    // 예측 기간 검증 및 클램핑 (1주 예측만 지원)
    const predictionWeeks = Math.min(
      Math.max(1, Number(weeksAhead) || 1),
      MAX_WEEKS_AHEAD
    );

    if (weeksAhead && (weeksAhead < 1 || weeksAhead > MAX_WEEKS_AHEAD)) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        `예측 기간은 1주에서 ${MAX_WEEKS_AHEAD}주 사이여야 합니다.`
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

      const trainerDoc = trainerSnapshot.docs[0];
      const trainerId = trainerDoc.id;

      // 4. 회원 정보 확인
      const memberDoc = await db.collection(Collections.MEMBERS).doc(memberId).get();
      if (!memberDoc.exists) {
        throw new functions.https.HttpsError(
          "not-found",
          "회원 정보를 찾을 수 없습니다."
        );
      }

      const memberData = memberDoc.data()!;
      const targetWeight = memberData.targetWeight || null;
      const goal = memberData.goal || "diet";

      // 6. 체중 기록 조회 (최근 6개월)
      const sixMonthsAgo = new Date();
      sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6);

      const recordsSnapshot = await db
        .collection(Collections.BODY_RECORDS)
        .where("memberId", "==", memberId)
        .where("recordDate", ">=", admin.firestore.Timestamp.fromDate(sixMonthsAgo))
        .orderBy("recordDate", "asc")
        .get();

      functions.logger.info("[predictWeight] 데이터 조회 완료", {
        memberId,
        recordCount: recordsSnapshot.size,
      });

      if (recordsSnapshot.empty) {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "체중 기록이 없습니다. 먼저 체중을 기록해주세요."
        );
      }

      // 7. 데이터 전처리
      const rawData: WeightDataPoint[] = recordsSnapshot.docs.map((doc) => {
        const docData = doc.data();
        return {
          date: docData.recordDate.toDate(),
          weight: docData.weight,
        };
      });

      // 최소 데이터 포인트 확인
      if (rawData.length < MIN_DATA_POINTS) {
        throw new functions.https.HttpsError(
          "failed-precondition",
          `체중 예측을 위해 최소 ${MIN_DATA_POINTS}주 이상의 기록이 필요합니다. ` +
          `현재 ${rawData.length}개의 기록이 있습니다.`
        );
      }

      // 이상치 제거
      const cleanedData = removeOutliers(rawData);
      const outlierCount = rawData.length - cleanedData.length;

      // 주간 데이터로 집계
      const weeklyData = aggregateToWeekly(cleanedData);

      functions.logger.info("[predictWeight] 전처리 완료", {
        originalCount: rawData.length,
        cleanedCount: cleanedData.length,
        outlierRemoved: outlierCount,
        weeklyDataPoints: weeklyData.length,
      });

      // 8. 선형 회귀 분석
      const dataForRegression: WeightDataPoint[] = weeklyData.map((w) => ({
        date: w.weekStart,
        weight: w.avgWeight,
      }));

      const regression = calculateLinearRegression(dataForRegression);

      // 주간 변화량 (kg/week) - 선형 회귀 기반
      const linearWeeklyTrend = Math.round(regression.slope * 7 * 100) / 100;

      // 가중 추세 계산 (최근 데이터에 더 많은 가중치)
      const weightedTrend = calculateWeightedTrend(weeklyData);

      // 최종 주간 추세: 선형 회귀와 가중 추세의 평균
      const weeklyTrend = Math.round(
        ((linearWeeklyTrend + weightedTrend) / 2) * 100
      ) / 100;

      // 9. 현재 체중 및 표준편차 계산
      const currentWeight = rawData[rawData.length - 1].weight;
      const lastDate = rawData[rawData.length - 1].date;
      const weights = rawData.map((d) => d.weight);
      const standardDeviation = calculateStandardDeviation(weights);
      const variance = standardDeviation ** 2;

      // 10. 예측 데이터 생성
      const predictedWeights: PredictedPoint[] = generatePredictedWeights({
        currentWeight,
        lastDate,
        weeklyTrend,
        weeksAhead: predictionWeeks,
        standardDeviation,
      });

      // 11. 목표 도달 예상 주 계산
      const estimatedWeeksToTarget = calculateWeeksToTarget(
        currentWeight,
        targetWeight,
        weeklyTrend
      );

      // 12. 신뢰도 계산
      const confidence = calculateConfidence(
        rawData.length,
        variance,
        regression.rSquared
      );

      // 13. 분석 메시지 생성
      const analysisMessage = generateAnalysisMessage({
        weeklyTrend,
        weeksToTarget: estimatedWeeksToTarget,
        confidence,
        goal,
        currentWeight,
        targetWeight,
      });

      // 13-1. 데이터 요약 생성
      const dataSummary = generateDataSummary(rawData);

      // 13-2. 목표 달성 시나리오 생성
      const goalScenarios = generateGoalScenarios(currentWeight, targetWeight, goal);

      // 13-3. AI 코칭 메시지 생성
      const coachingMessages = generateCoachingMessages({
        weeklyTrend,
        recentWeekChange: dataSummary.recentWeekChange,
        goal,
        currentWeight,
        targetWeight,
        consistencyScore: dataSummary.consistencyScore,
        dataPointsUsed: rawData.length,
      });

      // 13-4. Gemini AI 심층 분석 (모든 사용자)
      let geminiAnalysis: GeminiAnalysisResult | null = null;
      const geminiApiKey = functions.config().gemini?.api_key || process.env.GEMINI_API_KEY;
      if (geminiApiKey) {
        functions.logger.info("[predictWeight] Gemini 분석 시작");
        geminiAnalysis = await generateGeminiAnalysis({
          currentWeight,
          targetWeight,
          weeklyTrend,
          dataSummary,
          goal,
          confidence,
          dataPointsUsed: rawData.length,
          estimatedWeeksToTarget,
          apiKey: geminiApiKey,
        });
        functions.logger.info("[predictWeight] Gemini 분석 완료", {
          success: geminiAnalysis.success,
        });
      } else {
        functions.logger.warn("[predictWeight] Gemini API 키 미설정");
      }

      functions.logger.info("[predictWeight] 예측 계산 완료", {
        weeklyTrend,
        confidence,
        rSquared: regression.rSquared,
        dataSummary,
        coachingMessagesCount: coachingMessages.length,
        hasGeminiAnalysis: geminiAnalysis?.success ?? false,
      });

      // 14. 예측 결과 Firestore 저장
      const predictionData: Record<string, unknown> = {
        memberId,
        trainerId,
        currentWeight: Math.round(currentWeight * 10) / 10,
        targetWeight,
        predictedWeights,
        weeklyTrend,
        estimatedWeeksToTarget,
        confidence,
        dataPointsUsed: rawData.length,
        analysisMessage,
        dataSummary,
        goalScenarios,
        coachingMessages,
        createdAt: admin.firestore.Timestamp.now(),
      };

      // Gemini 분석 결과 추가
      if (geminiAnalysis?.success) {
        predictionData.geminiAnalysis = {
          aiInsight: geminiAnalysis.aiInsight,
          actionItems: geminiAnalysis.actionItems,
          motivationalMessage: geminiAnalysis.motivationalMessage,
        };
      }

      const predictionRef = await db.collection(Collections.PREDICTIONS).add(predictionData);

      functions.logger.info("[predictWeight] 예측 저장 완료", {
        predictionId: predictionRef.id,
      });

      const duration = Date.now() - startTime;
      functions.logger.info("[predictWeight] 함수 완료", {
        memberId,
        predictionId: predictionRef.id,
        dataPoints: rawData.length,
        confidence,
        durationMs: duration,
      });

      // 16. 결과 반환
      const response: Record<string, unknown> = {
        success: true,
        prediction: {
          id: predictionRef.id,
          memberId,
          trainerId,
          currentWeight: Math.round(currentWeight * 10) / 10,
          targetWeight,
          predictedWeights,
          weeklyTrend,
          estimatedWeeksToTarget,
          confidence,
          dataPointsUsed: rawData.length,
          analysisMessage,
          dataSummary,
          goalScenarios,
          coachingMessages,
          // Gemini AI 분석
          ...(geminiAnalysis?.success && {
            geminiAnalysis: {
              aiInsight: geminiAnalysis.aiInsight,
              actionItems: geminiAnalysis.actionItems,
              motivationalMessage: geminiAnalysis.motivationalMessage,
            },
          }),
        },
      };

      return response;
    } catch (error) {
      const duration = Date.now() - startTime;
      functions.logger.error("[predictWeight] 오류 발생", {
        error: error instanceof Error ? error.message : error,
        stack: error instanceof Error ? error.stack : undefined,
        memberId,
        durationMs: duration,
      });

      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      const errorMessage =
        error instanceof Error ? error.message : "알 수 없는 오류";
      throw new functions.https.HttpsError(
        "internal",
        `예측 처리 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요. (${errorMessage})`
      );
    }
  });
