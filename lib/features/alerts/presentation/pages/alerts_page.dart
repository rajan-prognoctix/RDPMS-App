import 'package:flutter/material.dart';

import '../../../../core/widgets/rdpms_app_bar.dart';
import '../../../auth/presentation/bloc/auth_context.dart';
import 'alert_history_tab.dart';
import 'alert_live_tab.dart';
import 'alert_summary_tab.dart';
import 'maintenance_mode_tab.dart';

/// Alerts (Annex E §7): Alert Live · Alert History · Alert Summary · Maintenance mode.
/// Tabs follow the user's role (§11.6): History and Summary are reports (not for
/// Guest users); Maintenance mode is a control function (Station users only).
class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watchRole();
    final tabs = <(String, Widget)>[
      ('Alert Live', const AlertLiveTab()),
      if (role.canViewReports) ...[
        ('Alert History', const AlertHistoryTab()),
        ('Alert Summary', const AlertSummaryTab()),
      ],
      if (role.canControl) ('Maintenance mode', const MaintenanceModeTab()),
    ];

    if (tabs.length == 1) {
      return Scaffold(appBar: const RdpmsAppBar(title: 'Alerts'), body: tabs.first.$2);
    }

    return DefaultTabController(
      key: ValueKey(tabs.length),
      length: tabs.length,
      child: Scaffold(
        appBar: RdpmsAppBar(
          title: 'Alerts',
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [for (final (label, _) in tabs) Tab(text: label)],
          ),
        ),
        body: TabBarView(children: [for (final (_, view) in tabs) view]),
      ),
    );
  }
}
