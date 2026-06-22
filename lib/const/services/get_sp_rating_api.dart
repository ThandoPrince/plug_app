import 'dart:convert';

import 'package:flutter_application_1/const/services/api_tokens_helper.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/sp_rating_model.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SPRatingApi {
 

  static final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? '';

  static Future<List<SPRatingModel>> fetchRatings(
    int providerId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/client/get-sp-ratings/$providerId/',
    );

    try {
      final response = await http.get(
        url,
        headers: await ApiTokensHelper.authHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to fetch ratings (${response.statusCode})',
        );
      }

      final decoded =
          jsonDecode(response.body) as Map<String, dynamic>;

      final List<dynamic> data =
          decoded['data'] ?? [];

      return SPRatingModel.listFromJson(data);
    } catch (e) {
      throw Exception('SPRatingApi error: $e');
    }
  }
}