import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:server/core/utils/env.dart';
import 'package:server/modules/authentication/models/user_credentials.dart';
import 'package:server/modules/authentication/services/login_service.dart';
import 'package:server/modules/authentication/services/sign_in_service.dart';
import 'package:shelf/shelf.dart';

class AuthController {
  const AuthController(LoginService login, SignInService signIn)
    : _login = login,
      _signIn = signIn;

  final LoginService _login;
  final SignInService _signIn;

  Future<Response> signIn(Request req) async {
    final body = jsonDecode(await req.readAsString());

    final credentials = UserCredentials(
      login: Login(body['login']),
      password: Password(body['password']),
    );

    if (!credentials.isValid) {
      final errors = credentials.errors;
      final payload = jsonEncode({
        'ok': false,
        'message': 'Credenciais inválidas',
        'errors': errors,
      });

      return Response.badRequest(
        body: payload,
        headers: {'content-type': 'application/json'},
      );
    }

    await _signIn(credentials);

    return Response.ok('Usuário cadastrado com sucesso');
  }

  Future<Response> login(Request req) async {
    // TODO:
    try {
      final body = jsonDecode(await req.readAsString());

      final UserCredentials credentials = UserCredentials(
        login: Login(body['login']),
        password: Password(body['password']),
      );

      final user = await _login(credentials);

      String payload = jsonEncode({'access': _generateJwtToken(user.id)});

      return Response.ok(
        payload,
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError();
    }
  }

  String _generateJwtToken(int userId) {
    final jwt = JWT({
      'id': userId,
      'role': 'Admin',
    }, issuer: 'easy_callcenter_api');

    return jwt.sign(SecretKey(Env.get('API_SECRET')));
  }
}
