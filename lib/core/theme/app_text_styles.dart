import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Shared text styles (see CLAUDE.md → UI design).
class AppTextStyles {
  AppTextStyles._();

  /// Font size for form field labels and hints across the whole app.
  static const double fieldTextSize = 14;

  /// Label shown above a form field (Login, Forgot password).
  static const TextStyle fieldLabel = TextStyle(
    fontSize: fieldTextSize,
    fontWeight: FontWeight.w600,
    color: AppColors.textLabel,
  );

  /// Label inside a Material text field / dropdown (`InputDecoration.labelText`).
  static const TextStyle inputLabel = TextStyle(
    fontSize: fieldTextSize,
    color: AppColors.textMuted,
  );

  /// Placeholder text (`InputDecoration.hintText`).
  static const TextStyle fieldHint = TextStyle(
    fontSize: fieldTextSize,
    color: AppColors.textMuted,
  );
}
