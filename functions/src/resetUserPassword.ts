import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * 비밀번호 직접 재설정 Cloud Function
 * 이메일과 새 비밀번호를 받아 Admin SDK로 비밀번호 변경
 */
export const resetUserPassword = functions
  .region("asia-northeast3")
  .https.onCall(
    async (data: {email: string; newPassword: string}) => {
      console.log("resetUserPassword called with data:", JSON.stringify(data));

      const {email, newPassword} = data;

      console.log("Parsed email:", email, "password length:", newPassword?.length);

      // 입력값 검증
      if (!email || !newPassword) {
        console.log("Validation failed: missing email or password");
        throw new functions.https.HttpsError(
          "invalid-argument",
          "이메일과 새 비밀번호를 입력해주세요."
        );
      }

      if (newPassword.length < 6) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "비밀번호는 6자 이상이어야 해요."
        );
      }

      try {
        // 이메일로 사용자 찾기
        console.log("Looking up user by email:", email.trim());
        const userRecord = await admin.auth().getUserByEmail(email.trim());
        console.log("User found:", userRecord.uid);

        // 비밀번호 변경
        await admin.auth().updateUser(userRecord.uid, {
          password: newPassword,
        });
        console.log("Password updated successfully for:", userRecord.uid);

        return {success: true, message: "비밀번호가 변경되었어요."};
      } catch (error: unknown) {
        console.error("resetUserPassword error:", error);
        const firebaseError = error as {code?: string; message?: string};
        if (firebaseError.code === "auth/user-not-found") {
          throw new functions.https.HttpsError(
            "not-found",
            "등록되지 않은 이메일이에요."
          );
        }
        throw new functions.https.HttpsError(
          "internal",
          `비밀번호 변경 중 문제가 생겼어요: ${firebaseError.message || "알 수 없는 오류"}`
        );
      }
    }
  );
