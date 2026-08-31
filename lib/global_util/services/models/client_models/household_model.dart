import 'package:flutter_application_1/global_util/services/models/client_models/client_model.dart';

class HouseHoldModel {
  final int id;

  final ClientDetailModel client;

  final int address;

  final bool isOwner;

  final bool houseAdministrator;

  final bool isSuperUser;

  final String addressType;

  bool isDefault;

  bool isActive;

  HouseHoldModel({
    required this.id,
    required this.client,
    required this.address,
    required this.isOwner,
    required this.houseAdministrator,
    required this.isSuperUser,
    required this.addressType,
    required this.isDefault,
    required this.isActive,
  });

  factory HouseHoldModel.fromJson(Map<String, dynamic> json) {
    return HouseHoldModel(
      id: json['id'] as int? ?? 0,

      client: ClientDetailModel.fromJson(
        json['client'] as Map<String, dynamic>? ?? {},
      ),

      address: json['address'] as int? ?? 0,

      isOwner: json['is_owner'] as bool? ?? false,

      houseAdministrator:
          json['house_administrator'] as bool? ?? false,

      isSuperUser:
          json['is_super_user'] as bool? ?? false,

      addressType:
          json['address_type'] as String? ?? '',

      isDefault:
          json['is_default'] as bool? ?? false,

      isActive:
          json['is_active'] as bool? ?? true,
    );
  }
}