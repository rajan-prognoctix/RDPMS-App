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
import '../widgets/asset_selector.dart';

/// Telemetry History (Annex E §8.2): parameter values for a selected duration.
class TelemetryHistoryTab extends StatefulWidget {
  const TelemetryHistoryTab({super.key});

  @override
  State<TelemetryHistoryTab> createState() => _TelemetryHistoryTabState();
}

class _TelemetryHistoryTabState extends State<TelemetryHistoryTab> {
  Asset _asset = MockData.assets.first;
  TelemetryParameter? _param;
  DateTimeRange _range = defaultRange(2);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _asset = firstAllowedAsset(context, _asset);
  }

  @override
  Widget build(BuildContext context) {
    final params = MockData.telemetryFor(_asset.assetTypeCode)
        .where((p) => double.tryParse(p.value) != null)
        .toList();
    final param = params.contains(_param) ? _param! : params.first;
    final base = double.parse(param.value);
    final values = MockData.history(base);
    final end = _range.end;
    final step = _range.duration ~/ values.length;
    final minSafe = double.tryParse(param.minSafe ?? '');
    final minFail = double.tryParse(param.minFail ?? '');

    return ListView(
      children: [
        AssetSelector(
          selected: _asset,
          onChanged: (a) => setState(() {
            _asset = a;
            _param = null;
          }),
          trailing: [
            AppDropdown<TelemetryParameter>(
              label: 'Parameter',
              allowAll: false,
              value: param,
              items: params,
              itemLabel: (p) => p.code,
              onChanged: (p) => setState(() => _param = p),
            ),
            DateRangeButton(range: _range, onChanged: (r) => setState(() => _range = r)),
          ],
        ),
        Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionTitle('${param.code} – ${param.name}', trailing: const DownloadButton()),
              Card(
                child: Padding(
                  padding: AppSpacing.cardPadding,
                  child: SimpleLineChart(
                    values: values,
                    unit: param.unit,
                    color: AppColors.primary,
                    thresholds: [
                      if (minSafe != null) ChartThreshold(minSafe, 'Min safe', AppColors.predictive),
                      if (minFail != null) ChartThreshold(minFail, 'Min fail', AppColors.failure),
                    ],
                  ),
                ),
              ),
              const SectionTitle('Readings'),
              AppDataTable(
                columns: ['Date & Time', '${param.code} (${param.unit})'],
                rows: List.generate(values.length, (i) {
                  final t = end.subtract(step * (values.length - 1 - i));
                  return <Object>[DateFormats.dateTime(t), values[i].toString()];
                }).reversed.take(12).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
