import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rdpms_app/core/routes/app_router.dart';
import 'package:rdpms_app/core/routes/route_names.dart';

/// Detail screens and Dashboard shortcuts open full screen: no bottom bar,
/// Back button in the app bar, and Back returns to Dashboard.
void main() {
  Future<void> openDashboard(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter));
    appRouter.go(RouteNames.dashboard);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
  }

  Future<void> tapOnDashboard(WidgetTester tester, Finder target) async {
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Future<void> expectFullScreenThenBack(WidgetTester tester) async {
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Latest pending alerts'), findsOneWidget);
  }

  testWidgets('alert detail from Dashboard opens full screen', (tester) async {
    await openDashboard(tester);
    await tapOnDashboard(tester, find.byIcon(Icons.warning_rounded).first);
    await expectFullScreenThenBack(tester);
  });

  testWidgets('"View all" opens Alerts full screen', (tester) async {
    await openDashboard(tester);
    await tapOnDashboard(tester, find.text('View all'));
    expect(find.text('Alerts'), findsOneWidget);
    await expectFullScreenThenBack(tester);
  });

  testWidgets('Sensors card opens RDPMS Health full screen', (tester) async {
    await openDashboard(tester);
    await tapOnDashboard(tester, find.text('Sensors'));
    expect(find.text('RDPMS Health'), findsOneWidget);
    await expectFullScreenThenBack(tester);
  });

  testWidgets('tabs still show the bottom bar and the menu button', (tester) async {
    await openDashboard(tester);
    await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Alerts')));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byTooltip('Menu'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
  });
}