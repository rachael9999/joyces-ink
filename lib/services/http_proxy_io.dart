import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'dart:io';

void configureDioProxyImpl(
  Dio dio, {
  String? host,
  int? port,
  bool allowBadCert = false,
}) {
  if (port == null) return;

  // Default hosts: Android emulator needs 10.0.2.2 to reach host; others can use localhost
  final resolvedHost = host ?? (Platform.isAndroid ? '10.0.2.2' : '127.0.0.1');

  final adapter = dio.httpClientAdapter;
  if (adapter is IOHttpClientAdapter) {
    adapter.createHttpClient = () {
      final client = HttpClient();
      client.findProxy = (uri) => 'PROXY ' + resolvedHost + ':' + port.toString();
      if (allowBadCert) {
        client.badCertificateCallback = (cert, host, port) => true;
      }
      return client;
    };
  }
}
