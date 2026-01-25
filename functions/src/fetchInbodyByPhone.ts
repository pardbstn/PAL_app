/**
 * LookinBody API를 통한 InBody 데이터 조회 Cloud Function
 * 전화번호를 기반으로 LookinBody Korea API에서 InBody 측정 데이터를 가져옵니다.
 *
 * @module fetchInbodyByPhone
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {db} from "./utils/firestore";
import {Collections} from "./constants/collections";
import {requireAuth} from "./middleware/auth";

// LookinBody Korea API 설정
const LOOKINBODY_API_BASE_URL = "https://apikr.lookinbody.com";
const LOOKINBODY_ACCOUNT_ID = "10lys0404";

// API 응답 타입 정의
interface LookinBodyApiResponse {
  success: boolean;
  data?: LookinBodyMeasurement[];
  error?: string;
  message?: string;
}

interface LookinBodyMeasurement {
  EquipSerial?: string;
  TelHP?: string;
  UserID?: string;
  TestDatetimes?: string;
  Account?: string;
  Equip?: string;
  Type?: string;
  IsTempData?: string;
  // InBody 측정 데이터
  Weight?: string;
  SMM?: string; // 골격근량
  BFM?: string; // 체지방량
  PBF?: string; // 체지방률
  BMI?: string;
  BMR?: string; // 기초대사량
  InBodyScore?: string;
  // 부위별 근육량
  RightArmMuscle?: string;
  LeftArmMuscle?: string;
  TrunkMuscle?: string;
  RightLegMuscle?: string;
  LeftLegMuscle?: string;
  // 부위별 체지방량
  RightArmFat?: string;
  LeftArmFat?: string;
  TrunkFat?: string;
  RightLegFat?: string;
  LeftLegFat?: string;
  // 체수분
  TBW?: string; // 체수분량
  ICW?: string; // 세포내수분
  ECW?: string; // 세포외수분
  // 기타
  Protein?: string;
  Minerals?: string;
  WHR?: string; // 복부지방률
  VFL?: string; // 내장지방레벨
}

// Flutter로 반환할 정제된 InBody 데이터 타입
interface InBodyData {
  measuredAt: string;
  source: string;
  equipSerial: string | null;
  equipModel: string | null;
  // 기본 측정값
  weight: number | null;
  skeletalMuscleMass: number | null;
  bodyFatMass: number | null;
  bodyFatPercentage: number | null;
  bmi: number | null;
  basalMetabolicRate: number | null;
  inbodyScore: number | null;
  // 부위별 근육량
  segmentalMuscle: {
    rightArm: number | null;
    leftArm: number | null;
    trunk: number | null;
    rightLeg: number | null;
    leftLeg: number | null;
  };
  // 부위별 체지방량
  segmentalFat: {
    rightArm: number | null;
    leftArm: number | null;
    trunk: number | null;
    rightLeg: number | null;
    leftLeg: number | null;
  };
  // 체수분
  totalBodyWater: number | null;
  intracellularWater: number | null;
  extracellularWater: number | null;
  // 기타
  protein: number | null;
  minerals: number | null;
  waistHipRatio: number | null;
  visceralFatLevel: number | null;
}

// 요청 파라미터 타입
interface FetchInbodyRequest {
  phone: string;
  memberId: string;
  startDate?: string; // YYYYMMDD 형식
  endDate?: string; // YYYYMMDD 형식
  saveToFirestore?: boolean; // 기본값 true
}

// 응답 타입
interface FetchInbodyResponse {
  success: boolean;
  data: InBodyData[];
  savedCount: number;
  message: string;
}

/**
 * 전화번호 정규화 (하이픈 제거, 01012345678 형식으로)
 */
function normalizePhoneNumber(phone: string): string {
  return phone.replace(/[^0-9]/g, "");
}

/**
 * 날짜 파싱 (20190811120103 -> ISO 문자열)
 */
