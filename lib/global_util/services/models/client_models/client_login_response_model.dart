class ClientLoginResponse {
  final int? id;
  final String? email;
  final String? accessToken;
  final String? refreshToken;
  

  ClientLoginResponse({
    this.id,
    this.email,
    this.accessToken,
    this.refreshToken,
  });

  factory ClientLoginResponse.fromJson(Map<String, dynamic> json) {
    return ClientLoginResponse(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),

      email: json['email']?.toString(),

      accessToken: json['access_token']?.toString(),

      refreshToken: json['refresh_token']?.toString(),
    );
  }
}