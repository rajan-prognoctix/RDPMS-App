import 'package:equatable/equatable.dart';

/// One value of a configurable parameter. Annex D §17: if the Zonal Railway
/// "does not want to give any duration, it should be possible to configure it
/// as 'No time limit'". A value with neither [amount] nor [noTimeLimit] is
/// "Not set" (the spec leaves it to the Zonal Railway, e.g. "*").
class ConfigValue extends Equatable {
  final double? amount;
  final bool noTimeLimit;

  const ConfigValue(this.amount) : noTimeLimit = false;
  const ConfigValue.noTimeLimit() : amount = null, noTimeLimit = true;
  const ConfigValue.notSet() : amount = null, noTimeLimit = false;

  bool get isSet => amount != null || noTimeLimit;

  /// "2 h", "No time limit", "Not set".
  String display(String unit) {
    if (noTimeLimit) return 'No time limit';
    final a = amount;
    if (a == null) return 'Not set';
    final text = a == a.roundToDouble() ? a.toInt().toString() : a.toString();
    return '$text $unit';
  }

  @override
  List<Object?> get props => [amount, noTimeLimit];
}

/// A configurable parameter of Annex D §17 ("configure them by Admin in user
/// Interface as decided by Zonal Railways").
///
/// [keys] are the columns the value is set for — asset types (e.g. "Point
/// machine", "Signal"), hierarchy levels ("JE/SE", "SSE"…), or a single
/// "Value" for global settings.
class ConfigSetting extends Equatable {
  /// Row number in the §17 table (1–23).
  final int number;
  final String title;

  /// "Asset type wise", "Asset wise" or "All" — as the §17 table states.
  final String scope;
  final String unit;

  /// Clause the default comes from (e.g. "Annex D §13.2").
  final String source;
  final List<String> keys;
  final Map<String, ConfigValue> values;

  const ConfigSetting({
    required this.number,
    required this.title,
    required this.scope,
    required this.unit,
    required this.source,
    required this.keys,
    required this.values,
  });

  ConfigValue valueOf(String key) => values[key] ?? const ConfigValue.notSet();

  /// "PM 2 h · LC 2 h · IPS 1 h …" or just "15 days" for a single value.
  String get summary => keys.length == 1
      ? valueOf(keys.first).display(unit)
      : keys.map((k) => '$k ${valueOf(k).display(unit)}').join(' · ');

  ConfigSetting copyWith({Map<String, ConfigValue>? values}) => ConfigSetting(
    number: number,
    title: title,
    scope: scope,
    unit: unit,
    source: source,
    keys: keys,
    values: values ?? this.values,
  );

  @override
  List<Object?> get props => [number, title, scope, unit, source, keys, values];
}