function parseTestDatetime(datetime: string): string {
  const year = parseInt(datetime.substring(0, 4));
  const month = parseInt(datetime.substring(4, 6)) - 1;
  const day = parseInt(datetime.substring(6, 8));
  const hour = parseInt(datetime.substring(8, 10)) || 0;
  const minute = parseInt(datetime.substring(10, 12)) || 0;
  const second = parseInt(datetime.substring(12, 14)) || 0;
  const date = new Date(year, month, day, hour, minute, second);
  return date.toISOString();
}

/**
 * 안전하게 숫자 파싱
 */
function safeParseFloat(value: string | undefined): number | null {
  if (!value) return null;
  const parsed = parseFloat(value);
  return isNaN(parsed) ? null : parsed;
}

/**
 * LookinBody API 응답을 정제된 InBodyData로 변환
 */
function transformMeasurement(measurement: LookinBodyMeasurement): InBodyData {
  return {
    measuredAt: measurement.TestDatetimes
      ? parseTestDatetime(measurement.TestDatetimes)
      : new Date().toISOString(),
    source: "lookinbody_api",
    equipSerial: measurement.EquipSerial || null,
    equipModel: measurement.Equip || null,
    // 기본 측정값
    weight: safeParseFloat(measurement.Weight),
    skeletalMuscleMass: safeParseFloat(measurement.SMM),
    bodyFatMass: safeParseFloat(measurement.BFM),
    bodyFatPercentage: safeParseFloat(measurement.PBF),
    bmi: safeParseFloat(measurement.BMI),
    basalMetabolicRate: safeParseFloat(measurement.BMR),
    inbodyScore: safeParseFloat(measurement.InBodyScore),
    // 부위별 근육량
    segmentalMuscle: {
      rightArm: safeParseFloat(measurement.RightArmMuscle),
      leftArm: safeParseFloat(measurement.LeftArmMuscle),
      trunk: safeParseFloat(measurement.TrunkMuscle),
      rightLeg: safeParseFloat(measurement.RightLegMuscle),
      leftLeg: safeParseFloat(measurement.LeftLegMuscle),
    },
    // 부위별 체지방량
    segmentalFat: {
      rightArm: safeParseFloat(measurement.RightArmFat),
      leftArm: safeParseFloat(measurement.LeftArmFat),
      trunk: safeParseFloat(measurement.TrunkFat),
      rightLeg: safeParseFloat(measurement.RightLegFat),
      leftLeg: safeParseFloat(measurement.LeftLegFat),
    },
    // 체수분
    totalBodyWater: safeParseFloat(measurement.TBW),
    intracellularWater: safeParseFloat(measurement.ICW),
    extracellularWater: safeParseFloat(measurement.ECW),
    // 기타
    protein: safeParseFloat(measurement.Protein),
    minerals: safeParseFloat(measurement.Minerals),
    waistHipRatio: safeParseFloat(measurement.WHR),
    visceralFatLevel: safeParseFloat(measurement.VFL),
  };
}

/**
 * InBody 데이터를 Firestore에 저장
 */
async function saveInbodyRecord(
  memberId: string,
  trainerId: string | null,
  inbodyData: InBodyData,
  rawData: LookinBodyMeasurement
): Promise<string> {
  const inbodyRecord = {
    memberId,
    trainerId,
    measuredAt: admin.firestore.Timestamp.fromDate(new Date(inbodyData.measuredAt)),
    source: inbodyData.source,
    equipSerial: inbodyData.equipSerial,
    equipModel: inbodyData.equipModel,
    // 기본 측정값
    weight: inbodyData.weight,
    skeletalMuscleMass: inbodyData.skeletalMuscleMass,
    bodyFatMass: inbodyData.bodyFatMass,
    bodyFatPercentage: inbodyData.bodyFatPercentage,
    bmi: inbodyData.bmi,
    basalMetabolicRate: inbodyData.basalMetabolicRate,
    inbodyScore: inbodyData.inbodyScore,
    // 부위별 데이터
    segmentalMuscle: inbodyData.segmentalMuscle,
    segmentalFat: inbodyData.segmentalFat,
    // 체수분
    totalBodyWater: inbodyData.totalBodyWater,
    intracellularWater: inbodyData.intracellularWater,
    extracellularWater: inbodyData.extracellularWater,
    // 기타
    protein: inbodyData.protein,
    minerals: inbodyData.minerals,
    waistHipRatio: inbodyData.waistHipRatio,
    visceralFatLevel: inbodyData.visceralFatLevel,
    // 메타데이터
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    rawPayload: rawData,
  };

  const docRef = await db.collection(Collections.INBODY_RECORDS).add(inbodyRecord);
  return docRef.id;
}

