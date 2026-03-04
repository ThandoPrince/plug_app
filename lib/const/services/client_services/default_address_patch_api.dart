// api_helper_client_address.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class DefaultAddressPatchApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Patch an address to be default
  Future<bool> setDefaultAddress({required int addressId, required String email}) async {
    
    final url = Uri.parse('$baseUrl/address-client/set-default/$addressId/?email=$email');

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer $token', // adjust if you use another auth method
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to set default: ${response.statusCode} ${response.body}');
      return false;
    }
  }
}