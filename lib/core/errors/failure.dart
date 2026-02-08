/// Failure sealed class
///
/// Result 패턴에서 실패 상태를 표현하는 sealed class입니다.
/// Either[Failure, Success] 패턴에서 Left 값으로 사용됩니다.
sealed class Failure {
  final String message;
  final String? code;
  final dynamic originalError;

  const Failure({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'Failure($code): $message';
}

/// 네트워크 실패
class NetworkFailure extends Failure {
  final bool isTimeout;
  final bool isConnectionError;

  const NetworkFailure({
    required super.message,
    super.code = 'NETWORK_FAILURE',
    super.originalError,
    this.isTimeout = false,
    this.isConnectionError = false,
  });

  factory NetworkFailure.timeout({
    String message = '요청 시간이 초과됐어요',
  }) {
    return NetworkFailure(
      message: message,
      code: 'TIMEOUT',
      isTimeout: true,
    );
  }

  factory NetworkFailure.noConnection({
    String message = '인터넷 연결을 확인해주세요',
  }) {
    return NetworkFailure(
      message: message,
      code: 'NO_CONNECTION',
      isConnectionError: true,
    );
  }
}

/// 서버 실패
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required super.message,
    super.code = 'SERVER_FAILURE',
    super.originalError,
    this.statusCode,
  });

  factory ServerFailure.internalError({
    String message = '서버에 문제가 생겼어요',
    int? statusCode,
  }) {
    return ServerFailure(
      message: message,
      code: 'INTERNAL_ERROR',
      statusCode: statusCode ?? 500,
    );
  }

  factory ServerFailure.notFound({
    String message = '요청한 데이터를 찾을 수 없어요',
  }) {
    return ServerFailure(
      message: message,
      code: 'NOT_FOUND',
      statusCode: 404,
    );
  }

  factory ServerFailure.badRequest({
    String message = '잘못된 요청이에요',
  }) {
    return ServerFailure(
      message: message,
      code: 'BAD_REQUEST',
      statusCode: 400,
    );
  }
}

/// 캐시 실패
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code = 'CACHE_FAILURE',
    super.originalError,
  });

  factory CacheFailure.notFound({
    String message = '캐시된 데이터가 없어요',
  }) {
    return const CacheFailure(
      message: '캐시된 데이터가 없어요',
      code: 'NOT_FOUND',
    );
  }

  factory CacheFailure.expired({
    String message = '캐시가 만료됐어요',
  }) {
    return const CacheFailure(
      message: '캐시가 만료됐어요',
      code: 'EXPIRED',
    );
  }
}

/// 인증 실패
class AuthFailure extends Failure {
  final bool isTokenExpired;
  final bool isUnauthorized;

  const AuthFailure({
    required super.message,
    super.code = 'AUTH_FAILURE',
    super.originalError,
    this.isTokenExpired = false,
    this.isUnauthorized = false,
  });

  factory AuthFailure.tokenExpired({
    String message = '로그인이 만료됐어요',
  }) {
    return AuthFailure(
      message: message,
      code: 'TOKEN_EXPIRED',
      isTokenExpired: true,
    );
  }

  factory AuthFailure.unauthorized({
    String message = '접근 권한이 없어요',
  }) {
    return AuthFailure(
      message: message,
      code: 'UNAUTHORIZED',
      isUnauthorized: true,
    );
  }

  factory AuthFailure.invalidCredentials({
    String message = '로그인 정보가 올바르지 않아요',
  }) {
    return AuthFailure(
      message: message,
      code: 'INVALID_CREDENTIALS',
    );
  }
}

/// 유효성 검증 실패
class ValidationFailure extends Failure {
  final String? field;
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_FAILURE',
    super.originalError,
    this.field,
    this.fieldErrors,
  });

  factory ValidationFailure.requiredField({
    required String fieldName,
    String? message,
  }) {
    return ValidationFailure(
      message: message ?? '$fieldName은(는) 필수예요',
      code: 'REQUIRED',
      field: fieldName,
    );
  }

  factory ValidationFailure.invalidFormat({
    required String fieldName,
    String? message,
  }) {
    return ValidationFailure(
      message: message ?? '$fieldName 형식이 올바르지 않아요',
      code: 'INVALID_FORMAT',
      field: fieldName,
    );
  }
}

/// AI 서비스 실패
class AIServiceFailure extends Failure {
  final bool isQuotaExceeded;
  final bool isRateLimited;

  const AIServiceFailure({
    required super.message,
    super.code = 'AI_SERVICE_FAILURE',
    super.originalError,
    this.isQuotaExceeded = false,
    this.isRateLimited = false,
  });

  factory AIServiceFailure.quotaExceeded({
    String message = 'AI 서비스 사용량이 초과됐어요',
  }) {
    return AIServiceFailure(
      message: message,
      code: 'QUOTA_EXCEEDED',
      isQuotaExceeded: true,
    );
  }

  factory AIServiceFailure.rateLimited({
    String message = '잠시 후 다시 시도해주세요',
  }) {
    return AIServiceFailure(
      message: message,
      code: 'RATE_LIMITED',
      isRateLimited: true,
    );
  }

  factory AIServiceFailure.analysisError({
    String message = 'AI 분석에 실패했어요',
  }) {
    return AIServiceFailure(
      message: message,
      code: 'ANALYSIS_ERROR',
    );
  }
}

/// 스토리지 실패
class StorageFailure extends Failure {
  const StorageFailure({
    required super.message,
    super.code = 'STORAGE_FAILURE',
    super.originalError,
  });

  factory StorageFailure.uploadFailed({
    String message = '파일 업로드에 실패했어요',
  }) {
    return StorageFailure(
      message: message,
      code: 'UPLOAD_FAILED',
    );
  }

  factory StorageFailure.downloadFailed({
    String message = '파일 다운로드에 실패했어요',
  }) {
    return StorageFailure(
      message: message,
      code: 'DOWNLOAD_FAILED',
    );
  }

  factory StorageFailure.fileTooLarge({
    String message = '파일이 너무 커요',
  }) {
    return StorageFailure(
      message: message,
      code: 'FILE_TOO_LARGE',
    );
  }
}

/// 알 수 없는 실패
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = '알 수 없는 문제가 생겼어요',
    super.code = 'UNKNOWN',
    super.originalError,
  });
}
