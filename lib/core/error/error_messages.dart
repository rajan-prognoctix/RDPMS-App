import 'package:flutter/foundation.dart';

/// Error text shown to the user.
///
/// Debug builds show the technical detail (server address, OS error, status
/// code…) to help with API integration. Release and profile builds show a
/// generic message so internal details aren't exposed (OWASP / STQC, §2.5).
/// Messages the server sends on purpose (e.g. "Invalid password") are always
/// shown; they don't go through [pick].
class ErrorMessages {
  ErrorMessages._();

  /// `true` only in debug builds.
  static const bool showDetails = kDebugMode;

  static const network =
      'Unable to connect to the server. Please check your internet connection and try again.';
  static const server = 'Something went wrong. Please try again later.';
  static const unexpectedResponse =
      'Received an unexpected response from the server. Please try again later.';

  /// Returns [detail] in debug builds and [generic] otherwise.
  static String pick(String detail, String generic) => showDetails ? detail : generic;
}
