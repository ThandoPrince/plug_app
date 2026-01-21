class ClientAuthModel {
  final String emailAddress;
  final String mobileNumber;
  final String password; 

  ClientAuthModel({
    required this.emailAddress,
    required this.mobileNumber,
    this.password = '',
  });

  factory ClientAuthModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClientAuthModel(
        emailAddress: 't.p.tshabalala98@gmail.com',
        mobileNumber: '0719503706',
      );
    }

    return ClientAuthModel(
      emailAddress: json['email_address'] as String? ?? 't.p.tshabalala98@gmail.com',
      mobileNumber: json['mobile_number'] as String? ?? '0719503706',
      password: json['password'] as String? ?? '',
    );
  }
}

class ClientModel {
  final ClientAuthModel clientProfile;
  final String firstName;
  final String lastName;
  final String rating;
  final String? profilePic;

  ClientModel({
    required this.clientProfile,
    required this.firstName,
    required this.lastName,
    required this.rating,
    this.profilePic,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      clientProfile: ClientAuthModel.fromJson(
        json['client_profile'] as Map<String, dynamic>?,
      ),
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      rating: json['rating'] as String? ?? '0.00',
      profilePic: json['client_pp'] as String?,
    );
  }
}
