import 'package:flutter/widgets.dart';

import '../mock/mock_data.dart';
import '../mock/mock_models.dart';
import '../widgets/filter_bar.dart';

/// The zone / division / station a signed-in user may see (§11.6, Annex G
/// note 2: Div/Zone icons "as per their role and jurisdiction"). A null level
/// is open (ALL); a set level is fixed for the user.
///
/// - Admin, Head Quarter: their zone
/// - Division: their zone + division
/// - Station: their zone + division + station
/// - Guest: the zone / division they were given
class Jurisdiction {
  final String? zc;
  final String? dc;
  final String? sc;

  const Jurisdiction({this.zc, this.dc, this.sc});

  /// No limit (signed out, or jurisdiction not known).
  static const all = Jurisdiction();

  /// From the login response text ("NCR", "NCR / PYRJ", "NCR / PYRJ / PRYJ"),
  /// keeping only the levels the [role] is tied to.
  factory Jurisdiction.forUser(UserRole role, String? text) {
    final parts = (text ?? '')
        .split('/')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final levels = switch (role) {
      UserRole.admin || UserRole.headQuarter => 1,
      UserRole.division || UserRole.guest => 2,
      UserRole.station => 3,
    };
    String? at(int i) => i < levels && i < parts.length ? parts[i] : null;
    return Jurisdiction(zc: at(0), dc: at(1), sc: at(2));
  }

  bool get isRestricted => zc != null;

  /// Zones the user can pick.
  List<Zone> get zones => MockData.zones.where((z) => zc == null || z.zc == zc).toList();

  /// Divisions the user can pick, within [zone] (null = all allowed zones).
  List<Division> divisionsIn(Zone? zone) => [
        for (final z in zone == null ? zones : [zone])
          for (final d in z.divisions)
            if (dc == null || d.dc == dc) d,
      ];

  /// Stations the user can pick, within [division] (null = all allowed).
  List<Station> stationsIn(Division? division, {Zone? zone}) => [
        for (final d in division == null ? divisionsIn(zone) : [division])
          for (final s in d.stations)
            if (sc == null || s.sc == sc) s,
      ];

  /// Whether data of station [stationCode] may be shown to the user.
  bool allowsStation(String stationCode) =>
      !isRestricted || stationsIn(null).any((s) => s.sc == stationCode);

  /// The widest filter the user may search with.
  LocationFilter get filter => LocationFilter(zc: zc, dc: dc, sc: sc);

  /// The signed-in user's jurisdiction; rebuilds when it changes.
  static Jurisdiction of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<JurisdictionScope>()?.jurisdiction ?? all;

  /// Same as [of] without listening (use in callbacks).
  static Jurisdiction read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<JurisdictionScope>()?.jurisdiction ?? all;

  @override
  bool operator ==(Object other) =>
      other is Jurisdiction && other.zc == zc && other.dc == dc && other.sc == sc;

  @override
  int get hashCode => Object.hash(zc, dc, sc);
}

/// Makes the signed-in user's [Jurisdiction] available to every screen
/// (set up in `App`).
class JurisdictionScope extends InheritedWidget {
  final Jurisdiction jurisdiction;

  const JurisdictionScope({super.key, required this.jurisdiction, required super.child});

  @override
  bool updateShouldNotify(JurisdictionScope oldWidget) => oldWidget.jurisdiction != jurisdiction;
}
