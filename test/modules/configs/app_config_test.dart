import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart';
import 'package:server/core/external/database/app_database.dart';
import 'package:server/modules/configs/app_config.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

class MockSqliteDatabase extends Mock implements AppDatabase {}

void main() {
  late MockSqliteDatabase storage;
  late AppConfig config;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    storage = MockSqliteDatabase();
    config = AppConfig(storage);

    final migrate = join(Directory.current.path, 'data', 'migrate.sql');
    final dbInstance = await databaseFactory.openDatabase(inMemoryDatabasePath);

    await dbInstance.execute(File(migrate).readAsStringSync());
    await dbInstance.insert('config', {
      'key': 'api/npx/lastSyncDateTime',
      'value': '2026-01-01',
    });

    when(() => storage.connection).thenAnswer((_) async => dbInstance);
  });

  group('AppConfig.get', () {
    group('database', () {
      test('deve recuperar o valor da chave no banco', () async {
        final value = await config.get<DateTime>(ConfigKeys.npxLastSyncAt);
        expect(value, DateTime(2026, 01, 01));
      });

      test(
        'deve retornar null se a chave ou valor nao exista no banco',
        () async {
          final value = await config.get(ConfigKeys.npxMonitoredQueues);
          expect(value, isNull);
        },
      );

      test('deve retornar null quando chave existe mas valor é null', () async {
        final db = await storage.connection;
        await db.insert('config', {
          'key': 'api/npx/monitoredQueues',
          'value': null,
        });

        final value = await config.get<String>(ConfigKeys.npxMonitoredQueues);
        expect(value, isNull);
      });
    });

    group('fallback', () {
      test('deve usar o fallBack se cache e banco forem null', () async {
        final value = await config.get(
          ConfigKeys.npxMonitoredQueues,
          fallback: 'FallBack',
        );

        expect(value, 'FallBack');
      });

      test('fallback deve ser salvo no banco caso seja usado', () async {
        await config.get(ConfigKeys.npxMonitoredQueues, fallback: 'FallBack');

        final db = await storage.connection;
        final query = await db.query(
          'config',
          where: 'key = ?',
          whereArgs: ['api/npx/monitoredQueues'],
        );

        expect(query.first['value'], 'FallBack');
      });

      test('deve retornar fallback quando parsing falhar', () async {
        final db = await storage.connection;

        await db.update('config', {
          'key': 'api/npx/lastSyncDateTime',
          'value': 'abc',
        });

        final value = await config.get<int>(
          ConfigKeys.npxLastSyncAt,
          fallback: 99,
        );

        expect(value, 99);
      });
    });

    group('cache', () {
      test('deve retornar o valor do cache quando existir', () async {
        await config.get(ConfigKeys.npxLastSyncAt, fallback: DateTime(2026));

        final db = await storage.connection;
        await db.update('config', {
          'key': 'api/npx/lastSyncDateTime',
          'value': '2027-01-01',
        });

        clearInteractions(storage);

        await config.get<DateTime>(ConfigKeys.npxLastSyncAt);
        verifyNever(() => storage.connection);
      });
    });

    group('parsing', () {
      test('deve parsear o valor para DateTime', () async {
        final value = await config.get<DateTime>(ConfigKeys.npxLastSyncAt);
        expect(value, isA<DateTime>());
      });

      test('deve parsear o valor para String', () async {
        final value = await config.get<String>(ConfigKeys.npxLastSyncAt);
        expect(value, isA<String>());
      });

      test('deve parsear o valor para Int', () async {
        final db = await storage.connection;
        await db.update('config', {
          'key': 'api/npx/lastSyncDateTime',
          'value': '1',
        });

        final value = await config.get<int>(ConfigKeys.npxLastSyncAt);
        expect(value, isA<int>());
      });

      test('deve parsear o valor para bool', () async {
        final db = await storage.connection;
        await db.update('config', {
          'key': 'api/npx/lastSyncDateTime',
          'value': '1',
        });

        final value = await config.get<bool>(ConfigKeys.npxLastSyncAt);
        expect(value, isA<bool>());
        expect(value, isTrue);
      });
    });
  });

  group('AppConfig.set', () {
    group('database', () {
      test('deve salvar o valor no banco', () async {
        await config.set(ConfigKeys.npxMonitoredQueues, 'Set');

        final db = await storage.connection;
        final query = await db.query(
          'config',
          where: 'key = ?',
          whereArgs: ['api/npx/monitoredQueues'],
        );

        expect(query.first['value'], 'Set');
      });

      test('deve substituir valor existente', () async {
        await config.set(ConfigKeys.npxLastSyncAt, 'NovoValor');

        final db = await storage.connection;

        final query = await db.query(
          'config',
          where: 'key = ?',
          whereArgs: ['api/npx/lastSyncDateTime'],
        );

        expect(query.length, 1);
        expect(query.first['value'], 'NovoValor');
      });
    });

    group('cache', () {
      test('deve salvar o valor no cache', () async {
        await config.set(ConfigKeys.npxMonitoredQueues, 'Cache');

        final db = await storage.connection;
        await db.insert('config', {
          'key': 'api/npx/monitoredQueues',
          'value': 'Database',
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        final cached = await config.get(ConfigKeys.npxMonitoredQueues);
        expect(cached, 'Cache');
      });

      test('deve salvar true como 1 no banco', () async {
        await config.set(ConfigKeys.npxMonitoredQueues, true);

        final db = await storage.connection;
        final query = await db.query(
          'config',
          where: 'key = ?',
          whereArgs: ['api/npx/monitoredQueues'],
        );

        expect(query.first['value'], '1');
      });

      test('deve manter valor do cache parseado', () async {
        await config.set(ConfigKeys.npxMonitoredQueues, 'Cache');
        dynamic value = await config.get(ConfigKeys.npxMonitoredQueues);
        expect(value, isA<String>());

        await config.set(ConfigKeys.npxMonitoredQueues, true);
        value = await config.get(ConfigKeys.npxMonitoredQueues);
        expect(value, isA<bool>());

        await config.set(ConfigKeys.npxMonitoredQueues, 1);
        value = await config.get(ConfigKeys.npxMonitoredQueues);
        expect(value, isA<int>());
      });
    });

    group('parse', () {
      test('deve parsear 0 como false', () async {
        final db = await storage.connection;
        await db.update('config', {
          'key': 'api/npx/lastSyncDateTime',
          'value': '0',
        });

        final value = await config.get<bool>(ConfigKeys.npxLastSyncAt);
        expect(value, isFalse);
      });

      test('deve salvar false como 0 no banco', () async {
        await config.set(ConfigKeys.npxMonitoredQueues, false);

        final db = await storage.connection;
        final query = await db.query(
          'config',
          where: 'key = ?',
          whereArgs: ['api/npx/monitoredQueues'],
        );

        expect(query.first['value'], '0');
      });
    });
  });
}
