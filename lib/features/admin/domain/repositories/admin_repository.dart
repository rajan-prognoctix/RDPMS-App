import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/admin_user.dart';
import '../entities/audit_event.dart';
import '../entities/config_setting.dart';

/// Contract implemented in the data layer.
abstract class AdminRepository {
  // ---------- Users (§11.6) ----------
  Future<Either<Failure, List<AdminUser>>> getUsers();

  /// Fails if the user ID, mobile or email is already used (§11.8).
  Future<Either<Failure, AdminUser>> createUser(AdminUser user);

  /// Saves changed details of an existing user (matched by user ID). Fails if
  /// the new mobile or email belongs to another user (§11.8).
  Future<Either<Failure, AdminUser>> updateUser(AdminUser user);

  /// Device pending → Active.
  Future<Either<Failure, AdminUser>> approveDevice(String userId);

  /// Disables the account, or enables it again.
  Future<Either<Failure, AdminUser>> setDisabled(
    String userId, {
    required bool disabled,
  });

  // ---------- Configurable parameters (Annex D §17) ----------
  Future<Either<Failure, List<ConfigSetting>>> getConfigSettings();

  /// Saves new values; the change is written to the audit log as [changedBy].
  Future<Either<Failure, ConfigSetting>> updateConfigSetting(
    ConfigSetting setting, {
    required String changedBy,
  });

  // ---------- Audit log (Annex D §19) ----------
  /// Newest first.
  Future<Either<Failure, List<AuditEvent>>> getAuditLog();
}
