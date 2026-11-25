import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/admin_user.dart';
import '../entities/audit_event.dart';
import '../entities/config_setting.dart';
import '../repositories/admin_repository.dart';

class GetUsers implements UseCase<List<AdminUser>, NoParams> {
  final AdminRepository repository;
  GetUsers(this.repository);

  @override
  Future<Either<Failure, List<AdminUser>>> call(NoParams params) =>
      repository.getUsers();
}

class CreateUser implements UseCase<AdminUser, AdminUser> {
  final AdminRepository repository;
  CreateUser(this.repository);

  @override
  Future<Either<Failure, AdminUser>> call(AdminUser user) =>
      repository.createUser(user);
}

class UpdateUser implements UseCase<AdminUser, AdminUser> {
  final AdminRepository repository;
  UpdateUser(this.repository);

  @override
  Future<Either<Failure, AdminUser>> call(AdminUser user) =>
      repository.updateUser(user);
}

class ApproveDevice implements UseCase<AdminUser, String> {
  final AdminRepository repository;
  ApproveDevice(this.repository);

  @override
  Future<Either<Failure, AdminUser>> call(String userId) =>
      repository.approveDevice(userId);
}

class SetUserDisabled implements UseCase<AdminUser, SetUserDisabledParams> {
  final AdminRepository repository;
  SetUserDisabled(this.repository);

  @override
  Future<Either<Failure, AdminUser>> call(SetUserDisabledParams params) =>
      repository.setDisabled(params.userId, disabled: params.disabled);
}

class GetConfigSettings implements UseCase<List<ConfigSetting>, NoParams> {
  final AdminRepository repository;
  GetConfigSettings(this.repository);

  @override
  Future<Either<Failure, List<ConfigSetting>>> call(NoParams params) =>
      repository.getConfigSettings();
}

class UpdateConfigSetting
    implements UseCase<ConfigSetting, UpdateConfigSettingParams> {
  final AdminRepository repository;
  UpdateConfigSetting(this.repository);

  @override
  Future<Either<Failure, ConfigSetting>> call(
    UpdateConfigSettingParams params,
  ) => repository.updateConfigSetting(
    params.setting,
    changedBy: params.changedBy,
  );
}

class UpdateConfigSettingParams extends Equatable {
  final ConfigSetting setting;
  final String changedBy;
  const UpdateConfigSettingParams({
    required this.setting,
    required this.changedBy,
  });

  @override
  List<Object?> get props => [setting, changedBy];
}

class GetAuditLog implements UseCase<List<AuditEvent>, NoParams> {
  final AdminRepository repository;
  GetAuditLog(this.repository);

  @override
  Future<Either<Failure, List<AuditEvent>>> call(NoParams params) =>
      repository.getAuditLog();
}

class SetUserDisabledParams extends Equatable {
  final String userId;
  final bool disabled;
  const SetUserDisabledParams({required this.userId, required this.disabled});

  @override
  List<Object?> get props => [userId, disabled];
}
