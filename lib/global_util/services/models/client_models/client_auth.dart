/// Represents authentication credentials for a client.
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
        emailAddress: '',
        mobileNumber: '',
      );
    }

    return ClientAuthModel(
      emailAddress: json['email_address'] as String? ?? '',
      mobileNumber: json['mobile_number'] as String? ?? '',
      password: json['password'] as String? ?? '',
    );
  }

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() => {
        'email_address': emailAddress,
        'mobile_number': mobileNumber,
        'password': password,
      };
}

/// Represents a client profile.
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

  /// Creates a [ClientModel] from JSON.
  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      clientProfile: ClientAuthModel.fromJson(
        json['client_profile'] as Map<String, dynamic>?,
      ),
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      rating: json['rating']?.toString() ?? '0.00',
      profilePic: json['client_pp'] as String?,
    );
  }

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() => {
        'client_profile': clientProfile.toJson(),
        'first_name': firstName,
        'last_name': lastName,
        'rating': rating,
        'client_pp': profilePic,
      };
}
