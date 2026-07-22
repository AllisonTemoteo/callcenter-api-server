import 'package:clock/clock.dart';
import 'package:server/core/utils/typedefs.dart';
import 'package:server/modules/scheduler/actions/schedule_enums.dart';

export '../actions/schedule_enums.dart';
export 'schedule_mapper.dart';

class Schedule {
  Schedule({
    required this.id,
    required this.type,
    DateTime? runAt,
    this.runInterval,
    this.params,
    this.status = Status.idle,
    this.error,
  }) : runAt = runAt ?? DateTime.now();

  final int id;
  final ActionType type;
  final Duration? runInterval;
  final Json? params;
  final DateTime runAt;
  final Status status;
  final String? error;

  bool get isOverdue => runAt.isBefore(clock.now());
  bool get isPeriodic => runInterval != null && runInterval != Duration.zero;

  Schedule copyWith({
    ActionType? type,
    Duration? runInterval,
    Json? params,
    DateTime? runAt,
    Status? status,
  }) {
    return Schedule(
      id: id,
      type: type ?? this.type,
      runAt: runAt ?? this.runAt,
      runInterval: runInterval ?? this.runInterval,
      params: params ?? this.params,
      status: status ?? this.status,
    );
  }

  Schedule updateNextRun([DateTime? nextRun]) {
    return copyWith(
      runAt: nextRun ?? clock.now().add(runInterval ?? Duration.zero),
      status: Status.idle,
    );
  }
}
