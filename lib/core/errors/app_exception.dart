// PAL 앱 커스텀 예외 클래스들
//
// 각 예외는 에러 코드와 원본 에러를 포함하여
// 디버깅과 사용자 메시지 생성에 활용됩니다.

/// 기본 앱 예외 클래스
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException($code): $message';
}

/// 네트워크 관련 예외
/// - 인터넷 연결 끊김
/// - 타임아웃
/// - DNS 오류 등
class NetworkException extends AppException {
  final bool isTimeout;
  final bool isConnectionError;

  const NetworkException({
    required super.message,
    super.code = 'NETWORK_ERROR',
    super.originalError,
    super.stackTrace,
    this.isTimeout = false,
    this.isConnectionError = false,
  });

  factory NetworkException.timeout({
    String message = '요청 시간이 초과됐어요',
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return NetworkException(
      message: message,
      code: 'NETWORK_TIMEOUT',
      originalError: originalError,
      stackTrace: stackTrace,
      isTimeout: true,
    );
  }

  factory NetworkException.noConnection({
    String message = '인터넷 연결을 확인해주세요',
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return NetworkException(
      message: message,
      code: 'NO_CONNECTION',
      originalError: originalError,
      stackTrace: stackTrace,
      isConnectionError: true,
    );
  }

  @override
  String toString() => 'NetworkException($code): $message';
}

/// 인증 관련 예외
/// - 로그인 실패
/// - 토큰 만료
/// - 권한 없음 등
class AuthException extends AppException {
  final bool isTokenExpired;
  final bool isInvalidCredentials;
  final bool isUnauthorized;

  const AuthException({
    required super.message,
    super.code = 'AUTH_ERROR',
    super.originalError,
    super.stackTrace,
    this.isTokenExpired = false,
    this.isInvalidCredentials = false,
    this.isUnauthorized = false,
  });

  factory AuthException.tokenExpired({
    String message = '로그인이 만료됐어요. 다시 로그인해주세요',
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AuthException(
      message: message,
      code: 'TOKEN_EXPIRED',
      originalError: originalError,
      stackTrace: stackTrace,
      isTokenExpired: true,
    );
  }

  factory AuthException.invalidCredentials({
    String message = '이메일 또는 비밀번호가 올바르지 않아요',
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AuthException(
      message: message,
      code: 'INVALID_CREDENTIALS',
      originalError: originalError,
      stackTrace: stackTrace,
      isInvalidCredentials: true,
    );
  }

  factory AuthException.unauthorized({
    String message = '접근 권한이 없어요',
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AuthException(
      message: message,
      code: 'UNAUTHORIZED',
      originalError: originalError,
      stackTrace: stackTrace,
      isUnauthorized: true,
    );
  }

  factory AuthException.userNotFound({
    String message = '등록되지 않은 사용자예요',
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AuthException(
      message: message,
      code: 'USER_NOT_FOUND',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  @override
  String toString() => 'AuthException($code): $message';
}

/// AI 서비스 관련 예외
/// - API 호출 실패
/// - 할당량 초과
/// - 모델 오류 등
class AIServiceException extends AppException {
  final bool isQuotaExceeded;
  final bool isModelError;
  final bool isRateLimited;

  const AIServiceException({
    required super.message,
    super.code = 'AI_SERVICE_ERROR',
    super.originalError,
    super.stackTrace,
    this.isQuotaExceeded = false,
    this.isModelError = false,
    this.isRateLimited = false,
  });

  factory AIServiceException.quotaExceeded({
    String message = 'AI 서비스 사용량이 초과됐어요',
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AIServiceException(
      message: message,
      code: 'QUOTA_EXCEEDED',
      originalError: originalError,
      stackTrace: stackTrace,
      isQuotaExceeded: true,
    );
  }

  factory AIServiceException.rateLimited({
    String message = '잠시 후 다시 시도해주세요',
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AIServiceException(
      message: message,
      code: 'RATE_LIMITED',
      originalError: originalError,
      stackTrace: stackTrace,
      isRateLimited: true,
    );
  }

  factory AIServiceException.modelError({
    String message = 'AI 분석 중 문제가 생겼어요',
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AIServiceException(
      message: message,
      code: 'MODEL_ERROR',
      originalError: originalError,
      stackTrace: stackTrace,
      isModelError: true,
    );
  }

  @override
  String toString() => 'AIServiceException($code): $message';
}

/// 스토리지 관련 예외
/// - 파일 업로드 실패
/// - 용량 초과
/// - 파일 형식 오류 등
class AppStorageException extends AppException {
  final bool isUploadFailed;
  final bool isDownloadFailed;
  final bool isFileTooLarge;
  final bool isInvalidFormat;

  const AppStorageException({
    required super.message,
    super.code = 'STORAGE_ERROR',
    super.originalError,
    super.stackTrace,
    this.isUploadFailed = false,
    this.isDownloadFailed = false,
    this.isFileTooLarge = false,
    this.isInvalidFormat = false,
  });

  factory AppStorageException.uploadFailed({
    String message = '파일 업로드에 실패했어요',
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppStorageException(
      message: message,
      code: 'UPLOAD_FAILED',
      originalError: originalError,
      stackTrace: stackTrace,
      isUploadFailed: true,
    );
  }

  factory AppStorageException.downloadFailed({
    String message = '파일 다운로드에 실패했어요',
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppStorageException(
      message: message,
      code: 'DOWNLOAD_FAILED',
      originalError: originalError,
      stackTrace: stackTrace,
      isDownloadFailed: true,
    );
  }

  factory AppStorageException.fileTooLarge({
    String message = '파일 크기가 너무 커요',
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppStorageException(
      message: message,
      code: 'FILE_TOO_LARGE',
      originalError: originalError,
      stackTrace: stackTrace,
      isFileTooLarge: true,
    );
  }

  factory AppStorageException.invalidFormat({
    String message = '지원하지 않는 파일 형식이에요',
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppStorageException(
      message: message,
      code: 'INVALID_FORMAT',
      originalError: originalError,
      stackTrace: stackTrace,
      isInvalidFormat: true,
    );
  }

  @override
  String toString() => 'AppStorageException($code): $message';
}

/// 유효성 검증 관련 예외
/// - 필수 필드 누락
/// - 형식 오류
/// - 범위 초과 등
class ValidationException extends AppException {
  final String? field;
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    super.originalError,
    super.stackTrace,
    this.field,
    this.fieldErrors,
  });

  factory ValidationException.requiredField({
    required String fieldName,
    String? message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return ValidationException(
      message: message ?? '$fieldName은(는) 필수 입력 항목이에요',
      code: 'REQUIRED_FIELD',
      originalError: originalError,
      stackTrace: stackTrace,
      field: fieldName,
    );
  }

  factory ValidationException.invalidFormat({
    required String fieldName,
    String? message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return ValidationException(
      message: message ?? '$fieldName 형식이 올바르지 않아요',
      code: 'INVALID_FORMAT',
      originalError: originalError,
      stackTrace: stackTrace,
      field: fieldName,
    );
  }

  factory ValidationException.outOfRange({
    required String fieldName,
    String? message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return ValidationException(
      message: message ?? '$fieldName 값이 허용 범위를 벗어났어요',
      code: 'OUT_OF_RANGE',
      originalError: originalError,
      stackTrace: stackTrace,
      field: fieldName,
    );
  }

  factory ValidationException.multipleErrors({
    required Map<String, String> errors,
    String message = '입력 정보를 확인해주세요',
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return ValidationException(
      message: message,
      code: 'MULTIPLE_ERRORS',
      originalError: originalError,
      stackTrace: stackTrace,
      fieldErrors: errors,
    );
  }

  @override
  String toString() => 'ValidationException($code): $message';
}

/// 데이터베이스/캐시 관련 예외
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code = 'CACHE_ERROR',
    super.originalError,
    super.stackTrace,
  });

  factory CacheException.notFound({
    String message = '캐시된 데이터를 찾을 수 없어요',
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return CacheException(
      message: message,
      code: 'CACHE_NOT_FOUND',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  factory CacheException.writeFailed({
    String message = '데이터 저장에 실패했어요',
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return CacheException(
      message: message,
      code: 'CACHE_WRITE_FAILED',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  @override
  String toString() => 'CacheException($code): $message';
}

/// 서버 관련 예외
class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    required super.message,
    super.code = 'SERVER_ERROR',
    super.originalError,
    super.stackTrace,
    this.statusCode,
  });

  factory ServerException.internalError({
    String message = '서버에 문제가 생겼어요',
    int? statusCode,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return ServerException(
      message: message,
      code: 'INTERNAL_SERVER_ERROR',
      originalError: originalError,
      stackTrace: stackTrace,
      statusCode: statusCode ?? 500,
    );
  }

  factory ServerException.serviceUnavailable({
    String message = '서비스가 일시적으로 이용 불가능해요',
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return ServerException(
      message: message,
      code: 'SERVICE_UNAVAILABLE',
      originalError: originalError,
      stackTrace: stackTrace,
      statusCode: 503,
    );
  }

  @override
  String toString() => 'ServerException($code, $statusCode): $message';
}
