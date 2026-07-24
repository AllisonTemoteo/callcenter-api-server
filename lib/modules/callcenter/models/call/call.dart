import 'package:server/modules/callcenter/models/call/call_enum.dart';
import 'package:server/modules/callcenter/models/call_activity.dart/activity.dart';

export 'call_enum.dart' show Direction;

class Call {
  const Call({
    required this.id,
    required this.linkedId,
    required this.peer,
    required this.callDateTime,
    required this.billSec,
    required this.direction,
    required this.queueName,
    required this.activities,
    this.protocol,
  });

  final int id;
  final String linkedId;
  final String peer;
  final DateTime callDateTime;
  final Duration billSec;
  final Direction direction;
  final String queueName;
  final String? protocol;
  final List<Activity> activities;

  bool get isAbandoned {
    return activities.any((event) => event.isAbandoned);
  }
}
