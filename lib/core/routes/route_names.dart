class RouteNames {
  RouteNames._();

  // Auth
  static const String splash = '/splash';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String forgotUserId = '/forgot-user-id';

  // Legal
  static const String privacyPolicy = '/privacy-policy';
  static const String terms = '/terms';

  // Bottom-navigation tabs (Annex G)
  static const String dashboard = '/dashboard';
  static const String alerts = '/alerts';
  static const String telemetry = '/telemetry';
  static const String health = '/health';
  static const String equipmentRoom = '/equipment-room';

  // Pushed full-screen pages (no bottom bar; Back → previous screen)
  static String alertDetail(String id) => '/alert-detail/$id';
  static const String assetDetail = '/asset-detail';
  static const String assetUtilization = '/asset-utilization';
  static const String performance = '/performance';
  static const String admin = '/admin';
  static const String adminCreateUser = '/admin/create-user';
  static const String adminEditUser = '/admin/edit-user';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
}
