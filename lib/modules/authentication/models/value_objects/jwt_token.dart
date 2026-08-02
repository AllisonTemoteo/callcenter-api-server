import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:server/core/utils/env.dart';

class JwtToken {
  const JwtToken(this.token);
  final String token;

  static String generate(int id) {
    final jwt = JWT({'id': id, 'role': 'admin'}, issuer: 'client');

    return jwt.sign(SecretKey(Env.get('API_SECRET')));
  }

  bool validate() {
    try {
      JWT.verify(token, SecretKey(Env.get('API_SECRET')));
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
}
