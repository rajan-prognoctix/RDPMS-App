import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/auth/user_role.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/mock/mock_data.dart';
import '../../domain/entities/user_profile.dart';

/// Keeps the user's edited name and photo on the device.
/// The read-only fields (mobile, email, role…) come from the user saved at
/// sign-in, falling back to [MockData]. Logout keeps the edited name and photo.
abstract class ProfileLocalDataSource {
  UserProfile getProfile();

  /// Throws [CacheException] when the photo can't be stored.
  Future<UserProfile> saveProfile({required String name, required String? photoPath});
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final SharedPreferences prefs;
  ProfileLocalDataSourceImpl(this.prefs);

  /// The user saved at sign-in (same key the auth feature writes), or empty.
  Map<String, dynamic> _signedInUser() {
    final raw = prefs.getString(AppConstants.userKey);
    if (raw == null) return const {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } on FormatException {
      return const {};
    }
  }

  @override
  UserProfile getProfile() {
    final photo = prefs.getString(AppConstants.profilePhotoKey);
    final user = _signedInUser();
    String field(String key, String fallback) =>
        (user[key] as String?)?.trim().isNotEmpty == true ? user[key] as String : fallback;

    return UserProfile(
      name: prefs.getString(AppConstants.profileNameKey) ?? field('name', MockData.userName),
      // Ignore a saved path whose file is gone (e.g. app data cleared).
      photoPath: photo != null && File(photo).existsSync() ? photo : null,
      designation: field('designation', MockData.userDesignation),
      roleLabel: UserRole.fromCode(user['role'] as String?).label,
      mobile: field('mobile', MockData.userMobile),
      email: field('email', MockData.userEmail),
      jurisdiction: field('jurisdiction', MockData.userJurisdiction),
      deviceId: MockData.deviceId,
      vendor: MockData.vendorName,
    );
  }

  @override
  Future<UserProfile> saveProfile({required String name, required String? photoPath}) async {
    final oldPhoto = prefs.getString(AppConstants.profilePhotoKey);
    try {
      if (photoPath == null) {
        await prefs.remove(AppConstants.profilePhotoKey);
        await _delete(oldPhoto);
      } else if (photoPath != oldPhoto) {
        // The picker returns a file in the cache folder, which the system can
        // clear: keep a copy in the app's documents folder. A new file name
        // each time so the image cache doesn't show the old photo.
        final dir = await getApplicationDocumentsDirectory();
        final dot = photoPath.lastIndexOf('.');
        final ext = dot > photoPath.lastIndexOf('/') ? photoPath.substring(dot) : '.jpg';
        final saved = await File(photoPath).copy(
          '${dir.path}/profile_photo_${DateTime.now().millisecondsSinceEpoch}$ext',
        );
        await prefs.setString(AppConstants.profilePhotoKey, saved.path);
        await _delete(oldPhoto);
      }
      await prefs.setString(AppConstants.profileNameKey, name);
    } on FileSystemException {
      throw const CacheException('Could not save the photo. Please try again.');
    }
    return getProfile();
  }

  Future<void> _delete(String? path) async {
    if (path == null) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}