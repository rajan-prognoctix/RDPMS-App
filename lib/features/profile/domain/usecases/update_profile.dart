import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

/// Changes the user's name and photo. Mobile, email and role are not editable.
class UpdateProfile implements UseCase<UserProfile, UpdateProfileParams> {
  final ProfileRepository repository;
  UpdateProfile(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(UpdateProfileParams params) =>
      repository.updateProfile(name: params.name, photoPath: params.photoPath);
}

class UpdateProfileParams extends Equatable {
  final String name;

  /// New photo path; null removes the photo.
  final String? photoPath;

  const UpdateProfileParams({required this.name, required this.photoPath});

  @override
  List<Object?> get props => [name, photoPath];
}