// service_provider_api.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/global_util/services/models/service_provider_model.dart';


class ServiceProviderApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<List<ServiceProviderModel>> fetchAllServiceProviders(int serviceId) async {
    final url = Uri.parse('$baseUrl/service_providers/?service_id=$serviceId');
    final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    if (kDebugMode) {
      print('Response body: ${response.body}');
    }
    return data.map((item) => ServiceProviderModel.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load service providers');
  }
}
  }

  // static Future<ServiceProviderModel> fetchProviderByEmail(String email) async {
  //   final url = Uri.parse('$baseUrl/service_providers/$email/');
  //   final response = await http.get(url);

  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> jsonData = json.decode(response.body);
  //     return ServiceProviderModel.fromJson(jsonData);
  //   } else {
  //     throw Exception('Failed to load service provider: ${response.statusCode}');
  //   }
  // }

