class Validators {
  Validators._();

  static String? required(String? value, [String field = 'This field']) =>
      (value == null || value.trim().isEmpty) ? '$field is required' : null;

  /// 10-digit Indian mobile number.
  static String? mobile(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Mobile number is required';
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v)) return 'Enter a valid 10-digit mobile number';
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) return 'Enter a valid email';
    return null;
  }

  /// Letters, digits and . _ - only; 3–30 characters.
  static String? userId(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'User ID is required';
    if (!RegExp(r'^[A-Za-z0-9._-]{3,30}$').hasMatch(v)) {
      return 'Use 3–30 letters, digits, dot, dash or underscore';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }
}
