import 'package:flutter/material.dart';

import '../../../../core/widgets/rdpms_app_bar.dart';
import 'alert_history_tab.dart';
import 'alert_live_tab.dart';
import 'alert_summary_tab.dart';
import 'maintenance_mode_tab.dart';

/// Alerts (Annex E §7): Alert Live · Alert History · Alert Summary · Maintenance mode.
class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: RdpmsAppBar(
          title: 'Alerts',
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Alert Live'),
              Tab(text: 'Alert History'),
              Tab(text: 'Alert Summary'),
              Tab(text: 'Maintenance mode'),
            ],
          ),
        ),
        body: TabBarView(
          children: [AlertLiveTab(), AlertHistoryTab(), AlertSummaryTab(), MaintenanceModeTab()],
        ),
      ),
    );
  }
}
