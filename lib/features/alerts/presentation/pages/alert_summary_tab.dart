import 'package:flutter/material.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/mock/mock_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_data_table.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/filter_bar.dart';

/// Alert Summary (Annex E §7.3): count of total & true alerts for cleared alerts.
class AlertSummaryTab extends StatefulWidget {
  const AlertSummaryTab({super.key});

  @override
  State<AlertSummaryTab> createState() => _AlertSummaryTabState();
}

class _AlertSummaryTabState extends State<AlertSummaryTab> {
  LocationFilter _location = const LocationFilter();
  DateTimeRange _range = defaultRange(30);
  String _view = 'Table';

  @override
  Widget build(BuildContext context) {
    final cleared = MockData.alerts
        .where((a) => a.status == AlertStatus.cleared && a.feedback != AlertFeedback.m)
        .where((a) => _location.matches(zc: a.zc, dc: a.dc, sc: a.sc));

    // Group by station + alert type + asset + cause
    final groups = <String, List<RdpmsAlert>>{};
    for (final a in cleared) {
      groups.putIfAbsent('${a.sc}|${a.type.code}|${a.assetTypeCode}|${a.assetNumberCode}|${a.causeCode}', () => []).add(a);
    }
    final rows = groups.entries.map((e) {
      final list = e.value;
      final a = list.first;
      final t = list.where((x) => x.feedback == AlertFeedback.t).length;
      final pt = list.where((x) => x.feedback == AlertFeedback.pt).length;
      final pct = (t + pt) / list.length * 100;
      return (a: a, total: list.length, t: t, pt: pt, pct: pct);
    }).toList();

    return ListView(
      children: [
        FilterBar(
          extraFilters: [
            DateRangeButton(range: _range, onChanged: (r) => setState(() => _range = r)),
            ViewToggle(options: const ['Table', 'Bar'], selected: _view, onChanged: (v) => setState(() => _view = v)),
          ],
          onSearch: (loc) => setState(() => _location = loc),
        ),
        Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionTitle('Cleared alerts (maintenance "M" excluded)', trailing: DownloadButton()),
              if (_view == 'Table')
                AppDataTable(
                  columns: const ['Zone', 'Division', 'Station', 'Alert Type', 'Asset Type', 'Asset No.', 'Cause', 'Total', 'True', 'Partially True', '% (T+PT)'],
                  rows: rows
                      .map((r) => <Object>[
                            r.a.zc, r.a.dc, r.a.sc, r.a.type.code, r.a.assetTypeCode, r.a.assetNumberCode,
                            r.a.causeCode, r.total, r.t, r.pt, '${r.pct.toStringAsFixed(1)}%',
                          ])
                      .toList(),
                )
              else
                ...rows.map((r) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: AppSpacing.cardPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${r.a.sc} ${r.a.assetNumberCode} · ${r.a.causeCode}',
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: r.pct / 100,
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(5),
                              color: r.pct >= 60 ? AppColors.healthy : AppColors.failure,
                              backgroundColor: AppColors.surfaceMuted,
                            ),
                            const SizedBox(height: 4),
                            Text('${r.pct.toStringAsFixed(1)}% true / partially true of ${r.total}',
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    )),
            ],
          ),
        ),
      ],
    );
  }
}
