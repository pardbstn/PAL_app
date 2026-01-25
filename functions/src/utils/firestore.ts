import * as admin from "firebase-admin";

/**
 * 공유 Firestore 인스턴스
 */
export const db = admin.firestore();

/**
 * 단일 문서 조회
 */
export const getDoc = async <T>(
  collection: string,
  id: string
): Promise<(T & {id: string}) | null> => {
  const doc = await db.collection(collection).doc(id).get();
  return doc.exists ? ({id: doc.id, ...doc.data()} as T & {id: string}) : null;
};

/**
 * 문서 생성/업데이트 (merge)
 */
export const setDoc = async <T extends Record<string, unknown>>(
  collection: string,
  id: string,
  data: T
): Promise<void> => {
  await db.collection(collection).doc(id).set(data, {merge: true});
};

/**
 * 문서 추가 (자동 ID)
 */
export const addDoc = async <T extends Record<string, unknown>>(
  collection: string,
  data: T
): Promise<string> => {
  const ref = await db.collection(collection).add(data);
  return ref.id;
};

/**
 * 조건부 문서 쿼리
 */
export const queryDocs = async <T>(
  collection: string,
  conditions: [string, FirebaseFirestore.WhereFilterOp, unknown][]
): Promise<(T & {id: string})[]> => {
  let query: FirebaseFirestore.Query = db.collection(collection);
  for (const [field, op, value] of conditions) {
    query = query.where(field, op, value);
  }
  const snapshot = await query.get();
  return snapshot.docs.map((doc) => ({id: doc.id, ...doc.data()} as T & {id: string}));
};

/**
 * Firestore Timestamp을 Date로 안전하게 변환
 */
export function safeToDate(value: unknown): Date | null {
  if (!value) return null;
  if (
    typeof value === "object" &&
    value !== null &&
    "toDate" in value &&
    typeof (value as {toDate: () => Date}).toDate === "function"
  ) {
    return (value as {toDate: () => Date}).toDate();
  }
  if (typeof value === "string") {
    const d = new Date(value);
    return isNaN(d.getTime()) ? null : d;
  }
  if (value instanceof Date) {
    return value;
  }
  return null;
}
