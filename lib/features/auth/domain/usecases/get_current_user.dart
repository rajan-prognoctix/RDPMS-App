import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Returns the signed-in user saved on the device (null if none), so the
/// user's role is known after an app restart.
class GetCurrentUser implements UseCase<User?, NoParams> {
  final AuthRepository repository;
  GetCurrentUser(this.repository);

  @override
  Future<Either<Failure, User?>> call(NoParams params) => repository.getCurrentUser();
}
