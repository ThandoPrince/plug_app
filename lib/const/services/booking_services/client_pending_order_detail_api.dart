import 'dart:convert';
import 'package:flutter_application_1/const/services/api_tokens_helper.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/order_service_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ClientPendingOrderDetailApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<OrderServiceModel> fetchBookingByOrderID(int orderID) async {
    final url = Uri.parse('$baseUrl/bookings/service_orders/$orderID');

    final response = await http.get(
      url,
      headers: await ApiTokensHelper.authHeaders(),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return OrderServiceModel.fromJson(data);
    } else {
      throw Exception(
        'Booking Info Failed (${response.statusCode}): ${response.body}',
      );
    }
  }
}
