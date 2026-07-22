import 'package:server/core/utils/typedefs.dart';
import 'package:server/modules/callcenter/models/call/call_enum.dart';
import 'package:server/modules/callcenter/models/call_activity.dart/activity.dart';
import 'package:server/modules/callcenter/models/call_activity.dart/activity_mapper.dart';
import 'package:server/modules/callcenter/models/call/call_mapper.dart';
import 'package:server/modules/callcenter/models/call_activity.dart/activity_enum.dart';

abstract class NpxMapper {
  static const String kCallDateTime = 'calldatetime';
  static const String kBillSec = 'billsec';
  static const String kWaitTime = 'wait';
  static const String kAgentCode = 'agent_code';
  static const String kSource = 'src';
  static const String kDestiny = 'dst';
  static const String kQueueName = 'queue_name';
  static const String kBound = 'bound';
  static const String kCallTypeName = 'call_type_name';
  static const String kStatus = 'status';
  static const String kLinkendId = 'linkedid';
  static const String kHangupCause = 'hangupcause';
  static const String kProtocol = 'protocol';
  static const String kCall = 'call';
  static const String kEvent = 'event';

  static int _direction = -1;

  static Json normalize(Json map) {
    _direction = _getCallDirection(map);
    return {
      kCall: {
        CallMapper.kLinkedId: map[kLinkendId],
        CallMapper.kCallDateTime: map[kCallDateTime],
        CallMapper.kBillSec: map[kBillSec],
        CallMapper.kPeerPhone: _parsePeerPhone(map),
        CallMapper.kDirection: _direction,
        CallMapper.kQueue: map[kQueueName],
        CallMapper.kProtocol: map[kProtocol],
      },
      kEvent: {
        ActivityMapper.kLinkedId: map[kLinkendId],
        ActivityMapper.kAgentCode: map[kAgentCode],
        ActivityMapper.kAgentName: _parseAgentName(map) ?? 'NONE',
        ActivityMapper.kWaitTimeInSec: map[kWaitTime],
        ActivityMapper.kEventDateTime: map[kCallDateTime],
        ActivityMapper.kStatus: _parseStatus(map[kStatus]),
        ActivityMapper.kEvent: _parseEvent(map[kEvent]),
        ActivityMapper.kHangupCause: _parseHangupCause(map[kHangupCause]),
      },
    };
  }

  static bool _isPhone(String value) {
    return RegExp(r'^\d+$').hasMatch(value);
  }

  static int _getCallDirection(Map<String, dynamic> call) {
    final src = call['dst']?.toString() ?? '';

    if (_isPhone(src)) {
      return Direction.outBound.code;
    }

    return Direction.inBound.code;
  }

  static int _parseStatus(String? status) {
    return switch (status ?? '') {
      'ANSWERED' => Status.answered.code,
      'NOT ANSWERED' => Status.notAnsweredPeer.code,
      'NOT ANSWERED AGENT' => Status.notAnsweredAgent.code,
      'BUSY' => Status.busy.code,
      'DND' => Status.doNotDisturb.code,
      _ => Status.unknown.code,
    };
  }

  static int _parseHangupCause(int? cause) {
    return switch (cause ?? 99) {
      -1 => HangupCause.abandon.code,
      0 => HangupCause.completeAgent.code,
      1 => HangupCause.completePeer.code,
      2 => HangupCause.transference.code,
      _ => HangupCause.unknown.code,
    };
  }

  static int _parseEvent(String? event) {
    return switch (event) {
      'ABANDON' => Event.abandon.code,
      'COMPLETEAGENT' => Event.completeAgent.code,
      'COMPLETECALLER' => Event.completePeer.code,
      'RINGNOANSWER' => Event.ringNoAnswer.code,
      'CDR' => Event.callDetailRecord.code,
      _ => Event.unknown.code,
    };
  }

  static String? _parseAgentName(Map<String, dynamic> map) {
    return _direction == Direction.inBound.code ? map['dst'] : map['src'];
  }

  static String _parsePeerPhone(Map<String, dynamic> map) {
    return _direction == Direction.inBound.code ? map['src'] : map['dst'];
  }
}

/*
{
  calldatetime: 2026-06-02T13: 16: 29.063-03: 00,
  billsec: 225,
  wait: 225,
  agent_code: NONE,
  src: 92995011325,
  dst: null,
  queue_name: Proabakus_Suporte,
  operator_name: Proabakus Desenvolvimento de Sistemas LTDA,
  trunk: 592,
  bound: 6,
  call_type_name: Celular DDD,
  status: NOT ANSWERED,
  linkedid: 4-1780416732.14050,
  file: 4-1780416732.14050.ogg,
  record: 0,
  hangupcause: -1,
  event: ABANDON,
  campaign_name: null,
  protocol: null
}
*/
