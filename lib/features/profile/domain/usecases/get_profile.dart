import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetProfile implements UseCase<UserProfile, NoParams> {
  final ProfileRepository repository;
  GetProfile(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(NoParams params) => repository.getProfile();
}