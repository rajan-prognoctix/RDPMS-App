import 'package:flutter/material.dart';

/// Key of the main shell's Scaffold (bottom-navigation tabs), which owns the
/// side menu. Each tab has its own inner Scaffold + app bar, so the menu button
/// opens the shell's drawer through this key.
final GlobalKey<ScaffoldState> homeShellScaffoldKey = GlobalKey<ScaffoldState>();

/// Opens the app side menu (left drawer).
void openAppMenu(BuildContext context) {
  final shell = homeShellScaffoldKey.currentState;
  if (shell != null && shell.hasDrawer) {
    shell.openDrawer();
  } else {
    Scaffold.maybeOf(context)?.openDrawer();
  }
}
