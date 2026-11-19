import 'package:flutter/widgets.dart';

/// Shared spacing (see CLAUDE.md → UI design). Use these instead of hard-coded
/// numbers so every screen and card lines up.
class AppSpacing {
  AppSpacing._();

  /// Outer padding of every screen (left, right, top, bottom).
  static const double screen = 15;

  /// Inner padding of every card.
  static const double card = 15;

  static const EdgeInsets screenPadding = EdgeInsets.all(screen);
  static const EdgeInsets cardPadding = EdgeInsets.all(card);
}
