import 'package:server/core/error/exceptions.dart';
import 'package:server/core/external/database/app_database.dart';
import 'package:server/core/utils/extensions.dart';
import 'package:server/modules/authentication/models/password_hash.dart';
import 'package:server/modules/authentication/models/user.dart';
import 'package:server/modules/authentication/models/user_mapper.dart';

abstract class IUserRepository {
  Future<User> findByLogin(String login);
  Future<User> createUser(String login, String hash);
}

class UserRepository implements IUserRepository {
  const UserRepository(AppDatabase storage) : _storage = storage;
  final AppDatabase _storage;

  @override
  Future<User> findByLogin(String login) async {
    final conn = await _storage.connection;
    final query = await conn.query(
      'user',
      where: 'login = ? and is_active = 1',
      whereArgs: [login],
    );

    if (query.isEmpty) {
      throw InvalidCredentialsException(
        'Credenciais de acesso inválidas',
      ).warn();
    }

    return UserMapper.fromMap(query.first);
  }

  @override
  Future<User> createUser(String login, String hash) async {
    final conn = await _storage.connection;
    final userId = await conn.insert('user', {
      'login': login,
      'password': hash,
    });

    return User(
      id: userId,
      login: login,
      password: PasswordHash(hash),
      isActive: false,
    );
  }
}
