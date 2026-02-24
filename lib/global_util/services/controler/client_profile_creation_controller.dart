import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ClientDetailsController with ChangeNotifier {
  bool isLoading = false;
  String? error;

  // Text controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  // Optional profile picture path
  String? profileImagePath;

  // Base URL from dotenv
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  

  // PATCH request to update client profile
  Future<bool> patchClientDetails(String email) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Build URI
      final uri = Uri.parse("$baseUrl/clientsDB/client/$email/complete-profile/");

      // Multipart request
      var request = http.MultipartRequest('PATCH', uri);

      // Add text fields
      request.fields['first_name'] = firstNameController.text.trim();
      request.fields['last_name'] = lastNameController.text.trim();
      request.fields['date_of_birth'] = dobController.text.trim();

      // Add profile picture if available
      if (profileImagePath != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'client_pp', // Must match your DRF serializer field name
          profileImagePath!,
        ));
      }

      // Send request
      var response = await request.send();

      // Parse response
      final respStr = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(respStr);
        // Handle DRF field errors or generic errors
        if (data is Map && data.containsKey('client_pp')) {
          error = data['client_pp'][0];
        } else {
          error = data['error'] ?? "Failed to update profile";
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
      if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return 0;
    }
  }
}
