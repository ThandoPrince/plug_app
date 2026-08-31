import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:http/http.dart' as http;

class DeactivateAddressHelper {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static const Duration _timeout = Duration(seconds: 30);

  // =========================
  // DEACTIVATE CLIENT ADDRESS
  // =========================
  static Future<bool> deactivateAddress({
    required int clientAddressId,
  }) async {
    final url = Uri.parse(
      "$baseUrl/clientsDB/addresses/$clientAddressId/deactivate/",
    );

    try {
      final response = await ApiClient.instance.request((token) {
        return http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            if (token != null)
              "Authorization": "Bearer $token",
          },
        );
      }).timeout(_timeout);

      if (kDebugMode) {
        print("========== DEACTIVATE ADDRESS ==========");
        print("URL: $url");
        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");
        print("========================================");
      }

      final data = _safeDecode(response.body);

      // =========================
      // SUCCESS
      // =========================
      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        if (data['success'] == true) {
          return true;
        }

        throw ApiException(data);
      }

      // =========================
      // BACKEND ERROR
      // =========================
      throw ApiException(data);

    } on TimeoutException {
      throw ApiException({
        "message": "Request timed out. Please try again.",
      });

    } on SocketException {
      throw ApiException({
        "message": "Server unreachable. Check your connection.",
      });

    } on ApiException {
      rethrow;

    } catch (e) {
      throw ApiException({
        "message": "Unexpected error: $e",
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

      return {
        "error": "Invalid response format",
      };
    } catch (_) {
      return {
        "error": "Failed to parse server response",
      };
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
    // Backend:
    // {"message": "..."}
    final backendMessage = errors['message'];

    if (backendMessage is String &&
        backendMessage.isNotEmpty) {
      return backendMessage;
    }

    // Backend:
    // {
    //   "errors": {
    //     "field": ["..."]
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

    // FastAPI-style:
    // {"detail": "..."}
    final detail = errors['detail'];

    if (detail is String && detail.isNotEmpty) {
      return detail;
    }

    // Generic:
    // {"error": "..."}
    final error = errors['error'];

    if (error is String && error.isNotEmpty) {
      return error;
    }

    return "Something went wrong. Please try again.";
  }

  @override
  String toString() => message;
}