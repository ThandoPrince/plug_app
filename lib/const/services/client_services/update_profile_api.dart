import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_application_1/global_util/services/api_exeption.dart';

class UpdateProfileApi {
  static final String _baseUrl = dotenv.env['API_BASE_URL']!;

  static const Duration _timeout = Duration(seconds: 30);

  // =========================
  // UPDATE PROFILE (MULTIPART)
  // =========================
  static Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    File? profilePicture,
  }) async {
    try {
      final response = await ApiClient.instance
          .multipartRequest((token) async {
            final request = http.MultipartRequest(
              'PATCH',
              Uri.parse('$_baseUrl/client/profile/update/'),
            );

            if (token != null) {
              request.headers['Authorization'] = 'Bearer $token';
            }

            if (firstName != null) {
              request.fields['first_name'] = firstName;
            }

            if (lastName != null) {
              request.fields['last_name'] = lastName;
            }

            if (dateOfBirth != null) {
              request.fields['date_of_birth'] = dateOfBirth;
            }

            if (profilePicture != null) {
              request.files.add(
                await http.MultipartFile.fromPath(
                  'client_pp',
                  profilePicture.path,
                ),
              );
            }

            return request;
          })
          .timeout(_timeout);

      final data = _safeDecode(response.body);

      // =========================
      // DEBUG LOGGING
      // =========================
      if (kDebugMode) {
        print("========== UPDATE PROFILE ==========");
        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");
        print("====================================");
      }

      if (response.statusCode == 200) {
        return data;
      }

      throw AppException(_extractError(data));

    } on TimeoutException {
      throw AppException("Upload timeout. Please try again.");

    } on SocketException {
      throw AppException("Server unreachable. Check your connection.");

    } catch (e) {
      if (kDebugMode) {
        print("UPDATE PROFILE ERROR: $e");
      }

      if (e is AppException) rethrow;

      throw AppException("Unexpected error: $e");
    }
  }

  // =========================
  // SAFE JSON DECODER
  // =========================
  static Map<String, dynamic> _safeDecode(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {"error": "Invalid response format"};
    } catch (_) {
      return {"error": "Failed to parse response"};
    }
  }

  // =========================
  // ERROR NORMALIZER
  // =========================
  static String _extractError(Map<String, dynamic> data) {
    return data['message'] ??
        data['error'] ??
        'Failed to update profile.';
  }
}