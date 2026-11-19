import 'package:flutter/material.dart';

import '../mock/mock_data.dart';
import '../mock/mock_models.dart';
import '../theme/app_spacing.dart';
import 'app_dropdown.dart';

/// Selected Zone / Division / Station. `null` = ALL.
class LocationFilter {
  final String? zc;
  final String? dc;
  final String? sc;
  const LocationFilter({this.zc, this.dc, this.sc});

  bool matches({required String zc, required String dc, required String sc}) =>
      (this.zc == null || this.zc == zc) &&
      (this.dc == null || this.dc == dc) &&
      (this.sc == null || this.sc == sc);

  bool matchesStation(String sc) {
    if (this.sc != null) return this.sc == sc;
    return _stationsInScope().contains(sc);
  }

  Set<String> _stationsInScope() => {
        for (final z in MockData.zones)
          if (zc == null || z.zc == zc)
            for (final d in z.divisions)
              if (dc == null || d.dc == dc)
                for (final s in d.stations) s.sc,
      };
}

/// Header filter row: Zone ▸ Division ▸ Station (cascading) + page-specific
/// filters + search icon. Results update only after search is tapped (Annex E §5).
class FilterBar extends StatefulWidget {
  final ValueChanged<LocationFilter> onSearch;
  final List<Widget> extraFilters;
  final bool showStation;

  const FilterBar({
    super.key,
    required this.onSearch,
    this.extraFilters = const [],
    this.showStation = true,
  });

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  Zone? _zone;
  Division? _division;
  Station? _station;

  List<Division> get _divisions =>
      _zone?.divisions ?? MockData.zones.expand((z) => z.divisions).toList();

  List<Station> get _stations =>
      _division?.stations ?? _divisions.expand((d) => d.stations).toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 10, AppSpacing.screen, 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppDropdown<Zone>(
            label: 'Zone',
            value: _zone,
            items: MockData.zones,
            itemLabel: (z) => z.zc,
            onChanged: (z) => setState(() {
              _zone = z;
              _division = null;
              _station = null;
            }),
          ),
          AppDropdown<Division>(
            label: 'Division',
            value: _division,
            items: _divisions,
            itemLabel: (d) => d.dc,
            onChanged: (d) => setState(() {
              _division = d;
              _station = null;
            }),
          ),
          if (widget.showStation)
            AppDropdown<Station>(
              label: 'Station',
              value: _station,
              items: _stations,
              itemLabel: (s) => s.sc,
              onChanged: (s) => setState(() => _station = s),
            ),
          ...widget.extraFilters,
          IconButton.filled(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () => widget.onSearch(
              LocationFilter(zc: _zone?.zc, dc: _division?.dc, sc: _station?.sc),
            ),
          ),
        ],
      ),
    );
  }
}
