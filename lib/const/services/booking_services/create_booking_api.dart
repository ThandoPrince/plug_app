import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_application_1/const/services/api_tokens_helper.dart';
import 'package:flutter_application_1/global_util/services/models/client_models/address_client_model.dart';
import 'package:flutter_application_1/global_util/services/models/service_provider_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class BookingApiResult {
  final bool success;
  final int? statusCode;
  final String message;
  final String? rawBody;

  const BookingApiResult({
    required this.success,
    required this.message,
    this.statusCode,
    this.rawBody,
  });
}

class BookingApiHelper {
  Future<BookingApiResult> submitBooking({
    required String clientEmail,
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
    final invitedProvidersEmails = selectedProviders
        .map((sp) => sp.spProfile.emailAddress.trim())
        .where((email) => email.isNotEmpty)
        .toList();

    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    if (baseUrl.isEmpty) {
      return const BookingApiResult(
        success: false,
        message: "API configuration is missing.",
      );
    }

    final uri = Uri.parse('$baseUrl/bookings/order_a_service/');

    final request = http.MultipartRequest('POST', uri);

    // =========================
    // AUTH HEADER FIX HERE
    // =========================
    request.headers.addAll(await ApiTokensHelper.authHeaders());

    final timeString =
        "${scheduled.hour.toString().padLeft(2, '0')}:"
        "${scheduled.minute.toString().padLeft(2, '0')}";

    final dateString =
        "${scheduled.year.toString().padLeft(4, '0')}-"
        "${scheduled.month.toString().padLeft(2, '0')}-"
        "${scheduled.day.toString().padLeft(2, '0')}";

    request.fields['client'] = clientEmail;
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

    for (final email in invitedProvidersEmails) {
      request.files.add(
        http.MultipartFile.fromString('invited_providers', email),
      );
    }

    for (final file in bookingImages) {
      if (!await file.exists()) {
        return const BookingApiResult(
          success: false,
          message: "Image file missing.",
        );
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'service_pictures',
          file.path,
        ),
      );
    }

    try {
      final response = await request.send().timeout(
        const Duration(seconds: 45),
      );

      final body = await response.stream.bytesToString();
      final parsed = _extractErrorMessage(body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return BookingApiResult(
          success: true,
          statusCode: response.statusCode,
          message: "Booking submitted successfully",
          rawBody: body,
        );
      }

      return BookingApiResult(
        success: false,
        statusCode: response.statusCode,
        message: parsed ??
            "Request failed (${response.statusCode})",
        rawBody: body,
      );
    } catch (e) {
      return BookingApiResult(
        success: false,
        message: "Booking failed: $e",
      );
    }
  }

  static String? _extractErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        return decoded.values.join("\n");
      }

      if (decoded is List) {
        return decoded.join("\n");
      }
    } catch (_) {}

    return body;
  }
}