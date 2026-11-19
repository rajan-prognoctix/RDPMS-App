class LoginRequestModel {
  final String userId;
  final String password;
  final String deviceId;
  final String deviceType;

  const LoginRequestModel({
    required this.userId,
    required this.password,
    required this.deviceId,
    required this.deviceType,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'password': password,
      'device_id': deviceId,
      'device_type': deviceType,
    };
  }
}
