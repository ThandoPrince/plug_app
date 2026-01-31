import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/const/services/sessions/submit_ratings_api.dart';


class RatingController extends ChangeNotifier {
  int rating = 1;
  String comment = '';
  bool isSubmitting = false;

  /// Set rating value
  void setRating(int value) {
    rating = value;
    notifyListeners();
  }

  /// Set comment
  void setComment(String value) {
    comment = value;
    notifyListeners();
  }

  /// Submit rating to API
  Future<bool> submitRating({
    required int sessionId,
    required String clientEmail,
  }) async {
    if (rating == 0) return false;

    isSubmitting = true;
    notifyListeners();

    final success = await RatingApiHelper.submitRating(
      sessionId: sessionId,
      clientEmail: clientEmail,
      rating: rating,
      comment: comment,
    );

    isSubmitting = false;
    notifyListeners();

    return success;
  }
}
