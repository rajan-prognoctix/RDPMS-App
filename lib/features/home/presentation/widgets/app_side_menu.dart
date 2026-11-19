import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/logout_dialog.dart';
import '../../../../core/widgets/track_art_painter.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';

/// Left side menu for the bottom-navigation tabs: user profile header (same
/// navy gradient as the Login header), the "Others" pages (Annex G: Admin,
/// User, Perform, Asset), and Logout.
class AppSideMenu extends StatelessWidget {
  /// Profile photo URL, when the API provides one. Null shows initials.
  final String? photoUrl;

  const AppSideMenu({super.key, this.photoUrl});

  static const _items = [
    (Icons.inventory_2_outlined, 'Asset Detail', RouteNames.assetDetail),
    (Icons.bar_chart, 'Asset Utilization', RouteNames.assetUtilization),
    (Icons.speed, 'Performance', RouteNames.performance),
    (Icons.admin_panel_settings_outlined, 'Admin', RouteNames.admin),
    (Icons.person_outline, 'User Profile', RouteNames.profile),
    (Icons.menu_book_outlined, 'Help & training', RouteNames.profile),
  ];

  /// How long the drawer takes to close (Flutter's drawer settle time is 246 ms).
  static const _drawerCloseDuration = Duration(milliseconds: 220);

  /// Closes the menu first, waits for it to finish sliding out, then opens
  /// [route] full screen on top of the current tab.
  Future<void> _open(BuildContext context, String route) async {
    final router = GoRouter.of(context);
    Scaffold.of(context).closeDrawer();
    await Future<void>.delayed(_drawerCloseDuration);
    router.push(route);
  }

  Future<void> _confirmLogout(BuildContext context) async {
    if (!await confirmLogout(context) || !context.mounted) return;
    final bloc = context.read<AuthBloc>();
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    bloc.add(const LogoutRequested());
    router.go(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileHeader(
            photoUrl: photoUrl,
            onTap: () => _open(context, RouteNames.profile),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                for (final (icon, label, route) in _items)
                  _MenuTile(icon: icon, label: label, onTap: () => _open(context, route)),
              ],
            ),
          ),
          const Divider(height: 1),
          _MenuTile(
            icon: Icons.logout,
            label: 'Logout',
            color: AppColors.failure,
            onTap: () => _confirmLogout(context),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screen,
              0,
              AppSpacing.screen,
              bottomInset + 12,
            ),
            child: const Text(
              'Version ${AppConstants.appVersion}',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

/// Navy gradient header with avatar, name, designation/level and jurisdiction.
class _ProfileHeader extends StatelessWidget {
  final String? photoUrl;
  final VoidCallback onTap;

  const _ProfileHeader({required this.photoUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    // Name and photo as edited on the User Profile page.
    final profile = context.select((ProfileCubit c) => c.state.profile);
    final name = profile?.name ?? MockData.userName;

    return Semantics(
      button: true,
      label: 'Open user profile',
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
          child: Stack(
            children: [
              const Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(painter: TrackArtPainter(trackBottomInset: 14)),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  topInset + 24,
                  AppSpacing.screen,
                  32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryLight.withValues(alpha: 0.45),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: UserAvatar(
                        name: name,
                        photoPath: profile?.photoPath,
                        photoUrl: photoUrl,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      name,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${MockData.userDesignation} · ${MockData.userRole.label} level user',
                      style: const TextStyle(color: AppColors.onNavyMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      MockData.userJurisdiction,
                      style: TextStyle(color: AppColors.onNavyMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _MenuTile({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      leading: Icon(icon, color: color ?? AppColors.primary),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: color ?? AppColors.textMain,
        ),
      ),
      trailing: color == null ? const Icon(Icons.chevron_right, color: AppColors.textMuted) : null,
      onTap: onTap,
    );
  }
}
