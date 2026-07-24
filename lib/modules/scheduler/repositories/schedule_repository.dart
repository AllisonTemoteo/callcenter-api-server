import 'dart:convert';

import 'package:server/core/external/database/app_database.dart';
import 'package:server/core/utils/extensions.dart';
import 'package:server/core/utils/typedefs.dart';
import 'package:server/modules/scheduler/models/schedule.dart';

abstract class IScheduleRepository {
  Future<List<Schedule>> getSchedules({
    bool overdueOnly = false,
    bool idleOnly = false,
  });

  Future<Schedule> schedule(
    ActionType type, {
    required DateTime runAt,
    Duration? runInterval,
    Json? params,
  });

  Future<Schedule> reschedule(Schedule scheduled, {DateTime? runAt});

  Future<Schedule> setStatus(Schedule schedule, Status status, {String? error});

  Future<void> reset();

  Future<void> complete(Schedule scheduled);

  Future<int> cancel(int id);
}

class ScheduleRepository implements IScheduleRepository {
  ScheduleRepository(AppDatabase storage) : _storage = storage;
  final AppDatabase _storage;

  @override
  Future<List<Schedule>> getSchedules({
    bool overdueOnly = false,
    bool idleOnly = false,
  }) async {
    final conn = await _storage.connection;

    final where = idleOnly ? 'status = 0' : null;
    var query = await conn.query('schedule', where: where);

    final schedules = query.map(ScheduleMapper.fromMap);

    return overdueOnly
        ? List.unmodifiable(schedules.where((s) => s.isOverdue))
        : List.unmodifiable(schedules);
  }

  @override
  Future<Schedule> schedule(
    ActionType type, {
    required DateTime runAt,
    Duration? runInterval,
    Json? params,
  }) async {
    final conn = await _storage.connection;

    final data = <String, dynamic>{
      'type': type.code,
      'run_at': runAt.iso,
      'run_interval': runInterval?.inSeconds,
      'params': jsonEncode(params),
    };

    data['id'] = await conn.insert('schedule', data);

    return ScheduleMapper.fromMap(data);
  }

  @override
  Future<Schedule> reschedule(Schedule scheduled, {DateTime? runAt}) async {
    final conn = await _storage.connection;
    final newSchedule = scheduled.updateNextRun(runAt);

    await conn.update(
      'schedule',
      ScheduleMapper.toMap(newSchedule),
      where: 'id = ?',
      whereArgs: [newSchedule.id],
    );

    return newSchedule;
  }

  @override
  Future<void> reset() async {
    final conn = await _storage.connection;
    await conn.update(
      'schedule',
      {'status': Status.idle.code},
      where: 'status != ?',
      whereArgs: [Status.failed.code],
    );
  }

  @override
  Future<Schedule> setStatus(
    Schedule schedule,
    Status status, {
    String? error,
  }) async {
    final conn = await _storage.connection;
    await conn.update('schedule', {'status': status.code, 'error': error});

    final newSchedule = schedule.copyWith(status: status);
    return newSchedule;
  }

  @override
  Future<void> complete(Schedule scheduled) async {
    if (scheduled.isPeriodic) {
      reschedule(scheduled);
      return;
    }

    await cancel(scheduled.id);
  }

  @override
  Future<int> cancel(int id) async {
    final conn = await _storage.connection;
    return await conn.delete('schedule', where: 'id = ?', whereArgs: [id]);
  }
}
