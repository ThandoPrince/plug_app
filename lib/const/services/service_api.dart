import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/global_util/services/models/services_model.dart';

class ServiceApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? ''; // Change to your actual domain in production

  static Future<List<ServiceModel>> fetchServices() async {
    final url = Uri.parse('$baseUrl/services/'); // adjust endpoint if different

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => ServiceModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load services: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching services: $e');
    }
  }
}
