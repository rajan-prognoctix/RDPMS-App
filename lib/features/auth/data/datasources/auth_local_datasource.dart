import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/login_response_model.dart';

abstract class AuthLocalDataSource {
  /// Keeps the signed-in user (role, jurisdiction…) so it is still known after
  /// an app restart (auto-login, §11.7).
  Future<void> cacheUser(UserData user);

  /// The saved user, or null when nobody has signed in.
  UserData? getCachedUser();

  Future<void> clear();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences prefs;
  AuthLocalDataSourceImpl(this.prefs);

  @override
  Future<void> cacheUser(UserData user) =>
      prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));

  @override
  UserData? getCachedUser() {
    final raw = prefs.getString(AppConstants.userKey);
    if (raw == null) return null;
    try {
      return UserData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> clear() async {
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
    await prefs.remove(AppConstants.lastSignInKey);
  }
}
