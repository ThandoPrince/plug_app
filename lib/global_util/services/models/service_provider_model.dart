import 'package:flutter_application_1/global_util/services/models/sp_profile_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ServiceProviderModel {
  final double? rating;
  final String? description;
  final String? profileImage;

  final String? fullName;
  final String? gender;
  final String? dob;

  final int? locationId;
final bool? isActive;
  final SPProfileModel? spProfile;

  

  ServiceProviderModel({
    this.rating,
    this.description,
    this.isActive,
    this.profileImage,
    this.fullName,
    this.gender,
    this.dob,
    this.locationId,
    this.spProfile,

  });

  factory ServiceProviderModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ServiceProviderModel();

    return ServiceProviderModel(
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,

          isActive: json['is_active'] is bool
          ? json['is_active']
          : json['is_active']?.toString() == 'true',

      description: json['sp_description']?.toString(),
      profileImage: json['profile_image']?.toString(),
      gender: json['gender']?.toString(),
      fullName: json['full_name']?.toString(),
      dob: json['dob']?.toString(),

      locationId: json['location'] is int
          ? json['location']
          : int.tryParse(json['location']?.toString() ?? ''),

      spProfile: json['sp_profile'] != null
          ? SPProfileModel.fromJson(json['sp_profile'])
          : null,

      
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'sp_description': description,
      'profile_image': profileImage,
      'full_name': fullName,
      'gender': gender,
      'dob': dob,
      'location': locationId,
      'is_active': isActive,
      'sp_profile': spProfile?.toJson(),
      
    };
  }

  String? get profileImageUrl {
    final baseUrl = dotenv.env['MEDIA_BASE_URL'];
    if (baseUrl == null || profileImage == null) return null;
    return "$baseUrl$profileImage";
  }
}