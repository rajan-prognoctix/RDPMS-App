import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// BLoC depends only on use cases (domain), never on repositories/API.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login login;
  final Logout logout;

  AuthBloc({
    required this.login,
    required this.logout,
  }) : super(const AuthInitial()) {
    on<LoginRequested>(_onLogin);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await login(
      LoginParams(username: event.username, password: event.password, deviceId: "Device_Android_A0ib", deviceType: "Mobile"),
    );
    emit(result.fold(
      (failure) => AuthError(failure.message),
      (user) => Authenticated(user),
    ));
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await logout(const NoParams());
    emit(const Unauthenticated());
  }
}