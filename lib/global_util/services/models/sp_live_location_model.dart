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

  /// Create instance from JSON
  factory SPLiveLocationModel.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return SPLiveLocationModel(
      providerId: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
      providerName: json['provider']?.toString(),
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  /// Convert instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': providerId,
      'provider': providerName,
      'latitude': latitude?.toString(),
      'longitude': longitude?.toString(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
