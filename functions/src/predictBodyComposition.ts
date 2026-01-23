/**
 * AI 체성분 예측 Cloud Function
 * 회원의 체중, 골격근량, 체지방률을 분석하여 미래 수치를 예측
 *
 * @module predictBodyComposition
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {
  WeightDataPoint,
  MIN_DATA_POINTS,
  calculateLinearRegression,
  calculateWeightedTrend,
  calculateStandardDeviation,
  removeOutliers,
  aggregateToWeekly,
  calculateConfidence,
  calculateWeeksToTarget,
} from "./utils/predictionHelpers";

// Firestore 인스턴스
const db = admin.firestore();

// ==================== 인터페이스 정의 ====================

/**
 * 단일 메트릭 예측 결과
 */
interface MetricPrediction {
  current: number;
  predicted: number;
  weeklyTrend: number;
  confidence: number;
  targetValue: number | null;
  estimatedWeeksToTarget: number | null;
}

/**
 * 체성분 예측 응답
 */
interface BodyCompositionPredictionResponse {
  success: boolean;
  predictions: {
    weight: MetricPrediction | null;
    skeletalMuscleMass: MetricPrediction | null;
    bodyFatPercent: MetricPrediction | null;
  };
  analysisMessage: string;
  dataPointsUsed: {
    weight: number;
    muscle: number;
    bodyFat: number;
  };
  createdAt: admin.firestore.Timestamp;
}

// ==================== 헬퍼 함수 ====================

/**
 * 단일 메트릭 예측 계산
 *
 * @param data - 시계열 데이터 포인트
 * @param targetValue - 목표 값 (선택)
 * @returns 메트릭 예측 결과 또는 null (데이터 부족 시)
 */
function calculateMetricPrediction(
  data: WeightDataPoint[],
  targetValue: number | null
): MetricPrediction | null {
  // 최소 데이터 포인트 확인
  if (data.length < MIN_DATA_POINTS) {
    return null;
  }

  // 이상치 제거
  const cleanedData = removeOutliers(data);

  // 주간 데이터로 집계
  const weeklyData = aggregateToWeekly(cleanedData);

  // 주간 데이터가 2개 미만이면 원본 데이터로 직접 예측
  let dataForRegression: WeightDataPoint[];
  let linearWeeklyTrend: number;
  let weightedTrend: number;

  if (weeklyData.length >= 2) {
    // 주간 데이터가 충분하면 주간 집계 사용
    dataForRegression = weeklyData.map((w) => ({
      date: w.weekStart,
      weight: w.avgWeight,
    }));
    const regression = calculateLinearRegression(dataForRegression);
    linearWeeklyTrend = Math.round(regression.slope * 7 * 100) / 100;
    weightedTrend = calculateWeightedTrend(weeklyData);
  } else {
    // 주간 데이터가 부족하면 원본 데이터로 직접 예측
    dataForRegression = cleanedData;
    const regression = calculateLinearRegression(cleanedData);
    linearWeeklyTrend = Math.round(regression.slope * 7 * 100) / 100;
    // 원본 데이터의 첫날과 마지막날 차이로 추세 계산
    if (cleanedData.length >= 2) {
      const firstWeight = cleanedData[0].weight;
      const lastWeight = cleanedData[cleanedData.length - 1].weight;
      const daysDiff = (cleanedData[cleanedData.length - 1].date.getTime() -
        cleanedData[0].date.getTime()) / (1000 * 60 * 60 * 24);
      weightedTrend = daysDiff > 0
        ? Math.round(((lastWeight - firstWeight) / daysDiff) * 7 * 100) / 100
        : 0;
    } else {
      weightedTrend = 0;
    }
  }

  const regression = calculateLinearRegression(dataForRegression);

  // 최종 주간 추세: 선형 회귀와 가중 추세의 평균
  const weeklyTrend = Math.round(
    ((linearWeeklyTrend + weightedTrend) / 2) * 100
  ) / 100;

  // 현재 값 및 표준편차 계산
  const currentValue = data[data.length - 1].weight;
  const values = data.map((d) => d.weight);
  const standardDeviation = calculateStandardDeviation(values);
  const variance = standardDeviation ** 2;

  // 4주 후 예측 값
  const predictedValue = Math.round((currentValue + weeklyTrend * 4) * 10) / 10;

  // 목표 도달 예상 주 계산
  const estimatedWeeksToTarget = calculateWeeksToTarget(
    currentValue,
    targetValue,
    weeklyTrend
  );

  // 신뢰도 계산
  const confidence = calculateConfidence(
    data.length,
    variance,
    regression.rSquared
  );

  return {
    current: Math.round(currentValue * 10) / 10,
    predicted: predictedValue,
    weeklyTrend,
    confidence,
    targetValue,
    estimatedWeeksToTarget,
  };
}

