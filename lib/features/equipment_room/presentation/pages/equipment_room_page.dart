import 'package:flutter/material.dart';

import '../../../../core/widgets/rdpms_app_bar.dart';
import 'equipment_room_history_tab.dart';
import 'equipment_room_live_tab.dart';

/// Equipment Room (Annex E §10): temperature, humidity and relay-room door.
class EquipmentRoomPage extends StatelessWidget {
  const EquipmentRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
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
