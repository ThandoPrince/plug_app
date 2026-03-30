import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PatchOrderFinalPriceApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  static Future<Map<String, dynamic>> patchFinalPrice({
    required int orderId,
    required double finalPrice,
    bool? isNegotiated,
  }) async {
    final url = Uri.parse('$baseUrl/bookings/$orderId/final-price/');

    final Map<String, dynamic> body = {
      'final_price': finalPrice.toStringAsFixed(2),
    };

    if (isNegotiated != null) {
      body['is_negotiated'] = isNegotiated;
    }

    final response = await http.patch(
      url,
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw Exception('Unexpected response format.');
    }

    if (response.statusCode == 400 || response.statusCode == 404) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          throw Exception(decoded.toString());
        }
      } catch (_) {
        throw Exception(
          'Failed to update final price. Status: ${response.statusCode}',
        );
      }
    }

    throw Exception(
      'Failed to update final price. '
      'Status: ${response.statusCode}, Body: ${response.body}',
    );
  }
}