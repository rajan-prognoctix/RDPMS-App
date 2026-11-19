import 'package:flutter/material.dart';

import '../../../../core/widgets/rdpms_app_bar.dart';
import 'telemetry_history_tab.dart';
import 'telemetry_live_tab.dart';

/// Telemetry (Annex E §8): Telemetry Live · Telemetry History.
class TelemetryPage extends StatelessWidget {
  const TelemetryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: RdpmsAppBar(
          title: 'Telemetry',
          bottom: TabBar(tabs: [Tab(text: 'Telemetry Live'), Tab(text: 'Telemetry History')]),
        ),
        body: TabBarView(children: [TelemetryLiveTab(), TelemetryHistoryTab()]),
      ),
    );
  }
}
