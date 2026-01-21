import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/global_util/services/models/service_groups.dart';

class GroupsApi {
    static final String baseUrl = dotenv.env['API_BASE_URL'] ?? ''; // Change to your actual domain in production

  static Future<List<ServiceGroupModel>> fetchServices() async {
    final url = Uri.parse('$baseUrl/service_groups/'); // adjust endpoint if different

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => ServiceGroupModel.fromJson(item)).toList();
      
      } else {
        throw Exception('Failed to load groups: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching groups: $e');
    }
  }
}