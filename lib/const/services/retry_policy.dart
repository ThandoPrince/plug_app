import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

/// Configuration for retry behavior.
class RetryPolicy {
  final int maxAttempts;
  final Duration baseDelay;
  final Duration maxDelay;
  final double backoffMultiplier;
  final double jitterFactor;
  final Set<int> retriableStatusCodes;
  final List<Type> retriableExceptions;

  const RetryPolicy({
    this.maxAttempts = 3,
    this.baseDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 10),
    this.backoffMultiplier = 2.0,
    this.jitterFactor = 0.3,
    this.retriableStatusCodes = const {408, 429, 500, 502, 503, 504},
    this.retriableExceptions = const [
      SocketException,
      TimeoutException,
      HttpException,
    ],
  });

  /// Default policy for general API calls.
  static const RetryPolicy defaultPolicy = RetryPolicy();

  /// Aggressive policy for critical operations (booking, auth).
  static const RetryPolicy aggressive = RetryPolicy(
    maxAttempts: 4,
    baseDelay: Duration(milliseconds: 300),
    maxDelay: Duration(seconds: 15),
    backoffMultiplier: 2.0,
    jitterFactor: 0.25,
  );

  /// Gentle policy for non-critical reads.
  static const RetryPolicy gentle = RetryPolicy(
    maxAttempts: 2,
    baseDelay: Duration(milliseconds: 800),
    maxDelay: Duration(seconds: 5),
  );

  /// Calculate delay for a given attempt (0-indexed).
  Duration delayForAttempt(int attempt) {
    final baseMs = min(
      (baseDelay.inMilliseconds * pow(backoffMultiplier, attempt)).toInt(),
      maxDelay.inMilliseconds,
    );
    final jitter =
        (baseMs * jitterFactor * (Random().nextDouble() * 2 - 1)).toInt();
    return Duration(
        milliseconds: (baseMs + jitter).clamp(0, maxDelay.inMilliseconds));
  }

  /// Whether an exception is retriable.
  bool isRetriableException(Object error) {
    return retriableExceptions.any((t) => error.runtimeType == t);
  }

  /// Whether an HTTP status code is retriable.
  bool isRetriableStatusCode(int statusCode) {
    return retriableStatusCodes.contains(statusCode);
  }
}

/// Result of a retried operation.
class RetryResult<T> {
  final T? value;
  final Object? error;
  final int attempts;
  final bool succeeded;

  const RetryResult._({
    this.value,
    this.error,
    required this.attempts,
    required this.succeeded,
  });

  factory RetryResult.success(T value, int attempts) = _RetrySuccess<T>;
  factory RetryResult.failure(Object error, int attempts) = _RetryFailure<T>;
}

class _RetrySuccess<T> extends RetryResult<T> {
  const _RetrySuccess(T value, int attempts)
      : super._(value: value, attempts: attempts, succeeded: true);
}

class _RetryFailure<T> extends RetryResult<T> {
  const _RetryFailure(Object error, int attempts)
      : super._(error: error, attempts: attempts, succeeded: false);
}

/// Executes an operation with retry logic.
class RetryExecutor {
  final RetryPolicy policy;
  final void Function(int attempt, Object error, Duration nextDelay)? onRetry;

  const RetryExecutor({
    this.policy = RetryPolicy.defaultPolicy,
    this.onRetry,
  });

  /// Execute [action] with retry logic.
  Future<RetryResult<T>> execute<T>(Future<T> Function() action) async {
    Object? lastError;
    int attempt = 0;

    while (attempt < policy.maxAttempts) {
      try {
        final result = await action();
        return RetryResult.success(result, attempt + 1);
      } catch (e) {
        lastError = e;
        attempt++;

        if (attempt >= policy.maxAttempts) {
          break;
        }

        if (!_shouldRetry(e)) {
          break;
        }

        final delay = policy.delayForAttempt(attempt - 1);
        if (kDebugMode) {
          print(
              'RetryExecutor: attempt $attempt failed ($e), retrying in ${delay.inMilliseconds}ms');
        }
        onRetry?.call(attempt, e, delay);
        await Future.delayed(delay);
      }
    }

    return RetryResult.failure(lastError!, attempt);
  }

  /// Execute [action] and throw on failure (convenience).
  Future<T> executeOrThrow<T>(Future<T> Function() action) async {
    final result = await execute(action);
    if (result.succeeded) {
      return result.value!;
    }
    throw result.error!;
  }

