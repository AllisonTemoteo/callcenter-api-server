import 'package:server/modules/authentication/models/value_objects/jwt_token.dart';
import 'package:shelf/shelf.dart';

Middleware authenticationJwt() {
  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers['Authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.forbidden('Token não fornecido');
      }

      final token = JwtToken(authHeader.substring(7));

      if (!token.validate()) {
        return Response.forbidden('Token inválido');
      }

      return innerHandler(request);
    };
  };
}
