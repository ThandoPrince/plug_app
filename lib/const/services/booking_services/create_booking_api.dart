import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
        .toSet()
        .toList();

    final String baseUrl = (dotenv.env['API_BASE_URL'] ?? '');
    if (baseUrl.isEmpty) {
      return const BookingApiResult(
        success: false,
        message: "API configuration is missing. Please check API_BASE_URL.",
      );
    }

    final uri = Uri.tryParse('$baseUrl/bookings/order_a_service/');
    if (uri == null) {
      return const BookingApiResult(
        success: false,
        message: "The booking URL is invalid.",
      );
    }

    final request = http.MultipartRequest('POST', uri);

    final timeString =
        "${scheduled.hour.toString().padLeft(2, '0')}:${scheduled.minute.toString().padLeft(2, '0')}";
    final dateString =
        "${scheduled.year.toString().padLeft(4, '0')}-"
        "${scheduled.month.toString().padLeft(2, '0')}-"
        "${scheduled.day.toString().padLeft(2, '0')}";

    request.fields['client'] = clientEmail;
    request.fields['title'] = title;
    request.fields['notes'] = notes;
    request.fields['requested_date_time'] = timeString;
    request.fields['requested_date'] = dateString;
    request.fields['delivery_address'] = defaultAddress.address.placeId.toString();
    request.fields['status'] = "pending";
    request.fields['is_broadcasted'] = "true";
    request.fields['service_required'] = serviceId.toString();
    request.fields['base_price'] =
        averagePrice != null ? averagePrice.toStringAsFixed(2) : "0.0";
    request.fields['proposal_price'] = negotiatedPrice.toStringAsFixed(2);
    request.fields['is_negotiated'] = "true";

    for (final providerEmail in invitedProvidersEmails) {
      request.files.add(
        http.MultipartFile.fromString('invited_providers', providerEmail),
      );
    }

    for (final file in bookingImages) {
      if (!await file.exists()) {
        return const BookingApiResult(
          success: false,
          message: "One of the selected images could not be found.",
        );
      }

      request.files.add(
        await http.MultipartFile.fromPath('service_pictures', file.path),
      );
    }

    try {
      final response = await request.send().timeout(
        const Duration(seconds: 45),
      );

      final respStr = await response.stream.bytesToString();
      final parsedMessage = _extractErrorMessage(respStr);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return BookingApiResult(
          success: true,
          statusCode: response.statusCode,
          message: "Booking submitted successfully",
          rawBody: respStr,
        );
      }

      if (response.statusCode == 400) {
        return BookingApiResult(
          success: false,
          statusCode: response.statusCode,
          message: parsedMessage ??
              "Invalid booking details. Please review your input.",
          rawBody: respStr,
        );
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        return BookingApiResult(
          success: false,
          statusCode: response.statusCode,
          message: parsedMessage ??
              "You are not authorized. Please log in again.",
          rawBody: respStr,
        );
      }

      if (response.statusCode == 404) {
        return BookingApiResult(
          success: false,
          statusCode: response.statusCode,
          message: parsedMessage ?? "Booking service not found.",
          rawBody: respStr,
        );
      }

      if (response.statusCode >= 500) {
        return BookingApiResult(
          success: false,
          statusCode: response.statusCode,
          message:
              "The server is currently unavailable. Please try again shortly.",
          rawBody: respStr,
        );
      }

      return BookingApiResult(
        success: false,
        statusCode: response.statusCode,
        message:
            parsedMessage ?? "Request failed with status ${response.statusCode}.",
        rawBody: respStr,
      );
    } on SocketException {
      return const BookingApiResult(
        success: false,
        message: "No internet connection. Please check your network and try again.",
      );
    } on HttpException {
      return const BookingApiResult(
        success: false,
        message: "A network error occurred while submitting your booking.",
      );
    } on FormatException {
      return const BookingApiResult(
        success: false,
        message: "The server returned an unexpected response.",
      );
    } on TimeoutException {
      return const BookingApiResult(
        success: false,
        message: "The request took too long. Please try again.",
      );
    } catch (e) {
      return BookingApiResult(
        success: false,
        message: "Failed to submit booking. ${e.toString()}",
      );
    }
  }

  static String? _extractErrorMessage(String responseBody) {
    if (responseBody.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(responseBody);

      if (decoded is Map<String, dynamic>) {
        final messages = <String>[];

        decoded.forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            messages.add(value.join(", "));
          } else if (value is String && value.trim().isNotEmpty) {
            messages.add(value);
          } else if (value is Map<String, dynamic>) {
            value.forEach((nestedKey, nestedValue) {
              if (nestedValue is List && nestedValue.isNotEmpty) {
                messages.add(nestedValue.join(", "));
              } else if (nestedValue is String &&
                  nestedValue.trim().isNotEmpty) {
                messages.add(nestedValue);
              }
            });
          }
        });

        if (messages.isNotEmpty) {
          return messages.join("\n");
        }
      }

      if (decoded is List && decoded.isNotEmpty) {
        return decoded.join("\n");
      }
    } catch (_) {
      return responseBody;
    }

    return responseBody;
  }
}