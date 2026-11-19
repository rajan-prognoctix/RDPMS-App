import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rdpms_app/core/mock/mock_data.dart';
import 'package:rdpms_app/core/routes/app_menu.dart';
import 'package:rdpms_app/core/routes/route_names.dart';
import 'package:rdpms_app/core/widgets/rdpms_app_bar.dart';
import 'package:rdpms_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rdpms_app/features/home/presentation/widgets/app_side_menu.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

/// A minimal shell like HomeShell: outer Scaffold owns the drawer, the tab
/// page has its own Scaffold + RdpmsAppBar.
Widget _app(AuthBloc bloc) {
  final router = GoRouter(
    initialLocation: RouteNames.dashboard,
    routes: [
      GoRoute(
        path: RouteNames.dashboard,
        builder: (_, _) => Scaffold(
          key: homeShellScaffoldKey,
          drawer: const AppSideMenu(),
          body: const Scaffold(
            appBar: RdpmsAppBar(title: 'Dashboard'),
            body: Text('DASHBOARD BODY'),
          ),
        ),
      ),
      GoRoute(path: RouteNames.performance, builder: (_, _) => const Text('PERFORMANCE PAGE')),
      GoRoute(path: RouteNames.profile, builder: (_, _) => const Text('PROFILE PAGE')),
      GoRoute(path: RouteNames.login, builder: (_, _) => const Text('LOGIN PAGE')),
    ],
  );
  return BlocProvider<AuthBloc>.value(
    value: bloc,
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  late MockAuthBloc bloc;

  // AuthEvent is sealed, so a real event is the fallback for any().
  setUpAll(() => registerFallbackValue(const LogoutRequested()));
  setUp(() {
    bloc = MockAuthBloc();
    when(() => bloc.state).thenReturn(const Unauthenticated());
  });

  Future<void> openMenu(WidgetTester tester) async {
    // Phone-size screen (390×844) so the whole menu is laid out.
    tester.view.physicalSize = const Size(390, 844) * tester.view.devicePixelRatio;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(_app(bloc));
    await tester.tap(find.byTooltip('Menu'));
    await tester.pumpAndSettle();
  }

  testWidgets('menu button replaces the 3-dot menu and opens the side menu', (tester) async {
    await tester.pumpWidget(_app(bloc));

    expect(find.byIcon(Icons.more_vert), findsNothing);
    expect(find.byIcon(Icons.menu), findsOneWidget);

    await tester.tap(find.byTooltip('Menu'));
    await tester.pumpAndSettle();

    expect(find.byType(Drawer), findsOneWidget);
  });

  testWidgets('shows the profile header and all menu items', (tester) async {
    await openMenu(tester);

    expect(find.text(MockData.userName), findsOneWidget);
    expect(find.text('DM'), findsOneWidget); // initials of "Demo Maintainer"
    expect(find.text(MockData.userJurisdiction), findsOneWidget);
    for (final label in [
      'Asset Detail',
      'Asset Utilization',
      'Performance',
      'Admin',
      'User Profile',
      'Help & training',
      'Logout',
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
  });

  testWidgets('tapping an item closes the menu and opens the page', (tester) async {
    await openMenu(tester);

    await tester.tap(find.text('Performance'));
    await tester.pumpAndSettle();

    expect(find.byType(Drawer), findsNothing);
    expect(find.text('PERFORMANCE PAGE'), findsOneWidget);
  });

  testWidgets('tapping the header opens User Profile', (tester) async {
    await openMenu(tester);

    await tester.tap(find.text(MockData.userName));
    await tester.pumpAndSettle();

    expect(find.text('PROFILE PAGE'), findsOneWidget);
  });

  testWidgets('Logout asks first; Cancel keeps the user signed in', (tester) async {
    await openMenu(tester);

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    expect(find.text('Logout?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(() => bloc.add(any()));
    expect(find.byType(Drawer), findsOneWidget);
  });

  testWidgets('confirming Logout signs out and opens Login', (tester) async {
    await openMenu(tester);

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Logout'));
    await tester.pumpAndSettle();

    verify(() => bloc.add(const LogoutRequested())).called(1);
    expect(find.text('LOGIN PAGE'), findsOneWidget);
  });
}
