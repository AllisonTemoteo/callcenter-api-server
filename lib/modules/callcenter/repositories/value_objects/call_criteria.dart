import 'package:server/core/external/database/sql_criteria.dart';
import 'package:server/core/utils/extensions.dart';
import 'package:server/modules/callcenter/models/call/call_mapper.dart';

class CallCriteria implements Criteria {
  final String? linkedId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? protocol;
  final String? phone;
  final int? pageItemsCount;
  final int? page;

  CallCriteria({
    this.linkedId,
    this.startDate,
    this.endDate,
    this.protocol,
    this.phone,
    this.pageItemsCount,
    this.page,
  });

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
    if (phone != null) {
      conditions.add('${CallMapper.kPeerPhone} = ?');
    }

    if (conditions.isEmpty) return '';

    return 'WHERE ${conditions.join(' AND ')}\n';
  }

  @override
  List<Object?> get args {
    final args = [];
    args.add(linkedId);
    args.add(startDate?.iso);
    args.add(endDate?.iso);
    args.add(protocol);
    args.add(phone);

    return List.unmodifiable(args.nonNulls.toList());
  }

  String get limit {
    return 'LIMIT ${pageItemsCount ?? 100}\n';
  }

  String get offset {
    final page = this.page ?? 1;
    final pageItemsCount = this.pageItemsCount ?? 100;
    return 'OFFSET ${(page * pageItemsCount) - pageItemsCount}\n';
  }
}
