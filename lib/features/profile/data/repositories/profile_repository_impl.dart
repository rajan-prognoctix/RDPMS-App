import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource local;
  ProfileRepositoryImpl({required this.local});

  @override
  Future<Either<Failure, UserProfile>> getProfile() async => right(local.getProfile());

  @override
  Future<Either<Failure, UserProfile>> updateProfile({
    required String name,
    required String? photoPath,
  }) async {
    try {
      return right(await local.saveProfile(name: name, photoPath: photoPath));
    } on CacheException catch (e) {
      return left(CacheFailure(e.message));
    }
  }
}