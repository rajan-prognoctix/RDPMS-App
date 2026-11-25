import 'package:flutter/material.dart';

/// Colours from the RDPMS UI Screens design canvas (see CLAUDE.md → UI design).
class AppColors {
  AppColors._();

  // Brand
  static const Color navy = Color(0xFF13294B); // app bar
  static const Color navyDeep = Color(0xFF0D1D36); // darker shade of navy (gradients)
  static const Color navyLight = Color(0xFF1C3D70); // lighter shade of navy (gradients)
  static const Color primary = Color(0xFF1F5FBF); // buttons, links, active chip
  static const Color primaryDark = Color(0xFF174C99); // darker shade of primary (gradients)
  static const Color primaryLight = Color(0xFF3B7BD9); // lighter shade of primary (gradients)
  static const Color primarySoft = Color(0xFFDCE7F7); // selected tab indicator

  // Gradients (shades of navy / primary only)
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navyDeep, navy, navyLight],
    stops: [0.0, 0.55, 1.0],
  );
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryDark, primary, primaryLight],
  );

  // Text
  static const Color textMain = Color(0xFF1A2233);
  static const Color textMuted = Color(0xFF5A6577);
  static const Color textLabel = Color(0xFF3A4558); // form labels
  static const Color onNavyMuted = Color(0xFF9FB0CC); // secondary text on navy

  // Status colours (Annex E/G: green = healthy, amber = predictive, red = failure)
  static const Color healthy = Color(0xFF1B7A43);
  static const Color predictive = Color(0xFFD98A1C); // bars, dots, fills
  static const Color predictiveText = Color(0xFFA35200); // "Predicted" label text (contrast)
  static const Color failure = Color(0xFFB3261E);
  static const Color neutral = Color(0xFF607D8B);

  // Soft badge backgrounds (M20 Admin user status)
  static const Color healthySoft = Color(0xFFE6F4EC);
  static const Color predictiveSoft = Color(0xFFFDF0E1);
  static const Color neutralSoft = Color(0xFFEEF1F6);
  static const Color failureSoft = Color(0xFFFBE7E6);

  // Surfaces
  static const Color surfaceMuted = Color(0xFFF3F5F8); // screen background
  static const Color backdrop = Color(0xFFE9EDF3);
  static const Color track = Color(0xFFE0E0E0); // empty part of progress bars
  static const Color border = Color(0xFFD9DEE6); // cards
  static const Color chipBorder = Color(0xFFC5CCD8);
}