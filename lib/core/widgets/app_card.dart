import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// White card from the app theme (border #D9DEE6, radius 12) with the standard
/// inner padding ([AppSpacing.card]). Use it for every new card.
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  const AppCard({super.key, required this.child, this.onTap, this.margin});

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: AppSpacing.cardPadding, child: child);
    return Card(
      margin: margin,
      child: onTap == null
          ? content
          : InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: content,
            ),
    );
  }
}
