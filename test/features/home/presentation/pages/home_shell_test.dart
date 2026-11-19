import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rdpms_app/features/home/presentation/pages/home_page.dart';

/// Same shell as the app, with simple text pages for the tabs.
Widget _app() {
  StatefulShellBranch branch(String path, String text, {List<RouteBase> routes = const []}) =>
      StatefulShellBranch(routes: [
        GoRoute(path: path, builder: (_, _) => Scaffold(body: Text(text)), routes: routes),
      ]);

  final router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => HomeShell(navigationShell: shell),
        branches: [
          branch('/dashboard', 'DASHBOARD PAGE'),
          branch('/alerts', 'ALERTS PAGE', routes: [
            GoRoute(path: 'detail', builder: (_, _) => const Scaffold(body: Text('DETAIL PAGE'))),
          ]),
          branch('/telemetry', 'TELEMETRY PAGE'),
          branch('/health', 'HEALTH PAGE'),
          branch('/equipment', 'EQUIPMENT PAGE'),
        ],
      ),
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

/// Simulates the Android system Back button.
Future<void> _pressBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Back on another tab returns to Dashboard', (tester) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.text('Telemetry'));
    await tester.pumpAndSettle();
    expect(find.text('TELEMETRY PAGE'), findsOneWidget);

    await _pressBack(tester);

    expect(find.text('DASHBOARD PAGE'), findsOneWidget);
    expect(find.text('Exit app?'), findsNothing);
  });

  testWidgets('Back on Dashboard asks before exiting; Cancel stays in the app', (tester) async {
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(() =>
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));

    await tester.pumpWidget(_app());
    await _pressBack(tester);
    expect(find.text('Exit app?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Exit app?'), findsNothing);
    expect(find.text('DASHBOARD PAGE'), findsOneWidget);
    expect(calls.where((c) => c.method == 'SystemNavigator.pop'), isEmpty);
  });

  testWidgets('Exit in the dialog closes the app', (tester) async {
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(() =>
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));

    await tester.pumpWidget(_app());
    await _pressBack(tester);
    await tester.tap(find.text('Exit'));
    await tester.pumpAndSettle();

    expect(calls.where((c) => c.method == 'SystemNavigator.pop'), hasLength(1));
  });

  testWidgets('Back on a pushed screen goes back within the tab first', (tester) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.text('Alerts'));
    await tester.pumpAndSettle();
    GoRouter.of(tester.element(find.text('ALERTS PAGE'))).go('/alerts/detail');
    await tester.pumpAndSettle();
    expect(find.text('DETAIL PAGE'), findsOneWidget);

    await _pressBack(tester);
    expect(find.text('ALERTS PAGE'), findsOneWidget);

    await _pressBack(tester);
    expect(find.text('DASHBOARD PAGE'), findsOneWidget);
  });
}