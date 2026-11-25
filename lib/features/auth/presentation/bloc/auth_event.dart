part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class LoginRequested extends AuthEvent {
  final String userId;
  final String password;
  const LoginRequested({required this.userId, required this.password});

  @override
  List<Object?> get props => [userId, password];
}

/// App start: restore the user saved at the last sign-in.
final class CurrentUserRequested extends AuthEvent {
  const CurrentUserRequested();
}

final class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
