import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../error/error_messages.dart';
import '../error/exceptions.dart';
import 'api_endpoints.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(SharedPreferences prefs)
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: AppConstants.connectTimeout,
            receiveTimeout: AppConstants.receiveTimeout,
            headers: {'Content-Type': 'application/json'},
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = prefs.getString(AppConstants.tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
    if (kDebugMode) {
      _dio.interceptors.add(_ApiLogInterceptor());
    }
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _request(() => _dio.get(path, queryParameters: query));

  Future<dynamic> post(String path, {Object? data}) =>
      _request(() => _dio.post(path, data: data));

  Future<dynamic> put(String path, {Object? data}) =>
      _request(() => _dio.put(path, data: data));

  Future<dynamic> delete(String path, {Object? data}) =>
      _request(() => _dio.delete(path, data: data));

  Future<dynamic> _request(Future<Response> Function() call) async {
    try {
      final response = await call();
      return response.data;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Turns a [DioException] into a [NetworkException] / [ServerException].
  /// Debug builds get the actual cause (wrong URL, refused, timeout, 4xx/5xx…);
  /// release builds get a generic message (see [ErrorMessages]).
  Exception _mapError(DioException e) {
    final uri = e.requestOptions.uri;
    final server = uri.hasPort ? '${uri.host}:${uri.port}' : uri.host;

    NetworkException network(String detail) =>
        NetworkException(ErrorMessages.pick(detail, ErrorMessages.network));
    ServerException serverError(String detail, {int? statusCode}) => ServerException(
          ErrorMessages.pick(detail, ErrorMessages.server),
          statusCode: statusCode,
        );

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return network('Connection timed out. Server $server did not respond.');
      case DioExceptionType.sendTimeout:
        return network('Timed out while sending the request to $server.');
      case DioExceptionType.receiveTimeout:
        return network('Server $server took too long to respond.');
      case DioExceptionType.transformTimeout:
        return serverError('Timed out while reading the response from $server.');
      case DioExceptionType.badCertificate:
        return serverError('The SSL certificate of $server is not trusted.');
      case DioExceptionType.cancel:
        return const ServerException('The request was cancelled.');
      case DioExceptionType.connectionError:
        return network(_connectionErrorMessage(e.error, server));
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        // A message the server sends on purpose (e.g. "Invalid password") is
        // meant for the user, so it is shown in every build.
        final serverText = _serverMessage(e.response?.data);
        if (serverText != null) return ServerException(serverText, statusCode: status);
        return serverError(
          'Server error ${status ?? ''} ${e.response?.statusMessage ?? ''} '
                  '(${e.requestOptions.method} ${uri.path})'
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim(),
          statusCode: status,
        );
      case DioExceptionType.unknown:
        final cause = e.error;
        if (cause is SocketException) {
          return network(_connectionErrorMessage(cause, server));
        }
        return serverError(
          cause?.toString() ?? e.message ?? 'Unexpected error while calling $server.',
        );
    }
  }

  String _connectionErrorMessage(Object? cause, String server) {
    if (cause is SocketException) {
      final reason = cause.osError?.message ?? cause.message;
      if (cause.message.contains('Failed host lookup')) {
        return 'Cannot find server $server. Check the API URL or your internet connection.';
      }
      if (reason.toLowerCase().contains('refused')) {
        return 'Server $server refused the connection. Check the API URL and port.';
      }
      if (reason.toLowerCase().contains('unreachable')) {
        return 'Network is unreachable. Check your internet connection.';
      }
      return 'Cannot connect to $server: $reason';
    }
    if (cause is HandshakeException) {
      return 'Secure connection (SSL) to $server failed.';
    }
    return 'Cannot connect to $server${cause != null ? ': $cause' : '.'}';
  }

  /// Reads the error text from a JSON error body (`message`, `error`, `detail`).
  String? _serverMessage(Object? data) {
    if (data is Map) {
      for (final key in const ['message', 'error', 'detail', 'msg']) {
        final value = data[key];
        if (value is String && value.trim().isNotEmpty) return value;
      }
    }
    return null;
  }
}

/// Debug-only logger: prints the method type, URL, request and response
class _ApiLogInterceptor extends Interceptor {
  static const _encoder = JsonEncoder.withIndent('  ');

  String _format(Object? body) {
    if (body == null) return '-';
    try {
      return _encoder.convert(body);
    } catch (_) {
      return body.toString();
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('┌── API REQUEST ─────────────────────────');
    debugPrint('│ Type    : ${options.method}');
    debugPrint('│ URL     : ${options.uri}');
    debugPrint('│ Request : ${_format(options.data)}');
    debugPrint('└────────────────────────────────────────');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final req = response.requestOptions;
    debugPrint('┌── API RESPONSE ────────────────────────');
    debugPrint('│ Type     : ${req.method}');
    debugPrint('│ URL      : ${req.uri}');
    debugPrint('│ Status   : ${response.statusCode}');
    debugPrint('│ Response : ${_format(response.data)}');
    debugPrint('└────────────────────────────────────────');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final req = err.requestOptions;
    debugPrint('┌── API ERROR ───────────────────────────');
    debugPrint('│ Type     : ${req.method}');
    debugPrint('│ URL      : ${req.uri}');
    debugPrint('│ Status   : ${err.response?.statusCode ?? '-'}');
    debugPrint('│ Error    : ${err.type.name} ${err.message ?? ''}');
    debugPrint('│ Response : ${_format(err.response?.data)}');
    debugPrint('└────────────────────────────────────────');
    handler.next(err);
  }
}
