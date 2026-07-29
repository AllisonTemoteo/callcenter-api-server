import 'package:server/modules/authentication/models/user.dart';
import 'package:server/modules/authentication/models/user_credentials.dart';
import 'package:server/modules/authentication/repositories/user_repository.dart';

class SignInService {
  const SignInService(IUserRepository users) : _users = users;
  final IUserRepository _users;

  Future<User> call(UserCredentials credentials) async {
    return await _users.createUser(
      credentials.login.raw,
      credentials.password.hash.value,
    );
  }
}
