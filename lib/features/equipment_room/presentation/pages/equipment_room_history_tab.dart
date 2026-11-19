import 'package:flutter/material.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/widgets/app_data_table.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/simple_line_chart.dart';

/// Equipment Room History (Annex E §10.2) — readings every 30 min.
class EquipmentRoomHistoryTab extends StatefulWidget {
  const EquipmentRoomHistoryTab({super.key});

  @override
  State<EquipmentRoomHistoryTab> createState() => _EquipmentRoomHistoryTabState();
}

class _EquipmentRoomHistoryTabState extends State<EquipmentRoomHistoryTab> {
  String _station = 'PRYJ';
  String _room = 'RR';
  DateTimeRange _range = defaultRange(1);

  @override
  Widget build(BuildContext context) {
    final stations = MockData.equipmentRooms.map((r) => r.sc).toSet().toList();
    final rooms = MockData.equipmentRooms.where((r) => r.sc == _station).map((r) => r.roomTypeCode).toList();
    final room = rooms.contains(_room) ? _room : rooms.first;
    final reading = MockData.equipmentRooms.firstWhere((r) => r.sc == _station && r.roomTypeCode == room);
    final temps = MockData.history(reading.temperature, spread: 0.12);
    final hums = MockData.history(reading.humidity, spread: 0.1);
    final now = DateTime.now();

    return ListView(
      children: [
        Container(
          color: Colors.white,
          padding: AppSpacing.screenPadding,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppDropdown<String>(
                label: 'Station',
                allowAll: false,
                value: _station,
                items: stations,
                itemLabel: (s) => s,
                onChanged: (s) => setState(() => _station = s ?? _station),
              ),
              AppDropdown<String>(
                label: 'Equipment Room',
                allowAll: false,
                value: room,
                items: rooms,
                itemLabel: (r) => r,
                onChanged: (r) => setState(() => _room = r ?? _room),
              ),
              DateRangeButton(range: _range, onChanged: (r) => setState(() => _range = r)),
            ],
          ),
        ),
        Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionTitle('Temperature (°C) – ${MockData.roomTypeNames[room]}', trailing: const DownloadButton()),
              Card(
                child: Padding(
                  padding: AppSpacing.cardPadding,
                  child: SimpleLineChart(values: temps, unit: '°C', color: AppColors.predictive, height: 150),
                ),
              ),
              const SectionTitle('Humidity (%)'),
              Card(
                child: Padding(
                  padding: AppSpacing.cardPadding,
                  child: SimpleLineChart(values: hums, unit: '%', color: AppColors.neutral, height: 150),
                ),
              ),
              const SectionTitle('Readings (every 30 min)'),
              AppDataTable(
                columns: const ['Date & Time', 'Temp (°C)', 'Humidity (%)', 'Door'],
                rows: List.generate(10, (i) {
                  final idx = temps.length - 1 - i;
                  return <Object>[
                    DateFormats.dateTime(now.subtract(Duration(minutes: 30 * i))),
                    temps[idx],
                    hums[idx],
                    room == 'RR' ? (i == 3 ? 'Open' : 'Close') : '—',
                  ];
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
