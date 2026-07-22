import 'dart:convert';

import 'package:server/core/utils/extensions.dart';
import 'package:server/core/utils/typedefs.dart';
import 'package:server/modules/callcenter/models/call/call.dart';
import 'package:server/modules/callcenter/models/call_activity.dart/activity.dart';
import 'package:server/modules/callcenter/models/call_activity.dart/activity_mapper.dart';

abstract class CallMapper {
  static const String kLinkedId = 'linked_id';
  static const String kPeerPhone = 'peer_phone';
  static const String kCallDateTime = 'call_date_time';
  static const String kBillSec = 'bill_sec';
  static const String kDirection = 'direction';
  static const String kQueue = 'queue';
  static const String kProtocol = 'protocol';
  static const String kActivities = 'events';

  static Call fromMap(Json map) {
    final json = jsonDecode(map[kActivities]);
    final activitiesMaps = List<Json>.from(json);
    final activities = activitiesMaps.map(ActivityMapper.fromMap).toList();

    return Call(
      linkedId: map[kLinkedId],
      peer: map[kPeerPhone],
      callDateTime: map[kCallDateTime].toString().toLocalDateTime,
      billSec: Duration(seconds: map[kBillSec]),
      direction: Direction.fromCode(map[kDirection]),
      queueName: map[kQueue],
      activities: activities,
    );
  }

  static Json toMap(Call call) {
    List<Json> events = [];

    for (final event in call.activities) {
      events.add(_activityToMap(event));
    }

    return {
      kLinkedId: call.linkedId,
      kPeerPhone: call.peer,
      kCallDateTime: call.callDateTime.iso,
      kBillSec: call.billSec.inSeconds,
      kDirection: call.direction.code,
      kQueue: call.queueName,
      kProtocol: call.protocol,
      kActivities: events,
    };
  }

  static Json _activityToMap(Activity event) => ActivityMapper.toMap(event);
}
