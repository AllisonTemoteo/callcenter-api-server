import 'package:server/core/utils/extensions.dart';
import 'package:server/core/utils/typedefs.dart';
import 'package:server/modules/callcenter/models/call_activity.dart/activity.dart';
import 'package:server/modules/callcenter/models/call_activity.dart/activity_agent.dart';

abstract class ActivityMapper {
  static const String kId = 'id';
  static const String kLinkedId = 'linked_id';
  static const String kWaitTimeInSec = 'wait_time';
  static const String kAgentCode = 'agent_code';
  static const String kAgentName = 'agent_name';
  static const String kEventDateTime = 'event_date_time';
  static const String kStatus = 'status';
  static const String kHangupCause = 'hangup_cause';
  static const String kEvent = 'event';

  static Activity fromMap(Json map) {
    return Activity(
      id: map[kId],
      linkedId: map[kLinkedId],
      waitTimeInSec: map[kWaitTimeInSec],
      agent: ActivityAgent(code: map[kAgentCode], name: map[kAgentName]),
      eventDateTime: map[kEventDateTime].toString().toLocalDateTime,
      status: Status.fromCode(map[kStatus]),
      hangupCause: HangupCause.fromCode(map[kHangupCause]),
      event: Event.fromCode(map[kEvent]),
    );
  }

  static Json toMap(Activity event) {
    return {
      kId: event.id,
      kLinkedId: event.linkedId,
      kWaitTimeInSec: event.waitTimeInSec,
      kAgentCode: event.agent.code,
      kAgentName: event.agent.name,
      kEventDateTime: event.eventDateTime.iso,
      kStatus: event.status.str,
      kHangupCause: event.hangupCause.str,
      kEvent: event.event.str,
    };
  }
}
