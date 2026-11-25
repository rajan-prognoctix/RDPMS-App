import 'package:flutter/material.dart';

import '../auth/jurisdiction.dart';
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
///
/// The lists follow the signed-in user's [Jurisdiction]: levels fixed for the
/// user are shown locked, and only places inside the jurisdiction are offered
/// ("All" means all within it). On first build it reports the jurisdiction
/// filter through [onSearch], so pages never show data outside it.
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
  Jurisdiction? _applied;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final j = Jurisdiction.of(context);
    if (j == _applied) return;
    // New user / first build: start from the jurisdiction and limit results to it.
    _applied = j;
    _zone = null;
    _division = null;
    _station = null;
    if (j.isRestricted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onSearch(j.filter);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final j = Jurisdiction.of(context);
    final zones = j.zones;
    final zoneLocked = j.zc != null;
    final zone = zoneLocked ? zones.firstOrNull : _zone;

    final divisions = j.divisionsIn(zone);
    final divisionLocked = j.dc != null;
    final division = divisionLocked ? divisions.firstOrNull : _division;

    final stations = j.stationsIn(division, zone: zone);
    final stationLocked = j.sc != null;
    final station = stationLocked ? stations.firstOrNull : _station;

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
            value: zone,
            items: zones,
            itemLabel: (z) => z.zc,
            enabled: !zoneLocked,
            allowAll: !zoneLocked,
            onChanged: (z) => setState(() {
              _zone = z;
              _division = null;
              _station = null;
            }),
          ),
          AppDropdown<Division>(
            label: 'Division',
            value: division,
            items: divisions,
            itemLabel: (d) => d.dc,
            enabled: !divisionLocked,
            allowAll: !divisionLocked,
            onChanged: (d) => setState(() {
              _division = d;
              _station = null;
            }),
          ),
          if (widget.showStation)
            AppDropdown<Station>(
              label: 'Station',
              value: station,
              items: stations,
              itemLabel: (s) => s.sc,
              enabled: !stationLocked,
              allowAll: !stationLocked,
              onChanged: (s) => setState(() => _station = s),
            ),
          ...widget.extraFilters,
          IconButton.filled(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            // "All" at an open level still means all within the jurisdiction.
            onPressed: () => widget.onSearch(
              LocationFilter(
                zc: zone?.zc ?? j.zc,
                dc: division?.dc ?? j.dc,
                sc: station?.sc ?? j.sc,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
