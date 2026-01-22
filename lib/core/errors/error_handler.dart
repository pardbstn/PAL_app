import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'app_exception.dart';
import 'failure.dart';

/// 전역 에러 핸들러
///
/// 다양한 에러 타입을 사용자 친화적인 한글 메시지로 변환하고
/// 적절한 Failure 또는 AppException 객체를 반환합니다.
class ErrorHandler {
  ErrorHandler._();

  /// 에러를 Failure로 변환
  static Failure handleFailure(dynamic error, [StackTrace? stackTrace]) {
    // 이미 Failure인 경우 그대로 반환
    if (error is Failure) {
      return error;
    }

    // AppException을 Failure로 변환
    if (error is AppException) {
      return _appExceptionToFailure(error);
    }

    // DioException 처리
    if (error is DioException) {
      return _handleDioException(error);
    }

    // Firebase Auth 에러 처리
    if (error is FirebaseAuthException) {
      return _handleFirebaseAuthException(error);
    }

    // Firestore 에러 처리
    if (error is FirebaseException) {
      return _handleFirebaseException(error);
    }

    // Supabase Storage 에러 처리
    if (error is supabase.StorageException) {
      return _handleSupabaseStorageException(error);
    }

    // 소켓/연결 에러 처리 (웹에서는 SocketException 사용 불가)
    if (!kIsWeb && error.runtimeType.toString() == 'SocketException') {
      return NetworkFailure.noConnection(
        message: '인터넷 연결을 확인해주세요',
      );
    }
    // 웹에서 네트워크 에러 처리
    if (error.toString().contains('SocketException') ||
        error.toString().contains('XMLHttpRequest error')) {
      return NetworkFailure.noConnection(
        message: '인터넷 연결을 확인해주세요',
      );
    }

    // 타임아웃 에러 처리
    if (error is TimeoutException) {
      return NetworkFailure.timeout(
        message: '요청 시간이 초과되었습니다. 다시 시도해주세요',
      );
    }

    // 포맷 에러 처리
    if (error is FormatException) {
      return const ValidationFailure(
        message: '데이터 형식이 올바르지 않습니다',
        code: 'FORMAT_ERROR',
      );
    }

    // 기본 Exception 처리
    if (error is Exception) {
      return UnknownFailure(
        message: _extractMessage(error),
        originalError: error,
      );
    }

    // 알 수 없는 에러
    return UnknownFailure(
      message: error?.toString() ?? '알 수 없는 오류가 발생했습니다',
      originalError: error,
    );
  }

  /// 에러를 사용자 친화적 메시지로 변환
  static String getMessage(dynamic error) {
    if (error is Failure) {
      return error.message;
    }

    if (error is AppException) {
      return error.message;
    }

    final failure = handleFailure(error);
    return failure.message;
  }

  /// AppException을 Failure로 변환
  static Failure _appExceptionToFailure(AppException exception) {
    return switch (exception) {
      NetworkException e => NetworkFailure(
          message: e.message,
          code: e.code,
          isTimeout: e.isTimeout,
          isConnectionError: e.isConnectionError,
        ),
      AuthException e => AuthFailure(
          message: e.message,
          code: e.code,
          isTokenExpired: e.isTokenExpired,
          isUnauthorized: e.isUnauthorized,
        ),
      AIServiceException e => AIServiceFailure(
          message: e.message,
          code: e.code,
          isQuotaExceeded: e.isQuotaExceeded,
          isRateLimited: e.isRateLimited,
        ),
      AppStorageException _ => StorageFailure(
          message: exception.message,
          code: exception.code,
        ),
      ValidationException e => ValidationFailure(
          message: e.message,
          code: e.code,
          field: e.field,
          fieldErrors: e.fieldErrors,
        ),
      CacheException _ => CacheFailure(
          message: exception.message,
          code: exception.code,
        ),
      ServerException e => ServerFailure(
          message: e.message,
          code: e.code,
          statusCode: e.statusCode,
        ),
      _ => UnknownFailure(
          message: exception.message,
          originalError: exception,
        ),
    };
  }

  /// Dio 에러 처리
  static Failure _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkFailure.timeout(
          message: '서버 응답이 지연되고 있습니다. 잠시 후 다시 시도해주세요',
        );

      case DioExceptionType.connectionError:
        return NetworkFailure.noConnection(
          message: '인터넷 연결을 확인해주세요',
        );

      case DioExceptionType.badCertificate:
        return const NetworkFailure(
          message: '보안 연결에 실패했습니다',
          code: 'BAD_CERTIFICATE',
        );

      case DioExceptionType.badResponse:
        return _handleDioStatusCode(error.response?.statusCode, error.response?.data);

      case DioExceptionType.cancel:
        return const NetworkFailure(
          message: '요청이 취소되었습니다',
          code: 'CANCELLED',
        );

