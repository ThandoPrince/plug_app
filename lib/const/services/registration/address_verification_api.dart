import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';



class AddressVerificationHelper {
  static final String baseUrl = dotenv.env['API_BASE_URL_NEW'] ?? '';

  static Future<bool> uploadVerification({
    required int clientAddressId,
    required File proofOfResidence,
    required File idDocument,
  }) async {

    final uri = Uri.parse('$baseUrl/clientsDB/address/verify/$clientAddressId/');

    final request = http.MultipartRequest('POST', uri);

    final token = AuthSessionController.instance.accessToken;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.files.add(await http.MultipartFile.fromPath(
      'proof_of_residence',
      proofOfResidence.path,
    ));

    request.files.add(await http.MultipartFile.fromPath(
      'id_document',
      idDocument.path,
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return true;
    }

    // -------------------------------------------------
    // 🔥 STRUCTURED ERROR HANDLING
    // -------------------------------------------------
    try {
      final data = jsonDecode(response.body);

      throw ApiException(data);
    } catch (_) {
      throw ApiException({
        "non_field_errors": "Failed to submit verification."
      });
    }
  }
}

class ApiException implements Exception {
  final Map<String, dynamic> errors;

  ApiException(this.errors);

  @override
  String toString() => errors.toString();
}