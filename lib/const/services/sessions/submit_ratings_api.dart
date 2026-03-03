import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class RatingApiHelper {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// POST rating and comment for a session
  static Future<bool> submitRating({
    required int sessionId,
    required String clientEmail,
    required int rating,
    String? comment,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/bookings/$sessionId/rate-provider/$clientEmail/',
      );

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer <token>', // uncomment if needed
        },
        body: jsonEncode({
          'score': rating,
          'review': comment ?? '',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        if (response.body.isNotEmpty) {
          print('❌ Rating submission failed: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      print('❌ Error submitting rating: $e');
      return false;
    }
  }
}
