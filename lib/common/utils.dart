import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/io_client.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

Future<IOClient> get ioClient async {
  final sslCert = await rootBundle.load('certificates/certificates.pem');
  final securityContext = SecurityContext(withTrustedRoots: false);
  securityContext.setTrustedCertificatesBytes(sslCert.buffer.asInt8List());
  final httpClient = HttpClient(context: securityContext);
  httpClient.badCertificateCallback = (_, __, ___) => false;

  return IOClient(httpClient);
}
