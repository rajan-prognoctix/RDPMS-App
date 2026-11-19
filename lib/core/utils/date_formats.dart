/// Date formats used by the spec:
/// - UI / APIs (Annex D/F): DD/MM/YYYY HH:mm:ss
/// - Alert message (Annex D §3): HH:mm/DD.MM.YY
class DateFormats {
  DateFormats._();

  static String _pad(int n) => n.toString().padLeft(2, '0');

  static String date(DateTime d) => '${_pad(d.day)}/${_pad(d.month)}/${d.year}';

  static String time(DateTime d) => '${_pad(d.hour)}:${_pad(d.minute)}';

  static String dateTime(DateTime d) =>
      '${date(d)} ${_pad(d.hour)}:${_pad(d.minute)}:${_pad(d.second)}';

  /// DD/MM/YYYY hh:mm AM/PM (12-hour clock).
  static String dateTime12h(DateTime d) {
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final period = d.hour < 12 ? 'AM' : 'PM';
    return '${date(d)} ${_pad(hour)}:${_pad(d.minute)} $period';
  }

  static String alertMessage(DateTime d) =>
      '${_pad(d.hour)}:${_pad(d.minute)}/${_pad(d.day)}.${_pad(d.month)}.${_pad(d.year % 100)}';

  static String duration(Duration d) =>
      '${_pad(d.inHours)}:${_pad(d.inMinutes % 60)}:${_pad(d.inSeconds % 60)}';
}
