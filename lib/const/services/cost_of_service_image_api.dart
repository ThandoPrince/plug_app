import 'dart:convert';
import 'package:flutter_application_1/global_util/services/models/order_service_models/cost_of_service_image.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CostOfServiceImageApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  static Future<List<CostOfServiceImageModel>> fetchImagesByCostId(
    int costId,
  ) async {
    final url = Uri.parse('$baseUrl/cost_of_service/$costId/images/');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded
            .map(
              (item) => CostOfServiceImageModel.fromJson(
                item as Map<String, dynamic>?,
              ),
            )
            .toList();
      }

      throw Exception('Unexpected response format for cost images.');
    }

    if (response.statusCode == 404) {
      return [];
    }

    throw Exception(
      'Failed to load images for cost ID $costId. '
      'Status: ${response.statusCode}, Body: ${response.body}',
    );
  }
}