import 'package:flutter/widgets.dart';

import '../theme/app_spacing.dart';

/// Standard outer padding for a screen's content ([AppSpacing.screen] on every side).
///
/// Use this (or `AppSpacing.screenPadding` on a ListView / SingleChildScrollView)
/// for every new screen instead of a hard-coded EdgeInsets.
class ScreenPadding extends StatelessWidget {
  final Widget child;

  /// Pad only left and right (for content that manages its own top/bottom spacing).
  final bool horizontalOnly;

  const ScreenPadding({super.key, required this.child, this.horizontalOnly = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: horizontalOnly
            ? const EdgeInsets.symmetric(horizontal: AppSpacing.screen)
            : AppSpacing.screenPadding,
        child: child,
      );
}
