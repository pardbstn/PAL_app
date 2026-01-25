/**
 * 소셜 로그인 커스텀 토큰 생성
 * Kakao, Naver 로그인을 위한 Firebase Custom Token 생성
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

interface SocialLoginRequest {
  provider: "kakao" | "naver";
  userId: string;
  email?: string;
  name?: string;
  profileImage?: string;
}

/**
 * 소셜 로그인용 Firebase Custom Token 생성
 */
export const createCustomToken = functions
  .region("asia-northeast3")
  .https.onCall(async (data: SocialLoginRequest, context) => {
    const {provider, userId, email, name, profileImage} = data;

    if (!provider || !userId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "provider와 userId가 필요합니다."
      );
    }

    // 고유 Firebase UID 생성 (provider:userId 형식)
    const firebaseUid = `${provider}:${userId}`;

    try {
      // 기존 사용자 확인 또는 생성
      let userRecord: admin.auth.UserRecord;

      try {
        userRecord = await admin.auth().getUser(firebaseUid);
        functions.logger.info(`기존 사용자 발견: ${firebaseUid}`);
      } catch (error: unknown) {
        const authError = error as { code?: string };
        if (authError.code === "auth/user-not-found") {
          // 새 사용자 생성 시도
          try {
            userRecord = await admin.auth().createUser({
              uid: firebaseUid,
              email: email || undefined,
              displayName: name || undefined,
              photoURL: profileImage || undefined,
            });
            functions.logger.info(`새 사용자 생성: ${firebaseUid}`);
          } catch (createError: unknown) {
            const createAuthError = createError as { code?: string };
            // 이메일 충돌 시 이메일 없이 생성
            if (createAuthError.code === "auth/email-already-exists") {
              functions.logger.info(`이메일 충돌, 이메일 없이 생성: ${firebaseUid}`);
              userRecord = await admin.auth().createUser({
                uid: firebaseUid,
                displayName: name || undefined,
                photoURL: profileImage || undefined,
              });
            } else {
              throw createError;
            }
          }
        } else {
          throw error;
        }
      }

      // Custom Token 생성
      const customToken = await admin.auth().createCustomToken(firebaseUid, {
        provider,
        socialUserId: userId,
      });

      functions.logger.info(`Custom token 생성 완료: ${firebaseUid}`);

      return {
        success: true,
        customToken,
        uid: userRecord.uid,
      };
    } catch (error) {
      functions.logger.error("Custom token 생성 실패:", error);
      throw new functions.https.HttpsError(
        "internal",
        "토큰 생성에 실패했습니다."
      );
    }
  });
