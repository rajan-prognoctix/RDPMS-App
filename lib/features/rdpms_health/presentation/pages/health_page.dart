import 'package:flutter/material.dart';

import '../../../../core/widgets/rdpms_app_bar.dart';
import 'health_live_tab.dart';
import 'health_summary_tab.dart';

/// RDPMS Health (Annex E §9): health of Sensors, IoT, Station Gateway & Network.
class HealthPage extends StatelessWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: RdpmsAppBar(
          title: 'RDPMS Health',
          bottom: TabBar(tabs: [Tab(text: 'Health Live'), Tab(text: 'Health Summary')]),
        ),
        body: TabBarView(children: [HealthLiveTab(), HealthSummaryTab()]),
      ),
    );
  }
}
