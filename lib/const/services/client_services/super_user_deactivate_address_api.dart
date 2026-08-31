import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:http/http.dart' as http;

class SuperUserDeactivateAddressHelper {
  static final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? '';

  static const Duration _timeout =
      Duration(seconds: 30);

  // =========================
  // SUPER USER DEACTIVATE
  // =========================
  static Future<bool> deactivateAddress({
  required int clientAddressId,
}) async {
  final url = Uri.parse(
    "$baseUrl/clientsDB/super-user/addresses/"
    "$clientAddressId/deactivate/",
  );

    try {
      final response =
          await ApiClient.instance.request((token) {
        return http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            if (token != null)
              "Authorization": "Bearer $token",
          },
          body: jsonEncode({}),
        );
      }).timeout(_timeout);

      if (kDebugMode) {
        print(
          "========== SUPER USER DEACTIVATE ADDRESS ==========",
        );
        print("URL: $url");
        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");
        print(
          "====================================================",
        );
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

        throw SuperUserDeactivateApiException(data);
      }

      // =========================
      // BACKEND ERROR
      // =========================
      throw SuperUserDeactivateApiException(data);
    } on TimeoutException {
      throw SuperUserDeactivateApiException({
        "message":
            "Request timed out. Please try again.",
      });
    } on SocketException {
      throw SuperUserDeactivateApiException({
        "message":
            "Server unreachable. Check your connection.",
      });
    } on SuperUserDeactivateApiException {
      rethrow;
    } catch (e) {
      throw SuperUserDeactivateApiException({
        "message":
            "Unexpected error: $e",
      });
    }
  }

  // =========================
  // SAFE JSON PARSER
  // =========================
  static Map<String, dynamic> _safeDecode(
    String body,
  ) {
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
// EXCEPTION
// =========================
class SuperUserDeactivateApiException
    implements Exception {
  final Map<String, dynamic> errors;

  SuperUserDeactivateApiException(this.errors);

  String get message {
    // =========================
    // MESSAGE
    // =========================
    final backendMessage = errors['message'];

    if (backendMessage is String &&
        backendMessage.isNotEmpty) {
      return backendMessage;
    }

    // =========================
    // VALIDATION ERRORS
    // =========================
    final validationErrors = errors['errors'];

    if (validationErrors is Map) {
      for (final value in validationErrors.values) {
        if (value is List &&
            value.isNotEmpty) {
          return value.first.toString();
        }

        if (value is String &&
            value.isNotEmpty) {
          return value;
        }
      }
    }

    // =========================
    // DETAIL
    // =========================
    final detail = errors['detail'];

    if (detail is String &&
        detail.isNotEmpty) {
      return detail;
    }

    // =========================
    // ERROR
    // =========================
    final error = errors['error'];

    if (error is String &&
        error.isNotEmpty) {
      return error;
    }

    return "Something went wrong. Please try again.";
  }

  @override
  String toString() => message;
}