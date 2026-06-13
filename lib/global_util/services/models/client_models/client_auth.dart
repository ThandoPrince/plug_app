class ClientAuthModel {
  final int id;
  final String emailAddress;
  final String mobileNumber;
  final String profileStatus; 

  ClientAuthModel({
    required this.id,
    required this.emailAddress,
    required this.mobileNumber,
    required this.profileStatus,
  });

  factory ClientAuthModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClientAuthModel(
        id: 0,
        emailAddress: '',
        mobileNumber: '',
        profileStatus: 'in-details',
      );
    }

    return ClientAuthModel(
      id: json['id'] as int? ?? 0,
      emailAddress: json['email_address'] as String? ?? '',
      mobileNumber: json['mobile_number'] as String? ?? '',
      profileStatus:
          json['is_profile_completed'] as String? ?? 'in-details',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email_address': emailAddress,
        'mobile_number': mobileNumber,
        'is_profile_completed': profileStatus,
      };
}