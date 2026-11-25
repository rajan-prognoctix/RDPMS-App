import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/entities/audit_event.dart';
import '../../domain/entities/config_setting.dart';
import '../../domain/usecases/admin_usecases.dart';

/// Admin page state: users (create, edit, disable/enable, approve device),
/// configurable parameters (Annex D §17) and the audit log (§19).
/// Actions return null on success, else the error message.
class AdminCubit extends Cubit<AdminState> {
  final GetUsers getUsers;
  final CreateUser createUser;
  final UpdateUser updateUser;
  final ApproveDevice approveDevice;
  final SetUserDisabled setUserDisabled;
  final GetConfigSettings getConfigSettings;
  final UpdateConfigSetting updateConfigSetting;
  final GetAuditLog getAuditLog;

  AdminCubit({
    required this.getUsers,
    required this.createUser,
    required this.updateUser,
    required this.approveDevice,
    required this.setUserDisabled,
    required this.getConfigSettings,
    required this.updateConfigSetting,
    required this.getAuditLog,
  }) : super(const AdminState(loading: true));

  Future<void> load() async {
    final users = await getUsers(const NoParams());
    final settings = await getConfigSettings(const NoParams());
    final audit = await getAuditLog(const NoParams());
    String? error;
    T valueOr<T>(Either<Failure, T> r, T fallback) => r.match((f) {
      error ??= f.message;
      return fallback;
    }, (v) => v);
    emit(
      AdminState(
        users: valueOr(users, const <AdminUser>[]),
        settings: valueOr(settings, const <ConfigSetting>[]),
        auditLog: valueOr(audit, const <AuditEvent>[]),
        error: error,
      ),
    );
  }

  Future<String?> _apply<T>(Future<Either<Failure, T>> action) async {
    final result = await action;
    return result.match((f) => f.message, (_) {
      load();
      return null;
    });
  }

  Future<String?> create(AdminUser user) => _apply(createUser(user));

  Future<String?> update(AdminUser user) => _apply(updateUser(user));

  Future<String?> approve(String userId) => _apply(approveDevice(userId));

  Future<String?> setDisabled(String userId, {required bool disabled}) =>
      _apply(
        setUserDisabled(
          SetUserDisabledParams(userId: userId, disabled: disabled),
        ),
      );

  /// Saves a §17 parameter; the change also appears in the audit log.
  Future<String?> saveSetting(
    ConfigSetting setting, {
    required String changedBy,
  }) => _apply(
    updateConfigSetting(
      UpdateConfigSettingParams(setting: setting, changedBy: changedBy),
    ),
  );
}

class AdminState extends Equatable {
  final List<AdminUser> users;
  final List<ConfigSetting> settings;
  final List<AuditEvent> auditLog;
  final bool loading;
  final String? error;

  const AdminState({
    this.users = const [],
    this.settings = const [],
    this.auditLog = const [],
    this.loading = false,
    this.error,
  });

  @override
  List<Object?> get props => [users, settings, auditLog, loading, error];
}
