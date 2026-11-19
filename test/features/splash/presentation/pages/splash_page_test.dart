import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rdpms_app/core/constants/app_constants.dart';
import 'package:rdpms_app/core/routes/route_names.dart';
import 'package:rdpms_app/core/storage/token_storage.dart';
import 'package:rdpms_app/features/splash/presentation/pages/splash_page.dart';

class MockTokenStorage extends Mock implements LocalStorage {}

Widget _app(LocalStorage tokens) {
  final router = GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(path: RouteNames.splash, builder: (_, _) => SplashPage(tokenStorage: tokens)),
      GoRoute(path: RouteNames.login, builder: (_, _) => const Text('LOGIN')),
      GoRoute(path: RouteNames.dashboard, builder: (_, _) => const Text('DASHBOARD')),
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

void main() {
  late MockTokenStorage tokens;

  setUp(() => tokens = MockTokenStorage());

  testWidgets('shows the RDPMS branding and version on the first frame', (tester) async {
    when(() => tokens.hasToken).thenReturn(false);
    await tester.pumpWidget(_app(tokens));

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text(AppConstants.appFullName), findsOneWidget);
    expect(find.text('Version ${AppConstants.appVersion}'), findsOneWidget);

    // Let the timer finish so no timer is left pending.
    await tester.pump(AppConstants.splashMinDuration);
    await tester.pump();
  });

  testWidgets('no saved token: stays for 2 seconds, then opens Login', (tester) async {
    when(() => tokens.hasToken).thenReturn(false);
    await tester.pumpWidget(_app(tokens));

    await tester.pump(AppConstants.splashMinDuration - const Duration(milliseconds: 100));
    expect(find.text('LOGIN'), findsNothing);

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('DASHBOARD'), findsNothing);
  });

  testWidgets('saved token: opens Dashboard directly (auto-login)', (tester) async {
    when(() => tokens.hasToken).thenReturn(true);
    await tester.pumpWidget(_app(tokens));

    await tester.pump(AppConstants.splashMinDuration);
    await tester.pump();
    expect(find.text('DASHBOARD'), findsOneWidget);
    expect(find.text('LOGIN'), findsNothing);
  });
}