import 'package:flutter/material.dart';

import '../../../../core/widgets/rdpms_app_bar.dart';
import '../../../auth/presentation/bloc/auth_context.dart';
import 'telemetry_history_tab.dart';
import 'telemetry_live_tab.dart';

/// Telemetry (Annex E §8): Telemetry Live · Telemetry History.
/// Guest users (limited monitoring, §11.6) see Live only.
class TelemetryPage extends StatelessWidget {
  const TelemetryPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!context.watchRole().canViewReports) {
      return const Scaffold(
        appBar: RdpmsAppBar(title: 'Telemetry'),
        body: TelemetryLiveTab(),
      );
    }
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
