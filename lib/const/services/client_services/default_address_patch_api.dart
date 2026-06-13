import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/const/services/api_tokens_helper.dart';

class DefaultAddressPatchApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Patch an address to be default
  Future<bool> setDefaultAddress({
    required int addressId,
    required String email,
  }) async {
    final url = Uri.parse(
      '$baseUrl/address-client/set-default/$addressId/?email=$email',
    );

    try {
      final response = await http.patch(
        url,
        headers: await ApiTokensHelper.authHeaders(),
      );

      if (kDebugMode) {
        print("Set Default Address HTTP: ${response.statusCode}");
        print("Response: ${response.body}");
      }

      if (response.statusCode == 200) {
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print("DefaultAddressPatchApi error: $e");
      }
      return false;
    }
  }
}
