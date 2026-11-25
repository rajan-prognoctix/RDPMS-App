part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class Authenticated extends AuthState {
  final User user;
  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

extension AuthStateUser on AuthState {
  /// The signed-in user, or null.
  User? get currentUser => switch (this) {
        Authenticated(:final user) => user,
        _ => null,
      };

  /// The signed-in user's level; [UserRole.guest] (least access) when unknown.
  UserRole get role => currentUser?.role ?? UserRole.guest;
}

final class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
