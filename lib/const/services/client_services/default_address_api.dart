import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/const/services/api_tokens_helper.dart';

class DefaultAddressApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Set default address for a client email
  static Future<void> setDefaultAddress({
    
    required int addressId,
  }) async {
    final id =  AuthSessionController.instance.clientId;
    final url = Uri.parse(
      
      '$baseUrl/clientsDB/set-default-address/$id/',
    );

    try {
      final response = await http.post(
        url,
        headers: await ApiTokensHelper.authHeaders(),
        body: jsonEncode({
          'address_id': addressId,
        }),
      );

      if (kDebugMode) {
        print("Set Default Address HTTP: ${response.statusCode}");
        print("Response: ${response.body}");
      }

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to set default address: ${response.body}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("DefaultAddressApi error: $e");
      }
      rethrow;
    }
  }
}
