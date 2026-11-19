import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/route_names.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/logout_dialog.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../cubit/profile_cubit.dart';

/// User Profile (Annex E §14) + training/manuals accessible in-app (§18.3).
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final lastSignIn = sl<LocalStorage>().lastSignIn;

    return SafeArea(
      top: false,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) context.go(RouteNames.login);
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('User Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit profile',
                onPressed: () => context.push(RouteNames.editProfile),
              ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: AppSpacing.cardPadding,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.failure,
                side: const BorderSide(color: AppColors.failure, width: 1.5),
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () async {
                if (!await confirmLogout(context) || !context.mounted) return;
                context.read<AuthBloc>().add(const LogoutRequested());
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ),
          body: ListView(
            padding: AppSpacing.screenPadding,
            children: [
              BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  final p = state.profile;
                  if (p == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Card(
                    child: Padding(
                      padding: AppSpacing.cardPadding,
                      child: Column(
                        children: [
                          UserAvatar(name: p.name, photoPath: p.photoPath),
                          const SizedBox(height: 8),
                          Text(
                            p.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text('${p.designation} · ${p.roleLabel} level user'),
                          const Divider(height: 24),
                          InfoRow('Mobile', p.mobile),
                          InfoRow('Email', p.email),
                          InfoRow('Jurisdiction', p.jurisdiction),
                          InfoRow('Linked device', p.deviceId),
                          InfoRow(
                            'Last sign-in',
                            lastSignIn == null ? '–' : DateFormats.dateTime12h(lastSignIn),
                          ),
                          InfoRow('Vendor', p.vendor),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SectionTitle('Help & training'),
              Card(
                child: Column(
                  children: [
                    for (final (icon, title) in const [
                      (Icons.menu_book_outlined, 'Training manual'),
                      (Icons.ondemand_video_outlined, 'Training video tutorial'),
                      (
                        Icons.build_outlined,
                        'Installation & commissioning manual',
                      ),
                      (Icons.troubleshoot, 'Troubleshooting manual'),
                    ])
                      ListTile(
                        leading: Icon(icon),
                        title: Text(title),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => showComingSoon(context, title),
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
