import 'dart:math' as math;

import 'mock_models.dart';

/// Hardcoded data for the UI-only phase. Codes follow docs/RDPMS_REQUIREMENTS.md (Annex A/C/D).
class MockData {
  MockData._();

  // ---------------- Current user (§11.6, §11.7) ----------------
  static const userId = 'EMP001';
  static const userName = 'Demo Maintainer';
  static const userDesignation = 'ESM';
  static const userMobile = '98XXXXXX21';
  static const userEmail = 'esm.prayagraj@example.com';
  static const UserRole userRole = UserRole.station;
  static const userJurisdiction = 'NCR / PYRJ / PRYJ';
  static const vendorName = 'Prognostix.ai';
  static const deviceId = 'ANDROID-7F3A-29C1';  static const demoOtp = '123456';

  // ---------------- Location hierarchy (Annex A §3) ----------------
  static const zones = <Zone>[
    Zone('NCR', 'North Central Railway', [
      Division('PYRJ', 'Prayagraj', [
        Station('PRYJ', 'Prayagraj Jn'),
        Station('MJA', 'Manauri'),
      ]),
    ]),
    Zone('NR', 'Northern Railway', [
      Division('LKO', 'Lucknow', [
        Station('LKO', 'Lucknow'),
        Station('BBK', 'Barabanki'),
      ]),
    ]),
    Zone('NER', 'North Eastern Railway', [
      Division('LJN', 'Lucknow', [Station('LJN', 'Lucknow Jn')]),
    ]),
  ];

  // ---------------- Asset types (Annex A §3e) ----------------
  static const assetTypeNames = <String, String>{
    'EOP': 'Point Machine',
    'LED': 'Main Signal',
    'LES': 'Shunt Signal',
    'LEC': 'Calling On Signal',
    'LER': 'Route Signal',
    'DCT': 'DC Track Circuit',
    'MSE': 'MSDAC - Eldyne',
    'SSC': 'SSDAC - CEL',
    'ELC': 'Electrical LC Gate',
    'IPS': 'Integrated Power Supply',
    'ELD': 'Earth Leakage Detector',
    'SPD': 'SPD',
  };

  static String assetTypeName(String code) => assetTypeNames[code] ?? code;

  // ---------------- Equipment rooms (Annex A §3j) ----------------
  static const roomTypeNames = <String, String>{
    'RR': 'Relay Room',
    'IPS': 'IPS Room',
    'BATT': 'Battery Room',
    'MAIN': 'Maintainer Room',
    'GEN': 'Generator Room',
    'OUTDOOR': 'Outdoor',
    'LOC': 'Location Box',
  };

  // ---------------- Cause codes (Annex C) ----------------
  static const causesByAssetType = <String, List<String>>{
    'EOP': [
      'PT N VOLT/CURR LOW', 'PT R VOLT/CURR LOW', 'PT N IND VOLT LOW AT LOC',
      'PT N TIME HIGH', 'PT R TIME HIGH', 'PT N IND VOLT FAIL AT LOC',
      'PT VOLT FAIL AT NWKR', 'PT NWKR RELAY DEFECT', 'PT N OBS', 'PT R OBS',
      'PT N FAIL UNKNOWN', 'PT R FAIL UNKNOWN',
    ],
    'DCT': [
      'TC TFC O/P VOLT LOW', 'TC BT CHG CURR LOW', 'TC BALST/SLPR RES LOW',
      'TC RAIL RES HIGH', 'TC TR VOLT LOW', 'TC GJ SHORT', 'TC SHORT',
      'TC CKT OPEN', 'TC TR RELAY DEFECT', 'REASON UNKNOWN',
    ],
    'LED': [
      'SIG RG VOLT/CURR LOW', 'SIG HG CURR HIGH', 'SIG HPR VOLT LOW',
      'SIG RG VOLT/CURR FAIL', 'SIG HG HPR VOLT FAIL', 'SIG HG HECR RELAY DEFECT',
      'SIG BLANK', 'SIG RG UNKOWN',
    ],
    'LEC': ['COSIG ASPECT VOLT/CURR LOW', 'COSIG HPR VOLT FAIL', 'COSIG REASON UNKOWN'],
    'IPS': [
      'IPS I/P VOLT LOW', 'IPS 110 DC BATT VOLT LOW', 'IPS BATT CHAR CURR LOW',
      'IPS I/P VOLT FAIL', 'IPS 110 DC VOLT FAIL',
    ],
  };

