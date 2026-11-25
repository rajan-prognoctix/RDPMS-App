import 'package:fpdart/fpdart.dart';
import 'package:rdpms_app/features/auth/data/models/login_request_model.dart';
import '../../../../core/error/error_messages.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;

  AuthRepositoryImpl({required this.remote, required this.local});

  @override
  Future<Either<Failure, User>> login({
    required LoginRequestModel request,
  }) async {
    try {
      final response = await remote.login(request: request);
      final data = response.data;
      if (!response.success || data == null) {
        return left(ServerFailure(
          response.message.isNotEmpty ? response.message : ErrorMessages.server,
        ));
      }
      await local.cacheUser(data);
      return right(User(data: data));
    } on ServerException catch (e) {
      return left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return left(NetworkFailure(e.message));
    } on FormatException catch (e) {
      return left(ServerFailure(ErrorMessages.pick(
        'Unexpected response from server: ${e.message}',
        ErrorMessages.unexpectedResponse,
      )));
    } on TypeError catch (e) {
      // Response JSON didn't match the expected model.
      return left(ServerFailure(ErrorMessages.pick(
        'Unexpected response from server: $e',
        ErrorMessages.unexpectedResponse,
      )));
    } on Exception catch (e) {
      return left(ServerFailure(ErrorMessages.pick(e.toString(), ErrorMessages.server)));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    final data = local.getCachedUser();
    return right(data == null ? null : User(data: data));
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
