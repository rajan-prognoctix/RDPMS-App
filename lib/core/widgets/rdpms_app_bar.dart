import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes/app_menu.dart';
import '../routes/route_names.dart';

/// App bar used by every bottom-navigation tab: menu button (opens the side
/// menu with Admin, User, Perform, Asset…), title, and live alerts.
/// When the same page is opened full screen (e.g. from a Dashboard shortcut)
/// it shows a Back button instead of the menu button.
class RdpmsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final PreferredSizeWidget? bottom;

  const RdpmsAppBar({super.key, required this.title, this.bottom});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final canGoBack = ModalRoute.of(context)?.canPop ?? false;
    return AppBar(
      leading: canGoBack
          ? const BackButton()
          : IconButton(
              icon: const Icon(Icons.menu),
              tooltip: 'Menu',
              onPressed: () => openAppMenu(context),
            ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      bottom: bottom,
      actions: [
        IconButton(
          tooltip: 'Live alerts',
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => context.go(RouteNames.alerts),
        ),
      ],
    );
  }
}
