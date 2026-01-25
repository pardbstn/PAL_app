/**
 * 통일된 API 응답 포맷
 */
export interface ApiResponse<T = unknown> {
  success: boolean;
  data: T | null;
  error: {code: string; message: string} | null;
}

export const successResponse = <T>(data: T): ApiResponse<T> => ({
  success: true,
  data,
  error: null,
});

export const errorResponse = (code: string, message: string): ApiResponse<null> => ({
  success: false,
  data: null,
  error: {code, message},
});
