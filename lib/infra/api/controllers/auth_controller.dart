import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:server/core/error/exceptions.dart';
import 'package:server/core/utils/typedefs.dart';
import 'package:server/infra/api/value_objects/response_body.dart';
import 'package:server/modules/authentication/models/user_credentials.dart';
import 'package:server/modules/authentication/models/value_objects/jwt_token.dart';
import 'package:server/modules/authentication/services/login_service.dart';
import 'package:server/modules/authentication/services/sign_in_service.dart';
import 'package:shelf/shelf.dart';

class AuthController {
  const AuthController(LoginService login, SignInService signIn)
    : _login = login,
      _signIn = signIn;

  final LoginService _login;
  final SignInService _signIn;

  Future<Response> signUp(Request req) async {
    final body = Json.from(jsonDecode(await req.readAsString()));

    if (!body.containsKey('login') || !body.containsKey('password')) {
      return Response.badRequest(
        body: ResponseBody.error(
          message: 'Login ou senha não foram fornecidos',
          errors: {
            'missing':
                '${body['login'] == null ? 'login' : ''};'
                '${body['password'] == null ? 'password' : ''};',
          },
        ).toJson(),
      );
    }

    final credentials = UserCredentials(
      login: Login(body['login']),
      password: Password(body['password']),
    );

    if (!credentials.isValid) {
      final errors = credentials.errors;
      return Response.badRequest(
        body: ResponseBody.error(
          message: 'Credenciais inválidas',
          errors: errors,
        ).toJson(),
      );
    }

    await _signIn(credentials);

    return Response(
      201,
      body: ResponseBody.ok(message: 'Usuário cadastrado com sucesso').toJson(),
    );
  }

  Future<Response> login(Request req) async {
    // TODO:
    try {
      final body = Json.from(jsonDecode(await req.readAsString()));

      if (!body.containsKey('login') || !body.containsKey('password')) {
        return Response.badRequest(
          body: ResponseBody.error(
            message: 'Login ou senha não foram fornecidos',
            errors: {
              'missing':
                  '${body['login'] == null ? 'login;' : ''}'
                  '${body['password'] == null ? 'password;' : ''}',
            },
          ).toJson(),
        );
      }

      final UserCredentials credentials = UserCredentials(
        login: Login(body['login']),
        password: Password(body['password']),
      );

      final user = await _login(credentials);

      return Response.ok(
        ResponseBody.ok(
          message: 'Login efetuado com sucesso',
          content: {'access': JwtToken.generate(user.id)},
        ).toJson(),
      );
    } on InvalidCredentialsException catch (e) {
      return Response.unauthorized(
        ResponseBody.error(
          message: 'Falha no login',
          errors: {'message': e.message},
        ).toJson(),
      );
    }
  }

  Future<Response> validate(Request req) async {
    final headers = req.headers;
    final jwt = JWT.decode(headers['Authorization']!.split(' ')[1]);
    final decoded = {
      'header': jwt.header,
      'issuer': jwt.issuer,
      'subject': jwt.subject,
      'payload': jwt.payload,
    };

    return Response.ok(
      ResponseBody.ok(message: 'Token validado', content: decoded).toJson(),
    );
  }
}
