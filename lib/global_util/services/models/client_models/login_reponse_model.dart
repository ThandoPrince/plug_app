
class LoginChallengeResponse {
  final bool success;
  final String message;
  final LoginChallengeData data;

  LoginChallengeResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LoginChallengeResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return LoginChallengeResponse(
      success: json["success"] as bool? ?? false,
      message: json["message"]?.toString() ?? "",
      data: LoginChallengeData.fromJson(
        json["data"] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class LoginChallengeData {
  final int id;
  final String email;
  final bool requiresEmailVerification;
  final String otpRequestId;
  final String isProfileCompleted;
  final String verificationToken;

  LoginChallengeData({
    required this.id,
    required this.email,
    required this.requiresEmailVerification,
    required this.isProfileCompleted,
    required this.otpRequestId,
    required this.verificationToken,
  });

  factory LoginChallengeData.fromJson(
    Map<String, dynamic> json,
  ) {
    return LoginChallengeData(
      id: int.tryParse(
            json["id"]?.toString() ?? "",
          ) ??
          0,

      email:
          json["email"]?.toString() ?? "",

      isProfileCompleted:
          json["is_profile_completed"]?.toString() ??
              "in-details",

      requiresEmailVerification:
          json["requires_email_verification"] as bool? ??
              false,

      otpRequestId:
          json["otp_request_id"]?.toString() ?? "",

      verificationToken:
          json["verification_token"]?.toString() ?? "",
    );
  }
}

