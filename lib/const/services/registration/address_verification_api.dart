import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/api_client.dart';

class AddressVerificationHelper {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // Video uploads take longer than a couple of images — a 30s ceiling
  // was fine for two files, but is tight once a several-MB video is in
  // the same multipart request on a slower connection.
  static const Duration _timeout = Duration(seconds: 90);

  // =========================
  // UPLOAD VERIFICATION DOCUMENTS
  // =========================
  static Future<bool> uploadVerification({
    required int clientAddressId,
    required File proofOfResidence,
    required File idDocument,
    required File livenessVideo,
    required String idNumber,
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

            request.fields['id_number'] = idNumber;

            request.files.add(
  await http.MultipartFile.fromPath(
    'proof_of_residence',
    proofOfResidence.path,
    contentType: _getMediaType(proofOfResidence),
  ),
);

            request.files.add(
  await http.MultipartFile.fromPath(
    'id_document',
    idDocument.path,
    contentType: _getMediaType(idDocument),
  ),
);

            request.files.add(
  await http.MultipartFile.fromPath(
    'liveness_video',
    livenessVideo.path,
    contentType: _getMediaType(livenessVideo),
  ),
);
            return request;
          })
          .timeout(_timeout);

      // =========================
      // DEBUG LOGGING
      // =========================
      if (kDebugMode) {
        print("========== ADDRESS VERIFICATION ==========");
        print("URL: $uri");
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");
      print("==========================================");
      }
      

     

      final data = _safeDecode(response.body);

      // Backend successfully processed the request.
      // This can be 200, 201 or 202 depending on the verification state.
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (data['success'] == true) {
          return true;
        }

        // Backend processed the request but verification failed.
        throw ApiException(data);
      }

      // HTTP error from backend.
      throw ApiException(data);

        } on TimeoutException {
      throw ApiException({
        "message": "Upload timeout. Please try again.",
      });

    } on SocketException {
      throw ApiException({
        "message": "Server unreachable. Check your connection.",
      });

    } on ApiException {
      // IMPORTANT:
      // Preserve the original backend response.
      rethrow;

    } catch (e) {
      throw ApiException({
        "message": "Unexpected upload error: $e",
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
static MediaType _getMediaType(File file) {
  final extension = p.extension(file.path).toLowerCase();

  switch (extension) {
    case '.jpg':
    case '.jpeg':
      return MediaType('image', 'jpeg');

    case '.png':
      return MediaType('image', 'png');

    case '.pdf':
      return MediaType('application', 'pdf');

    case '.mp4':
      return MediaType('video', 'mp4');

    default:
      return MediaType('application', 'octet-stream');
  }
}

}

// =========================
// LOCAL EXCEPTION TYPE
// =========================
class ApiException implements Exception {
  final Map<String, dynamic> errors;

  ApiException(this.errors);

  String get message {
    // Backend response:
    // {"message": "ID document failed quality checks."}
    final backendMessage = errors['message'];

    if (backendMessage is String && backendMessage.isNotEmpty) {
      return backendMessage;
    }

    // Backend response:
    // {
    //   "errors": {
    //     "id_number": [
    //       "ID number must contain exactly 13 digits."
    //     ]
    //   }
    // }
    final validationErrors = errors['errors'];

    if (validationErrors is Map) {
      for (final value in validationErrors.values) {
        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        }

        if (value is String && value.isNotEmpty) {
          return value;
        }
      }
    }

    // FastAPI-style response
    final detail = errors['detail'];

    if (detail is String && detail.isNotEmpty) {
      return detail;
    }

    // Generic error
    final error = errors['error'];

    if (error is String && error.isNotEmpty) {
      return error;
    }

    return "Something went wrong. Please try again.";
  }

  @override
  String toString() => message;
}