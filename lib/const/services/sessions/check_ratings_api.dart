import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/const/services/api_tokens_helper.dart';

class CheckClientRatingApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<bool> hasClientRatedSession({
    required String clientEmail,
    required int sessionId,
  }) async {
    final url = Uri.parse(
      '$baseUrl/bookings/get_ratings/by_client_email/$clientEmail/?session_id=$sessionId',
    );

    try {
      final response = await http.get(
        url,
        headers: await ApiTokensHelper.authHeaders(),
      );

      if (kDebugMode) {
        print('Rating Check HTTP ${response.statusCode}');
        print('Response: ${response.body}');
      }

      if (response.statusCode != 200) {
        return false;
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        return false;
      }

      return decoded.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('CheckClientRatingApi error: $e');
      }
      return false;
    }
  }
}
