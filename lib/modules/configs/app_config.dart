import 'package:server/core/error/exceptions.dart';
import 'package:server/core/external/database/app_database.dart';
import 'package:server/core/utils/extensions.dart';
import 'package:server/modules/configs/app_config_cache.dart';
import 'package:server/modules/configs/app_config_keys.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

export './app_config_keys.dart';

class AppConfig {
  AppConfig(AppDatabase db) : _helper = _AppConfigHelper(db);
  final _AppConfigHelper _helper;

  Future<T?> get<T>(ConfigKeys key, {T? fallback}) async {
    return await _helper.get<T>(key.str, fallBack: fallback);
  }

  Future<void> set(ConfigKeys key, dynamic value) async {
    await _helper.set(key.str, value);
  }
}

class _AppConfigHelper {
  _AppConfigHelper(this._storage);
  final AppDatabase _storage;
  final AppConfigCache _cache = AppConfigCache();

  Future<T?> get<T>(String key, {T? fallBack}) async {
    try {
      final cached = _cache.get<T>(key);
      if (cached != null) {
        return cached;
      }

      final db = await _storage.connection;
      final map = await db.query('config', where: 'key = ?', whereArgs: [key]);

      if (map.isNotEmpty) {
        final value = _parseValue<T>(map.first['value']);
        _cache.set(key, value);
        return value;
      }

      await db.insert('config', {
        'key': key,
        'value': _serializeValue(fallBack),
      });

      _cache.set(key, fallBack);
      return fallBack;
    } on DataParsingException {
      return fallBack;
    }
  }

  Future<void> set(String key, Object value) async {
    final db = await _storage.connection;
    await db.insert('config', {
      'key': key,
      'value': _stringfy(value),
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    _cache.set(key, value);
  }

  T? _stringfy<T>(Object? value) {
    if (value is int) return value as T;
    if (value is bool) return (value ? '1' : '0') as T;
    if (value is DateTime) return value.iso as T;

    return value as T?;
  }

  T? _parseValue<T>(Object? value) {
    try {
      if (value == null) return null;
      if (T == int) return int.parse(value.toString()) as T;
      if (T == bool) return _parseBool(value.toString()) as T;
      if (T == DateTime) return value.toString().toLocalDateTime as T;

      return value.toString() as T;
    } catch (e, s) {
      // final trace = Trace.from(s).terse;
      throw DataParsingException(
        'Error parsing $value to $T',
        exception: e,
        stackTrace: s,
      ).error();
    }
  }

  bool _parseBool(String value) {
    final truly = ['t', 'true', '1'];
    return truly.contains(value.toLowerCase());
  }

  Object? _serializeValue(Object? value) {
    if (value is bool) {
      return value ? '1' : '0';
    }

    return value?.toString();
  }
}
