import 'package:equatable/equatable.dart';
import '../../../../core/auth/user_role.dart';
import '../../data/models/login_response_model.dart';

class User extends Equatable {
  final UserData? data;

  const User({
    required this.data,
  });

  /// User level from the login response; decides what the UI shows (§11.6).
  UserRole get role => UserRole.fromCode(data?.role);

  @override
  List<Object?> get props => [data];
}
