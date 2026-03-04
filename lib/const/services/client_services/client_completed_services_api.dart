import 'dart:convert';
import 'package:flutter_application_1/global_util/services/models/order_service_models/ratings_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;


class ClientCompletedServicesApi {
  
static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';
  

  Future<List<RatingModel>> fetchRatingsByClientEmail(String email) async {
    final url = Uri.parse('$baseUrl/bookings/get_ratings/by_client_email/$email/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => RatingModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch client ratings: ${response.body}');
    }
  }
}