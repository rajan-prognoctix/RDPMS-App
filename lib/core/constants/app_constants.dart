class AppConstants {
  AppConstants._();

  static const String appName = 'RDPMS';
  static const String appFullName = 'Remote Diagnostic and Predictive Maintenance System';

  /// Shown on the splash screen. Keep in sync with `version` in pubspec.yaml.
  static const String appVersion = '1.0.0';

  /// How long the splash screen stays visible.
  static const Duration splashMinDuration = Duration(seconds: 2);

  /// UI-only phase: use hardcoded data instead of the backend.
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // SharedPreferences keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'cached_user';
  static const String lastSignInKey = 'last_sign_in';
  static const String profileNameKey = 'profile_name';
  static const String profilePhotoKey = 'profile_photo_path';
}
