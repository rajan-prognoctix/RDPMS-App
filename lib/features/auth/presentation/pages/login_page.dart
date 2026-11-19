import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/track_art_painter.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/login_form.dart';

/// Landing page (Annex E/G): title, vendor name, user id, password, Sign in for new user.
/// Sign-in is always OTP based (§11.7) and limited to one mobile per user (§11.8).
/// Based on the M01 Login mobile design, with a gradient header (navy shades only).
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  /// How far the form card overlaps the header.
  static const double _overlap = 56;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return MultiBlocListener(
      listeners: [
        // Fresh login → OTP device authentication (§11.7).
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (prev, curr) => prev is AuthLoading && curr is Authenticated,
          listener: (context, _) => context.go(RouteNames.otp),
        ),
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (_, curr) => curr is AuthError,
          listener: (context, state) => ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text((state as AuthError).message))),
        ),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: AppColors.surfaceMuted,
          body: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _Header(bottomPadding: _overlap + 28),
                      Expanded(
                        child: Transform.translate(
                          offset: const Offset(0, -_overlap),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              AppSpacing.screen,
                              0,
                              AppSpacing.screen,
                              bottomInset,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const _FormCard(),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'New to RDPMS?',
                                      style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                                    ),
                                    SizedBox(width: 15),
                                    TextButton(
                                      onPressed: () => context.push(RouteNames.register),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                        minimumSize: const Size(44, 44),
                                        padding: const EdgeInsets.symmetric(horizontal: 6),
                                        textStyle: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      child: const Text('Sign in for New User'),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                const SizedBox(height: 12),
                                const _SignInInfoCard(),
                                const SizedBox(height: 16),
                                const _LegalLine(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Gradient header: RDPMS badge, full name and vendor, over faint track-and-signal line art.
class _Header extends StatelessWidget {
  final double bottomPadding;
  const _Header({required this.bottomPadding});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: AppColors.headerGradient),
        child: Stack(
          children: [
            const Positioned.fill(child: CustomPaint(painter: TrackArtPainter())),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screen,
                topInset + 28,
                AppSpacing.screen,
                bottomPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: AppColors.buttonGradient,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryLight.withValues(alpha: 0.45),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Text(
                      AppConstants.appName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    AppConstants.appFullName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          MockData.vendorName,
                          style: const TextStyle(color: AppColors.onNavyMuted, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// White card holding the sign-in form; overlaps the header.
class _FormCard extends StatelessWidget {
  const _FormCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome back',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.navy),
          ),
          SizedBox(height: 4),
          Text(
            'Sign in with your User ID and password. An OTP will be sent to your registered mobile.',
            style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.textMuted),
          ),
          SizedBox(height: 20),
          LoginForm(),
        ],
      ),
    );
  }
}

/// One-line sign-in rules: OTP based (§11.7) and single mobile device (§11.8).
class _SignInInfoCard extends StatelessWidget {
  const _SignInInfoCard();

  static const _textStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  static Widget _item(IconData icon, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label, style: _textStyle),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _item(Icons.sms_outlined, 'OTP-based sign in'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text('•', style: _textStyle),
          ),
          _item(Icons.phone_android_outlined, 'Single mobile device'),
        ],
      ),
    );
  }
}

/// "By signing in, you agree to the Privacy Policy and Terms & Conditions."
class _LegalLine extends StatelessWidget {
  const _LegalLine();

  static const _textStyle = TextStyle(fontSize: 12, height: 1.5, color: AppColors.textMuted);

  Widget _link(BuildContext context, String label, String route) => InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            label,
            style: _textStyle.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primary,
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text('By signing in, you agree to the ', style: _textStyle),
        _link(context, 'Privacy Policy', RouteNames.privacyPolicy),
        const Text(' and ', style: _textStyle),
        _link(context, 'Terms & Conditions', RouteNames.terms),
        const Text('.', style: _textStyle),
      ],
    );
  }
}