/**
 * LookinBody API를 통해 전화번호로 InBody 데이터 조회
 *
 * @description
 * LookinBody Korea API를 호출하여 특정 전화번호의 InBody 측정 데이터를 가져옵니다.
 * 조회된 데이터는 Firestore에 저장할 수 있습니다.
 *
 * @fires https.onCall
 * @region asia-northeast3
 *
 * @param {Object} data - 요청 데이터
 * @param {string} data.phone - 조회할 전화번호 (하이픈 포함/미포함 모두 가능)
 * @param {string} data.memberId - PAL 회원 ID
 * @param {string} [data.startDate] - 조회 시작일 (YYYYMMDD 형식)
 * @param {string} [data.endDate] - 조회 종료일 (YYYYMMDD 형식)
 * @param {boolean} [data.saveToFirestore=true] - Firestore 저장 여부
 *
 * @returns {Promise<FetchInbodyResponse>} InBody 측정 데이터 목록
 *
 * @throws {HttpsError} unauthenticated - 로그인 필요
 * @throws {HttpsError} invalid-argument - 필수 파라미터 누락
 * @throws {HttpsError} not-found - 회원 정보 없음
 * @throws {HttpsError} internal - API 호출 실패
 */
export const fetchInbodyByPhone = functions
  .region("asia-northeast3")
  .runWith({
    secrets: ["LOOKINBODY_API_KEY"],
  })
  .https.onCall(async (data: FetchInbodyRequest, context): Promise<FetchInbodyResponse> => {
    const startTime = Date.now();

    functions.logger.info("[fetchInbodyByPhone] 함수 시작", {
      callerUid: context.auth?.uid,
      phone: data.phone ? `${data.phone.substring(0, 3)}****` : "없음",
      memberId: data.memberId,
    });

    // 1. 인증 확인
    requireAuth(context);

    // 2. 필수 파라미터 검증
    const {phone, memberId, startDate, endDate, saveToFirestore = true} = data;

    if (!phone) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "전화번호를 입력해주세요."
      );
    }

    if (!memberId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "회원 ID를 입력해주세요."
      );
    }

    const normalizedPhone = normalizePhoneNumber(phone);

    if (normalizedPhone.length < 10 || normalizedPhone.length > 11) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "올바른 전화번호 형식이 아닙니다."
      );
    }

    try {
      // 3. API 키 확인
      const apiKey = process.env.LOOKINBODY_API_KEY;
      if (!apiKey) {
        functions.logger.error("[fetchInbodyByPhone] API 키 미설정");
        throw new functions.https.HttpsError(
          "failed-precondition",
          "LookinBody API 설정이 완료되지 않았습니다. 관리자에게 문의해주세요."
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

      const memberData = memberDoc.data();
      const trainerId = memberData?.trainerId || null;

      // 5. LookinBody API 호출
      functions.logger.info("[fetchInbodyByPhone] LookinBody API 호출", {
        phone: `${normalizedPhone.substring(0, 3)}****`,
        startDate,
        endDate,
      });

      // API 요청 파라미터 구성
      const apiParams = new URLSearchParams({
        account: LOOKINBODY_ACCOUNT_ID,
        phone: normalizedPhone,
      });

      if (startDate) {
        apiParams.append("startDate", startDate);
      }
      if (endDate) {
        apiParams.append("endDate", endDate);
      }

      const apiUrl = `${LOOKINBODY_API_BASE_URL}/api/v1/measurements?${apiParams.toString()}`;

      const apiResponse = await fetch(apiUrl, {
        method: "GET",
        headers: {
          "Authorization": `Bearer ${apiKey}`,
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      });

      functions.logger.info("[fetchInbodyByPhone] API 응답 수신", {
        status: apiResponse.status,
        statusText: apiResponse.statusText,
      });

      if (!apiResponse.ok) {
        const errorText = await apiResponse.text();
        functions.logger.error("[fetchInbodyByPhone] API 오류 응답", {
          status: apiResponse.status,
          errorText,
        });

        if (apiResponse.status === 401) {
          throw new functions.https.HttpsError(
            "permission-denied",
            "LookinBody API 인증에 실패했습니다."
          );
        }

        if (apiResponse.status === 404) {
          // 데이터 없음은 정상 응답으로 처리
          return {
            success: true,
            data: [],
            savedCount: 0,
            message: "해당 전화번호로 등록된 InBody 측정 데이터가 없습니다.",
          };
        }

        throw new functions.https.HttpsError(
          "internal",
          `LookinBody API 호출 실패: ${apiResponse.status} ${apiResponse.statusText}`
        );
      }

      const responseData: LookinBodyApiResponse = await apiResponse.json();

      functions.logger.info("[fetchInbodyByPhone] API 데이터 파싱 완료", {
        success: responseData.success,
        dataCount: responseData.data?.length || 0,
      });

      if (!responseData.success || !responseData.data) {
        return {
          success: true,
          data: [],
          savedCount: 0,
          message: responseData.message || "InBody 측정 데이터가 없습니다.",
        };
      }

      // 6. 데이터 변환
      const transformedData: InBodyData[] = responseData.data.map(transformMeasurement);

      // 7. Firestore 저장 (옵션)
      let savedCount = 0;
      if (saveToFirestore && transformedData.length > 0) {
        // 기존 데이터 중복 확인을 위해 최근 기록 조회
        const existingRecords = await db
          .collection(Collections.INBODY_RECORDS)
          .where("memberId", "==", memberId)
          .where("source", "==", "lookinbody_api")
          .orderBy("measuredAt", "desc")
          .limit(100)
          .get();

        const existingDates = new Set<string>();
        existingRecords.docs.forEach((doc) => {
          const data = doc.data();
          if (data.measuredAt) {
            existingDates.add(data.measuredAt.toDate().toISOString());
          }
        });

        // 중복되지 않는 데이터만 저장
        for (let i = 0; i < transformedData.length; i++) {
          const inbodyData = transformedData[i];
          if (!existingDates.has(inbodyData.measuredAt)) {
            await saveInbodyRecord(
              memberId,
              trainerId,
              inbodyData,
              responseData.data[i]
            );
            savedCount++;
          }
        }

        functions.logger.info("[fetchInbodyByPhone] Firestore 저장 완료", {
          totalData: transformedData.length,
          newlySaved: savedCount,
          skippedDuplicates: transformedData.length - savedCount,
        });
      }

      const duration = Date.now() - startTime;
      functions.logger.info("[fetchInbodyByPhone] 함수 완료", {
        dataCount: transformedData.length,
        savedCount,
        durationMs: duration,
      });

      return {
        success: true,
        data: transformedData,
        savedCount,
        message: transformedData.length > 0
          ? `${transformedData.length}건의 InBody 데이터를 조회했습니다.${savedCount > 0 ? ` (${savedCount}건 신규 저장)` : ""}`
          : "해당 전화번호로 등록된 InBody 측정 데이터가 없습니다.",
      };
    } catch (error) {
      functions.logger.error("[fetchInbodyByPhone] 오류 발생", {
        error: error instanceof Error ? error.message : error,
        stack: error instanceof Error ? error.stack : undefined,
      });

      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      const errorMessage = error instanceof Error ? error.message : "알 수 없는 오류";
      throw new functions.https.HttpsError(
        "internal",
        `InBody 데이터 조회 중 오류가 발생했습니다: ${errorMessage}`
      );
    }
  });
