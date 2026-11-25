import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Access token kept in SharedPreferences.
/// Saved only after OTP device authentication (§11.7); while it is present the
/// app opens Dashboard directly from Splash (auto-login). Logout removes it.
/// Uses the same key that [ApiClient] reads for the Authorization header.
///
/// Also keeps the time of the last successful sign-in (OTP accepted), shown on
/// the User Profile. Logout keeps it; the next sign-in overwrites it.
abstract class LocalStorage {
  Future<void> saveToken(String token);
  bool get hasToken;
  Future<void> saveLastSignIn(DateTime time);
  DateTime? get lastSignIn;
}

class LocalStorageImpl implements LocalStorage {
  final SharedPreferences prefs;
  LocalStorageImpl(this.prefs);

  @override
  Future<void> saveToken(String token) => prefs.setString(AppConstants.tokenKey, token);

  @override
  bool get hasToken => (prefs.getString(AppConstants.tokenKey) ?? '').isNotEmpty;

  @override
  Future<void> saveLastSignIn(DateTime time) =>
      prefs.setString(AppConstants.lastSignInKey, time.toIso8601String());

  @override
  DateTime? get lastSignIn {
    final value = prefs.getString(AppConstants.lastSignInKey);
    return value == null ? null : DateTime.tryParse(value);
  }
}