import 'package:flutter/material.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_data_table.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/filter_bar.dart';

/// RDPMS Health Summary (Annex E §9.2): % availability for selected duration (Annex D §16).
class HealthSummaryTab extends StatefulWidget {
  const HealthSummaryTab({super.key});

  @override
  State<HealthSummaryTab> createState() => _HealthSummaryTabState();
}

class _HealthSummaryTabState extends State<HealthSummaryTab> {
  LocationFilter _location = const LocationFilter();
  DateTimeRange _range = defaultRange(1);

  String _p(double v) => '${v.toStringAsFixed(1)}%';

  @override
  Widget build(BuildContext context) {
    final rows = MockData.healthAvailability.where((h) => _location.matchesStation(h.sc)).toList();
    return ListView(
      children: [
        FilterBar(
          extraFilters: [DateRangeButton(range: _range, onChanged: (r) => setState(() => _range = r))],
          onSearch: (l) => setState(() => _location = l),
        ),
        Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionTitle('Availability', trailing: DownloadButton()),
              AppDataTable(
                columns: const ['Station', 'Asset Type', 'Sensors', '% Avail.', 'IoTs', '% Avail.', 'Network', '% Avail.', 'Stn GW', '% Avail.'],
                rows: rows
                    .map((h) => <Object>[
                          h.sc, h.assetTypeCode,
                          h.sensors, _p(h.sensorAvail),
                          h.iots, _p(h.iotAvail),
                          h.networks, _p(h.networkAvail),
                          h.gateways, _p(h.gatewayAvail),
                        ])
                    .toList(),
              ),
              const SizedBox(height: 12),
              const Card(
                child: Padding(
                  padding: AppSpacing.cardPadding,
                  child: Text(
                    'Availability of sensors = Σ healthy time of each sensor ÷ (number of sensors × duration). '
                    'Same formula for IoT, station gateway and network.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
