import 'package:server/modules/scheduler/actions/actions.dart';
import 'package:server/modules/scheduler/models/schedule.dart';
import 'package:server/modules/scheduler/repositories/schedule_repository.dart';

abstract class IJobRunner {
  Future<void> run(Schedule schedule);
}

class JobRunner implements IJobRunner {
  JobRunner(IScheduleRepository schedules) : _schedules = schedules;
  final IScheduleRepository _schedules;

  @override
  Future<void> run(Schedule schedule) async {
    try {
      if (schedule.status != Status.idle) {
        return;
      }

      await _schedules.setStatus(schedule, Status.running);
      await IAction.get(schedule.type).execute(schedule.params);
      await _schedules.setStatus(schedule, Status.completed);
      await _schedules.complete(schedule);
      //
    } catch (e) {
      await _schedules.setStatus(schedule, Status.failed);
      rethrow;
    }
  }
}