  // ---------------- Assets ----------------
  static const assets = <Asset>[
    Asset(zc: 'NCR', dc: 'PYRJ', sc: 'PRYJ', assetTypeCode: 'EOP', assetNumberCode: 'PT-101', smmsAssetCode: 'EOPPRYJ00013', make: 'ABC', status: AssetStatus.failure, operations: 184),
    Asset(zc: 'NCR', dc: 'PYRJ', sc: 'PRYJ', assetTypeCode: 'EOP', assetNumberCode: 'PT-102', smmsAssetCode: 'EOPPRYJ00014', make: 'ABC', status: AssetStatus.predictive, operations: 162),
    Asset(zc: 'NCR', dc: 'PYRJ', sc: 'PRYJ', assetTypeCode: 'EOP', assetNumberCode: 'PT-103', smmsAssetCode: 'EOPPRYJ00015', make: 'DEF', status: AssetStatus.healthy, operations: 97),
    Asset(zc: 'NCR', dc: 'PYRJ', sc: 'PRYJ', assetTypeCode: 'DCT', assetNumberCode: 'TC-12', smmsAssetCode: 'DCTPRYJ00047', make: 'GHI', status: AssetStatus.predictive),
    Asset(zc: 'NCR', dc: 'PYRJ', sc: 'PRYJ', assetTypeCode: 'DCT', assetNumberCode: 'TC-101', smmsAssetCode: 'DCTPRYJ00048', make: 'GHI', status: AssetStatus.healthy),
    Asset(zc: 'NCR', dc: 'PYRJ', sc: 'PRYJ', assetTypeCode: 'LED', assetNumberCode: 'S-1', smmsAssetCode: 'LEDPRYJ00101', make: 'JKL', status: AssetStatus.failure),
    Asset(zc: 'NCR', dc: 'PYRJ', sc: 'PRYJ', assetTypeCode: 'LEC', assetNumberCode: 'CO-1', smmsAssetCode: 'LECPRYJ00102', make: 'JKL', status: AssetStatus.healthy),
    Asset(zc: 'NCR', dc: 'PYRJ', sc: 'PRYJ', assetTypeCode: 'IPS', assetNumberCode: 'IPS-1', smmsAssetCode: 'IPSPRYJ00001', make: 'MNO', status: AssetStatus.predictive),
    Asset(zc: 'NCR', dc: 'PYRJ', sc: 'MJA', assetTypeCode: 'EOP', assetNumberCode: 'PT-201', smmsAssetCode: 'EOPMJA00021', make: 'ABC', status: AssetStatus.healthy, operations: 210),
    Asset(zc: 'NCR', dc: 'PYRJ', sc: 'MJA', assetTypeCode: 'DCT', assetNumberCode: 'TC-21', smmsAssetCode: 'DCTMJA00031', make: 'GHI', status: AssetStatus.failure),
    Asset(zc: 'NCR', dc: 'PYRJ', sc: 'MJA', assetTypeCode: 'ELC', assetNumberCode: 'LC-41', smmsAssetCode: 'ELCMJA00041', make: 'PQR', status: AssetStatus.healthy, operations: 76),
    Asset(zc: 'NR', dc: 'LKO', sc: 'LKO', assetTypeCode: 'EOP', assetNumberCode: 'PT-11', smmsAssetCode: 'EOPLKO00011', make: 'DEF', status: AssetStatus.healthy, operations: 301),
    Asset(zc: 'NR', dc: 'LKO', sc: 'LKO', assetTypeCode: 'MSE', assetNumberCode: 'AC-5', smmsAssetCode: 'MSELKO00005', make: 'Eldyne', status: AssetStatus.predictive),
    Asset(zc: 'NR', dc: 'LKO', sc: 'BBK', assetTypeCode: 'LED', assetNumberCode: 'S-14', smmsAssetCode: 'LEDBBK00014', make: 'JKL', status: AssetStatus.healthy),
    Asset(zc: 'NER', dc: 'LJN', sc: 'LJN', assetTypeCode: 'DCT', assetNumberCode: 'TC-7', smmsAssetCode: 'DCTLJN00007', make: 'GHI', status: AssetStatus.healthy),
  ];

