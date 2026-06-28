import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/api_client.dart';

class AddressVerificationHelper {
  static final String baseUrl = dotenv.env['API_BASE_URL_NEW'] ?? '';

  static const Duration _timeout = Duration(seconds: 30);

  // =========================
  // UPLOAD VERIFICATION DOCUMENTS
  // =========================
  static Future<bool> uploadVerification({
    required int clientAddressId,
    required File proofOfResidence,
    required File idDocument,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/clientsDB/address/verify/$clientAddressId/',
    );

    try {
      final response = await ApiClient.instance
          .multipartRequest((token) async {
            final request = http.MultipartRequest('POST', uri);

            if (token != null) {
              request.headers['Authorization'] = 'Bearer $token';
            }

            request.files.add(
              await http.MultipartFile.fromPath(
                'proof_of_residence',
                proofOfResidence.path,
              ),
            );

            request.files.add(
              await http.MultipartFile.fromPath(
                'id_document',
                idDocument.path,
              ),
            );

            return request;
          })
          .timeout(_timeout);

      // =========================
      // DEBUG LOGGING
      // =========================
      print("========== ADDRESS VERIFICATION ==========");
      print("URL: $uri");
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");
      print("==========================================");

      if (response.statusCode == 201) {
        return true;
      }

      final data = _safeDecode(response.body);

      throw ApiException(data);

    } on TimeoutException {
      throw ApiException({
        "error": "Upload timeout. Please try again."
      });

    } on SocketException {
      throw ApiException({
        "error": "Server unreachable. Check your connection."
      });

    } catch (e) {
      throw ApiException({
        "error": "Unexpected upload error: $e"
      });
    }
  }

  // =========================
  // SAFE JSON PARSER
  // =========================
  static Map<String, dynamic> _safeDecode(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {"error": "Invalid response format"};
    } catch (_) {
      return {"error": "Failed to parse server response"};
    }
  }
}

// =========================
// LOCAL EXCEPTION TYPE
// =========================
class ApiException implements Exception {
  final Map<String, dynamic> errors;

  ApiException(this.errors);

  @override
  String toString() => errors.toString();
}