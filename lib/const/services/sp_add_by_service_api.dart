import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/models/sp_live_location_model.dart';
import 'package:flutter_application_1/const/services/api_tokens_helper.dart';

class SpAddByServiceApi {
  static final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? '';

  static Future<List<SPLiveLocationModel>>
      fetchSPsByAddress(
    int serviceId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/service_providersDB/live-loc-by-service/$serviceId/',
    );

    try {
      final response = await http.get(
        url,
        headers: await ApiTokensHelper.authHeaders(),
      );

      if (kDebugMode) {
        print("========== SP API ==========");
        print("URL: $url");
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");
      print("============================");
      }
      

      if (response.statusCode != 200) {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.body}',
        );
      }

      final decoded =
          jsonDecode(response.body);

      if (kDebugMode) {
        print(
        "DECODED TYPE: ${decoded.runtimeType}",
      );
      }

      if (kDebugMode) {
        print(
        "DECODED DATA: $decoded",
      );
      }

      if (decoded is! Map<String, dynamic>) {
        throw Exception(
          'Invalid response format',
        );
      }

      final List<dynamic> data =
          decoded['data'] ?? [];

      if (kDebugMode) {
        print(
        "DATA COUNT: ${data.length}",
      );
      }

      return data
          .map(
            (item) =>
                SPLiveLocationModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print(
        "SP API ERROR: $e",
      );
      }

      if (kDebugMode) {
        print(stackTrace);
      }

      throw Exception(
        'SpAddByServiceApi error: $e',
      );
    }
  }
}