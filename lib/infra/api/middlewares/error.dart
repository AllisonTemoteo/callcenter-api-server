import 'package:server/infra/api/value_objects/response_body.dart';
import 'package:shelf/shelf.dart';

Middleware errorMiddleware() {
  return (Handler innerHandler) {
    return (Request req) async {
      try {
        return await innerHandler(req);
      } on FormatException catch (e) {
        return Response.badRequest(
          body: ResponseBody.error(
            message: 'Requisição mal formatada',
            errors: {'message': e.toString()},
          ).toJson(),
        );
      } catch (e) {
        print(e.toString());
        return Response.internalServerError();
      }
    };
  };
}
