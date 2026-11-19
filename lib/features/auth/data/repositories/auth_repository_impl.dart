import 'package:fpdart/fpdart.dart';
import 'package:rdpms_app/features/auth/data/models/login_request_model.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

/// Calls datasources and maps exceptions -> failures.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;

  AuthRepositoryImpl({required this.remote, required this.local});

  /// Checks user id + password only. Nothing is saved on the device here:
  /// the access token is saved after OTP verification (see OtpPage, §11.7).
  @override
  Future<Either<Failure, User>> login({
    required LoginRequestModel request,
  }) async {
    try {
      final user = await remote.login(request: request);
      return right(
        User(
          id: user.data?.userId ?? "",
          name: user.data?.name ?? "",
          email: user.data?.email ?? "",
        ),
      );
    } on ServerException catch (e) {
      return left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await remote.logout();
    } on Exception {
      // Ignore server errors on logout; always clear local session.
    }
    await local.clear();
    return right(unit);
  }
}
