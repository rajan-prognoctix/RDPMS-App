import '../../domain/entities/audit_event.dart';
import '../../domain/entities/config_setting.dart';

/// Mock Annex D §17 settings and §19 audit log for the UI-only phase.
/// Defaults are the spec's indicative values ("Zonal Railway may decide the
/// durations"); rows the spec leaves to the Zonal Railway start as "Not set".
class AdminMockData {
  AdminMockData._();

  /// Asset-type columns (§13 tables): Point machine, LC gate, IPS, Signal,
  /// Track circuit / Axle counter.
  static const assetTypes = ['PM', 'LC', 'IPS', 'Signal', 'TC/AC'];

  static const _levels = ['JE/SE', 'SSE', 'ASTE/DSTE', 'Higher officer'];

  static Map<String, ConfigValue> _perType(List<double?> hours) => {
    for (var i = 0; i < assetTypes.length; i++)
      assetTypes[i]: hours[i] == null
          ? const ConfigValue.notSet()
          : ConfigValue(hours[i]),
  };

  static Map<String, ConfigValue> _same(double? value) =>
      _perType(List.filled(assetTypes.length, value));

  static ConfigSetting _assetTypeWise(
    int n,
    String title,
    String source,
    Map<String, ConfigValue> values, {
    String unit = 'h',
  }) => ConfigSetting(
    number: n,
    title: title,
    scope: 'Asset type wise',
    unit: unit,
    source: source,
    keys: assetTypes,
    values: values,
  );

  static ConfigSetting _single(
    int n,
    String title,
    String source,
    double value,
  ) => ConfigSetting(
    number: n,
    title: title,
    scope: 'All',
    unit: 'days',
    source: source,
    keys: const ['Value'],
    values: {'Value': ConfigValue(value)},
  );

  static ConfigSetting _firstPush(int n, String title) => ConfigSetting(
    number: n,
    title: title,
    scope: 'Asset wise',
    unit: 'min',
    source: 'Annex D §13.3',
    keys: _levels,
    values: const {
      'JE/SE': ConfigValue(30),
      'SSE': ConfigValue(60),
      'ASTE/DSTE': ConfigValue(120),
      'Higher officer': ConfigValue.notSet(),
    },
  );

  static List<ConfigSetting> settings() => [
    _assetTypeWise(
      1,
      'Repeat alert advising maintainer staff that maintenance mode is active',
      'Annex D §5',
      _perType([60, null, null, 45, 60]),
      unit: 'min',
    ),
    _assetTypeWise(
      2,
      'Failure alert feedback duration by Maintainer',
      'Annex D §6 ("*")',
      _same(null),
    ),
    _assetTypeWise(
      3,
      'Predictive alert feedback duration by Maintainer',
      'Annex D §6 ("*")',
      _same(null),
    ),
    _assetTypeWise(
      4,
      'Failure alert comment duration by Vendor after PT/F feedback by Maintainer',
      'Annex D §6.1',
      _same(null),
    ),
    _assetTypeWise(
      5,
      'Predictive alert comment duration by Vendor after PT/F feedback by Maintainer',
      'Annex D §6.2',
      _same(null),
    ),
    _assetTypeWise(
      6,
      'Failure alert feedback modification duration by JE/SSE after Vendor comment on PT/F',
      'Annex D §6.1',
      _same(null),
    ),
    _assetTypeWise(
      7,
      'Predictive alert feedback modification duration by JE/SSE after Vendor comment on PT/F',
      'Annex D §6.2',
      _same(null),
    ),
    _firstPush(
      8,
      'Delay before the first Failure alert is pushed to higher hierarchy',
    ),
    _firstPush(
      9,
      'Delay before the first Predictive alert is pushed to higher hierarchy',
    ),
    _assetTypeWise(
      10,
      'Repeat Failure alert frequency to Maintainer',
      'Annex D §13.2',
      _perType([2, 2, 1, 3, 3]),
    ),
    _assetTypeWise(
      11,
      'Repeat Failure alert frequency to JE/SE',
      'Annex D §13.3',
      _perType([3, 3, 1, 4, 4]),
    ),
    _assetTypeWise(
      12,
      'Repeat Failure alert frequency to SSE',
      'Annex D §13.3',
      _perType([6, 6, 1, 8, 8]),
    ),
    _assetTypeWise(
      13,
      'Repeat Failure alert frequency to ASTE/DSTE',
      'Annex D §13.3',
      _perType([9, 9, 2, 12, 12]),
    ),
    _assetTypeWise(
      14,
      'Repeat Failure alert frequency to higher Officer',
      'Annex D §17',
      _same(null),
    ),
    _assetTypeWise(
      15,
      'Repeat Predictive alert frequency to Maintainer',
      'Annex D §13.2',
      _same(12),
    ),
    _assetTypeWise(
      16,
      'Repeat Predictive alert frequency to JE/SE',
      'Annex D §13.3',
      _same(18),
    ),
    _assetTypeWise(
      17,
      'Repeat Predictive alert frequency to SSE',
      'Annex D §13.3',
      _same(24),
    ),
    _assetTypeWise(
      18,
      'Repeat Predictive alert frequency to ASTE/DSTE',
      'Annex D §13.3',
      _same(36),
    ),
    _assetTypeWise(
      19,
      'Repeat Predictive alert frequency to higher Officer',
      'Annex D §17',
      _same(null),
    ),
    _single(
      20,
      'Number of days for the average operating parameter value',
      'Annex A, Annex C',
      15,
    ),
    _single(21, 'Time sync data packet sending frequency', 'Annex B ¶1.1.3', 7),
    _single(
      22,
      'Information request data packet sending frequency',
      'Annex B ¶1.1.5',
      30,
    ),
    _single(
      23,
      'Image request data packet sending frequency',
      'Annex B ¶1.1.6',
      7,
    ),
  ];

