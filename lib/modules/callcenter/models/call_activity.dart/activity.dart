import 'package:server/modules/callcenter/models/call_activity.dart/activity_agent.dart';
import 'package:server/modules/callcenter/models/call_activity.dart/activity_enum.dart';

export 'activity_enum.dart';

class Activity {
  Activity({
    required this.id,
    required this.linkedId,
    required this.agent,
    required this.eventDateTime,
    required this.status,
    required this.hangupCause,
    required this.event,
    required this.waitTimeInSec,
  });

  final int id;
  final String linkedId;
  final ActivityAgent agent;
  final int waitTimeInSec;
  final DateTime eventDateTime;
  final Status status;
  final HangupCause hangupCause;
  final Event event;

  bool get isAbandoned =>
      hangupCause == HangupCause.abandon && status == Status.notAnsweredAgent;
}
