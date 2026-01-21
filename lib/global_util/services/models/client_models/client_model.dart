import 'package:flutter_application_1/global_util/services/models/client_models/client_auth.dart';

class ClientDetailModel {
  final ClientAuthModel? clientProfile;
  final String? firstName;
  final String? lastName;
  final String? rating;
  final String? profilePic;      // maps to client_pp
  final DateTime? dateOfBirth;   // maps to date_of_birth
  final String? clientID;        // maps to client_ID

  ClientDetailModel({
    this.clientProfile,
    this.firstName,
    this.lastName,
    this.rating,
    this.profilePic,
    this.dateOfBirth,
    this.clientID,
  });

  factory ClientDetailModel.fromJson(Map<String, dynamic>? json) {
    json ??= {};

    // Parse date_of_birth safely
    DateTime? dob;
    if (json['date_of_birth'] != null && json['date_of_birth'].toString().isNotEmpty) {
      dob = DateTime.tryParse(json['date_of_birth']);
    }

    return ClientDetailModel(
      clientProfile: json['client_profile'] != null
          ? ClientAuthModel.fromJson(json['client_profile'] as Map<String, dynamic>)
          : null,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      rating: json['rating'] as String?,
      profilePic: json['client_pp'] as String?,
      dateOfBirth: dob,
      clientID: json['client_ID']?.toString(),
    );
  }
}
