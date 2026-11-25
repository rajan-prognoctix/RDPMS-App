import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_context.dart';
import '../../domain/entities/admin_user.dart';
import '../cubit/admin_cubit.dart';
import '../widgets/admin_scope.dart';
import '../widgets/admin_user_card.dart';
import '../widgets/audit_log_tab.dart';
import '../widgets/config_tab.dart';

/// Admin (Annex E §13, vendor-designed), three tabs:
/// - Users (mobile design M20): users of the admin's zone / division with status,
///   device approval, Create user, Edit and Disable / Enable (§11.6).
/// - Configuration (Annex D §17, web W22 fields): editable by Admin / HQ users.
/// - Audit log (Annex D §19, web W22 fields).
class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Only HQ and Division users can assign users (§11.6). The menu hides
    // Admin from others; this also blocks the page if opened another way.
    if (!context.watchRole().canOpenAdmin) {
      return SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(title: const Text('Admin')),
          body: const EmptyState(
            'Admin is available to Head Quarter and Division users only.',
            icon: Icons.lock_outline,
          ),
        ),
      );
    }
    return BlocProvider(
      create: (_) => sl<AdminCubit>()..load(),
      child: const _AdminView(),
    );
  }
}

class _AdminView extends StatefulWidget {
  const _AdminView();

  @override
  State<_AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<_AdminView> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _toast(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  Future<void> _approve(AdminUser user) async {
    final error = await context.read<AdminCubit>().approve(user.userId);
    if (!mounted) return;
    _toast(error ?? 'Device approved for ${user.name}');
  }

  Future<void> _createUser() async {
    final created = await context.push<bool>(
      RouteNames.adminCreateUser,
      extra: context.read<AdminCubit>(),
    );
    if (created == true && mounted) {
      _toast('User created. Status: Device pending.');
    }
  }

  Future<void> _editUser(AdminUser user) async {
    final saved = await context.push<bool>(
      RouteNames.adminEditUser,
      extra: (context.read<AdminCubit>(), user),
    );
    if (saved == true && mounted) _toast('Changes saved for ${user.name}');
  }

  Future<void> _toggleDisabled(AdminUser user) async {
    final disable = !user.isDisabled;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(disable ? 'Disable user?' : 'Enable user?'),
        content: Text(
          disable
              ? '${user.name} (${user.userId}) won\'t be able to sign in until the account is enabled again.'
              : '${user.name} (${user.userId}) will be able to sign in again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: disable ? AppColors.failure : AppColors.healthy,
            ),
            child: Text(disable ? 'Disable' : 'Enable'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final error = await context.read<AdminCubit>().setDisabled(
      user.userId,
      disabled: disable,
    );
    if (!mounted) return;
    _toast(error ?? '${user.name} ${disable ? 'disabled' : 'enabled'}');
  }

  /// Actions for [u]: edit / disable only users this admin manages, and never
  /// their own account.
  AdminUserActions _actionsFor(
    AdminUser u,
    AdminScope scope,
    String? myUserId,
  ) {
    final manageable = scope.canManage(u);
    final isMe =
        myUserId != null && u.userId.toLowerCase() == myUserId.toLowerCase();
    late final AdminUserActions actions;
    actions = AdminUserActions(
      onApprove: () => _approve(u),
      onDetails: () => showAdminUserDetails(context, u, actions),
      onEdit: manageable ? () => _editUser(u) : null,
      onToggleDisabled: manageable && !isMe ? () => _toggleDisabled(u) : null,
    );
    return actions;
  }

  bool _matches(AdminUser u, String q) {
    if (q.isEmpty) return true;
    return [
      u.name,
      u.userId,
      u.location,
      u.designation,
    ].any((s) => s.toLowerCase().contains(q));
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watchUser();
    final scope = AdminScope.from(
      context.watchRole(),
      user?.data?.jurisdiction ?? MockData.userJurisdiction,
    );
    final state = context.watch<AdminCubit>().state;
    final query = _search.text.trim().toLowerCase();
    final inScope = state.users.where(scope.includes).toList();
    final shown = inScope.where((u) => _matches(u, query)).toList();

    final usersTab = Column(
      children: [
        Expanded(
          child: ListView(
            padding: AppSpacing.screenPadding,
            children: [
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search name, user ID or station',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: 'Clear search',
                          onPressed: () => setState(_search.clear),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Users in ${scope.label} · ${inScope.length}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLabel,
                ),
              ),
              const SizedBox(height: 10),
              if (state.error != null)
                EmptyState(state.error!, icon: Icons.error_outline)
              else if (shown.isEmpty)
                const EmptyState(
                  'No users found',
                  icon: Icons.person_search_outlined,
                )
              else
                for (final u in shown)
                  AdminUserCard(
                    user: u,
                    actions: _actionsFor(u, scope, user?.data?.userId),
                  ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: GradientButton(
              label: 'Create user',
              leadingIcon: Icons.person_add_alt_1_outlined,
              onPressed: _createUser,
            ),
          ),
        ),
      ],
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Users'),
              Tab(text: 'Configuration'),
              Tab(text: 'Audit log'),
            ],
          ),
        ),
        body: state.loading
            ? const AppLoader()
            : TabBarView(
                children: [
                  usersTab,
                  SafeArea(
                    top: false,
                    child: ConfigTab(
                      settings: state.settings,
                      canEdit: scope.canEditConfig,
                      onSave: (s) => context.read<AdminCubit>().saveSetting(
                        s,
                        changedBy: user?.data?.userId ?? 'admin',
                      ),
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: AuditLogTab(events: state.auditLog),
                  ),
                ],
              ),
      ),
    );
  }
}