  bool _shouldRetry(Object error) {
    if (error is HttpException) {
      return true;
    }
    if (policy.isRetriableException(error)) {
      return true;
    }
    return false;
  }
}

/// Extension for easy retry on any Future.
extension RetryExtension<T> on Future<T> {
  Future<RetryResult<T>> withRetry({
    RetryPolicy policy = RetryPolicy.defaultPolicy,
    void Function(int attempt, Object error, Duration nextDelay)? onRetry,
  }) {
    return RetryExecutor(policy: policy, onRetry: onRetry).execute(() => this);
  }

  Future<T> withRetryOrThrow({
    RetryPolicy policy = RetryPolicy.defaultPolicy,
    void Function(int attempt, Object error, Duration nextDelay)? onRetry,
  }) {
    return RetryExecutor(policy: policy, onRetry: onRetry)
        .executeOrThrow(() => this);
  }
}

/// Classification of network errors for UI handling.
enum NetworkErrorType {
  unreachable, // No internet / DNS / connection refused
  timeout, // Request timed out
  serverError, // 5xx from server
  authFailure, // 401/403 - needs re-auth
  notFound, // 404
  validationError, // 400/422
  rateLimited, // 429
  unknown,
}

class NetworkError extends Error {
  final NetworkErrorType type;
  final String message;
  final int? statusCode;
  final Object? originalError;

  NetworkError({
    required this.type,
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'NetworkError($type): $message';

  /// Create from exception thrown during HTTP call.
  factory NetworkError.fromException(Object error, {int? statusCode}) {
    if (error is SocketException) {
      return NetworkError(
        type: NetworkErrorType.unreachable,
        message: 'Server unreachable. Check your internet connection.',
        originalError: error,
      );
    }
    if (error is TimeoutException) {
      return NetworkError(
        type: NetworkErrorType.timeout,
        message: 'Request timed out. Please try again.',
        originalError: error,
      );
    }
    if (error is HttpException) {
      return NetworkError(
        type: NetworkErrorType.serverError,
        message: error.message,
        originalError: error,
      );
    }
    if (statusCode != null) {
      switch (statusCode) {
        case 401:
        case 403:
          return NetworkError(
            type: NetworkErrorType.authFailure,
            message: 'Authentication failed. Please log in again.',
            statusCode: statusCode,
            originalError: error,
          );
        case 404:
          return NetworkError(
            type: NetworkErrorType.notFound,
            message: 'Resource not found.',
            statusCode: statusCode,
            originalError: error,
          );
        case 400:
        case 422:
          return NetworkError(
            type: NetworkErrorType.validationError,
            message: error.toString(),
            statusCode: statusCode,
            originalError: error,
          );
        case 429:
          return NetworkError(
            type: NetworkErrorType.rateLimited,
            message: 'Too many requests. Please wait a moment.',
            statusCode: statusCode,
            originalError: error,
          );
        case 500:
        case 502:
        case 503:
        case 504:
          return NetworkError(
            type: NetworkErrorType.serverError,
            message: 'Server error. Please try again later.',
            statusCode: statusCode,
            originalError: error,
          );
      }
    }
    return NetworkError(
      type: NetworkErrorType.unknown,
      message: error.toString(),
      originalError: error,
    );
  }

  /// User-friendly message for display.
  String get userMessage {
    switch (type) {
      case NetworkErrorType.unreachable:
        return 'Unable to connect to server. Please check your internet connection.';
      case NetworkErrorType.timeout:
        return 'The request timed out. Please try again.';
      case NetworkErrorType.serverError:
        return 'Server is having issues. Please try again in a moment.';
      case NetworkErrorType.authFailure:
        return 'Your session has expired. Please log in again.';
      case NetworkErrorType.notFound:
        return 'The requested resource was not found.';
      case NetworkErrorType.validationError:
        return message;
      case NetworkErrorType.rateLimited:
        return 'Too many requests. Please wait a moment and try again.';
      case NetworkErrorType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Whether this error is retriable by the user (e.g., pull-to-refresh).
  bool get isUserRetriable {
    return type != NetworkErrorType.authFailure &&
        type != NetworkErrorType.notFound &&
        type != NetworkErrorType.validationError;
  }
}