  // ---------------- Dashboard groups (Annex G dashboard) ----------------
  static const dashboardGroups = <DashboardGroup>[
    DashboardGroup('PT-M/C', 50, 10, 5),
    DashboardGroup('Track Circuit', 40, 7, 4),
    DashboardGroup('Signal', 45, 10, 6),
    DashboardGroup('Axle Counter', 55, 10, 8),
    DashboardGroup('LC Gate', 10, 2, 1),
    DashboardGroup('Other Gears', 30, 5, 2),
  ];
  static const sensorsHealthy = 480, sensorsFailed = 20;
  static const iotHealthy = 48, iotFailed = 2;
  static const cpuUsage = 0.42, ramUsage = 0.58, storageUsage = 0.35;

  // ---------------- Alerts (Annex D) ----------------
  static final DateTime _now = DateTime.now();

  static final alerts = <RdpmsAlert>[
    RdpmsAlert(id: 'A1001', zc: 'NCR', dc: 'PYRJ', sc: 'PRYJ', type: AlertType.failure, assetTypeCode: 'EOP', assetNumberCode: 'PT-101', causeCode: 'PT N OBS', causeDetail: 'Point No. PT-101 failed in Normal. Normal indication voltage at Loc failed OR point in obstruction.', incidence: _now.subtract(const Duration(minutes: 42))),
    RdpmsAlert(id: 'A1002', zc: 'NCR', dc: 'PYRJ', sc: 'PRYJ', type: AlertType.failure, assetTypeCode: 'LED', assetNumberCode: 'S-1', causeCode: 'SIG HG HPR VOLT FAIL', causeDetail: 'Sig No. S-1 HG aspect failed. Voltage of HPR failed.', incidence: _now.subtract(const Duration(hours: 1, minutes: 15))),
    RdpmsAlert(id: 'A1003', zc: 'NCR', dc: 'PYRJ', sc: 'PRYJ', type: AlertType.predictive, assetTypeCode: 'EOP', assetNumberCode: 'PT-102', causeCode: 'PT N TIME HIGH', causeDetail: 'Predictive alert for PT-102. Normal operation time high.', incidence: _now.subtract(const Duration(hours: 3, minutes: 5))),
    RdpmsAlert(id: 'A1004', zc: 'NCR', dc: 'PYRJ', sc: 'PRYJ', type: AlertType.predictive, assetTypeCode: 'DCT', assetNumberCode: 'TC-12', causeCode: 'TC BALST/SLPR RES LOW', causeDetail: 'Track ckt predictive alert for TC-12: Track relay voltage/current is low due to ballast/sleeper low resistance.', incidence: _now.subtract(const Duration(hours: 5, minutes: 20))),
    RdpmsAlert(id: 'A1005', zc: 'NCR', dc: 'PYRJ', sc: 'PRYJ', type: AlertType.predictive, assetTypeCode: 'IPS', assetNumberCode: 'IPS-1', causeCode: 'IPS 110 DC BATT VOLT LOW', causeDetail: 'IPS 110 DC O/P voltage low while battery is on load.', incidence: _now.subtract(const Duration(hours: 7))),
    RdpmsAlert(id: 'A1006', zc: 'NCR', dc: 'PYRJ', sc: 'MJA', type: AlertType.failure, assetTypeCode: 'DCT', assetNumberCode: 'TC-21', causeCode: 'TC TR RELAY DEFECT', causeDetail: 'Track Ckt No. TC-21 failed. TR current is OK but TR relay may be defective.', incidence: _now.subtract(const Duration(minutes: 18))),
    RdpmsAlert(id: 'A1007', zc: 'NR', dc: 'LKO', sc: 'LKO', type: AlertType.predictive, assetTypeCode: 'MSE', assetNumberCode: 'AC-5', causeCode: 'AXCO EQ VOLT LOW', causeDetail: 'Axle counter equipment supply voltage low (vendor logic approved by Zonal Railway).', incidence: _now.subtract(const Duration(hours: 9))),
    // Cleared (history)
    RdpmsAlert(id: 'A0991', zc: 'NCR', dc: 'PYRJ', sc: 'PRYJ', type: AlertType.failure, assetTypeCode: 'EOP', assetNumberCode: 'PT-101', causeCode: 'PT N OBS', causeDetail: 'Point in obstruction.', incidence: _now.subtract(const Duration(days: 2, hours: 3)), rectification: _now.subtract(const Duration(days: 2, hours: 1)), status: AlertStatus.cleared, feedback: AlertFeedback.t, feedbackTime: _now.subtract(const Duration(days: 2)), remarks: 'Found stone chip between tongue and stock rail. Removed.', maintainerName: 'Ranjan Kumar', maintainerDesignation: 'ESM-III', maintainerMobile: '75XXXXXX95'),
    RdpmsAlert(id: 'A0987', zc: 'NCR', dc: 'PYRJ', sc: 'PRYJ', type: AlertType.predictive, assetTypeCode: 'DCT', assetNumberCode: 'TC-101', causeCode: 'TC TFC O/P VOLT LOW', causeDetail: 'TFC output voltage low.', incidence: _now.subtract(const Duration(days: 4)), rectification: _now.subtract(const Duration(days: 3, hours: 20)), status: AlertStatus.cleared, feedback: AlertFeedback.pt, feedbackTime: _now.subtract(const Duration(days: 3, hours: 19)), remarks: 'Loose connection at TFC terminal; charger OK.', maintainerName: 'Suresh Yadav', maintainerDesignation: 'ESM-II', maintainerMobile: '94XXXXXX10'),
    RdpmsAlert(id: 'A0975', zc: 'NCR', dc: 'PYRJ', sc: 'MJA', type: AlertType.failure, assetTypeCode: 'ELC', assetNumberCode: 'LC-41', causeCode: 'ELB MOTOR CURR FAIL', causeDetail: 'ELB motor current failed.', incidence: _now.subtract(const Duration(days: 6)), rectification: _now.subtract(const Duration(days: 6)).add(const Duration(minutes: 50)), status: AlertStatus.cleared, feedback: AlertFeedback.m, feedbackTime: _now.subtract(const Duration(days: 5, hours: 22)), remarks: 'Alert during scheduled maintenance.', maintainerName: 'Ranjan Kumar', maintainerDesignation: 'ESM-III', maintainerMobile: '75XXXXXX95'),
    RdpmsAlert(id: 'A0960', zc: 'NR', dc: 'LKO', sc: 'LKO', type: AlertType.predictive, assetTypeCode: 'EOP', assetNumberCode: 'PT-11', causeCode: 'PT R TIME HIGH', causeDetail: 'Reverse operation time high.', incidence: _now.subtract(const Duration(days: 8)), status: AlertStatus.cleared, feedback: AlertFeedback.f, feedbackTime: _now.subtract(const Duration(days: 7, hours: 20)), remarks: 'No abnormality found at site.', maintainerName: 'Amit Singh', maintainerDesignation: 'ESM-I', maintainerMobile: '99XXXXXX44'),
  ];