/**
 * 분석 메시지 생성 (3개 메트릭 통합)
 *
 * @param predictions - 각 메트릭별 예측 결과
 * @returns 통합 분석 메시지 (한글)
 */
function generateCompositionAnalysisMessage(predictions: {
  weight: MetricPrediction | null;
  skeletalMuscleMass: MetricPrediction | null;
  bodyFatPercent: MetricPrediction | null;
}): string {
  const parts: string[] = [];

  // 체중 메시지
  if (predictions.weight) {
    const change = predictions.weight.predicted - predictions.weight.current;
    const arrow = change > 0 ? "▲" : change < 0 ? "▼" : "→";
    const changeStr = change !== 0 ? `${arrow}${Math.abs(change).toFixed(1)}kg` : "유지";
    parts.push(`체중 ${predictions.weight.predicted}kg (${changeStr})`);
  }

  // 골격근량 메시지
  if (predictions.skeletalMuscleMass) {
    const change = predictions.skeletalMuscleMass.predicted - predictions.skeletalMuscleMass.current;
    const arrow = change > 0 ? "▲" : change < 0 ? "▼" : "→";
    const changeStr = change !== 0 ? `${arrow}${Math.abs(change).toFixed(1)}kg` : "유지";
    parts.push(`골격근량 ${predictions.skeletalMuscleMass.predicted}kg (${changeStr})`);
  }

  // 체지방률 메시지
  if (predictions.bodyFatPercent) {
    const change = predictions.bodyFatPercent.predicted - predictions.bodyFatPercent.current;
    const arrow = change > 0 ? "▲" : change < 0 ? "▼" : "→";
    const changeStr = change !== 0 ? `${arrow}${Math.abs(change).toFixed(1)}%` : "유지";
    parts.push(`체지방률 ${predictions.bodyFatPercent.predicted}% (${changeStr})`);
  }

  if (parts.length === 0) {
    return "예측을 위한 충분한 데이터가 없습니다.";
  }

  return `4주 뒤 예측: ${parts.join(", ")}`;
}

// ==================== 메인 함수 ====================

/**
 * AI 체성분 예측 Cloud Function
 *
 * @description
 * 회원의 체중, 골격근량, 체지방률 기록을 분석하여
 * 선형 회귀 + 가중 이동 평균 기반으로 미래 수치를 예측합니다.
 *
 * @fires https.onCall
 * @region asia-northeast3
 *
 * @param {Object} data - 요청 데이터
 * @param {string} data.memberId - 회원 ID (필수)
 * @param {number} [data.targetWeight] - 목표 체중 (선택)
 * @param {number} [data.targetMuscle] - 목표 골격근량 (선택)
 * @param {number} [data.targetBodyFat] - 목표 체지방률 (선택)
 *
 * @returns {Promise<BodyCompositionPredictionResponse>} 예측 결과
 */
