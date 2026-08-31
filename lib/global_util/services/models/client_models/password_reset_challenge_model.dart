// models/client_models/password_reset_challenge_model.dart
class PasswordResetChallengeResponse {
  final bool success;
  final String message;
  final PasswordResetChallengeData data;

  PasswordResetChallengeResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PasswordResetChallengeResponse.fromJson(Map<String, dynamic> json) {
    return PasswordResetChallengeResponse(
      success: json["success"] as bool? ?? false,
      message: json["message"]?.toString() ?? "",
      data: PasswordResetChallengeData.fromJson(
        json["data"] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class PasswordResetChallengeData {
  final String otpRequestId;
  final String verificationToken;

  PasswordResetChallengeData({
    required this.otpRequestId,
    required this.verificationToken,
  });

  factory PasswordResetChallengeData.fromJson(Map<String, dynamic> json) {
    return PasswordResetChallengeData(
      otpRequestId: json["otp_request_id"]?.toString() ?? "",
      verificationToken: json["verification_token"]?.toString() ?? "",
    );
  }
}