  static RdpmsAlert? alertById(String id) {
    for (final a in alerts) {
      if (a.id == id) return a;
    }
    return null;
  }

  // ---------------- Maintenance mode (Annex D §5) ----------------
  static final maintenanceModes = <MaintenanceMode>[
    MaintenanceMode(id: 'M1', sc: 'PRYJ', assetTypeCode: 'EOP', assetNumberCode: 'PT-103', from: _now.subtract(const Duration(minutes: 20)), to: _now.add(const Duration(hours: 1))),
  ];

  /// Reminder interval when maintenance mode stays active (Annex D §5)
  static const maintenanceReminder = {'DCT': '60 min', 'EOP': '60 min', 'LED': '45 min'};

  // ---------------- Telemetry (Annex A parameter nomenclature) ----------------
  static List<TelemetryParameter> telemetryFor(String assetTypeCode) {
    switch (assetTypeCode) {
      case 'EOP':
        return const [
          TelemetryParameter(code: 'V PT NWKR', name: '24 VDC at RR from Loc Normal', paraId: '00010000', value: '23.8', unit: 'V', minSafe: '21', minFail: '18'),
          TelemetryParameter(code: 'NWKR', name: 'Digital status of NWKR', paraId: '00014010', value: 'UP', unit: ''),
          TelemetryParameter(code: 'RWKR', name: 'Digital status of RWKR', paraId: '00014011', value: 'DN', unit: ''),
          TelemetryParameter(code: 'V PT 110 DC LOC N', name: '110 DC at Loc box for Normal', paraId: '00012020', value: '84.6', unit: 'V', minSafe: '90', minFail: '82', status: AssetStatus.predictive),
          TelemetryParameter(code: 'I PT N', name: 'Point machine current Normal', paraId: '00010030', value: '1.62', unit: 'A', minSafe: '*', minFail: '*'),
          TelemetryParameter(code: 'V PT 24 DC LOC N', name: '24 V DC to RR after detection (N)', paraId: '00012040', value: '24.1', unit: 'V'),
          TelemetryParameter(code: 'T PT N', name: 'Normal operation time', paraId: '00019060', value: '9.2', unit: 's', minSafe: '8 (max)', status: AssetStatus.failure),
          TelemetryParameter(code: 'T PT R', name: 'Reverse operation time', paraId: '00019061', value: '4.1', unit: 's', minSafe: '8 (max)'),
        ];
      case 'DCT':
        return const [
          TelemetryParameter(code: 'V TC 24 DC TPR I/P', name: '24 V DC TPR I/P', paraId: '20012000', value: '23.6', unit: 'V', minSafe: '21', minFail: '18'),
          TelemetryParameter(code: 'TPR', name: 'Digital status of TPR', paraId: '20014010', value: 'UP', unit: ''),
          TelemetryParameter(code: 'V TC TFC O/P', name: 'Track feed charger O/P voltage', paraId: '20012021', value: '9.8', unit: 'V'),
          TelemetryParameter(code: 'I TC FEED END', name: 'Track feed current', paraId: '20010125', value: '505', unit: 'mA'),
          TelemetryParameter(code: 'I TC RELAY END', name: 'Track relay end current', paraId: '20010141', value: '188', unit: 'mA', minSafe: '210', minFail: '100', status: AssetStatus.predictive),
          TelemetryParameter(code: 'V TC TR', name: 'Track relay voltage (QTA2)', paraId: '20012042', value: '2.6', unit: 'V', minSafe: '2.1'),
          TelemetryParameter(code: 'I BALST', name: 'Ballast / sleeper current', paraId: '20010160', value: '317', unit: 'mA', status: AssetStatus.predictive),
          TelemetryParameter(code: 'R RAIL', name: 'Rail resistance', paraId: '20018061', value: '0.42', unit: 'Ω'),
        ];
      case 'LED':
        return const [
          TelemetryParameter(code: 'HR', name: 'Digital status of HR', paraId: '10014011', value: 'UP', unit: ''),
          TelemetryParameter(code: 'HECR', name: 'Digital status of HECR', paraId: '10014000', value: 'DN', unit: '', status: AssetStatus.failure),
          TelemetryParameter(code: 'V SIG HPR', name: 'HPR voltage', paraId: '10012021', value: '3.2', unit: 'V', minSafe: '21', minFail: '18', status: AssetStatus.failure),
          TelemetryParameter(code: 'V SIG RG', name: 'Red aspect voltage', paraId: '10013033', value: '109', unit: 'V', minSafe: '90', minFail: '82'),
          TelemetryParameter(code: 'I SIG RG', name: 'Red aspect current', paraId: '10011143', value: '128', unit: 'mA', minSafe: '110', minFail: '90'),
        ];
      case 'IPS':
        return const [
          TelemetryParameter(code: 'V IPS I/P', name: 'IPS input voltage', paraId: '50003079', value: '228', unit: 'V'),
          TelemetryParameter(code: 'V IPS 110 DC', name: 'IPS 110 DC O/P voltage', paraId: '50002000', value: '98.4', unit: 'V', minSafe: '*', minFail: '*', status: AssetStatus.predictive),
          TelemetryParameter(code: 'I IPS BATT CHAR 110 DC', name: 'Battery charging current', paraId: '50000078', value: '-3.2', unit: 'A'),
          TelemetryParameter(code: 'V IPS SIG-1 110 AC', name: 'Signal-1 O/P voltage', paraId: '50003010', value: '110.6', unit: 'V'),
          TelemetryParameter(code: 'V IPS DC R EXT', name: 'DC-DC relay external voltage', paraId: '50002048', value: '24.2', unit: 'V'),
        ];
      default:
        return const [
          TelemetryParameter(code: 'V EQ', name: 'Power supply of equipment', paraId: '--', value: '24.0', unit: 'V'),
          TelemetryParameter(code: 'I EQ', name: 'Current of equipment', paraId: '--', value: '0.8', unit: 'A'),
        ];
    }
  }

