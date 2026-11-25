class LoginResponseModel {
  final bool success;
  final String message;
  final UserData? data;

  const LoginResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  /// Mock users for testing, one per user level (§11.6). Password for all: `Test@123`.
  ///
  /// | User ID  | Role         | Sees |
  /// |----------|--------------|------|
  /// | ADMIN001 | Admin        | monitor, reports, Admin (creates any role) — no control |
  /// | HQ001    | Head Quarter | monitor, reports, Admin — no control |
  /// | DIV001   | Division     | monitor, reports, Admin (division users) — no control |
  /// | EMP001   | Station      | monitor, reports, Ack / feedback / maintenance mode — no Admin |
  /// | GUEST001 | Guest        | live monitoring only |
  static const mockUsers = <UserData>[
    UserData(
      userId: 'ADMIN001',
      name: 'R. Sharma',
      password: 'Test@123',
      email: 'admin.ncr@example.com',
      mobile: '9876500000',
      role: 'Admin',
      designation: 'Zonal Admin',
      jurisdiction: 'NCR',
    ),
    UserData(
      userId: 'HQ001',
      name: 'S. Verma',
      password: 'Test@123',
      email: 'cste.ncr@example.com',
      mobile: '9876500001',
      role: 'Head Quarter',
      designation: 'CSTE',
      jurisdiction: 'NCR',
    ),
    UserData(
      userId: 'DIV001',
      name: 'M. Gupta',
      password: 'Test@123',
      email: 'sr.dste.pyrj@example.com',
      mobile: '9876500002',
      role: 'Division',
      designation: 'Sr. DSTE',
      jurisdiction: 'NCR / PYRJ',
    ),
    UserData(
      userId: 'EMP001',
      name: 'John Doe',
      password: 'Test@123',
      email: 'john@example.com',
      mobile: '9876543210',
      role: 'Station',
      designation: 'ESM',
      jurisdiction: 'NCR / PYRJ / PRYJ',
    ),
    UserData(
      userId: 'GUEST001',
      name: 'Guest Viewer',
      password: 'Test@123',
      email: 'guest@example.com',
      mobile: '9876500004',
      role: 'Guest',
      designation: 'Viewer',
      jurisdiction: 'NCR / PYRJ',
    ),
  ];

  /// Mock response for testing: signs in the matching [mockUsers] entry
  /// (user id is not case-sensitive), else fails like a wrong password.
  factory LoginResponseModel.mock({required String userId, required String password}) {
    final id = userId.trim().toUpperCase();
    for (final user in mockUsers) {
      if (user.userId == id && user.password == password) {
        return LoginResponseModel(success: true, message: 'Login successful', data: user);
      }
    }
    return const LoginResponseModel(success: false, message: 'Invalid User ID or password');
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
  final String? password;
  final String? email;
  final String? mobile;
  final String? role;
  final String? designation;

  /// Zone / division / station the user is responsible for, e.g. "NCR / PYRJ".
  final String? jurisdiction;

  const UserData({
    this.userId,
    this.name,
    this.password,
    this.email,
    this.mobile,
    this.role,
    this.designation,
    this.jurisdiction,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      userId: json['user_id'],
      name: json['name'],
      password: json['password'],
      email: json['email'],
      mobile: json['mobile'],
      role: json['role'],
      designation: json['designation'],
      jurisdiction: json['jurisdiction'],
    );
  }

  /// Saved on the device after sign-in. The password is never stored.
  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'name': name,
        'email': email,
        'mobile': mobile,
        'role': role,
        'designation': designation,
        'jurisdiction': jurisdiction,
      };
}
