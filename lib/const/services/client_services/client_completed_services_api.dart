import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/models/order_service_models/ratings_model.dart';
import 'package:flutter_application_1/const/services/api_tokens_helper.dart';

class ClientCompletedServicesApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // =========================
  // FETCH RATINGS BY CLIENT
  // =========================
  static Future<List<RatingModel>> fetchRatingsByClientEmail(
    String email,
  ) async {
    final url = Uri.parse(
      '$baseUrl/bookings/get_ratings/by_client_email/$email/',
    );

    try {
      final response = await http.get(
        url,
        headers: await ApiTokensHelper.authHeaders(),
      );

      if (kDebugMode) {
        print("Client Ratings HTTP: ${response.statusCode}");
        print("Response: ${response.body}");
      }

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to fetch client ratings: ${response.body}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception('Invalid ratings response format');
      }

      return decoded.map((item) {
        if (item is! Map<String, dynamic>) {
          throw Exception('Invalid rating item format');
        }
        return RatingModel.fromJson(item);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('ClientCompletedServicesApi error: $e');
      }
      throw Exception('Error fetching client ratings: $e');
    }
  }
}
