import 'package:bcrypt/bcrypt.dart';
import 'package:server/modules/authentication/models/user_credentials.dart';

class PasswordHash {
  const PasswordHash(this.value);
  final String value;

  bool verify(Password pass) {
    return BCrypt.checkpw(pass.raw, value);
  }
}
