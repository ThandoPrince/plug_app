import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/const/services/sessions/check_ratings_api.dart';

class RatingNavigationController {
  static Timer? _timer;
  static bool _hasNavigated = false;

  static VoidCallback? onRatingAvailable;

  static void startPolling({
    required String clientEmail,
    required int sessionId,
  }) {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_hasNavigated) return;

      final hasRating =
          await CheckClientRatingApi.hasClientRatedSession(
        clientEmail: clientEmail,
        sessionId: sessionId,
      );

      if (hasRating) {
        _hasNavigated = true;
        _timer?.cancel();

        if (kDebugMode) {
          print('⭐ Rating detected → navigating');
        }

        onRatingAvailable?.call();
      }
    });
  }

  static Future<void> checkImmediately({
    required String clientEmail,
    required int sessionId,
  }) async {
    if (_hasNavigated) return;

    final hasRating =
        await CheckClientRatingApi.hasClientRatedSession(
      clientEmail: clientEmail,
      sessionId: sessionId,
    );

    if (hasRating) {
      _hasNavigated = true;

      if (kDebugMode) {
        print('⭐ Rating already exists → navigating');
      }

      onRatingAvailable?.call();
    }
  }

  static void reset() {
    _hasNavigated = false;
    _timer?.cancel();
    _timer = null;
  }

  static void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
