import 'package:flutter_application_1/global_util/services/models/cost_of_service_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'sp_address_model.dart';
import 'sp_profile_model.dart';



class ServiceProviderModel {
 
  final double? rating;
  final String? description;
  final String? profileImage;
  final String fullName;
  final String idNumber;
  final String gender;
  final String dob;

  final SpAddressModel?
      location; // nullable to handle missing or invalid location
  final SPProfileModel spProfile;
  
  final List<CostOfServiceModel>
      costOfServices; // list of services, not just one

  ServiceProviderModel({

    this.rating,
    this.description,
    required this.costOfServices,
    this.profileImage,
    required this.gender,
    required this.fullName,
    required this.idNumber,
    required this.dob,
   
    required this.location,
    required this.spProfile,
 
  });

  factory ServiceProviderModel.fromJson(Map<String, dynamic> json) {
    return ServiceProviderModel(
     

      costOfServices: (json['cost_of_services'] as List<dynamic>?)
              ?.map((e) => CostOfServiceModel.fromJson(e))
              .toList() ??
          [],
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      description: json['sp_description'],
      profileImage: json['profile_image'],
      gender: json['gender'],
      fullName: json['full_name'],
      idNumber: json['id_number'],
      dob: json['dob'],
      
      location:
          (json['location'] != null && json['location'] is Map<String, dynamic>)
              ? SpAddressModel.fromJson(json['location'])
              : null,
      spProfile: SPProfileModel.fromJson(json['sp_profile']),
     
    );
  }

  Map<String, dynamic> toJson() {
    return {
    
      'gender': gender,
      'description': description,
      'full_name': fullName,
      'id_number': idNumber,
      'dob': dob,
      
      'rating': rating,
      'profile_image': profileImage,
      'location': location?.toJson(),
      'sp_profile': spProfile.toJson(),
  
    };
  }
  String get profileImageUrl {
    final String baseUrl = dotenv.env['MEDIA_BASE_URL'] ?? '';
    // Replace with your server's IP/domain
    return "$baseUrl$profileImage";
  }
}
