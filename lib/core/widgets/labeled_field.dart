import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

/// Form field with its label above it, in the standard label style
/// ([AppTextStyles.fieldLabel], 14). Hint and in-field label sizes (14) come
/// from the app theme's InputDecorationTheme, so plain TextFormFields match too.
class LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const LabeledField({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyles.fieldLabel),
          const SizedBox(height: 6),
          child,
        ],
      );
}
