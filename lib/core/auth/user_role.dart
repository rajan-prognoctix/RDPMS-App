/// User levels and what each one may do (§11.6, Annex E §1, Annex D §5–§7).
///
/// - Admin: manages users and the Admin page for a zone, monitor, reports — no
///   control functions. The spec refers to "Admin" (Annex D §17, §19, Annex E
///   §13, Annex G note 2) but does not define it as a level; this app adds it.
/// - Head Quarter / Division: assign users, monitor, reports — no control functions.
/// - Station: acknowledge, monitor, reports, control functions (T/PT/F/M feedback,
///   remarks, maintenance mode) — cannot assign users.
/// - Guest: limited monitoring only (live pages, no reports, no actions).
enum UserRole {
  admin('Admin'),
  headQuarter('Head Quarter'),
  division('Division'),
  station('Station'),
  guest('Guest');

  const UserRole(this.label);
  final String label;

  /// Maps the API `role` text ("Admin", "Head Quarter", "HQ", "Division Level",
  /// "Station Level", "Guest"…) to a role. Unknown or missing → [guest]
  /// (least access).
  static UserRole fromCode(String? code) {
    final c = (code ?? '').trim().toLowerCase();
    if (c.startsWith('admin')) return UserRole.admin;
    if (c.startsWith('head') || c == 'hq') return UserRole.headQuarter;
    if (c.startsWith('div')) return UserRole.division;
    if (c.startsWith('station') || c.startsWith('stn')) return UserRole.station;
    return UserRole.guest;
  }

  /// Roles a person can pick when signing up as a new user (Admin is assigned
  /// only by an existing Admin / HQ user).
  static const selfSignUp = [headQuarter, division, station, guest];

  /// Admin page: users (create, edit, disable, approve device).
  bool get canOpenAdmin =>
      this == UserRole.admin || this == UserRole.headQuarter || this == UserRole.division;

  /// Acknowledge alerts, T/PT/F/M feedback, remarks, maintenance mode.
  bool get canControl => this == UserRole.station;

  /// History / summary tabs, Asset, Performance.
  bool get canViewReports => this != UserRole.guest;

  /// "Actual Failure entry" on Performance (Annex E §12 — staff nominated by
  /// the Zonal Railway; the backend should narrow this to nominated users).
  bool get canEnterActualFailures => this != UserRole.guest;
}
