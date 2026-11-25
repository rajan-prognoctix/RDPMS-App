import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/mock/mock_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_data_table.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/filter_bar.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../auth/presentation/bloc/auth_context.dart';

/// Performance of RDPMS (§14, Annex D §15, Annex E §12). Target > 60 %.
class PerformancePage extends StatefulWidget {
  const PerformancePage({super.key});

  @override
  State<PerformancePage> createState() => _PerformancePageState();
}

class _PerformancePageState extends State<PerformancePage> {
  LocationFilter _location = const LocationFilter();
  DateTimeRange _range = defaultRange(30);

  Widget _pct(double v) => Text(
    '${v.toStringAsFixed(2)}%',
    style: TextStyle(
      color: v > 60 ? AppColors.healthy : AppColors.failure,
      fontWeight: FontWeight.w700,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final rows = MockData.performance
        .where((p) => _location.matches(zc: p.zc, dc: p.dc, sc: p.sc))
        .toList();
    double avg(double Function(StationPerformance) f) =>
        rows.isEmpty ? 0 : rows.map(f).reduce((a, b) => a + b) / rows.length;

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Performance of RDPMS'),
          actions: [
            if (context.watchRole().canEnterActualFailures)
              TextButton.icon(
                onPressed: () => _showActualFailureEntry(context),
                icon: const Icon(Icons.add_task),
                label: const Text('Actual Failure entry'),
              ),
          ],
        ),
        body: ListView(
          children: [
            FilterBar(
              extraFilters: [
                DateRangeButton(
                  range: _range,
                  onChanged: (r) => setState(() => _range = r),
                ),
              ],
              onSearch: (l) => setState(() => _location = l),
            ),
            Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _KpiCard(
                    '% (T+PT) Failure alerts out of total failure alerts',
                    avg((p) => p.failAlertPer),
                  ),
                  const SizedBox(height: 8),
                  _KpiCard(
                    '% (T+PT) Predictive alerts out of total predictive alerts',
                    avg((p) => p.predAlertPer),
                  ),
                  const SizedBox(height: 8),
                  _KpiCard(
                    '% (T+PT) Failure alerts out of actual failures at station',
                    avg((p) => p.actualFailAlertPer),
                  ),
                  const SectionTitle(
                    'Station-wise',
                    trailing: DownloadButton(),
                  ),
                  AppDataTable(
                    columns: const [
                      'Zone',
                      'Division',
                      'Station',
                      'Failure alert %',
                      'Predictive alert %',
                      'Actual failure %',
                    ],
                    rows: rows
                        .map(
                          (p) => <Object>[
                            p.zc,
                            p.dc,
                            p.sc,
                            _pct(p.failAlertPer),
                            _pct(p.predAlertPer),
                            _pct(p.actualFailAlertPer),
                          ],
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Target: > 60% for all three, 6 months after commissioning.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Nominated railway staff enter actual signal failures asset-wise (Annex E §12).
  void _showActualFailureEntry(BuildContext context) {
    String? asset;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screen,
          0,
          AppSpacing.screen,
          MediaQuery.viewInsetsOf(ctx).bottom + AppSpacing.screen,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Actual failure entry',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Asset'),
              items: MockData.assets
                  .map(
                    (a) => DropdownMenuItem(
                      value: '${a.sc} ${a.assetNumberCode}',
                      child: Text('${a.sc} · ${a.assetNumberCode}'),
                    ),
                  )
                  .toList(),
              onChanged: (v) => asset = v,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Number of actual failures (today)',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),
            GradientButton(
              label: 'Save',
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Actual failures saved${asset == null ? '' : ' for $asset'}',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final double value;
  const _KpiCard(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final ok = value > 60;
    final color = ok ? AppColors.healthy : AppColors.failure;
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
            const SizedBox(width: 12),
            Text(
              '${value.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
