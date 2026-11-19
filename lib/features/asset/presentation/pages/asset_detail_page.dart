import 'package:flutter/material.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/widgets/app_data_table.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/filter_bar.dart';
import '../../../../core/widgets/status_badge.dart';

/// Asset Detail (Annex E §11.1): count of assets per type & make as on today.
class AssetDetailPage extends StatefulWidget {
  const AssetDetailPage({super.key});

  @override
  State<AssetDetailPage> createState() => _AssetDetailPageState();
}

class _AssetDetailPageState extends State<AssetDetailPage> {
  LocationFilter _location = const LocationFilter();
  String? _type;
  String? _appliedType;

  @override
  Widget build(BuildContext context) {
    final assets = MockData.assets
        .where((a) => _location.matches(zc: a.zc, dc: a.dc, sc: a.sc))
        .where((a) => _appliedType == null || a.assetTypeCode == _appliedType)
        .toList();
    final counts = <String, int>{};
    for (final a in assets) {
      counts.update(
        '${a.zc}|${a.dc}|${a.sc}|${a.assetTypeCode}|${a.make}',
        (v) => v + 1,
        ifAbsent: () => 1,
      );
    }

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(title: const Text('Asset Detail')),
        body: ListView(
          children: [
            FilterBar(
              extraFilters: [
                AppDropdown<String>(
                  label: 'Asset Type',
                  value: _type,
                  items: MockData.assetTypeNames.keys.toList(),
                  itemLabel: MockData.assetTypeName,
                  onChanged: (v) => setState(() => _type = v),
                ),
              ],
              onSearch: (l) => setState(() {
                _location = l;
                _appliedType = _type;
              }),
            ),
            Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionTitle(
                    'As on ${DateFormats.date(DateTime.now())}',
                    trailing: const DownloadButton(),
                  ),
                  AppDataTable(
                    columns: const [
                      'Zone',
                      'Division',
                      'Station',
                      'Asset Type',
                      'Asset make',
                      'Count',
                    ],
                    rows: counts.entries
                        .map((e) => <Object>[...e.key.split('|'), e.value])
                        .toList(),
                  ),
                  const SectionTitle('Assets'),
                  ...assets.map(
                    (a) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          '${a.sc} · ${a.assetNumberCode}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${MockData.assetTypeName(a.assetTypeCode)} (${a.assetTypeCode})\n'
                          'SMMS: ${a.smmsAssetCode} · Make: ${a.make}',
                        ),
                        isThreeLine: true,
                        trailing: StatusBadge(
                          text: statusLabel(a.status),
                          color: statusColor(a.status),
                        ),
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
