import 'package:equatable/equatable.dart';

/// Outcome of an audited event (design W22).
enum AuditResult {
  blocked('Blocked'),
  warned('Warned'),
  logged('Logged');

  const AuditResult(this.label);
  final String label;
}

/// One audit log row (Annex D §19): unauthorised access to IoT, Station Gateway
/// and the RDPMS application, plus admin changes. "The audit report can be
/// accessed by admin or as desired by Railway authority in RDPMS application."
class AuditEvent extends Equatable {
  final DateTime time;

  /// User ID involved, or "unknown".
  final String userId;
  final String event;

  /// "RDPMS App", "Station Gateway PRYJ-01", "IoT LB-3"…
  final String source;

  /// Device or IP, e.g. "Android · new device", "10.12.4.88".
  final String device;
  final AuditResult result;

  const AuditEvent({
    required this.time,
    required this.userId,
    required this.event,
    required this.source,
    required this.device,
    required this.result,
  });

  @override
  List<Object?> get props => [time, userId, event, source, device, result];
}
