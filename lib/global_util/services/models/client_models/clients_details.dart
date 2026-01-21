import 'package:flutter_application_1/global_util/services/models/client_models/client_auth.dart';

class ClientModel {
  final ClientAuthModel clientProfile;
  final String firstName;
  final String lastName;
  final String rating;

  ClientModel({
    required this.clientProfile,
    required this.firstName,
    required this.lastName,
    required this.rating,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      clientProfile: ClientAuthModel.fromJson(
        json['client_profile'] as Map<String, dynamic>? ?? {},
      ),
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      rating: json['rating'] as String? ?? '0.00',
    );
  }
}
