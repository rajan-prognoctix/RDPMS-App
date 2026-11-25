// Lightweight view models for the UI-only phase.
// These will be replaced by domain entities + repositories when the backend APIs are wired.

// User roles (§11.6) live in core/auth so the app can check permissions.
export '../auth/user_role.dart';

enum AssetStatus { healthy, predictive, failure }

/// alert_type_code (Annex D §1.1)
enum AlertType {
  failure('Failure'),
  predictive('Predictive');

  const AlertType(this.code);
  final String code;
}

/// alert_status_code (Annex D §8)
enum AlertStatus {
  pending('pending'),
  cleared('cleared');

  const AlertStatus(this.code);
  final String code;
}

/// alert_feedback_code (Annex D §6)
enum AlertFeedback {
  t('T', 'True'),
  pt('PT', 'Partially True'),
  f('F', 'False'),
  m('M', 'Maintenance');

  const AlertFeedback(this.code, this.label);
  final String code;
  final String label;
}


class Zone {
  final String zc;
  final String name;
  final List<Division> divisions;
  const Zone(this.zc, this.name, this.divisions);
}

class Division {
  final String dc;
  final String name;
  final List<Station> stations;
  const Division(this.dc, this.name, this.stations);
}

class Station {
  final String sc;
  final String name;
  const Station(this.sc, this.name);
}

class Asset {
  final String zc;
  final String dc;
  final String sc;
  final String assetTypeCode; // Annex A, e.g. EOP, DCT, LED
  final String assetNumberCode; // e.g. PT-101
  final String smmsAssetCode;
  final String make;
  final AssetStatus status;
  final int operations; // for Asset Utilization

  const Asset({
    required this.zc,
    required this.dc,
    required this.sc,
    required this.assetTypeCode,
    required this.assetNumberCode,
    required this.smmsAssetCode,
    required this.make,
    required this.status,
    this.operations = 0,
  });
}

class RdpmsAlert {
  final String id;
  final String zc;
  final String dc;
  final String sc;
  final AlertType type;
  final String assetTypeCode;
  final String assetNumberCode;
  final String causeCode; // Annex C
  final String causeDetail;
  final DateTime incidence;

  // Mutable for the UI-only phase (feedback is captured locally).
  DateTime? rectification;
  AlertStatus status;
  AlertFeedback? feedback;
  DateTime? feedbackTime;
  String? remarks;
  String? maintainerName;
  String? maintainerDesignation;
  String? maintainerMobile;
  bool acknowledged;

  RdpmsAlert({
    required this.id,
    required this.zc,
    required this.dc,
    required this.sc,
    required this.type,
    required this.assetTypeCode,
    required this.assetNumberCode,
    required this.causeCode,
    required this.causeDetail,
    required this.incidence,
    this.rectification,
    this.status = AlertStatus.pending,
    this.feedback,
    this.feedbackTime,
    this.remarks,
    this.maintainerName,
    this.maintainerDesignation,
    this.maintainerMobile,
    this.acknowledged = false,
  });

  Duration get duration => (rectification ?? DateTime.now()).difference(incidence);
}

class TelemetryParameter {
  final String code; // parameter_representation_code
  final String name;
  final String paraId;
  final String value;
  final String unit;
  final String? minSafe;
  final String? minFail;
  final AssetStatus status;

  const TelemetryParameter({
    required this.code,
    required this.name,
    required this.paraId,
    required this.value,
    required this.unit,
    this.minSafe,
    this.minFail,
    this.status = AssetStatus.healthy,
  });
}

class MaintenanceMode {
  final String id;
  final String sc;
  final String assetTypeCode;
  final String assetNumberCode;
  final DateTime from;
  final DateTime to;

  const MaintenanceMode({
    required this.id,
    required this.sc,
    required this.assetTypeCode,
    required this.assetNumberCode,
    required this.from,
    required this.to,
  });
}

class HealthFault {
  final String sc;
  final String assetTypeCode;
  final String assetNumberCode;
  final String? faultySensor;
  final String? faultyIot;
  final String? faultyNetwork;
  final String? faultyGateway;

  const HealthFault({
    required this.sc,
    required this.assetTypeCode,
    required this.assetNumberCode,
    this.faultySensor,
    this.faultyIot,
    this.faultyNetwork,
    this.faultyGateway,
  });
}

class HealthAvailability {
  final String sc;
  final String assetTypeCode;
  final int sensors;
  final double sensorAvail;
  final int iots;
  final double iotAvail;
  final int networks;
  final double networkAvail;
  final int gateways;
  final double gatewayAvail;

  const HealthAvailability(
    this.sc,
    this.assetTypeCode,
    this.sensors,
    this.sensorAvail,
    this.iots,
    this.iotAvail,
    this.networks,
    this.networkAvail,
    this.gateways,
    this.gatewayAvail,
  );
}

class EquipmentRoomReading {
  final String sc;
  final String roomTypeCode; // RR, IPS, BATT, MAIN, GEN, OUTDOOR, LOC
  final double temperature;
  final double humidity;
  final bool? doorOpen; // Relay room only

  const EquipmentRoomReading(
    this.sc,
    this.roomTypeCode,
    this.temperature,
    this.humidity, [
    this.doorOpen,
  ]);
}

class StationPerformance {
  final String zc;
  final String dc;
  final String sc;
  final double failAlertPer;
  final double predAlertPer;
  final double actualFailAlertPer;

  const StationPerformance(
    this.zc,
    this.dc,
    this.sc,
    this.failAlertPer,
    this.predAlertPer,
    this.actualFailAlertPer,
  );
}

class DashboardGroup {
  final String title;
  final int healthy;
  final int predictive;
  final int failure;
  const DashboardGroup(this.title, this.healthy, this.predictive, this.failure);
  int get total => healthy + predictive + failure;
}
