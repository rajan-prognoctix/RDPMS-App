import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/entities/audit_event.dart';
import '../../domain/entities/config_setting.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_local_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminLocalDataSource local;
  AdminRepositoryImpl({required this.local});

  Future<Either<Failure, AdminUser>> _run(AdminUser Function() action) async {
    try {
      return right(action());
    } on ServerException catch (e) {
      return left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<AdminUser>>> getUsers() async =>
      right(local.getUsers());

  @override
  Future<Either<Failure, AdminUser>> createUser(AdminUser user) =>
      _run(() => local.createUser(user));

  @override
  Future<Either<Failure, AdminUser>> updateUser(AdminUser user) =>
      _run(() => local.updateUser(user));

  @override
  Future<Either<Failure, AdminUser>> approveDevice(String userId) =>
      _run(() => local.approveDevice(userId));

  @override
  Future<Either<Failure, AdminUser>> setDisabled(
    String userId, {
    required bool disabled,
  }) => _run(() => local.setDisabled(userId, disabled: disabled));

  @override
  Future<Either<Failure, List<ConfigSetting>>> getConfigSettings() async =>
      right(local.getConfigSettings());

  @override
  Future<Either<Failure, ConfigSetting>> updateConfigSetting(
    ConfigSetting setting, {
    required String changedBy,
  }) async {
    try {
      return right(local.updateConfigSetting(setting, changedBy: changedBy));
    } on ServerException catch (e) {
      return left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<AuditEvent>>> getAuditLog() async =>
      right(local.getAuditLog());
}
