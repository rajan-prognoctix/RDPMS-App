import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getProfile();

  /// Saves the user-editable fields. A null [photoPath] removes the photo.
  Future<Either<Failure, UserProfile>> updateProfile({
    required String name,
    required String? photoPath,
  });
}