  /// Point machine current signature sampled every 20 ms (Annex A §20).
  static List<double> pointCurrentSignature() {
    final out = <double>[];
    for (var i = 0; i < 230; i++) {
      final t = i / 230;
      double v;
      if (t < 0.05) {
        v = 6.5 * (t / 0.05); // inrush
      } else if (t < 0.12) {
        v = 6.5 - (t - 0.05) / 0.07 * 5.0;
      } else if (t < 0.85) {
        v = 1.5 + 0.12 * math.sin(i * 0.35);
      } else if (t < 0.92) {
        v = 2.6; // locking / friction
      } else {
        v = 0.0;
      }
      out.add(double.parse(v.toStringAsFixed(2)));
    }
    return out;
  }

  /// Hourly history series for a parameter.
  static List<double> history(double base, {int points = 48, double spread = 0.04}) {
    final r = math.Random(base.toInt());
    return List.generate(points, (i) {
      final drift = (i / points) * -spread * base;
      return double.parse((base + drift + (r.nextDouble() - 0.5) * spread * base).toStringAsFixed(2));
    });
  }

  // ---------------- RDPMS Health (Annex D §16, Annex E §9) ----------------
  static const totalSensors = 500, faultySensors = 20;
  static const totalIots = 50, faultyIots = 2;
  static const totalNetworks = 50, faultyNetworks = 2;
  static const totalGateways = 2, faultyGateways = 1;

