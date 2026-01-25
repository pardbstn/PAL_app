import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {db} from "./utils/firestore";
import {Collections} from "./constants/collections";

// LookinBody 웹훅 페이로드 타입
interface LookinBodyPayload {
  EquipSerial: string;
  TelHP: string;
  UserID: string;
  TestDatetimes: string;
  Account: string;
  Equip: string;
  Type: string;
  IsTempData: string;
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

// 전화번호 정규화 (하이픈 제거, 01012345678 형식으로)
function normalizePhoneNumber(phone: string): string {
  return phone.replace(/[^0-9]/g, "");
}

// 날짜 파싱 (20190811120103 -> Date)
function parseTestDatetime(datetime: string): Date {
  const year = parseInt(datetime.substring(0, 4));
  const month = parseInt(datetime.substring(4, 6)) - 1;
  const day = parseInt(datetime.substring(6, 8));
  const hour = parseInt(datetime.substring(8, 10));
  const minute = parseInt(datetime.substring(10, 12));
  const second = parseInt(datetime.substring(12, 14));
  return new Date(year, month, day, hour, minute, second);
}

// 안전하게 숫자 파싱
function safeParseFloat(value: string | undefined): number | null {
  if (!value) return null;
  const parsed = parseFloat(value);
  return isNaN(parsed) ? null : parsed;
}

/**
 * LookinBody InBody 웹훅 수신 Cloud Function
 *
 * LookinBody에서 측정 완료 시 이 엔드포인트로 POST 요청을 보냄
 */
export const inbodyWebhook = functions
  .region("asia-northeast3")
  .https.onRequest(async (req, res) => {
    // CORS 헤더 설정
    res.set("Access-Control-Allow-Origin", "*");
    res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
    res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");

    // Preflight 요청 처리
    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }

    // POST만 허용
    if (req.method !== "POST") {
      res.status(405).json({error: "Method not allowed"});
      return;
    }

    try {
      const payload = req.body as LookinBodyPayload;

      console.log("LookinBody 웹훅 수신:", JSON.stringify(payload, null, 2));

      // 필수 필드 검증
      if (!payload.TelHP || !payload.TestDatetimes) {
        console.error("필수 필드 누락:", payload);
        res.status(400).json({error: "Missing required fields: TelHP, TestDatetimes"});
        return;
      }

      // 전화번호로 회원 찾기
      const normalizedPhone = normalizePhoneNumber(payload.TelHP);

      const membersSnapshot = await db.collection(Collections.MEMBERS)
        .where("phone", "==", normalizedPhone)
        .limit(1)
        .get();

      if (membersSnapshot.empty) {
        // 하이픈 포함된 형식도 시도
        const formattedPhone = normalizedPhone.replace(
          /(\d{3})(\d{4})(\d{4})/,
          "$1-$2-$3"
        );
        const membersSnapshot2 = await db.collection(Collections.MEMBERS)
          .where("phone", "==", formattedPhone)
          .limit(1)
          .get();

        if (membersSnapshot2.empty) {
          console.log("회원을 찾을 수 없음:", normalizedPhone);
          // 성공 응답 반환 (LookinBody는 200을 기대)
          res.status(200).json({
            success: false,
            message: "Member not found",
            phone: normalizedPhone,
          });
          return;
        }

        membersSnapshot.docs.push(...membersSnapshot2.docs);
      }

      const memberDoc = membersSnapshot.docs[0];
      const memberData = memberDoc.data();
      const memberId = memberDoc.id;

      // 측정 날짜 파싱
      const measuredAt = parseTestDatetime(payload.TestDatetimes);

      // InBody 기록 생성
      const inbodyRecord = {
        memberId: memberId,
        trainerId: memberData.trainerId || null,
        measuredAt: admin.firestore.Timestamp.fromDate(measuredAt),
        source: "lookinbody_webhook",
        equipSerial: payload.EquipSerial || null,
        equipModel: payload.Equip || null,

        // 기본 측정값
        weight: safeParseFloat(payload.Weight),
        skeletalMuscleMass: safeParseFloat(payload.SMM),
        bodyFatMass: safeParseFloat(payload.BFM),
        bodyFatPercentage: safeParseFloat(payload.PBF),
        bmi: safeParseFloat(payload.BMI),
        basalMetabolicRate: safeParseFloat(payload.BMR),
        inbodyScore: safeParseFloat(payload.InBodyScore),

        // 부위별 근육량
        segmentalMuscle: {
          rightArm: safeParseFloat(payload.RightArmMuscle),
          leftArm: safeParseFloat(payload.LeftArmMuscle),
          trunk: safeParseFloat(payload.TrunkMuscle),
          rightLeg: safeParseFloat(payload.RightLegMuscle),
          leftLeg: safeParseFloat(payload.LeftLegMuscle),
        },

        // 부위별 체지방량
        segmentalFat: {
          rightArm: safeParseFloat(payload.RightArmFat),
          leftArm: safeParseFloat(payload.LeftArmFat),
          trunk: safeParseFloat(payload.TrunkFat),
          rightLeg: safeParseFloat(payload.RightLegFat),
          leftLeg: safeParseFloat(payload.LeftLegFat),
        },

        // 체수분
        totalBodyWater: safeParseFloat(payload.TBW),
        intracellularWater: safeParseFloat(payload.ICW),
        extracellularWater: safeParseFloat(payload.ECW),

        // 기타
        protein: safeParseFloat(payload.Protein),
        minerals: safeParseFloat(payload.Minerals),
        waistHipRatio: safeParseFloat(payload.WHR),
        visceralFatLevel: safeParseFloat(payload.VFL),

        // 메타데이터
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        rawPayload: payload, // 원본 데이터 보관
      };

      // Firestore에 저장
      const docRef = await db.collection(Collections.INBODY_RECORDS).add(inbodyRecord);

      console.log("InBody 기록 저장 완료:", {
        docId: docRef.id,
        memberId: memberId,
        memberName: memberData.name,
        measuredAt: measuredAt.toISOString(),
      });

      // 회원에게 푸시 알림 전송 (선택적)
      if (memberData.userId) {
        const userDoc = await db.collection(Collections.USERS).doc(memberData.userId).get();
        if (userDoc.exists) {
          const userData = userDoc.data();
          const fcmToken = userData?.fcmToken;

          if (fcmToken) {
            try {
              await admin.messaging().send({
                token: fcmToken,
                notification: {
                  title: "인바디 측정 완료",
                  body: "새로운 인바디 측정 결과가 등록되었습니다.",
                },
                data: {
                  type: "inbody_recorded",
                  recordId: docRef.id,
                },
              });
              console.log("푸시 알림 전송 완료:", memberData.userId);
            } catch (notifError) {
              console.error("푸시 알림 전송 실패:", notifError);
            }
          }
        }
      }

      res.status(200).json({
        success: true,
        recordId: docRef.id,
        memberId: memberId,
        memberName: memberData.name,
      });
    } catch (error) {
      console.error("InBody 웹훅 처리 오류:", error);
      res.status(500).json({
        error: "Internal server error",
        message: error instanceof Error ? error.message : "Unknown error",
      });
    }
  });
