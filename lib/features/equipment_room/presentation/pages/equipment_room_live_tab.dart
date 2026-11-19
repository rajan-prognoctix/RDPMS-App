import 'package:flutter/material.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/mock/mock_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_data_table.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/filter_bar.dart';

/// Equipment Room Live (Annex E §10.1, Annex G).
class EquipmentRoomLiveTab extends StatefulWidget {
  const EquipmentRoomLiveTab({super.key});

  @override
  State<EquipmentRoomLiveTab> createState() => _EquipmentRoomLiveTabState();
}

class _EquipmentRoomLiveTabState extends State<EquipmentRoomLiveTab> {
  LocationFilter _location = const LocationFilter();
  String _view = 'Cards';

  @override
  Widget build(BuildContext context) {
    final rooms = MockData.equipmentRooms.where((r) => _location.matchesStation(r.sc)).toList();
    return ListView(
      children: [
        FilterBar(
          extraFilters: [
            ViewToggle(options: const ['Cards', 'Table'], selected: _view, onChanged: (v) => setState(() => _view = v)),
          ],
          onSearch: (l) => setState(() => _location = l),
        ),
        Padding(
          padding: AppSpacing.screenPadding,
          child: _view == 'Table'
              ? AppDataTable(
                  columns: const ['Station', 'Equipment Room', 'Temp (°C)', 'Humidity (%)', 'Open/Close'],
                  rows: rooms
                      .map((r) => <Object>[
                            r.sc, r.roomTypeCode, r.temperature, r.humidity,
                            r.doorOpen == null ? '—' : (r.doorOpen! ? 'Open' : 'Close'),
                          ])
                      .toList(),
                )
              : Column(children: rooms.map((r) => _RoomCard(r)).toList()),
        ),
      ],
    );
  }
}

class _RoomCard extends StatelessWidget {
  final EquipmentRoomReading r;
  const _RoomCard(this.r);

  @override
  Widget build(BuildContext context) {
    final hot = r.temperature >= 35;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${r.sc} · ${MockData.roomTypeNames[r.roomTypeCode]}',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(r.roomTypeCode, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            _Metric(Icons.thermostat, '${r.temperature} °C', hot ? AppColors.predictive : AppColors.healthy),
            const SizedBox(width: 14),
            _Metric(Icons.water_drop_outlined, '${r.humidity.toStringAsFixed(0)} %', AppColors.neutral),
            if (r.doorOpen != null) ...[
              const SizedBox(width: 14),
              _Metric(
                r.doorOpen! ? Icons.door_front_door : Icons.door_front_door_outlined,
                r.doorOpen! ? 'Open' : 'Closed',
                r.doorOpen! ? AppColors.failure : AppColors.healthy,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _Metric(this.icon, this.text, this.color);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(icon, color: color, size: 20),
          Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      );
}
