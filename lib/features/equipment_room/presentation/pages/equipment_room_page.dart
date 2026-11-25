import 'package:flutter/material.dart';

import '../../../../core/widgets/rdpms_app_bar.dart';
import '../../../auth/presentation/bloc/auth_context.dart';
import 'equipment_room_history_tab.dart';
import 'equipment_room_live_tab.dart';

/// Equipment Room (Annex E §10): temperature, humidity and relay-room door.
/// Guest users (limited monitoring, §11.6) see Live only.
class EquipmentRoomPage extends StatelessWidget {
  const EquipmentRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!context.watchRole().canViewReports) {
      return const Scaffold(
        appBar: RdpmsAppBar(title: 'Equipment Room'),
        body: EquipmentRoomLiveTab(),
      );
    }
    return const DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: RdpmsAppBar(
          title: 'Equipment Room',
          bottom: TabBar(tabs: [Tab(text: 'Live'), Tab(text: 'History')]),
        ),
        body: TabBarView(children: [EquipmentRoomLiveTab(), EquipmentRoomHistoryTab()]),
      ),
    );
  }
}
