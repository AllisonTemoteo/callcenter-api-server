import 'dart:convert';

import 'package:server/core/utils/extensions.dart';
import 'package:server/core/utils/typedefs.dart';
import 'package:server/modules/scheduler/models/schedule.dart';

abstract class ScheduleMapper {
  static const String kId = 'id';
  static const String kType = 'type';
  static const String kRunAt = 'run_at';
  static const String kRunInterval = 'run_interval';
  static const String kStatus = 'status';
  static const String kParams = 'params';
  static const String kError = 'error';

  static Schedule fromMap(Json map) {
    return Schedule(
      id: map[kId],
      type: ActionType.fromCode(map[kType]),
      runInterval: Duration(seconds: map[kRunInterval] ?? 0),
      runAt: (map[kRunAt] as String).toLocalDateTime,
      params: jsonDecode(map[kParams] ?? '{}'),
      error: map['error'],
    );
  }

  static Json toMap(Schedule schedule) {
    return {
      kId: schedule.id,
      kType: schedule.type.code,
      kRunAt: schedule.runAt.iso,
      kRunInterval: schedule.runInterval?.inSeconds,
      kStatus: schedule.status.code,
      kParams: jsonEncode(schedule.params),
      kError: schedule.error,
    };
  }
}
