import 'package:shelf/shelf.dart';

Middleware responseHeaders() {
  return (Handler innerHandler) {
    return (Request req) async {
      final response = await innerHandler(req);
      return response.change(
        headers: {...response.headers, 'content-type': 'application/json'},
      );
    };
  };
}
