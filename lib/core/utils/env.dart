import 'package:dotenv/dotenv.dart';

class Env {
  Env._();

  static final DotEnv _env = DotEnv(includePlatformEnvironment: true);
  static bool _loaded = false;

  static void load() {
    if (_loaded) {
      return;
    }

    _env.load();
    _loaded = true;
  }

  static String get(String key, {String? defaultValue}) {
    if (!_loaded) {
      load();
    }

    final value = _env[key.trim()];

    if (value != null) {
      return value;
    }

    if (defaultValue != null) {
      return defaultValue;
    }

    throw StateError(
      'Environment variable '
      '"$key" not found.',
    );
  }
}
