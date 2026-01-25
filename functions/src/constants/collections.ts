/**
 * Firestore 컬렉션명 상수
 */
export const Collections = {
  USERS: "users",
  TRAINERS: "trainers",
  MEMBERS: "members",
  SCHEDULES: "schedules",
  EXERCISES: "exercises",
  INSIGHTS: "insights",
  BODY_RECORDS: "body_records",
  DIETS: "diets",
  DIET_RECORDS: "diet_records",
  CHAT_ROOMS: "chat_rooms",
  MESSAGES: "messages",
  CURRICULUMS: "curriculums",
  PREDICTIONS: "predictions",
  INBODY_RECORDS: "inbody_records",
  SESSIONS: "sessions",
  BADGES: "badges",
  NOTIFICATIONS: "notifications",
} as const;

export type CollectionName = typeof Collections[keyof typeof Collections];