  static List<AuditEvent> auditLog() {
    final now = DateTime.now();
    AuditEvent e(
      Duration ago,
      String user,
      String event,
      String source,
      String device,
      AuditResult r,
    ) => AuditEvent(
      time: now.subtract(ago),
      userId: user,
      event: event,
      source: source,
      device: device,
      result: r,
    );
    return [
      e(
        const Duration(minutes: 25),
        'esm.pryj.1',
        'Sign-in from a second mobile',
        'RDPMS App',
        'Android · new device',
        AuditResult.blocked,
      ),
      e(
        const Duration(minutes: 40),
        'unknown',
        'Wrong password × 5',
        'RDPMS App',
        '10.12.4.88',
        AuditResult.blocked,
      ),
      e(
        const Duration(hours: 2),
        'dste.pyrj',
        'Opened Admin page without permission',
        'RDPMS App',
        '10.12.2.14',
        AuditResult.blocked,
      ),
      e(
        const Duration(hours: 3),
        'guest.rdso',
        'Disabled account tried to sign in',
        'RDPMS App',
        '10.12.9.3',
        AuditResult.blocked,
      ),
      e(
        const Duration(hours: 4),
        'sse.sig.pryj',
        'OTP entered wrong twice',
        'RDPMS App',
        'iOS · registered',
        AuditResult.warned,
      ),
      e(
        const Duration(hours: 5),
        'unknown',
        'Mobile number not authorised',
        'RDPMS App',
        'Android · unknown',
        AuditResult.blocked,
      ),
      e(
        const Duration(days: 1, hours: 2),
        'unknown',
        'Unauthorised laptop connection on config port',
        'Station Gateway PRYJ-01',
        'Laptop · 192.168.1.40',
        AuditResult.blocked,
      ),
      e(
        const Duration(days: 1, hours: 6),
        'je.sig.mja',
        'Session ended — signed in on another desktop',
        'RDPMS App',
        '10.12.6.40',
        AuditResult.logged,
      ),
      e(
        const Duration(days: 2),
        'cste.ncr',
        'Changed parameter #10: Repeat Failure alert frequency to Maintainer',
        'RDPMS App',
        '10.12.1.2',
        AuditResult.logged,
      ),
      e(
        const Duration(days: 3),
        'unknown',
        'Firmware access attempt without certificate',
        'IoT LB-3',
        'Local port',
        AuditResult.blocked,
      ),
      e(
        const Duration(days: 4),
        'admin.ncr',
        'Device reset by Admin for esm.bmu.1',
        'RDPMS App',
        '—',
        AuditResult.logged,
      ),
    ];
  }
}
