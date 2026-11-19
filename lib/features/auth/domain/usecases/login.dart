import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rdpms_app/features/auth/data/models/login_request_model.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class Login implements UseCase<User, LoginParams> {
  final AuthRepository repository;

  Login(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    final apiRequest = LoginRequestModel(
      userId: params.username,
      password: params.password,
      deviceId: params.deviceId,
      deviceType: params.deviceType,
    );

    return await repository.login(request: apiRequest);
  }
}


class LoginParams extends Equatable {
  final String username;
  final String password;
  final String deviceId;
  final String deviceType;
  const LoginParams({required this.username, required this.password, required this.deviceId, required this.deviceType});

  @override
  List<Object?> get props => [username, password, deviceId, deviceType];
}
