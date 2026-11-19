import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_profile.dart';

/// App-wide profile state, so an edit shows at once on the User Profile page
/// and in the side-menu header.
class ProfileCubit extends Cubit<ProfileState> {
  final GetProfile getProfile;
  final UpdateProfile updateProfile;

  ProfileCubit({required this.getProfile, required this.updateProfile})
      : super(const ProfileState());

  Future<void> load() async {
    final result = await getProfile(const NoParams());
    result.match(
      (f) => emit(state.copyWith(error: f.message)),
      (p) => emit(ProfileState(profile: p)),
    );
  }

  /// Saves the name and photo. Returns null on success, else the error message.
  Future<String?> save({required String name, required String? photoPath}) async {
    emit(state.copyWith(saving: true));
    final result = await updateProfile(
      UpdateProfileParams(name: name.trim(), photoPath: photoPath),
    );
    return result.match(
      (f) {
        emit(state.copyWith(saving: false));
        return f.message;
      },
      (p) {
        emit(ProfileState(profile: p));
        return null;
      },
    );
  }
}

class ProfileState extends Equatable {
  final UserProfile? profile;
  final bool saving;
  final String? error;

  const ProfileState({this.profile, this.saving = false, this.error});

  ProfileState copyWith({bool? saving, String? error}) => ProfileState(
        profile: profile,
        saving: saving ?? this.saving,
        error: error ?? this.error,
      );

  @override
  List<Object?> get props => [profile, saving, error];
}