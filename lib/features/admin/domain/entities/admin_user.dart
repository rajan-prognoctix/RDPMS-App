import 'package:equatable/equatable.dart';

import '../../../../core/auth/user_role.dart';

/// Account state shown on the Admin user list (M20).
enum UserStatus {
  /// Mobile linked after the first OTP sign-in (§11.7).
  active('Active'),

  /// Created by Admin; waiting for the first OTP sign-in / device approval.
  devicePending('Device pending'),

  /// Can't sign in until an admin enables the account again.
  disabled('Disabled');

  const UserStatus(this.label);
  final String label;
}

/// A user managed on the Admin page (§11.6 assign users, §11.7 authorised
/// mobile + device, §11.8 one account per mobile no / email id).
///
/// Which location fields are set depends on [role]:
/// - Admin, Head Quarter: [zc]
/// - Division: [zc] + [dc]
/// - Station: [zc] + [dc] + [sc]
/// - Guest: [zc] + [dc] (area they may monitor) + [organisation], optional [validUntil]
class AdminUser extends Equatable {
  final String userId;
  final String name;
  final UserRole role;
  final String designation;

  /// Authorised mobile number (§11.7) — also the account identity (§11.8).
  final String mobile;
  final String email;

  final String zc;
  final String? dc;
  final String? sc;

  final UserStatus status;

  /// True once the user's mobile device is linked/approved (§11.7). Kept while
  /// the account is disabled, so enabling it restores the right status.
  final bool deviceLinked;

  /// Station / Division users nominated by the Zonal Railway to enter actual
  /// failures on the Performance page (Annex E §12).
  final bool nominatedForFailureEntry;

  /// Guest only: organisation the guest belongs to (e.g. RDSO, vendor).
  final String? organisation;

  /// Guest only: last day of access; null = no end date.
  final DateTime? validUntil;

  const AdminUser({
    required this.userId,
    required this.name,
    required this.role,
    required this.designation,
    required this.mobile,
    required this.email,
    required this.zc,
    this.dc,
    this.sc,
    this.status = UserStatus.devicePending,
    this.deviceLinked = false,
    this.nominatedForFailureEntry = false,
    this.organisation,
    this.validUntil,
  });

  /// "NCR", "NCR / PYRJ" or "NCR / PYRJ / PRYJ".
  String get jurisdiction => [zc, dc, sc].whereType<String>().join(' / ');

  /// Lowest location code, as shown on the user card (e.g. "PRYJ").
  String get location => sc ?? dc ?? zc;

  bool get isDisabled => status == UserStatus.disabled;

  /// Status to return to when the account is enabled again.
  UserStatus get enabledStatus =>
      deviceLinked ? UserStatus.active : UserStatus.devicePending;

  AdminUser copyWith({UserStatus? status, bool? deviceLinked}) => AdminUser(
    userId: userId,
    name: name,
    role: role,
    designation: designation,
    mobile: mobile,
    email: email,
    zc: zc,
    dc: dc,
    sc: sc,
    status: status ?? this.status,
    deviceLinked: deviceLinked ?? this.deviceLinked,
    nominatedForFailureEntry: nominatedForFailureEntry,
    organisation: organisation,
    validUntil: validUntil,
  );

  @override
  List<Object?> get props => [
    userId,
    name,
    role,
    designation,
    mobile,
    email,
    zc,
    dc,
    sc,
    status,
    deviceLinked,
    nominatedForFailureEntry,
    organisation,
    validUntil,
  ];
}
