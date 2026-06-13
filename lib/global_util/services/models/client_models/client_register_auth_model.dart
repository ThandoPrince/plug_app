class ClientRegisterResponse {
  final bool success;
  final String message;
  final ClientRegisterData data;

  ClientRegisterResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ClientRegisterResponse.fromJson(
      Map<String, dynamic> json) {
    return ClientRegisterResponse(
      success: json["success"],
      message: json["message"],
      data: ClientRegisterData.fromJson(json["data"]),
    );
  }
}

class ClientRegisterData {
  final int id;
  final String email;
  final String mobileNumber;
  final String accessToken;
  final String refreshToken;

  ClientRegisterData({
    required this.id,
    required this.email,
    required this.mobileNumber,
    required this.accessToken,
    required this.refreshToken,
  });

  factory ClientRegisterData.fromJson(
      Map<String, dynamic> json) {
    return ClientRegisterData(
      id: json["id"],
      email: json["email"],
      mobileNumber: json["mobile_number"],
      accessToken: json["access_token"],
      refreshToken: json["refresh_token"],
    );
  }
}