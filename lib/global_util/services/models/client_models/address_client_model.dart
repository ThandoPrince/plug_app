import 'package:flutter_application_1/global_util/services/models/client_models/client_address_model.dart';
import 'package:flutter_application_1/global_util/services/models/client_models/client_model.dart';

class AddressClientModel {
  final int id;
  final ClientDetailModel client;
  final ClientAddressModel address;
  final bool isOwner;
  final bool houseAdministrator;
  final bool isSuperUser;
  final String addressType;
  bool isDefault;
  bool isActive;

  AddressClientModel({
    required this.id,
    required this.client,
    required this.address,
    required this.isOwner,
    required this.houseAdministrator,
    required this.isSuperUser,
    required this.addressType,
    required this.isDefault,
    required this.isActive
  });

  factory AddressClientModel.fromJson(Map<String, dynamic> json) {
    // Remove duplicate clients from address.clients
    List<dynamic> uniqueClientsJson = [];
    final seenEmails = <String>{};
    final clientsJson = (json['address']?['clients'] as List<dynamic>?) ?? [];
    for (var c in clientsJson) {
      final email = c['client_profile']?['email_address'] as String?;
      if (email != null && !seenEmails.contains(email)) {
        uniqueClientsJson.add(c);
        seenEmails.add(email);
      }
    }

    final addressJson = Map<String, dynamic>.from(json['address'] ?? {});
    addressJson['clients'] = uniqueClientsJson;

    return AddressClientModel(
      id: json['id'] as int? ?? 0,
      client: ClientDetailModel.fromJson(
          json['client'] as Map<String, dynamic>? ?? {}),
      address: ClientAddressModel.fromJson(addressJson),
      isOwner: json['is_owner'] as bool? ?? false,
      houseAdministrator: json['house_administrator'] as bool? ?? false,
      isSuperUser: json['is_super_user'] as bool? ?? false,
      addressType: json['address_type'] as String? ?? '',
      isDefault: json['is_default'] as bool? ?? false,
      isActive:  json['is_active'] as bool? ?? true,
    );
  }
}
