import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_application_1/global_util/services/models/sp_profile_model.dart';

class SpProfileApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // =========================
  // HEADERS (AUTH CENTRALIZED)
  // =========================
  static Map<String, String> _headers() {
    final token = AuthSessionController.instance.accessToken;

    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // =========================
  // FETCH PROFILE BY EMAIL
  // =========================
  static Future<SPProfileModel> fetchProfileByEmail(String email) async {
    final url = Uri.parse('$baseUrl/sp_profiles/$email/');

    try {
      final response = await http.get(
        url,
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        return SPProfileModel.fromJson(json.decode(response.body));
      }

      throw Exception(
        'Failed to load profile: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  // =========================
  // FETCH ALL PROFILES
  // =========================
  static Future<List<SPProfileModel>> fetchAllProfiles() async {
    final url = Uri.parse('$baseUrl/sp_profiles/');

    try {
      final response = await http.get(
        url,
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => SPProfileModel.fromJson(item)).toList();
      }

      throw Exception(
        'Failed to load profiles: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      throw Exception('Error fetching profiles: $e');
    }
  }
}