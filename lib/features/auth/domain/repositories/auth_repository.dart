import 'package:fpdart/fpdart.dart';
import 'package:rdpms_app/features/auth/data/models/login_request_model.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';

/// Contract implemented in the data layer.
abstract class AuthRepository {
  Future<Either<Failure, User>> login({required LoginRequestModel request});

  Future<Either<Failure, Unit>> logout();
}
