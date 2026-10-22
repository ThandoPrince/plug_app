import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class RoundSendResult {
  final bool success;
  final String? error;
  const RoundSendResult.ok() : success = true, error = null;
  const RoundSendResult.fail(this.error) : success = false;
}

class NegotiatiationRoundStartApi {
  static final String coreUrl = dotenv.env['API_BASE_URL'] ?? '';

  static final String baseUrl =
      "$coreUrl/bookings/service_orders/negotiation/rounds";

  static const _unreachableMsg =
      "Can't reach the server. Check your connection and try again.";

  static Future<RoundSendResult> startClientRound({
    required int negotiationId,
    required double offeredPrice,
    String? message,
  }) async {
    final url = Uri.parse("$baseUrl/$negotiationId/client_start_round/");

    try {
      final response = await ApiClient.instance.request((token) {
        return http
            .post(
              url,
              headers: {
                "Content-Type": "application/json",
                if (token != null) "Authorization": "Bearer $token",
              },
              body: jsonEncode({
  "offered_price": offeredPrice,
  if (message != null && message.trim().isNotEmpty) "message": message.trim(),
}),
            )
            .timeout(const Duration(seconds: 60));
      });

      if (response.statusCode == 201) return const RoundSendResult.ok();

      debugPrint("ROUND SEND FAILED: ${response.statusCode} → ${response.body}");

      if (response.statusCode == 401 || response.statusCode == 403) {
        return const RoundSendResult.fail(
            "Your session has expired. Please sign in again.");
      }
      if (response.statusCode >= 500) {
        return const RoundSendResult.fail(
            "Something went wrong on our side. Please try again.");
      }
      return RoundSendResult.fail(_extractError(response.body));
    } on TimeoutException {
      return const RoundSendResult.fail(
          "The server took too long to respond. Please try again.");
    } on SocketException {
      return const RoundSendResult.fail(_unreachableMsg);
    } on http.ClientException {
      return const RoundSendResult.fail(_unreachableMsg);
    } catch (e) {
      debugPrint("ROUND SEND ERROR: $e");
      return const RoundSendResult.fail("Failed to send round");
    }
  }

  /// Handles {"error": "..."}, {"detail": "..."} and DRF field errors
  /// like {"offered_price": ["A valid number is required."]}.
  static String _extractError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        for (final key in ['error', 'detail', 'message']) {
          final v = decoded[key];
          if (v is String && v.isNotEmpty) return v;
        }
        final parts = <String>[];
        decoded.forEach((_, v) {
          if (v is List && v.isNotEmpty) {
            parts.add(v.first.toString());
          } else if (v is String && v.isNotEmpty) {
            parts.add(v);
          }
        });
        if (parts.isNotEmpty) return parts.join('\n');
      }
    } catch (_) {}
    return "Failed to send round";
  }
}