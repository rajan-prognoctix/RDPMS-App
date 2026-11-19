import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rdpms_app/core/error/failures.dart';
import 'package:rdpms_app/core/usecase/usecase.dart';
import 'package:rdpms_app/features/auth/domain/entities/user.dart';
import 'package:rdpms_app/features/auth/domain/usecases/login.dart';
import 'package:rdpms_app/features/auth/domain/usecases/logout.dart';
import 'package:rdpms_app/features/auth/presentation/bloc/auth_bloc.dart';

class MockLogin extends Mock implements Login {}

class MockLogout extends Mock implements Logout {}

void main() {
  late MockLogin login;
  late MockLogout logout;

  const user = User(id: '1', name: 'Test', email: 't@t.com');
  const params = LoginParams(username: 'u', password: 'secret', deviceId: "d_id", deviceType: "m");

  setUpAll(() {
    registerFallbackValue(params);
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    login = MockLogin();
    logout = MockLogout();
  });

  AuthBloc build() => AuthBloc(login: login, logout: logout);

  blocTest<AuthBloc, AuthState>(
    'emits [Loading, Authenticated] when login succeeds',
    setUp: () => when(() => login(any())).thenAnswer((_) async => right(user)),
    build: build,
    act: (b) => b.add(const LoginRequested(username: 'u', password: 'secret')),
    expect: () => [const AuthLoading(), const Authenticated(user)],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [Loading, AuthError] when login fails',
    setUp: () => when(() => login(any()))
        .thenAnswer((_) async => left(const ServerFailure('Invalid credentials'))),
    build: build,
    act: (b) => b.add(const LoginRequested(username: 'u', password: 'secret')),
    expect: () => [const AuthLoading(), const AuthError('Invalid credentials')],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [Unauthenticated] on logout',
    setUp: () => when(() => logout(any())).thenAnswer((_) async => right(unit)),
    build: build,
    act: (b) => b.add(const LogoutRequested()),
    expect: () => [const Unauthenticated()],
  );
}