import 'package:server/core/external/database/sql_criteria.dart';
import 'package:server/core/utils/extensions.dart';
import 'package:server/modules/callcenter/models/call/call_mapper.dart';

class CallCriteria implements Criteria {
  final String? linkedId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? protocol;

  CallCriteria({this.linkedId, this.startDate, this.endDate, this.protocol});

  @override
  String? get whereClausule {
    final conditions = <String>[];
    if (linkedId != null) {
      conditions.add('${CallMapper.kLinkedId} = ?');
    }
    if (startDate != null) {
      conditions.add('${CallMapper.kCallDateTime} >= ?');
    }
    if (endDate != null) {
      conditions.add('${CallMapper.kCallDateTime} <= ?');
    }
    if (protocol != null) {
      conditions.add('${CallMapper.kProtocol} = ?');
    }

    if (conditions.isEmpty) return '';

    return 'WHERE ${conditions.join(' AND ')}';
  }

  @override
  List<Object?> get args {
    final args = [];
    args.add(linkedId);
    args.add(startDate?.iso);
    args.add(endDate?.iso);
    args.add(protocol);

    return args.nonNulls.toList();
  }
}
