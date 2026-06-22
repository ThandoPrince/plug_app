class SPLiveLocationModel {
  final int? providerId;
  final String? providerName;
  final double? latitude;
  final double? longitude;
  final DateTime? updatedAt;

  SPLiveLocationModel({
    this.providerId,
    this.providerName,
    this.latitude,
    this.longitude,
    this.updatedAt,
  });

  factory SPLiveLocationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;

      if (value is double) {
        return value;
      }

      if (value is int) {
        return value.toDouble();
      }

      return double.tryParse(
        value.toString(),
      );
    }

    return SPLiveLocationModel(
      providerId: json['provider'] is int
          ? json['provider']
          : int.tryParse(
              json['provider'].toString(),
            ),
      providerName:
          json['provider_name']?.toString(),
      latitude: parseDouble(
        json['latitude'],
      ),
      longitude: parseDouble(
        json['longitude'],
      ),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(
              json['updated_at'].toString(),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': providerId,
      'provider_name': providerName,
      'latitude': latitude,
      'longitude': longitude,
      'updated_at':
          updatedAt?.toIso8601String(),
    };
  }
}