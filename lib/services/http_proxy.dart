import 'package:dio/dio.dart';

// Conditional implementation: no-op on web, IO implementation on mobile/desktop
import 'http_proxy_stub.dart'
    if (dart.library.io) 'http_proxy_io.dart'
    if (dart.library.js) 'http_proxy_web.dart';

/// Configure a proxy for Dio. On web this is a no-op (browser uses system proxy).
/// On IO (Android/iOS/desktop), it sets an HTTP proxy for all requests.
void configureDioProxy(
  Dio dio, {
  String? host,
  int? port,
  bool allowBadCert = false,
}) => configureDioProxyImpl(
      dio,
      host: host,
      port: port,
      allowBadCert: allowBadCert,
    );
