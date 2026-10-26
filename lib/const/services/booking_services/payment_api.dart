// Shared by both apps. Copy into each (e.g. lib/common/services/payment_api.dart).
import 'dart:convert';

import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/payment_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;



class PaymentApiException implements Exception {
  final String message;
  final int? statusCode;
  const PaymentApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class PaymentApi {
  PaymentApi._();

  // Assumes the payments urls are mounted under /bookings/. Adjust if you mounted them elsewhere.
  static Uri _uri(String path) =>
      Uri.parse('${dotenv.env['API_BASE_URL']}/payments/$path');

  static Map<String, String> _headers(String? token) => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  static Future<http.Response> _get(Uri url) => ApiClient.instance
      .request((token) => http.get(url, headers: _headers(token)));

  static Future<http.Response> _post(Uri url, {Object? body}) =>
      ApiClient.instance.request(
        (token) => http.post(url, headers: _headers(token), body: body),
      );

  static Map<String, dynamic> _decode(http.Response r) {
    dynamic body;
    try {
      body = r.body.isEmpty ? <String, dynamic>{} : jsonDecode(r.body);
    } catch (_) {
      body = null;
    }

    if (r.statusCode < 200 || r.statusCode >= 300) {
      final detail = body is Map ? body['detail']?.toString() : null;
      throw PaymentApiException(
        detail ?? 'Payment request failed. Please try again.',
        statusCode: r.statusCode,
      );
    }
    if (body is! Map<String, dynamic>) {
      throw const PaymentApiException('Unexpected response from server.');
    }
    return body;
  }

  /// Client taps Cash or Card.
  static Future<Payment> selectMethod({
    required int shipmentId,
    required PaymentMethod method,
  }) async {
    final r = await _post(
      _uri('select-method/'),
      body: jsonEncode({'shipment_id': shipmentId, 'method': method.apiValue}),
    );
    return Payment.fromJson(_decode(r));
  }

  /// Client, after the provider has scanned. Returns the payment with `checkout` filled in.
  static Future<Payment> initiateCard(int paymentId) async {
    final r = await _post(_uri('$paymentId/initiate/'));
    return Payment.fromJson(_decode(r));
  }

  /// Both apps. Returns null when no payment exists yet.
  static Future<Payment?> forShipment(int shipmentId) async {
    final r = await _get(_uri('shipment/$shipmentId/'));
    if (r.statusCode == 404) return null;
    return Payment.fromJson(_decode(r));
  }
}