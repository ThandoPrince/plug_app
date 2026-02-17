class ClientAddressModel {
  final int id;
  final double? latitude;
  final double? longitude;
  final String? placeId;
  final String streetNumber;
  final String route;
  final String locality;
  final String administrativeArea;
  final String? formattedAddress;

  final String country;
  final String postalCode;

  // New fields to match backend
  final String unitNumber;
  final String? accessNotes;
  final String buildingType;
  final bool isVerified;

  final String addressType;

  ClientAddressModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.placeId,
    required this.streetNumber,
    required this.route,
    required this.locality,
    required this.administrativeArea,
    this.formattedAddress,
    required this.country,
    required this.postalCode,
    required this.unitNumber,
    this.accessNotes,
    required this.buildingType,
    required this.isVerified,
    required this.addressType,
  });

  /// Parse from API JSON
  factory ClientAddressModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClientAddressModel(
        id: 0,
        latitude: null,
        longitude: null,
        streetNumber: '',
        route: '',
        locality: '',
        administrativeArea: '',
        country: '',
        postalCode: '',
        unitNumber: '',
        accessNotes: null,
        buildingType: 'house',
        isVerified: false,
        addressType: '',
      );
    }

    return ClientAddressModel(
      id: json['id'] as int? ?? 0,
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      placeId: json['place_id'] as String?,
      streetNumber: json['street_number'] as String? ?? '',
      route: json['route'] as String? ?? '',
      locality: json['locality'] as String? ?? '',
      administrativeArea: json['administrative_area_level_1'] as String? ?? 'Unknown Area',
      formattedAddress: json['formatted_address'] as String?,
      country: json['country'] as String? ?? '',
      postalCode: json['postal_code'] as String? ?? '',
      unitNumber: json['unit_number'] as String? ?? '',
      accessNotes: json['access_notes'] as String?,
      buildingType: json['building_type'] as String? ?? 'house',
      isVerified: json['is_verified'] as bool? ?? false,
      addressType: json['address_type'] as String? ?? '',
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'place_id': placeId,
      'street_number': streetNumber,
      'route': route,
      'locality': locality,
      'administrative_area_level_1': administrativeArea,
      'formatted_address': formattedAddress,
      'country': country,
      'postal_code': postalCode,
      'unit_number': unitNumber,
      'access_notes': accessNotes,
      'building_type': buildingType,
      'is_verified': isVerified,
      'address_type': addressType,
    };
  }

  /// Copy object with updated fields
  ClientAddressModel copyWith({
    int? id,
    double? latitude,
    double? longitude,
    String? placeId,
    String? streetNumber,
    String? route,
    String? locality,
    String? administrativeArea,
    String? formattedAddress,
    String? country,
    String? postalCode,
    String? unitNumber,
    String? accessNotes,
    String? buildingType,
    bool? isVerified,
    String? addressType,
  }) {
    return ClientAddressModel(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeId: placeId ?? this.placeId,
      streetNumber: streetNumber ?? this.streetNumber,
      route: route ?? this.route,
      locality: locality ?? this.locality,
      administrativeArea: administrativeArea ?? this.administrativeArea,
      formattedAddress: formattedAddress ?? this.formattedAddress,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      unitNumber: unitNumber ?? this.unitNumber,
      accessNotes: accessNotes ?? this.accessNotes,
      buildingType: buildingType ?? this.buildingType,
      isVerified: isVerified ?? this.isVerified,
      addressType: addressType ?? this.addressType,
    );
  }

  @override
  String toString() {
    return formattedAddress ??
        "$streetNumber $route, $locality, $administrativeArea, $country";
  }
}
