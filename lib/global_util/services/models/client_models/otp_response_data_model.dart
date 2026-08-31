class ClientOTPResponse {
  final bool success;
  final String message;
  final ClientRegisterData data;

  ClientOTPResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ClientOTPResponse.fromJson(
      Map<String, dynamic> json) {
    return ClientOTPResponse(
      success: json["success"],
      message: json["message"],
      data: ClientRegisterData.fromJson(json["data"]),
    );
  }
}

class ClientRegisterData {
  final int id;

  final String accessToken;
  final String refreshToken;

  ClientRegisterData({
    required this.id,

    required this.accessToken,
    required this.refreshToken,
  });

  factory ClientRegisterData.fromJson(
      Map<String, dynamic> json) {
    return ClientRegisterData(
      id: json["id"],

      accessToken: json["access_token"],
      refreshToken: json["refresh_token"],
    );
  }
}