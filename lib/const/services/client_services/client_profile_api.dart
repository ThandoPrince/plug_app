import 'dart:convert';
import 'package:flutter_application_1/global_util/services/models/client_models/client_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;


class ClientProfileApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<ClientDetailModel> fetchClientProfileByEmail(String email) async {
    final url = Uri.parse('$baseUrl/clientsDB/clients/$email/');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return ClientDetailModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  static Future<List<ClientDetailModel>> fetchClientProfile() async {
    final url = Uri.parse('$baseUrl/');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => ClientDetailModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load profiles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching profiles: $e');
    }
  }
}
