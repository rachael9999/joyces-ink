import 'package:dio/dio.dart';

void configureDioProxyImpl(
  Dio dio, {
  String? host,
  int? port,
  bool allowBadCert = false,
}) {
  // No-op default. Implemented per-platform.
}
