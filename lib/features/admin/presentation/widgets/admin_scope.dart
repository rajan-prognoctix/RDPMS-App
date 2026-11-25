import '../../../../core/auth/user_role.dart';
import '../../domain/entities/admin_user.dart';

/// What the signed-in admin may see and create, from their role and
/// jurisdiction (§11.6: HQ and Division users assign users).
///
/// - Admin / Head Quarter: users of their zone; create Admin, HQ, Division,
///   Station and Guest users.
/// - Division: users of their division; create Division, Station and Guest users.
class AdminScope {
  final UserRole role;
  final String zc;
  final String? dc;

  const AdminScope({required this.role, required this.zc, this.dc});

  /// [jurisdiction] is the login response text, e.g. "NCR" or "NCR / PYRJ".
  factory AdminScope.from(UserRole role, String jurisdiction) {
    final parts = jurisdiction
        .split('/')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return AdminScope(
      role: role,
      zc: parts.isNotEmpty ? parts[0] : '',
      dc: role == UserRole.division && parts.length > 1 ? parts[1] : null,
    );
  }

  /// "PYRJ division" / "NCR zone".
  String get label => dc != null ? '$dc division' : '$zc zone';

  List<UserRole> get creatableRoles => role == UserRole.division
      ? const [UserRole.division, UserRole.station, UserRole.guest]
      : const [
          UserRole.admin,
          UserRole.headQuarter,
          UserRole.division,
          UserRole.station,
          UserRole.guest,
        ];

  /// Annex D §17: parameters are configured "by Admin in user Interface as
  /// decided by Zonal Railways". Every user with Admin access (Admin, HQ,
  /// Division — [UserRole.canOpenAdmin]) may change them; each change is logged.
  bool get canEditConfig => role.canOpenAdmin;

  bool includes(AdminUser u) => u.zc == zc && (dc == null || u.dc == dc);

  /// Edit / disable only users of a role this admin could create.
  bool canManage(AdminUser u) => includes(u) && creatableRoles.contains(u.role);
}
