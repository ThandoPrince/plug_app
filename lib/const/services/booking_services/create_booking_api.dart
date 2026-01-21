import 'dart:convert';
import 'package:flutter_application_1/global_util/services/models/order_service_models/order_service_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class BookingApiService {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Create booking from an OrderService object
  Future<OrderServiceModel> createBooking(OrderServiceModel booking) async {
    final url = Uri.parse('$baseUrl/bookings/order_a_service/');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(booking.toJson()),
    );

    return _handleResponse(response);
  }

  /// Create booking from a JSON payload (Map<String, dynamic>)
  Future<OrderServiceModel> createBookingFromJson(Map<String, dynamic> payload) async {
    final url = Uri.parse('$baseUrl/bookings/order_a_service/');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    return _handleResponse(response);
  }

  /// Common response handler
  OrderServiceModel _handleResponse(http.Response response) {
    if (response.statusCode == 201 || response.statusCode == 200) {
      return OrderServiceModel.fromJson(jsonDecode(response.body));
    } else if (response.body.isNotEmpty) {
      try {
        final Map<String, dynamic> errorData = json.decode(response.body);
        final errors = errorData.entries
            .map((e) => "${e.key}: ${e.value}")
            .join("\n");
        throw Exception(errors);
      } catch (e) {
        throw Exception(
            'Failed to create booking: ${response.statusCode} ${response.body}');
      }
    } else {
      throw Exception(
          'Failed to create booking: ${response.statusCode} ${response.reasonPhrase}');
    }
  }
}
