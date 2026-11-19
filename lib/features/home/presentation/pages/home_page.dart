import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_menu.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/app_side_menu.dart';

/// Main shell with the Annex G bottom navigation:
/// Dashboard · Alert · Telemetry · RDPMS health · Equipment Room,
/// plus the left side menu opened from every tab's app bar.
///
/// Android Back button: on any other tab it returns to Dashboard (index 0);
/// on Dashboard it asks before closing the app. An open side menu, a pushed
/// screen (e.g. alert detail) or an open dialog is closed first, as usual.
class HomeShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const HomeShell({super.key, required this.navigationShell});

  Future<void> _confirmExit(BuildContext context) async {
    final exit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit app?'),
        content: const Text('Do you want to close RDPMS?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.failure),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    if (exit == true) await SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (navigationShell.currentIndex != 0) {
          navigationShell.goBranch(0);
        } else {
          _confirmExit(context);
        }
      },
      child: Scaffold(
        key: homeShellScaffoldKey,
        drawer: const AppSideMenu(),
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (i) =>
              navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
            NavigationDestination(icon: Icon(Icons.warning_amber_outlined), selectedIcon: Icon(Icons.warning_amber), label: 'Alerts'),
            NavigationDestination(icon: Icon(Icons.show_chart), label: 'Telemetry'),
            NavigationDestination(icon: Icon(Icons.monitor_heart_outlined), selectedIcon: Icon(Icons.monitor_heart), label: 'Health'),
            NavigationDestination(icon: Icon(Icons.thermostat_outlined), selectedIcon: Icon(Icons.thermostat), label: 'Equip. Room'),
          ],
        ),
      ),
    );
  }
}