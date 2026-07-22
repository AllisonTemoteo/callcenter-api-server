import 'package:server/core/utils/typedefs.dart';
import 'package:server/modules/authentication/models/password_hash.dart';
import 'package:server/modules/authentication/models/user.dart';

abstract class UserMapper {
  static const String kId = 'id';
  static const String kLogin = 'login';
  static const String kPassword = 'password';

  static User fromMap(Json map) {
    return User(
      id: map[kId],
      login: map[kLogin],
      password: PasswordHash(map[kPassword]),
    );
  }

  static Json toMap(User user) {
    return {kId: user.id, kLogin: user.login, kPassword: user.password.value};
  }
}
