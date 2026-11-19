import 'package:flutter/material.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_data_table.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/filter_bar.dart';

/// RDPMS Health Live (Annex E §9.1, Annex G): totals, faulty items, table or pictorial view.
class HealthLiveTab extends StatefulWidget {
  const HealthLiveTab({super.key});

  @override
  State<HealthLiveTab> createState() => _HealthLiveTabState();
}

class _HealthLiveTabState extends State<HealthLiveTab> {
  LocationFilter _location = const LocationFilter();
  String _view = 'Table';

  @override
  Widget build(BuildContext context) {
    final faults = MockData.healthFaults.where((f) => _location.matchesStation(f.sc)).toList();

    return ListView(
      children: [
        FilterBar(
          extraFilters: [
            ViewToggle(options: const ['Table', 'Pictorial'], selected: _view, onChanged: (v) => setState(() => _view = v)),
          ],
          onSearch: (l) => setState(() => _location = l),
        ),
        Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.2,
                children: const [
                  _TotalTile('Sensors', MockData.totalSensors, MockData.faultySensors, Icons.sensors),
                  _TotalTile('IoTs', MockData.totalIots, MockData.faultyIots, Icons.memory),
                  _TotalTile('Network', MockData.totalNetworks, MockData.faultyNetworks, Icons.lan),
                  _TotalTile('Stn gateway', MockData.totalGateways, MockData.faultyGateways, Icons.router),
                ],
              ),
              const SectionTitle('Faulty items'),
              if (_view == 'Table')
                AppDataTable(
                  columns: const ['Station', 'Asset Type', 'Asset No.', 'Faulty Sensor', 'Faulty IoT', 'Faulty Network', 'Faulty Stn Gateway'],
                  rows: faults
                      .map((f) => <Object>[
                            f.sc, f.assetTypeCode, f.assetNumberCode,
                            f.faultySensor ?? '—', f.faultyIot ?? '—', f.faultyNetwork ?? '—', f.faultyGateway ?? '—',
                          ])
                      .toList(),
                )
              else
                const _PictorialView(),
            ],
          ),
        ),
      ],
    );
  }
}

class _TotalTile extends StatelessWidget {
  final String title;
  final int total, faulty;
  final IconData icon;
  const _TotalTile(this.title, this.total, this.faulty, this.icon);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.card),
        child: Row(
          children: [
            Icon(icon, color: AppColors.neutral),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('Total $total', style: const TextStyle(fontSize: 12)),
                  Text('Faulty $faulty',
                      style: const TextStyle(fontSize: 12, color: AppColors.failure, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Station view: gateways → IoTs, each with sensor dots. Green = working, red = failed (Annex E §9.1).
class _PictorialView extends StatelessWidget {
  const _PictorialView();

  @override
  Widget build(BuildContext context) {
    const gateways = [
      ('PRYJ – Gateway 00', true, [('IoT LB-1', true, 8, 0), ('IoT LB-2', true, 6, 1), ('IoT LB-3', false, 9, 9), ('IoT RR-1', true, 12, 0)]),
      ('MJA – Gateway 00', false, [('IoT LB-1', true, 6, 0), ('IoT LC-41', true, 5, 0)]),
    ];
    return Column(
      children: gateways.map((g) {
        final (name, gwOk, iots) = g;
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.router, color: gwOk ? AppColors.healthy : AppColors.failure),
                    const SizedBox(width: 8),
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 10),
                ...iots.map((iot) {
                  final (label, ok, sensors, faulty) = iot;
                  return Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.memory, size: 18, color: ok ? AppColors.healthy : AppColors.failure),
                        const SizedBox(width: 6),
                        SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12))),
                        Expanded(
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: List.generate(
                              sensors,
                              (i) => Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: i < sensors - faulty ? AppColors.healthy : AppColors.failure,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
