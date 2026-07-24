import 'dart:async';

import 'package:clock/clock.dart';
import 'package:server/core/utils/typedefs.dart';
import 'package:server/modules/scheduler/actions/schedule_enums.dart';
import 'package:server/modules/scheduler/repositories/schedule_repository.dart';
import 'package:server/modules/scheduler/services/job_runner.dart';

class Scheduler {
  Scheduler(IScheduleRepository schedules, IJobRunner runner)
    : _schedules = schedules,
      _runner = runner;

  final IScheduleRepository _schedules;
  final IJobRunner _runner;

  Timer? _timer;

  void start() async {
    await _schedules.reset();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      final schedules = await _schedules.getSchedules(
        overdueOnly: true,
        idleOnly: true,
      );

      for (final sch in schedules) {
        await _runner.run(sch);
      }
    });
  }

  void stop() {
    // _running = false;
    _timer?.cancel();
  }

  Future<void> schedule(
    ActionType type, {
    Duration delay = Duration.zero,
    DateTime? runAt,
    Duration? runInterval,
    Json? params,
  }) async {
    await _schedules.schedule(
      type,
      runAt: runAt?.add(delay) ?? clock.now().add(delay),
      runInterval: runInterval,
      params: params,
    );
  }

  Future<void> cancel(int id) async {
    await _schedules.cancel(id);
  }
}
