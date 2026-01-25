/**
 * 에러 코드 상수
 */
export const ErrorCodes = {
  // Auth
  AUTH_REQUIRED: "auth_required",
  INVALID_TOKEN: "invalid_token",
  PERMISSION_DENIED: "permission_denied",

  // Validation
  INVALID_INPUT: "invalid_input",
  MISSING_FIELD: "missing_field",

  // Resource
  NOT_FOUND: "not_found",
  ALREADY_EXISTS: "already_exists",

  // Quota
  QUOTA_EXCEEDED: "quota_exceeded",

  // External
  AI_SERVICE_ERROR: "ai_service_error",
  FIRESTORE_ERROR: "firestore_error",
  FCM_ERROR: "fcm_error",
} as const;

export type ErrorCode = typeof ErrorCodes[keyof typeof ErrorCodes];
