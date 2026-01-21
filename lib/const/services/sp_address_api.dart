import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/global_util/services/models/sp_address_model.dart';

class AddressApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<SpAddressModel> fetchAddressById(int id) async {
    final url = Uri.parse('$baseUrl/serviceProvidersDB/address/$id/');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return SpAddressModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load address: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching address: $e');
    }
  }

  static Future<List<SpAddressModel>> fetchAllAddresses() async {
    final url = Uri.parse('$baseUrl/address/');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => SpAddressModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load addresses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching addresses: $e');
    }
  }
}
