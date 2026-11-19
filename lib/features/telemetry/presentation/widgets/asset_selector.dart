import 'package:flutter/material.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/mock/mock_models.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_dropdown.dart';

/// Station ▸ Asset type ▸ Asset number selector used by Telemetry pages.
class AssetSelector extends StatelessWidget {
  final Asset selected;
  final ValueChanged<Asset> onChanged;
  final List<Widget> trailing;

  const AssetSelector({super.key, required this.selected, required this.onChanged, this.trailing = const []});

  @override
  Widget build(BuildContext context) {
    final stations = MockData.assets.map((a) => a.sc).toSet().toList();
    final types = MockData.assets.where((a) => a.sc == selected.sc).map((a) => a.assetTypeCode).toSet().toList();
    final numbers = MockData.assets
        .where((a) => a.sc == selected.sc && a.assetTypeCode == selected.assetTypeCode)
        .toList();

    return Container(
      color: Colors.white,
      padding: AppSpacing.screenPadding,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppDropdown<String>(
            label: 'Station',
            allowAll: false,
            value: selected.sc,
            items: stations,
            itemLabel: (s) => s,
            onChanged: (s) => onChanged(MockData.assets.firstWhere((a) => a.sc == s)),
          ),
          AppDropdown<String>(
            label: 'Asset Type',
            allowAll: false,
            value: selected.assetTypeCode,
            items: types,
            itemLabel: MockData.assetTypeName,
            onChanged: (t) => onChanged(
              MockData.assets.firstWhere((a) => a.sc == selected.sc && a.assetTypeCode == t),
            ),
          ),
          AppDropdown<Asset>(
            label: 'Asset No.',
            allowAll: false,
            value: selected,
            items: numbers,
            itemLabel: (a) => a.assetNumberCode,
            onChanged: (a) {
              if (a != null) onChanged(a);
            },
          ),
          ...trailing,
        ],
      ),
    );
  }
}
