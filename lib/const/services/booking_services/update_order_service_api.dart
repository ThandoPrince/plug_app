import 'dart:convert';

import 'package:flutter_application_1/const/services/api_tokens_helper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class UpdateOrderServiceApi {
  static final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? '';

  Future<Map<String, dynamic>> updateOrder({
    required int orderId,
    String? title,
    String? notes,
    String? requestedDate,
    String? requestedTime,
  }) async {
    final url = Uri.parse(
      '$baseUrl/bookings/service_orders/$orderId/update/',
    );

    final Map<String, dynamic> body = {};

    if (title != null) body["title"] = title;
    if (notes != null) body["notes"] = notes;
    if (requestedDate != null) {
      body["requested_date"] = requestedDate;
    }
    if (requestedTime != null) {
      body["requested_date_time"] = requestedTime;
    }

    try {
      final response = await http.patch(
        url,
        headers: await ApiTokensHelper.authHeaders(),
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      }

      throw Exception(
        responseData["detail"] ??
            responseData.toString(),
      );
    } catch (e) {
      throw Exception(
        "Failed to update booking: $e",
      );
    }
  }
}