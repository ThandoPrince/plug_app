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
  final bool requiresEmailVerification;
  final String otpRequestId;
  final String verificationToken;

  ClientRegisterData({
    required this.id,
    required this.email,
    required this.mobileNumber,
    required this.requiresEmailVerification,
    required this.otpRequestId,
    required this.verificationToken,
  });

  factory ClientRegisterData.fromJson(
      Map<String, dynamic> json) {
    return ClientRegisterData(
      id: json["id"],
      email: json["email"],
      mobileNumber: json["mobile_number"],
      requiresEmailVerification:
          json["requires_email_verification"] ?? false,
      otpRequestId: json["otp_request_id"],
      verificationToken: json["verification_token"],
    );
  }
}