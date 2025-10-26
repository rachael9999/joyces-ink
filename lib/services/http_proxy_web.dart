import 'package:dio/dio.dart';

// Browser uses system proxy settings; programmatic proxy is not supported here.
void configureDioProxyImpl(
  Dio dio, {
  String? host,
  int? port,
  bool allowBadCert = false,
}) {}