  static const healthFaults = <HealthFault>[
    HealthFault(sc: 'PRYJ', assetTypeCode: 'EOP', assetNumberCode: 'PT-101', faultySensor: 'I PT R (current sensor)'),
    HealthFault(sc: 'PRYJ', assetTypeCode: 'DCT', assetNumberCode: 'TC-12', faultyIot: 'IoT LB-3 (TC-12)'),
    HealthFault(sc: 'MJA', assetTypeCode: 'ELC', assetNumberCode: 'LC-41', faultyNetwork: '4G link LC-41 gate hut'),
    HealthFault(sc: 'MJA', assetTypeCode: '--', assetNumberCode: '--', faultyGateway: 'Station Gateway 01'),
  ];

  static const healthAvailability = <HealthAvailability>[
    HealthAvailability('PRYJ', 'EOP', 24, 98.6, 6, 99.2, 6, 99.8, 1, 100),
    HealthAvailability('PRYJ', 'DCT', 36, 97.4, 8, 96.1, 8, 99.5, 1, 100),
    HealthAvailability('MJA', 'EOP', 16, 99.9, 4, 100, 4, 100, 1, 92.3),
    HealthAvailability('LKO', 'EOP', 40, 99.1, 10, 99.7, 10, 98.9, 1, 100),
  ];

  // ---------------- Equipment room (Annex A §3j, Annex E §10) ----------------
  static const equipmentRooms = <EquipmentRoomReading>[
    EquipmentRoomReading('PRYJ', 'RR', 27.4, 52, false),
    EquipmentRoomReading('PRYJ', 'IPS', 31.2, 48),
    EquipmentRoomReading('PRYJ', 'BATT', 33.8, 61),
    EquipmentRoomReading('PRYJ', 'LOC', 39.5, 44),
    EquipmentRoomReading('PRYJ', 'OUTDOOR', 36.1, 40),
    EquipmentRoomReading('MJA', 'RR', 28.9, 57, true),
    EquipmentRoomReading('MJA', 'IPS', 32.0, 50),
    EquipmentRoomReading('LKO', 'RR', 26.2, 49, false),
  ];

  // ---------------- Performance (§14, Annex D §15) ----------------
  static const performance = <StationPerformance>[
    StationPerformance('NCR', 'PYRJ', 'PRYJ', 75.78, 77.60, 79.60),
    StationPerformance('NCR', 'PYRJ', 'MJA', 68.20, 58.40, 71.00),
    StationPerformance('NR', 'LKO', 'LKO', 82.10, 64.90, 88.30),
    StationPerformance('NR', 'LKO', 'BBK', 55.00, 61.20, 59.80),
  ];
}
