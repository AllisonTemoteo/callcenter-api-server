import 'dart:io';

import 'package:server/infra/api/middlewares/authentication.dart';
import 'package:server/infra/api/middlewares/error.dart';
import 'package:server/infra/api/middlewares/response_headers.dart';
import 'package:server/infra/api/routes/api_routes.dart';
import 'package:server/infra/api/routes/auth_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

class ApiServer {
  final Router _router = Router();
  late final HttpServer _server;

  Future<void> start() async {
    _router.mount('/api/auth/', authRoutes().call);
    _router.mount(
      '/api/',
      Pipeline()
          .addMiddleware(authenticationJwt())
          .addHandler(apiRoutes().call),
    );

    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(responseHeaders())
        .addMiddleware(errorMiddleware())
        .addHandler(_router.call);

    _server = await serve(handler, InternetAddress.anyIPv4, 8080);
    print('Server running in: http://${_server.address.host}:${_server.port}');
  }

  Future<void> stop() async {
    await _server.close();
  }
}
