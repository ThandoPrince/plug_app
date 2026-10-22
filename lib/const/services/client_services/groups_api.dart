
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_application_1/global_util/services/models/service_groups.dart';
import 'package:http/http.dart' as http;

class GroupsApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static const Duration _timeout = Duration(seconds: 60);


  static Future<List<ServiceGroupModel>> fetchServices() async {
    final url = Uri.parse('$baseUrl/service_groups/');

    try {
      final response = await ApiClient.instance.request((token) async {
        return await http
            .get(
              url,
              headers: {
                'Content-Type': 'application/json',
                if (token != null) 'Authorization': 'Bearer $token',
              },
            )
            .timeout(_timeout);
      }).timeout(_timeout);

      if (kDebugMode) {
        print('========== SERVICE GROUPS ==========');
        print('URL: $url');
        print('STATUS: ${response.statusCode}');
        print('BODY: ${response.body}');
        print('====================================');
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          return decoded
              .map(
                (item) => ServiceGroupModel.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList();
        }

        throw Exception('Invalid response format from server.');
      }

      String message = 'Failed to load service groups.';

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          message = decoded['message'] ??
              decoded['error'] ??
              decoded['detail'] ??
              message;
        }
      } catch (_) {
        // Ignore invalid JSON and use the default message.
      }

      throw Exception(message);
    } on TimeoutException {
      throw Exception(
        'Server timeout. Please try again.',
      );
    } on SocketException {
      throw Exception(
        'Server unreachable. Check your internet connection.',
      );
    } catch (e) {
      rethrow;
    }
  }
}

