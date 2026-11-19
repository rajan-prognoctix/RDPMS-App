class LoginResponseModel {
  final bool success;
  final String message;
  final UserData? data;

  const LoginResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  /// Mock Response for testing purpose.
  factory LoginResponseModel.mock() {
    return const LoginResponseModel(
      success: true,
      message: 'Login successful',
      data: UserData(
        userId: 'EMP001',
        name: 'John Doe',
        email: 'john@example.com',
        mobile: '9876543210',
        role: "Station Level"
      ),
    );
  }


  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? UserData.fromJson(json['data'])
          : null,
    );
  }
}

class UserData {
  final String? userId;
  final String? name;
  final String? email;
  final String? mobile;
  final String? role;

  const UserData({
    this.userId,
    this.name,
    this.email,
    this.mobile,
    this.role,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      userId: json['user_id'],
      name: json['name'],
      email: json['email'],
      mobile: json['mobile'],
      role: json['role'],
    );
  }
}
