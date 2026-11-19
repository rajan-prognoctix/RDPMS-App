import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/track_art_painter.dart';
import '../../../../injection_container.dart';

/// First Flutter screen, shown right after the navy native splash.
/// After [AppConstants.splashMinDuration] it opens Dashboard if an access token
/// is saved (OTP already done on this phone → auto-login, §11.7), else Login.
class SplashPage extends StatefulWidget {
  /// Defaults to the registered [LocalStorage]; pass one in tests.
  final LocalStorage? tokenStorage;

  const SplashPage({super.key, this.tokenStorage});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final LocalStorage _tokens = widget.tokenStorage ?? sl<LocalStorage>();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(AppConstants.splashMinDuration, () {
      if (!mounted) return;
      context.go(_tokens.hasToken ? RouteNames.dashboard : RouteNames.login);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.navy,
        body: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
          child: Stack(
            children: [
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(painter: TrackArtPainter(trackBottomInset: bottomInset + 96)),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(flex: 3),
                      const Column(
                        children: [
                          _Badge(),
                          SizedBox(height: 24),
                          Text(
                            AppConstants.appFullName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              height: 1.3,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            MockData.vendorName,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.onNavyMuted, fontSize: 14),
                          ),
                        ],
                      ),
                      const Spacer(flex: 2),
                      const Text(
                        'Version ${AppConstants.appVersion}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.onNavyMuted,
                          fontSize: 12,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// RDPMS badge, matching the native splash logo and the login header badge.
class _Badge extends StatelessWidget {
  const _Badge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      decoration: BoxDecoration(
        gradient: AppColors.buttonGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withValues(alpha: 0.45),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Text(
        AppConstants.appName,
        style: TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