      case DioExceptionType.unknown:
        // 웹에서는 SocketException 타입 체크 불가
        final errorStr = error.error?.toString() ?? '';
        if (errorStr.contains('SocketException') || errorStr.contains('XMLHttpRequest')) {
          return NetworkFailure.noConnection();
        }
        return const UnknownFailure(
          message: '네트워크 오류가 발생했습니다',
        );
    }
  }

  /// HTTP 상태 코드별 처리
  static Failure _handleDioStatusCode(int? statusCode, dynamic data) {
    final serverMessage = _extractServerMessage(data);

    switch (statusCode) {
      case 400:
        return ServerFailure.badRequest(
          message: serverMessage ?? '잘못된 요청입니다',
        );
      case 401:
        return AuthFailure.unauthorized(
          message: serverMessage ?? '로그인이 필요합니다',
        );
      case 403:
        return const AuthFailure(
          message: '접근이 거부되었습니다',
          code: 'FORBIDDEN',
        );
      case 404:
        return ServerFailure.notFound(
          message: serverMessage ?? '요청한 정보를 찾을 수 없습니다',
        );
      case 408:
        return NetworkFailure.timeout();
      case 429:
        return AIServiceFailure.rateLimited(
          message: serverMessage ?? '요청이 너무 많습니다. 잠시 후 다시 시도해주세요',
        );
      case 500:
      case 501:
      case 502:
      case 503:
        return ServerFailure.internalError(
          message: serverMessage ?? '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요',
          statusCode: statusCode,
        );
      default:
        return ServerFailure(
          message: serverMessage ?? '서버 오류가 발생했습니다',
          statusCode: statusCode,
        );
    }
  }

  /// Firebase Auth 에러 처리
  static Failure _handleFirebaseAuthException(FirebaseAuthException error) {
    final message = switch (error.code) {
      'user-not-found' => '등록되지 않은 이메일입니다',
      'wrong-password' => '비밀번호가 올바르지 않습니다',
      'invalid-email' => '유효하지 않은 이메일 형식입니다',
      'user-disabled' => '비활성화된 계정입니다. 관리자에게 문의해주세요',
      'email-already-in-use' => '이미 사용 중인 이메일입니다',
      'operation-not-allowed' => '허용되지 않은 작업입니다',
      'weak-password' => '비밀번호가 너무 약합니다. 6자 이상 입력해주세요',
      'invalid-credential' => '로그인 정보가 올바르지 않습니다',
      'account-exists-with-different-credential' =>
        '다른 로그인 방식으로 가입된 계정입니다',
      'requires-recent-login' => '보안을 위해 다시 로그인해주세요',
      'provider-already-linked' => '이미 연결된 계정입니다',
      'credential-already-in-use' => '다른 계정에서 사용 중인 인증 정보입니다',
      'invalid-verification-code' => '인증 코드가 올바르지 않습니다',
      'invalid-verification-id' => '인증 ID가 유효하지 않습니다',
      'network-request-failed' => '네트워크 오류가 발생했습니다',
      'too-many-requests' => '요청이 너무 많습니다. 잠시 후 다시 시도해주세요',
      'expired-action-code' => '인증 코드가 만료되었습니다',
      _ => error.message ?? '인증 오류가 발생했습니다',
    };

    if (error.code == 'network-request-failed') {
      return NetworkFailure.noConnection(message: message);
    }

    if (error.code == 'too-many-requests') {
      return AIServiceFailure.rateLimited(message: message);
    }

    return AuthFailure(
      message: message,
      code: error.code,
      originalError: error,
    );
  }

  /// Firebase 일반 에러 처리
  static Failure _handleFirebaseException(FirebaseException error) {
    final message = switch (error.code) {
      'permission-denied' => '접근 권한이 없습니다',
      'unavailable' => '서비스가 일시적으로 이용 불가능합니다',
      'not-found' => '요청한 데이터를 찾을 수 없습니다',
      'already-exists' => '이미 존재하는 데이터입니다',
      'resource-exhausted' => '요청 한도를 초과했습니다',
      'cancelled' => '작업이 취소되었습니다',
      'data-loss' => '데이터 손실이 발생했습니다',
      'deadline-exceeded' => '요청 시간이 초과되었습니다',
      'failed-precondition' => '작업 조건이 충족되지 않았습니다',
      'internal' => '서버 내부 오류가 발생했습니다',
      'invalid-argument' => '잘못된 요청 데이터입니다',
      'out-of-range' => '요청 범위를 벗어났습니다',
      'unauthenticated' => '인증이 필요합니다',
      'unimplemented' => '지원하지 않는 기능입니다',
      _ => error.message ?? '오류가 발생했습니다',
    };

    if (error.code == 'permission-denied' || error.code == 'unauthenticated') {
      return AuthFailure(message: message, code: error.code);
    }

    if (error.code == 'unavailable' || error.code == 'deadline-exceeded') {
      return NetworkFailure(message: message, code: error.code);
    }

    return ServerFailure(message: message, code: error.code);
  }

  /// Supabase Storage 에러 처리
  static Failure _handleSupabaseStorageException(supabase.StorageException error) {
    final message = error.message;

    if (message.contains('size') || message.contains('too large')) {
      return StorageFailure.fileTooLarge();
    }

    if (message.contains('not found')) {
      return const StorageFailure(
        message: '파일을 찾을 수 없습니다',
        code: 'NOT_FOUND',
      );
    }

    if (message.contains('permission') || message.contains('unauthorized')) {
      return const AuthFailure(
        message: '파일 접근 권한이 없습니다',
        code: 'STORAGE_UNAUTHORIZED',
      );
    }

    return StorageFailure(
      message: '파일 처리 중 오류가 발생했습니다: $message',
      code: error.statusCode,
    );
  }

  /// 서버 응답에서 메시지 추출
  static String? _extractServerMessage(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      return data['message'] as String? ??
          data['error'] as String? ??
          data['msg'] as String?;
    }

    if (data is String && data.isNotEmpty) {
      return data;
    }

    return null;
  }

  /// Exception에서 메시지 추출
  static String _extractMessage(Exception error) {
    final errorString = error.toString();

    // "Exception: " 접두사 제거
    if (errorString.startsWith('Exception: ')) {
      return errorString.substring(11);
    }

    return errorString;
  }
}

/// ErrorHandler 확장 - 간편한 사용을 위한 글로벌 함수들
Failure handleError(dynamic error, [StackTrace? stackTrace]) {
  return ErrorHandler.handleFailure(error, stackTrace);
}

String getErrorMessage(dynamic error) {
  return ErrorHandler.getMessage(error);
}
