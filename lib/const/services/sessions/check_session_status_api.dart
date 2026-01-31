import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CheckSessionStatusApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<bool> isSessionCompleted(int sessionId) async {
    final url = Uri.parse(
      '$baseUrl/bookings/sessions/$sessionId/check_status/',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
 if (kDebugMode) {
   print('🔥 Session $sessionId status: ${data['status']}');
 }
      return data['status'] == 'completed';
    }

    return false;
  }
}
  