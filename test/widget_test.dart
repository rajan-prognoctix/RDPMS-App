import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rdpms_app/features/alerts/presentation/pages/alerts_page.dart';
import 'package:rdpms_app/core/mock/mock_data.dart';
import 'package:rdpms_app/core/widgets/gradient_button.dart';
import 'package:rdpms_app/features/legal/presentation/pages/legal_page.dart';
import 'package:rdpms_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rdpms_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:rdpms_app/features/auth/presentation/pages/login_page.dart';
import 'package:rdpms_app/features/dashboard/presentation/pages/dashboard_page.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  testWidgets('LoginPage shows user id, password, login and new-user link', (tester) async {
    final bloc = MockAuthBloc();
    when(() => bloc.state).thenReturn(const Unauthenticated());

    await tester.pumpWidget(
      MaterialApp(home: BlocProvider<AuthBloc>.value(value: bloc, child: const LoginPage())),
    );

    expect(find.text('User ID'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign in with OTP'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Sign in for New User'), findsOneWidget);
    expect(find.text('OTP-based sign in'), findsOneWidget);
    expect(find.text('Single mobile device'), findsOneWidget);
    expect(find.text('OTP based sign in'), findsNothing);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Terms & Conditions'), findsOneWidget);
  });

  testWidgets('ForgotPasswordPage goes User ID → OTP → new password', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordPage()));

    expect(find.text('Forgot password?'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'user1');
    await tester.tap(find.text('Send OTP'));
    await tester.pump();

    expect(find.text('Enter the OTP'), findsOneWidget);
    await tester.enterText(find.byType(TextField), MockData.demoOtp);
    await tester.pump();
    await tester.tap(find.text('Verify OTP'));
    await tester.pump();

    expect(find.text('Set a new password'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'secret1');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret2');
    final resetButton = find.widgetWithText(GradientButton, 'Reset password');
    await tester.ensureVisible(resetButton);
    await tester.pump();
    await tester.tap(resetButton);
    await tester.pump();
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('LegalPage shows the placeholder Privacy Policy and Terms', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LegalPage(document: LegalDocument.privacyPolicy)),
    );
    expect(find.text('Privacy Policy'), findsWidgets);
    expect(find.text('Placeholder. The final text is to be provided.'), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: LegalPage(document: LegalDocument.terms)));
    expect(find.text('Terms & Conditions'), findsWidgets);
  });

  testWidgets('Dashboard shows asset groups from hardcoded data', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardPage()));

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('PT-M/C'), findsOneWidget);
    expect(find.text('Track Circuit'), findsOneWidget);
  });

  testWidgets('Alerts page shows the four tabs and live alert feedback buttons', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AlertsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Alert Live'), findsOneWidget);
    expect(find.text('Maintenance mode'), findsOneWidget);
    expect(find.text('PT'), findsWidgets);
  });
}
