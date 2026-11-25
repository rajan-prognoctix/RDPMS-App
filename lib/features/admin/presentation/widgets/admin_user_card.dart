import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../domain/entities/admin_user.dart';

/// Status pill: Active (green) · Device pending (amber) · Disabled (grey) — M20.
class UserStatusBadge extends StatelessWidget {
  final UserStatus status;
  const UserStatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      UserStatus.active => (AppColors.healthySoft, AppColors.healthy),
      UserStatus.devicePending => (
        AppColors.predictiveSoft,
        AppColors.predictiveText,
      ),
      UserStatus.disabled => (AppColors.neutralSoft, AppColors.textLabel),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

/// Callbacks for the actions an admin can take on a user. Null [onEdit] /
/// [onToggleDisabled] hide those actions (user outside the admin's scope).
class AdminUserActions {
  final VoidCallback onDetails;
  final VoidCallback onApprove;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleDisabled;

  const AdminUserActions({
    required this.onDetails,
    required this.onApprove,
    this.onEdit,
    this.onToggleDisabled,
  });
}

enum _MenuAction { edit, toggleDisabled }

/// One user on the Admin list (M20): name + status, "role · station · user id",
/// a ⋮ menu (Edit, Disable / Enable), and Approve device / Details while the
/// device is pending.
class AdminUserCard extends StatelessWidget {
  final AdminUser user;
  final AdminUserActions actions;

  const AdminUserCard({super.key, required this.user, required this.actions});

  @override
  Widget build(BuildContext context) {
    final pending = user.status == UserStatus.devicePending;
    final hasMenu = actions.onEdit != null || actions.onToggleDisabled != null;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      onTap: actions.onDetails,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: user.isDisabled
                        ? AppColors.textMuted
                        : AppColors.textMain,
                  ),
                ),
              ),
              UserStatusBadge(user.status),
              if (hasMenu)
                SizedBox(
                  width: 36,
                  height: 32,
                  child: PopupMenuButton<_MenuAction>(
                    padding: EdgeInsets.zero,
                    tooltip: 'More actions',
                    icon: const Icon(
                      Icons.more_vert,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                    onSelected: (a) => switch (a) {
                      _MenuAction.edit => actions.onEdit?.call(),
                      _MenuAction.toggleDisabled =>
                        actions.onToggleDisabled?.call(),
                    },
                    itemBuilder: (_) => [
                      if (actions.onEdit != null)
                        const PopupMenuItem(
                          value: _MenuAction.edit,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.edit_outlined),
                            title: Text('Edit'),
                          ),
                        ),
                      if (actions.onToggleDisabled != null)
                        PopupMenuItem(
                          value: _MenuAction.toggleDisabled,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              user.isDisabled
                                  ? Icons.check_circle_outline
                                  : Icons.block,
                              color: user.isDisabled
                                  ? AppColors.healthy
                                  : AppColors.failure,
                            ),
                            title: Text(user.isDisabled ? 'Enable' : 'Disable'),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              text: '${user.role.label} · ${user.location} · ',
              children: [
                TextSpan(
                  text: user.userId,
                  style: const TextStyle(
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          if (pending) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                OutlinedButton(
                  onPressed: actions.onApprove,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    minimumSize: const Size(0, 40),
                  ),
                  child: const Text('Approve device'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: actions.onDetails,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textMain,
                    side: const BorderSide(color: AppColors.chipBorder),
                    minimumSize: const Size(0, 40),
                  ),
                  child: const Text('Details'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Bottom sheet with every field of [user], plus Approve device (while
/// pending), Edit and Disable / Enable.
Future<void> showAdminUserDetails(
  BuildContext context,
  AdminUser user,
  AdminUserActions actions,
) {
  Widget row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );

  String deviceNote() => switch (user.status) {
    UserStatus.devicePending => 'Mobile device not linked yet. Approve after the user completes the first OTP sign-in (§11.7).',
    UserStatus.disabled =>
      'Account disabled: the user can\'t sign in until it is enabled again.',
    UserStatus.active => 'One mobile and one desktop allowed per user (§11.8).',
  };

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      void run(VoidCallback? action) {
        Navigator.pop(ctx);
        action?.call();
      }

      return SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                  UserStatusBadge(user.status),
                ],
              ),
              const Divider(height: 24, color: AppColors.border),
              row('User ID', user.userId),
              row('Role', '${user.role.label} level'),
              row('Designation', user.designation),
              row('Jurisdiction', user.jurisdiction),
              row('Authorised mobile', user.mobile),
              row('Email', user.email),
              if (user.organisation != null)
                row('Organisation', user.organisation!),
              if (user.validUntil != null)
                row('Access valid until', DateFormats.date(user.validUntil!)),
              if (user.nominatedForFailureEntry)
                row('Nominated', 'Actual failure entry'),
              const SizedBox(height: 8),
              Text(
                deviceNote(),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
              if (user.status == UserStatus.devicePending) ...[
                const SizedBox(height: 16),
                GradientButton(
                  label: 'Approve device',
                  leadingIcon: Icons.verified_user_outlined,
                  onPressed: () => run(actions.onApprove),
                ),
              ],
              if (actions.onEdit != null ||
                  actions.onToggleDisabled != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (actions.onEdit != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => run(actions.onEdit),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                      ),
                    if (actions.onEdit != null &&
                        actions.onToggleDisabled != null)
                      const SizedBox(width: 10),
                    if (actions.onToggleDisabled != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => run(actions.onToggleDisabled),
                          icon: Icon(
                            user.isDisabled
                                ? Icons.check_circle_outline
                                : Icons.block,
                          ),
                          label: Text(user.isDisabled ? 'Enable' : 'Disable'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            foregroundColor: user.isDisabled
                                ? AppColors.healthy
                                : AppColors.failure,
                            side: BorderSide(
                              color: user.isDisabled
                                  ? AppColors.healthy
                                  : AppColors.failure,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}
