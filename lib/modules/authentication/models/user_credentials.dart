import 'package:bcrypt/bcrypt.dart';
import 'package:server/core/utils/typedefs.dart';
import 'package:server/core/utils/validable_object.dart';
import 'package:server/modules/authentication/models/password_hash.dart';

class UserCredentials {
  UserCredentials({required this.login, required this.password});
  final Login login;
  final Password password;

  bool get isValid => (login.validate() ?? password.validate()) == null;
  Json get errors => {
    'login': login.validate(),
    'password': password.validate(),
  };
}

class Login extends ValidableObject<String> {
  Login(super.value);

  @override
  List<String>? validate() {
    final errors = [];
    if (raw.length < 4) {
      errors.add('Login deve ter pelo menos 4 caracteres');
    }

    return null;
  }
}

class Password extends ValidableObject<String> {
  Password(super.value);

  PasswordHash get hash => PasswordHash(BCrypt.hashpw(raw, BCrypt.gensalt()));

  @override
  List<String>? validate() {
    final errors = [];

    final hasMinLength = raw.length >= 8;
    final hasUpperCase = RegExp(r'[A-Z]').hasMatch(raw);
    final hasLowerCase = RegExp(r'[a-z]').hasMatch(raw);
    final hasNumber = RegExp(r'\d').hasMatch(raw);
    final hasSpecialChar = RegExp(r'[^\w\s]').hasMatch(raw);

    if (!hasMinLength) {
      errors.add('A senha deve ter pelo menos 8 caracteres.');
    }

    if (!hasUpperCase) {
      errors.add('A senha deve conter uma letra maiúscula.');
    }

    if (!hasLowerCase) {
      errors.add('A senha deve conter uma letra minúscula.');
    }

    if (!hasNumber) {
      errors.add('A senha deve conter um número.');
    }

    if (!hasSpecialChar) {
      errors.add('A senha deve conter um caractere especial.');
    }

    return null;
  }
}
