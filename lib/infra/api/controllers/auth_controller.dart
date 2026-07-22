import 'dart:convert';

import 'package:server/modules/authentication/models/user_credentials.dart';
import 'package:server/modules/authentication/services/login_service.dart';
import 'package:shelf/shelf.dart';

class AuthController {
  const AuthController(LoginService login) : _login = login;
  final LoginService _login;

  Future<Response> login(Request req) async {
    // TODO:
    try {
      final body = jsonDecode(await req.readAsString());

      final UserCredentials credentials = UserCredentials(
        login: body['login'],
        password: Password(body['password']),
      );

      await _login(credentials);

      return Response(200);
    } catch (e) {
      return Response.internalServerError();
    }
  }
}
