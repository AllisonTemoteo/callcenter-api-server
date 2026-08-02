import 'package:server/modules/authentication/models/password_hash.dart';

class User {
  User({
    required this.id,
    required this.login,
    required this.password,
    required this.isActive,
  });

  final int id;
  final String login;
  final PasswordHash password;
  final bool isActive;
}
