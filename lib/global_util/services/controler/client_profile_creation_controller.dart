import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_application_1/const/services/api_tokens_helper.dart';

class ClientDetailsController with ChangeNotifier {
  bool isLoading = false;
  String? error;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  String? profileImagePath;

  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<bool> patchClientDetails(String email) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final uri = Uri.parse(
        "$baseUrl/clientsDB/client/profile/complete/",
      );

      var request = http.MultipartRequest('PATCH', uri);

      request.headers['Authorization'] =
    'Bearer ${AuthSessionController.instance.accessToken}';

      request.fields['first_name'] =
          firstNameController.text.trim();
      request.fields['last_name'] =
          lastNameController.text.trim();
      request.fields['date_of_birth'] =
          dobController.text.trim();

      if (profileImagePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'client_pp',
            profileImagePath!,
          ),
        );
      }

      if (kDebugMode) {
  print("========== PROFILE UPDATE REQUEST ==========");
  print("URL: ${request.url}");
  print("METHOD: ${request.method}");

  print("HEADERS:");
  request.headers.forEach((key, value) {
    print("$key: $value");
  });

  print("FIELDS:");
  request.fields.forEach((key, value) {
    print("$key: $value");
  });

  print("FILES:");
  for (final file in request.files) {
    print(
      "Field: ${file.field}, "
      "Filename: ${file.filename}, "
      "Length: ${file.length}",
    );
  }

  print("===========================================");
}

      var response = await request.send();

      final respStr =
          await response.stream.bytesToString();

      if (response.statusCode == 200) {
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(respStr);

        if (data is Map &&
            data.containsKey('client_pp')) {
          error = data['client_pp'][0];
        } else {
          error =
              data['error'] ?? "Failed to update profile";
        }
      }
    } catch (e) {
      error = "An error occurred: $e";
    }

    isLoading = false;
    notifyListeners();
    return false;
  }
}

extension DateUtils on String {
  /// Returns age in years from a yyyy-MM-dd string
  int toAge() {
    try {
      final dob = DateTime.parse(this);
      final today = DateTime.now();
      int age = today.year - dob.year;
      if (today.month < dob.month ||
          (today.month == dob.month && today.day < dob.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return 0;
    }
  }
}
