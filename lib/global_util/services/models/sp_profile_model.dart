class SPProfileModel {
  final int? id;
  final String? isProfileCompleted;
  final bool? isActive;

  SPProfileModel({
    this.id,
    this.isProfileCompleted,
    this.isActive,
  });

  factory SPProfileModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return SPProfileModel();

    return SPProfileModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),

      isProfileCompleted: json['is_profile_completed']?.toString(),

      isActive: json['is_active'] is bool
          ? json['is_active']
          : json['is_active']?.toString() == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_profile_completed': isProfileCompleted,
      'is_active': isActive,
    };
  }
}