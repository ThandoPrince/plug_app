import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_application_1/global_util/services/models/client_models/address_client_model.dart';
import 'package:flutter_application_1/global_util/services/models/service_provider_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class BookingApiResult {
  final bool success;
  final int? statusCode;
  final String message;
  final String? type;
  final String? rawBody;

  const BookingApiResult({
    required this.success,
    required this.message,
    this.statusCode,
    this.type,
    this.rawBody,
  });
}

class BookingApiHelper {
  Future<BookingApiResult> submitBooking({
    required String clientId,
    required String title,
    required String notes,
    required DateTime scheduled,
    required AddressClientModel defaultAddress,
    required List<ServiceProviderModel> selectedProviders,
    required int serviceId,
    required List<File> bookingImages,
    required double? averagePrice,
    required double negotiatedPrice,
  }) async {
    final invitedProviderIds = selectedProviders
        .map((sp) => sp.spProfile?.id)
        .whereType<int>()
        .toList();

    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    if (baseUrl.isEmpty) {
      return const BookingApiResult(
        success: false,
        message: "API configuration is missing.",
        type: "config_error",
      );
    }

    final uri = Uri.parse('$baseUrl/bookings/order_a_service/');

    final timeString =
        "${scheduled.hour.toString().padLeft(2, '0')}:"
        "${scheduled.minute.toString().padLeft(2, '0')}";

    final dateString =
        "${scheduled.year.toString().padLeft(4, '0')}-"
        "${scheduled.month.toString().padLeft(2, '0')}-"
        "${scheduled.day.toString().padLeft(2, '0')}";

    try {
      final response = await ApiClient.instance.multipartRequest(
        (token) async {
          final request = http.MultipartRequest('POST', uri);

          request.headers.addAll({
            "Content-Type": "multipart/form-data",
            if (token != null) "Authorization": "Bearer $token",
          });

          request.fields['client'] = clientId.toString();
          request.fields['title'] = title;
          request.fields['notes'] = notes;
          request.fields['requested_date_time'] = timeString;
          request.fields['requested_date'] = dateString;
          request.fields['delivery_address'] =
              defaultAddress.address.placeId.toString();
          request.fields['status'] = "pending";
          request.fields['is_broadcasted'] = "true";
          request.fields['service_required'] = serviceId.toString();
          request.fields['base_price'] =
              (averagePrice ?? 0.0).toStringAsFixed(2);
          request.fields['proposal_price'] =
              negotiatedPrice.toStringAsFixed(2);
          request.fields['is_negotiated'] = "true";

          request.fields['invited_providers'] =
              jsonEncode(invitedProviderIds);

          for (final file in bookingImages) {
            if (!await file.exists()) {
              throw Exception("Image file missing");
            }

            request.files.add(
              await http.MultipartFile.fromPath(
                'service_pictures',
                file.path,
              ),
            );
          }

          return request;
        },
      ).timeout(const Duration(seconds: 45));

      final body = response.body;
      final decoded = _safeDecode(body);

      // =========================
      // SUCCESS
      // =========================
      if (response.statusCode == 200 || response.statusCode == 201) {
        return BookingApiResult(
          success: true,
          statusCode: response.statusCode,
          message: "Booking submitted successfully",
          rawBody: body,
          type: "success",
        );
      }

      // =========================
      // AUTH ERROR
      // =========================
      if (response.statusCode == 401 || response.statusCode == 403) {
        return BookingApiResult(
          success: false,
          statusCode: response.statusCode,
          message: _extractMessage(decoded) ?? "Authentication failed",
          rawBody: body,
          type: "auth_error",
        );
      }

      // =========================
      // VALIDATION ERROR
      // =========================
      if (response.statusCode == 400) {
        return BookingApiResult(
          success: false,
          statusCode: response.statusCode,
          message: _extractMessage(decoded) ?? "Invalid booking payload",
          rawBody: body,
          type: "validation_error",
        );
      }

      // =========================
      // SERVER ERROR
      // =========================
      if (response.statusCode >= 500) {
        return BookingApiResult(
          success: false,
          statusCode: response.statusCode,
          message: "Server error",
          rawBody: body,
          type: "server_error",
        );
      }

      return BookingApiResult(
        success: false,
        statusCode: response.statusCode,
        message: "Request failed (${response.statusCode})",
        rawBody: body,
        type: "unknown_error",
      );
    } on TimeoutException {
      return const BookingApiResult(
        success: false,
        message: "Request timed out",
        type: "timeout",
      );
    } catch (e) {
      return BookingApiResult(
        success: false,
        message: "Booking failed: $e",
        type: "exception",
      );
    }
  }

  // -------------------------
  // SAFE JSON DECODER
  // -------------------------
  dynamic _safeDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  // -------------------------
  // MESSAGE EXTRACTOR
  // -------------------------
  String? _extractMessage(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      if (decoded.containsKey('message')) return decoded['message']?.toString();
      if (decoded.containsKey('detail')) return decoded['detail']?.toString();
      return decoded.values.join("\n");
    }

    if (decoded is List) {
      return decoded.join("\n");
    }

    return null;
  }
}