import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CheckClientRatingApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<bool> hasClientRatedSession({
    required String clientEmail,
    required int sessionId,
  }) async {
    final url = Uri.parse(
      '$baseUrl/bookings/get_ratings/by_client_email/$clientEmail/?session_id=$sessionId',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      if (kDebugMode) {
        print('⭐ Ratings for session $sessionId: ${data.length}');
      }

      return data.isNotEmpty;
    }

    return false;
  }
}
