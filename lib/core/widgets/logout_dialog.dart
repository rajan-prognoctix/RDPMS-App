import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Asks the user to confirm logout. Returns true when they tap Logout.
/// Shared by the side menu and the User Profile page.
Future<bool> confirmLogout(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Logout?'),
      content: const Text('You will need to sign in again with OTP.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(foregroundColor: AppColors.failure),
          child: const Text('Logout'),
        ),
      ],
    ),
  );
  return ok == true;
}