import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rdpms_app/core/mock/mock_data.dart';
import 'package:rdpms_app/core/routes/route_names.dart';
import 'package:rdpms_app/core/storage/token_storage.dart';
import 'package:rdpms_app/features/auth/domain/entities/user.dart';
import 'package:rdpms_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rdpms_app/features/auth/presentation/pages/otp_page.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockTokenStorage extends Mock implements LocalStorage {}

const _user = User(id: '1', name: 'Demo', email: 'demo@example.com');

Widget _app(AuthBloc bloc, LocalStorage tokens) {
  final router = GoRouter(
    initialLocation: RouteNames.otp,
    routes: [
      GoRoute(path: RouteNames.otp, builder: (_, _) => OtpPage(tokenStorage: tokens)),
      GoRoute(path: RouteNames.dashboard, builder: (_, _) => const Text('DASHBOARD')),
      GoRoute(path: RouteNames.login, builder: (_, _) => const Text('LOGIN')),
    ],
  );
  return BlocProvider<AuthBloc>.value(
    value: bloc,
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  late MockAuthBloc bloc;
  late MockTokenStorage tokens;

  setUp(() {
    bloc = MockAuthBloc();
    tokens = MockTokenStorage();
    when(() => bloc.state).thenReturn(const Authenticated(_user));
    when(() => tokens.saveToken(any())).thenAnswer((_) async {});
  });

  Future<void> enterOtpAndVerify(WidgetTester tester, String otp) async {
    await tester.pumpWidget(_app(bloc, tokens));
    await tester.enterText(find.byType(TextField), otp);
    await tester.pump();
    await tester.tap(find.text('Verify and link phone'));
    await tester.pumpAndSettle();
  }

  testWidgets('correct OTP saves the access token, then opens Dashboard', (tester) async {
    await enterOtpAndVerify(tester, MockData.demoOtp);

    verify(() => tokens.saveToken('access-token-123')).called(1);
    expect(find.text('DASHBOARD'), findsOneWidget);
  });

  testWidgets('uses the common app bar; Back goes to Login without saving', (tester) async {
    await tester.pumpWidget(_app(bloc, tokens));
    expect(find.widgetWithText(AppBar, 'Verify this phone'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('LOGIN'), findsOneWidget);
    verifyNever(() => tokens.saveToken(any()));
  });

  testWidgets('wrong OTP saves nothing and shows an error', (tester) async {
    final wrong = MockData.demoOtp == '000000' ? '111111' : '000000';
    await enterOtpAndVerify(tester, wrong);

    verifyNever(() => tokens.saveToken(any()));
    expect(find.text('Invalid OTP'), findsOneWidget);
    expect(find.text('DASHBOARD'), findsNothing);
  });
}