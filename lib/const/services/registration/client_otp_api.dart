import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ClientOtpApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static const Duration _timeout = Duration(seconds: 60);

  // =========================
  // VERIFY CLIENT LOGIN OTP
  // =========================
  static Future<Map<String, dynamic>> verifyOtp({
    required String otp,
  }) async {
    final auth = AuthSessionController.instance;

   
    final verificationToken = auth.verificationToken;

    

    if (verificationToken == null || verificationToken.isEmpty) {
      throw Exception(
        "Verification session is invalid. Please request a new OTP.",
      );
    }

    final url = Uri.parse(
      '$baseUrl/client/login/verify-email/',
    );

    try {
      final response = await http
    .post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $verificationToken",
      },
      body: jsonEncode({
        "otp": otp.trim(),
      }),
    )
    .timeout(_timeout);

      if (kDebugMode) {
        print("========== CLIENT OTP VERIFY API ==========");
        print("URL: $url");
        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");
        print("============================================");
      }

      final data = _decodeResponse(response);

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return data;
      }

      throw Exception(
        _extractError(
          response.statusCode,
          data,
        ),
      );
    } on TimeoutException {
      throw Exception(
        "The verification request timed out. Please try again.",
      );
    } on SocketException {
      throw Exception(
        "Unable to reach the server. Check your internet connection.",
      );
    } on FormatException {
      throw Exception(
        "Invalid response received from the server.",
      );
    } on Exception {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print("Unexpected OTP verification error: $e");
      }

      throw Exception(
        "An unexpected error occurred. Please try again.",
      );
    }
  }


  static Future<Map<String, dynamic>> resendOtp() async {
  final auth = AuthSessionController.instance;
  final verificationToken = auth.verificationToken;

  if (verificationToken == null || verificationToken.isEmpty) {
    throw Exception(
      "Verification session is invalid. Please register again.",
    );
  }

  final url = Uri.parse('$baseUrl/client/login/resend-otp/');

  try {
    final response = await http
        .post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $verificationToken",
          },
        )
        .timeout(_timeout);

    if (kDebugMode) {
      print("========== CLIENT OTP RESEND API ==========");
      print("URL: $url");
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");
      print("=============================================");
    }

    final data = _decodeResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
  final newToken = data["data"]?["verification_token"];
  final newRequestId = data["data"]?["otp_request_id"];

  if (newToken is String && newToken.isNotEmpty) {
    await auth.updateVerificationToken(
      newToken,
      otpRequestId: newRequestId is String ? newRequestId : null,
    );
  }

  return data;
}

    throw Exception(_extractError(response.statusCode, data));
  } on TimeoutException {
    throw Exception("The request timed out. Please try again.");
  } on SocketException {
    throw Exception("Unable to reach the server. Check your internet connection.");
  } on FormatException {
    throw Exception("Invalid response received from the server.");
  } on Exception {
    rethrow;
  } catch (e) {
    if (kDebugMode) print("Unexpected OTP resend error: $e");
    throw Exception("An unexpected error occurred. Please try again.");
  }
}

  // =========================
  // RESPONSE DECODER
  // =========================
  static Map<String, dynamic> _decodeResponse(
    http.Response response,
  ) {
    if (response.body.trim().isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        "data": decoded,
      };
    } catch (_) {
      throw const FormatException(
        "Server returned an invalid JSON response.",
      );
    }
  }

  // =========================
  // ERROR PARSER
  // =========================
  static String _extractError(
    int statusCode,
    Map<String, dynamic> data,
  ) {
    // Standard API messages
    final message = data["message"];

    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }

    final error = data["error"];

    if (error is String && error.trim().isNotEmpty) {
      return error.trim();
    }

    final detail = data["detail"];

    if (detail is String && detail.trim().isNotEmpty) {
      return detail.trim();
    }

    // DRF-style field errors
    final errors = data["errors"];

    if (errors is Map) {
      final messages = <String>[];

      errors.forEach((key, value) {
        if (value is List) {
          for (final item in value) {
            if (item != null && item.toString().trim().isNotEmpty) {
              messages.add(item.toString());
            }
          }
        } else if (value != null &&
            value.toString().trim().isNotEmpty) {
          messages.add(value.toString());
        }
      });

      if (messages.isNotEmpty) {
        return messages.join("\n");
      }
    }

    // Direct DRF field errors
    final fieldMessages = <String>[];

    for (final entry in data.entries) {
      if (entry.key == "message" ||
          entry.key == "error" ||
          entry.key == "detail" ||
          entry.key == "success" ||
          entry.key == "data") {
        continue;
      }

      final value = entry.value;

      if (value is List) {
        for (final item in value) {
          if (item != null &&
              item.toString().trim().isNotEmpty) {
            fieldMessages.add(item.toString());
          }
        }
      } else if (value != null &&
          value.toString().trim().isNotEmpty) {
        fieldMessages.add(value.toString());
      }
    }

    if (fieldMessages.isNotEmpty) {
      return fieldMessages.join("\n");
    }

    // HTTP fallback
    switch (statusCode) {
      case 400:
        return "Invalid OTP request. Please check your OTP and try again.";

      case 401:
        return "Your verification session is invalid or has expired. Please request a new OTP.";

      case 403:
        return "OTP verification is not permitted for this request.";

      case 404:
        return "OTP verification request was not found. Please request a new OTP.";

      case 409:
        return "This OTP has already been used. Please request a new OTP.";

      case 429:
        return "Too many OTP attempts. Please wait before trying again.";

      case 500:
      case 502:
      case 503:
      case 504:
        return "The verification service is temporarily unavailable. Please try again.";

      default:
        return "OTP verification failed. Please try again.";
    }
  }
}