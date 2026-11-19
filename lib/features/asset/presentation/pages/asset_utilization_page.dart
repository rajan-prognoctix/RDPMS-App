import 'package:flutter/material.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_data_table.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/filter_bar.dart';

/// Asset Utilization (Annex E §11.2): number of operations for the selected duration.
class AssetUtilizationPage extends StatefulWidget {
  const AssetUtilizationPage({super.key});

  @override
  State<AssetUtilizationPage> createState() => _AssetUtilizationPageState();
}

class _AssetUtilizationPageState extends State<AssetUtilizationPage> {
  LocationFilter _location = const LocationFilter();
  DateTimeRange _range = defaultRange(30);
  String _view = 'Table';

  @override
  Widget build(BuildContext context) {
    final assets =
        MockData.assets
            .where((a) => a.operations > 0)
            .where((a) => _location.matches(zc: a.zc, dc: a.dc, sc: a.sc))
            .toList()
          ..sort((a, b) => b.operations.compareTo(a.operations));
    final maxOps = assets.isEmpty ? 1 : assets.first.operations;

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(title: const Text('Asset Utilization')),
        body: ListView(
          children: [
            FilterBar(
              extraFilters: [
                DateRangeButton(
                  range: _range,
                  onChanged: (r) => setState(() => _range = r),
                ),
                ViewToggle(
                  options: const ['Table', 'Bar'],
                  selected: _view,
                  onChanged: (v) => setState(() => _view = v),
                ),
              ],
              onSearch: (l) => setState(() => _location = l),
            ),
            Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionTitle(
                    'Number of operations',
                    trailing: DownloadButton(),
                  ),
                  if (_view == 'Table')
                    AppDataTable(
                      columns: const [
                        'Zone',
                        'Division',
                        'Station',
                        'Asset Type',
                        'Asset No.',
                        'Operations',
                      ],
                      rows: assets
                          .map(
                            (a) => <Object>[
                              a.zc,
                              a.dc,
                              a.sc,
                              a.assetTypeCode,
                              a.assetNumberCode,
                              a.operations,
                            ],
                          )
                          .toList(),
                    )
                  else
                    Card(
                      child: Padding(
                        padding: AppSpacing.cardPadding,
                        child: Column(
                          children: assets
                              .map(
                                (a) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 90,
                                        child: Text(
                                          '${a.sc} ${a.assetNumberCode}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      Expanded(
                                        child: LinearProgressIndicator(
                                          value: a.operations / maxOps,
                                          minHeight: 14,
                                          color: AppColors.primary,
                                          backgroundColor:
                                              AppColors.surfaceMuted,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 40,
                                        child: Text(
                                          '${a.operations}',
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
