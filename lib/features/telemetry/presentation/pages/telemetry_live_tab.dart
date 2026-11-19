import 'package:flutter/material.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/mock/mock_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/widgets/app_data_table.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/simple_line_chart.dart';
import '../../../../core/widgets/status_badge.dart';
import '../widgets/asset_selector.dart';

/// Telemetry Live (Annex E §8.1, Annex G): live parameters of the selected asset.
class TelemetryLiveTab extends StatefulWidget {
  const TelemetryLiveTab({super.key});

  @override
  State<TelemetryLiveTab> createState() => _TelemetryLiveTabState();
}

class _TelemetryLiveTabState extends State<TelemetryLiveTab> {
  Asset _asset = MockData.assets.first;
  String _view = 'Table';

  @override
  Widget build(BuildContext context) {
    final params = MockData.telemetryFor(_asset.assetTypeCode);
    final isPoint = _asset.assetTypeCode == 'EOP';

    return ListView(
      children: [
        AssetSelector(
          selected: _asset,
          onChanged: (a) => setState(() => _asset = a),
          trailing: [
            ViewToggle(options: const ['Table', 'Graph'], selected: _view, onChanged: (v) => setState(() => _view = v)),
          ],
        ),
        Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: ListTile(
                  title: Text('${_asset.zc} / ${_asset.dc} / ${_asset.sc}  ·  ${_asset.assetNumberCode}',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${MockData.assetTypeName(_asset.assetTypeCode)} · Make ${_asset.make}\n'
                      'As on ${DateFormats.dateTime(DateTime.now())}'),
                  isThreeLine: true,
                  trailing: StatusBadge(text: statusLabel(_asset.status), color: statusColor(_asset.status)),
                ),
              ),
              if (_view == 'Graph') ...[
                SectionTitle(isPoint ? 'Motor current signature – last operation (20 ms samples)' : 'Last 48 h trend'),
                Card(
                  child: Padding(
                    padding: AppSpacing.cardPadding,
                    child: isPoint
                        ? SimpleLineChart(
                            values: MockData.pointCurrentSignature(),
                            unit: 'A',
                            color: AppColors.primary,
                          )
                        : SimpleLineChart(
                            values: MockData.history(double.tryParse(params.first.value) ?? 24),
                            unit: params.first.unit,
                            color: AppColors.healthy,
                          ),
                  ),
                ),
              ],
              const SectionTitle('Parameters (as per Annexure A)'),
              AppDataTable(
                columns: const ['Parameter', 'Description', 'Value', 'Min safe', 'Min fail', 'para_id'],
                rows: params
                    .map((p) => <Object>[
                          p.code,
                          p.name,
                          Text('${p.value} ${p.unit}',
                              style: TextStyle(color: statusColor(p.status), fontWeight: FontWeight.w700)),
                          p.minSafe ?? '—',
                          p.minFail ?? '—',
                          p.paraId,
                        ])
                    .toList(),
              ),
              const SizedBox(height: 8),
              const Text('Circuit view will be added with the station schematic (§11.9).',
                  style: TextStyle(fontSize: 11, color: Colors.black45)),
            ],
          ),
        ),
      ],
    );
  }
}
