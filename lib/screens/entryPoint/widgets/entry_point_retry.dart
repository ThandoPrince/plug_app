import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/const/services/retry_policy.dart';
 // adjust path

/// Retries [action] on failure using [policy]'s backoff schedule.
///
/// Intended for the app's initial-load prefetch calls: transient network
/// blips (a dropped packet, a slow cold-start) shouldn't take down the
/// whole startup sequence, but a call that keeps failing after several
/// attempts should still surface as a real failure to the caller.
Future<T> retryWithBackoff<T>(
  Future<T> Function() action, {
  RetryPolicy policy = const RetryPolicy(
    maxAttempts: 3,
    baseDelay: Duration(seconds: 1),
    maxDelay: Duration(seconds: 8),
    backoffMultiplier: 2.0,
    jitterFactor: 0.3,
  ),
  String? label,
}) async {
  Object? lastError;

  for (var attempt = 0; attempt < policy.maxAttempts; attempt++) {
    try {
      return await action();
    } catch (e) {
      lastError = e;

      final isLastAttempt = attempt == policy.maxAttempts - 1;
      if (isLastAttempt) break;

      final delay = policy.delayForAttempt(attempt);

      if (kDebugMode) {
        debugPrint(
          'retryWithBackoff${label != null ? " ($label)" : ""}: '
          'attempt ${attempt + 1}/${policy.maxAttempts} failed with $e, '
          'retrying in ${delay.inMilliseconds}ms',
        );
      }

      await Future.delayed(delay);
    }
  }

  throw lastError!;
}