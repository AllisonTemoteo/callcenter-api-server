import 'package:server/core/error/exceptions.dart';
import 'package:server/core/utils/extensions.dart';
import 'package:server/modules/authentication/models/user.dart';
import 'package:server/modules/authentication/models/user_credentials.dart';
import 'package:server/modules/authentication/repositories/user_repository.dart';

class LoginService {
  const LoginService(IUserRepository users) : _users = users;
  final IUserRepository _users;

  Future<User> call(UserCredentials credentials) async {
    final user = await _users.findByLogin(credentials.login.raw);

    if (!user.password.verify(credentials.password)) {
      throw InvalidCredentialsException(
        'Credenciais de acesso inválidas',
      ).warn();
    }

    return user;
  }
}
