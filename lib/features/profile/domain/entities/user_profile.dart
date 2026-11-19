import 'package:equatable/equatable.dart';

/// The signed-in user's profile (User Profile page, side-menu header).
/// Only [name] and [photoPath] can be changed by the user; the rest is set by
/// the admin (§11.6) and is read-only in the app.
class UserProfile extends Equatable {
  final String name;

  /// Local file path of the profile photo, or null for initials.
  final String? photoPath;

  final String designation;
  final String roleLabel;
  final String mobile;
  final String email;
  final String jurisdiction;
  final String deviceId;
  final String vendor;

  const UserProfile({
    required this.name,
    required this.photoPath,
    required this.designation,
    required this.roleLabel,
    required this.mobile,
    required this.email,
    required this.jurisdiction,
    required this.deviceId,
    required this.vendor,
  });

  @override
  List<Object?> get props => [
        name,
        photoPath,
        designation,
        roleLabel,
        mobile,
        email,
        jurisdiction,
        deviceId,
        vendor,
      ];
}