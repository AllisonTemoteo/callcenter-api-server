import 'dart:io';

import 'package:server/infra/api/routes/api_routes.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

class ApiServer {
  final Router _app = Router();
  late final HttpServer _server;

  Future<void> call() async {
    _app.mount('/api/', apiRoutes().call);

    final handler = Pipeline()
        .addMiddleware(errorMiddleware())
        .addMiddleware(logRequests())
        .addHandler(_app.call);

    _server = await serve(handler, InternetAddress.anyIPv4, 8080);
    print('Server running in: http://${_server.address.host}:${_server.port}');
  }

  Middleware errorMiddleware() {
    return (Handler innerHandler) {
      return (Request req) async {
        try {
          return await innerHandler(req);
        } catch (e) {
          return Response.internalServerError(
            body: {'ok': false, 'message': e.toString()},
          );
        }
      };
    };
  }
}
