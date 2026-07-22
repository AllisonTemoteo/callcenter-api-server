import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabase {
  AppDatabase() {
    sqfliteFfiInit();
  }
  Database? _db;

  Future<Database> get connection async => _db ??= await _connect();

  Future<Database> _connect() async {
    try {
      final path = join(Directory.current.path, 'data');
      final db = join(path, 'data.db');
      Directory(path).createSync();

      return databaseFactoryFfi.openDatabase(
        db,
        options: OpenDatabaseOptions(version: 1, onCreate: _onCreate),
      );
    } catch (e) {
      rethrow;
    }
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    String path = join(Directory.current.path, 'data');
    String migratePath = join(path, 'migrate.sql');
    File migrate = File(migratePath);

    if (migrate.existsSync()) {
      await db.transaction(
        (txn) async => {txn.execute(migrate.readAsStringSync())},
      );
    }
  }
}