export const predictBodyComposition = functions
  .region("asia-northeast3")
  .https.onCall(async (data, context) => {
    const startTime = Date.now();
    functions.logger.info("[predictBodyComposition] 함수 시작", {
      memberId: data?.memberId,
      callerUid: context.auth?.uid,
    });

    // 1. 인증 확인
    if (!context.auth) {
      functions.logger.warn("[predictBodyComposition] 인증되지 않은 요청");
      throw new functions.https.HttpsError(
        "unauthenticated",
        "로그인이 필요합니다."
      );
    }

    const userId = context.auth.uid;

    // 2. 입력 데이터 검증
    const {memberId, targetWeight, targetMuscle, targetBodyFat} = data || {};

    if (!memberId || typeof memberId !== "string") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "회원 ID가 필요합니다."
      );
    }

    try {
      // 3. 트레이너 정보 확인 (트레이너 또는 회원 모두 호출 가능)
      let trainerId: string;
      let trainerData: FirebaseFirestore.DocumentData;
      let trainerDoc: FirebaseFirestore.QueryDocumentSnapshot | FirebaseFirestore.DocumentSnapshot;

      const trainerSnapshot = await db
        .collection("trainers")
        .where("userId", "==", userId)
        .limit(1)
        .get();

      if (!trainerSnapshot.empty) {
        // 트레이너가 호출한 경우
        trainerDoc = trainerSnapshot.docs[0];
        trainerId = trainerDoc.id;
        trainerData = trainerDoc.data()!;
      } else {
        // 회원이 호출한 경우 - 회원의 trainerId로 트레이너 찾기
        const memberSnapshot = await db
          .collection("members")
          .where("userId", "==", userId)
          .limit(1)
          .get();

        if (memberSnapshot.empty) {
          throw new functions.https.HttpsError(
            "permission-denied",
            "사용자 정보를 찾을 수 없습니다."
          );
        }

        const memberDocData = memberSnapshot.docs[0].data();
        const memberTrainerId = memberDocData.trainerId;

        if (!memberTrainerId) {
          throw new functions.https.HttpsError(
            "failed-precondition",
            "트레이너가 배정되지 않았습니다."
          );
        }

        const trainerDocRef = await db.collection("trainers").doc(memberTrainerId).get();
        if (!trainerDocRef.exists) {
          throw new functions.https.HttpsError(
            "not-found",
            "트레이너 정보를 찾을 수 없습니다."
          );
        }

        trainerDoc = trainerDocRef;
        trainerId = memberTrainerId;
        trainerData = trainerDocRef.data()!;
      }

      // 4. 사용량 한도 체크 (현재 비활성화 - 테스트용)
      // const tier = trainerData.subscriptionTier || "free";
      const aiUsage = trainerData.aiUsage || {
        curriculumCount: 0,
        predictionCount: 0,
        resetDate: null,
      };

      // 리셋 날짜 확인
      let resetDate: Date;
      if (aiUsage.resetDate?.toDate) {
        resetDate = aiUsage.resetDate.toDate();
      } else if (aiUsage.resetDate) {
        resetDate = new Date(aiUsage.resetDate);
      } else {
        resetDate = new Date(0);
      }

      const now = new Date();
      const shouldReset =
        now.getMonth() !== resetDate.getMonth() ||
        now.getFullYear() !== resetDate.getFullYear();

      const currentPredictionCount = shouldReset
        ? 0
        : aiUsage.predictionCount || 0;

      // TODO: 테스트 완료 후 한도 체크 활성화

      // 5. 회원 정보 확인
      const memberDoc = await db.collection("members").doc(memberId).get();
      if (!memberDoc.exists) {
        throw new functions.https.HttpsError(
          "not-found",
          "회원 정보를 찾을 수 없습니다."
        );
      }

      const memberData = memberDoc.data()!;
      const memberTargetWeight = targetWeight ?? memberData.targetWeight ?? null;
      const memberTargetMuscle = targetMuscle ?? memberData.targetMuscle ?? null;
      const memberTargetBodyFat = targetBodyFat ?? memberData.targetBodyFat ?? null;

      // 6. 데이터 조회 기간 설정 (최근 6개월)
      const sixMonthsAgo = new Date();
      sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6);
      const sixMonthsAgoTimestamp = admin.firestore.Timestamp.fromDate(sixMonthsAgo);

      // 7. 체중 기록 조회 (body_records)
      let weightRecordsSnapshot;
      try {
        weightRecordsSnapshot = await db
          .collection("body_records")
          .where("memberId", "==", memberId)
          .where("recordDate", ">=", sixMonthsAgoTimestamp)
          .orderBy("recordDate", "asc")
          .get();
      } catch (queryError) {
        functions.logger.warn("[predictBodyComposition] body_records 조회 실패 (인덱스 필요할 수 있음)", {
          error: queryError instanceof Error ? queryError.message : queryError,
          memberId,
        });
        weightRecordsSnapshot = {docs: []};
      }

      /**
       * 안전한 날짜 변환 헬퍼 함수
       * Firestore Timestamp, Date, 또는 ISO 문자열을 Date로 변환
       */
      const safeToDate = (recordDate: unknown): Date | null => {
        try {
          if (!recordDate) return null;
          // Firestore Timestamp
          if (typeof recordDate === "object" && recordDate !== null && "toDate" in recordDate) {
            return (recordDate as admin.firestore.Timestamp).toDate();
          }
          // 이미 Date 객체인 경우
          if (recordDate instanceof Date) {
            return recordDate;
          }
          // ISO 문자열 또는 숫자
          if (typeof recordDate === "string" || typeof recordDate === "number") {
            const parsed = new Date(recordDate);
            return isNaN(parsed.getTime()) ? null : parsed;
          }
          return null;
        } catch (e) {
          functions.logger.debug("[predictBodyComposition] 날짜 변환 실패", {
            recordDate,
            error: e instanceof Error ? e.message : e,
          });
          return null;
        }
      };

      const weightData: WeightDataPoint[] = weightRecordsSnapshot.docs
        .map((doc) => {
          const docData = doc.data();
          const date = safeToDate(docData.recordDate);
          if (!date || typeof docData.weight !== "number") {
            return null;
          }
          return {
            date,
            weight: docData.weight,
          };
        })
        .filter((item): item is WeightDataPoint => item !== null);

      // body_records에서 골격근량/체지방률도 추출 (inbody_records가 없는 경우 fallback)
      const bodyRecordMuscleData: WeightDataPoint[] = weightRecordsSnapshot.docs
        .map((doc) => {
          const docData = doc.data();
          const date = safeToDate(docData.recordDate);
          if (!date || typeof docData.muscleMass !== "number") {
            return null;
          }
          return {date, weight: docData.muscleMass};
        })
        .filter((item): item is WeightDataPoint => item !== null);

      const bodyRecordFatData: WeightDataPoint[] = weightRecordsSnapshot.docs
        .map((doc) => {
          const docData = doc.data();
          const date = safeToDate(docData.recordDate);
          if (!date || typeof docData.bodyFatPercent !== "number") {
            return null;
          }
          return {date, weight: docData.bodyFatPercent};
        })
        .filter((item): item is WeightDataPoint => item !== null);

      // 8. InBody 기록 조회 (inbody_records)
      let inbodyRecordsSnapshot;
      try {
        inbodyRecordsSnapshot = await db
          .collection("inbody_records")
          .where("memberId", "==", memberId)
          .where("recordDate", ">=", sixMonthsAgoTimestamp)
          .orderBy("recordDate", "asc")
          .get();
      } catch (queryError) {
        functions.logger.warn("[predictBodyComposition] inbody_records 조회 실패 (인덱스 필요할 수 있음)", {
          error: queryError instanceof Error ? queryError.message : queryError,
          memberId,
        });
        inbodyRecordsSnapshot = {docs: []};
      }

      const muscleData: WeightDataPoint[] = [];
      const bodyFatData: WeightDataPoint[] = [];

      inbodyRecordsSnapshot.docs.forEach((doc) => {
        const docData = doc.data();
        // recordDate를 안전하게 변환
        const recordDate = safeToDate(docData.recordDate);
        if (!recordDate) {
          functions.logger.debug("[predictBodyComposition] InBody 레코드 날짜 변환 실패, 스킵", {
            docId: doc.id,
          });
          return;
        }

        // 골격근량 데이터
        if (typeof docData.skeletalMuscleMass === "number") {
          muscleData.push({
            date: recordDate,
            weight: docData.skeletalMuscleMass,
          });
        }

        // 체지방률 데이터
        if (typeof docData.bodyFatPercent === "number") {
          bodyFatData.push({
            date: recordDate,
            weight: docData.bodyFatPercent,
          });
        }
      });

      // body_records 데이터를 fallback으로 병합 (inbody_records에 데이터가 없는 경우)
      if (muscleData.length < MIN_DATA_POINTS && bodyRecordMuscleData.length > 0) {
        muscleData.push(...bodyRecordMuscleData);
      }
      if (bodyFatData.length < MIN_DATA_POINTS && bodyRecordFatData.length > 0) {
        bodyFatData.push(...bodyRecordFatData);
      }

      functions.logger.info("[predictBodyComposition] 데이터 조회 완료", {
        memberId,
        weightRecordCount: weightData.length,
        muscleRecordCount: muscleData.length,
        bodyFatRecordCount: bodyFatData.length,
      });

      // 9. 최소 하나의 메트릭에 대한 데이터가 있는지 확인
      if (
        weightData.length < MIN_DATA_POINTS &&
        muscleData.length < MIN_DATA_POINTS &&
        bodyFatData.length < MIN_DATA_POINTS
      ) {
        throw new functions.https.HttpsError(
          "failed-precondition",
          `체성분 예측을 위해 최소 ${MIN_DATA_POINTS}개 이상의 기록이 필요합니다. ` +
            `현재 체중 ${weightData.length}개, 골격근량 ${muscleData.length}개, ` +
            `체지방률 ${bodyFatData.length}개의 기록이 있습니다.`
        );
      }

      // 10. 각 메트릭별 예측 계산
      const weightPrediction = calculateMetricPrediction(
        weightData,
        memberTargetWeight
      );
      const musclePrediction = calculateMetricPrediction(
        muscleData,
        memberTargetMuscle
      );
      const bodyFatPrediction = calculateMetricPrediction(
        bodyFatData,
        memberTargetBodyFat
      );

      const predictions = {
        weight: weightPrediction,
        skeletalMuscleMass: musclePrediction,
        bodyFatPercent: bodyFatPrediction,
      };

      // 11. 분석 메시지 생성
      const analysisMessage = generateCompositionAnalysisMessage(predictions);

      // 12. 데이터 포인트 수 집계
      const dataPointsUsed = {
        weight: weightData.length,
        muscle: muscleData.length,
        bodyFat: bodyFatData.length,
      };

      functions.logger.info("[predictBodyComposition] 예측 계산 완료", {
        hasWeightPrediction: weightPrediction !== null,
        hasMusclePrediction: musclePrediction !== null,
        hasBodyFatPrediction: bodyFatPrediction !== null,
        analysisMessage,
      });

      // 13. 예측 결과 Firestore 저장
      const predictionData = {
        memberId,
        trainerId,
        type: "body_composition",
        predictions,
        analysisMessage,
        dataPointsUsed,
        createdAt: admin.firestore.Timestamp.now(),
      };

      const predictionRef = await db.collection("predictions").add(predictionData);

      functions.logger.info("[predictBodyComposition] 예측 저장 완료", {
        predictionId: predictionRef.id,
      });

      // 14. 트레이너 AI 사용량 업데이트
      const updateData: Record<string, unknown> = {
        "aiUsage.predictionCount": currentPredictionCount + 1,
      };
      if (shouldReset) {
        updateData["aiUsage.resetDate"] = admin.firestore.Timestamp.now();
        updateData["aiUsage.curriculumCount"] = 0;
      }

      await trainerDoc.ref.update(updateData);

      const duration = Date.now() - startTime;
      functions.logger.info("[predictBodyComposition] 함수 완료", {
        memberId,
        predictionId: predictionRef.id,
        dataPointsUsed,
        durationMs: duration,
      });

      // 15. 결과 반환
      const response: BodyCompositionPredictionResponse = {
        success: true,
        predictions,
        analysisMessage,
        dataPointsUsed,
        createdAt: admin.firestore.Timestamp.now(),
      };

      return response;
    } catch (error) {
      const duration = Date.now() - startTime;

      // 에러 타입에 따른 상세 로깅
      let errorType = "unknown";
      let errorDetail = "";
      if (error instanceof Error) {
        errorDetail = error.message;
        if (error.message.includes("index")) {
          errorType = "missing_index";
        } else if (error.message.includes("permission")) {
          errorType = "permission_denied";
        } else if (error.message.includes("toDate")) {
          errorType = "date_conversion";
        } else if (error.message.includes("network") || error.message.includes("UNAVAILABLE")) {
          errorType = "network";
        }
      }

      functions.logger.error("[predictBodyComposition] 오류 발생", {
        errorType,
        error: error instanceof Error ? error.message : error,
        stack: error instanceof Error ? error.stack : undefined,
        memberId,
        durationMs: duration,
      });

      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      // 사용자 친화적 에러 메시지 생성
      let userMessage = "체성분 예측 처리 중 오류가 발생했습니다.";
      if (errorType === "missing_index") {
        userMessage = "데이터베이스 설정 문제가 발생했습니다. 관리자에게 문의해주세요.";
      } else if (errorType === "network") {
        userMessage = "네트워크 연결에 문제가 있습니다. 잠시 후 다시 시도해주세요.";
      } else if (errorType === "date_conversion") {
        userMessage = "데이터 형식에 문제가 있습니다. 관리자에게 문의해주세요.";
      } else {
        userMessage = `체성분 예측 처리 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요. (${errorDetail || "알 수 없는 오류"})`;
      }

      throw new functions.https.HttpsError("internal", userMessage);
    }
  });
