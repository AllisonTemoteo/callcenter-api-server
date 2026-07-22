import 'package:server/core/external/database/app_database.dart';
import 'package:server/core/utils/typedefs.dart';
import 'package:server/modules/callcenter/models/call/call.dart';
import 'package:server/modules/callcenter/models/call_activity.dart/activity_mapper.dart';
import 'package:server/modules/callcenter/models/call/call_mapper.dart';
import 'package:server/modules/callcenter/repositories/value_objects/call_criteria.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

abstract class ICallLocalRepository {
  Future<int> saveAll(List<Json> calls);
  Future<List<Call>> get([CallCriteria? criteria]);
}

class CallSqliteRepository implements ICallLocalRepository {
  CallSqliteRepository(AppDatabase storage) : _storage = storage;
  final AppDatabase _storage;

  @override
  Future<List<Call>> get([CallCriteria? criteria]) async {
    final conn = await _storage.connection;

    final sql =
        'SELECT \n'
        '    c.${CallMapper.kLinkedId},\n'
        '    c.${CallMapper.kCallDateTime},\n'
        '    c.${CallMapper.kDirection},\n'
        '    c.${CallMapper.kPeerPhone},\n'
        '    c.${CallMapper.kQueue},\n'
        '    c.${CallMapper.kProtocol},\n'
        '    c.${CallMapper.kBillSec},\n'
        '    c.${CallMapper.kCallDateTime},\n'
        '    json_group_array(\n'
        '        json_object(\n'
        '            \'${ActivityMapper.kId}\', ca.${ActivityMapper.kId},\n'
        '            \'${ActivityMapper.kLinkedId}\', ca.${ActivityMapper.kLinkedId},\n'
        '            \'${ActivityMapper.kAgentCode}\', a.code,\n'
        '            \'${ActivityMapper.kAgentName}\', a.name,\n'
        '            \'${ActivityMapper.kEventDateTime}\', ca.${ActivityMapper.kEventDateTime},\n'
        '            \'${ActivityMapper.kStatus}\', ca.${ActivityMapper.kStatus},\n'
        '            \'${ActivityMapper.kHangupCause}\', ca.${ActivityMapper.kHangupCause},\n'
        '            \'${ActivityMapper.kEvent}\', ca.${ActivityMapper.kEvent},\n'
        '            \'${ActivityMapper.kWaitTimeInSec}\', ca.${ActivityMapper.kWaitTimeInSec}\n'
        '        )\n'
        '    ) as ${CallMapper.kActivities}\n'
        'FROM call c\n'
        'JOIN call_activity ca USING(${CallMapper.kLinkedId})\n'
        'LEFT JOIN agent a ON \n'
        '    a.code = ca.agent_code\n'
        '${criteria != null ? '${criteria.whereClausule}\n' : ''}'
        'GROUP BY \n'
        '    c.${CallMapper.kLinkedId},\n'
        '    c.${CallMapper.kCallDateTime},\n'
        '    c.${CallMapper.kDirection},\n'
        '    c.${CallMapper.kPeerPhone},\n'
        '    c.${CallMapper.kQueue},\n'
        '    c.${CallMapper.kProtocol},\n'
        '    c.${CallMapper.kBillSec}\n'
        ';';

    final query = await conn.rawQuery(sql, criteria?.args);
    return query.map(CallMapper.fromMap).toList();
  }

  @override
  Future<int> saveAll(List<Json> calls) async {
    final db = await _storage.connection;
    await db.transaction((txn) async {
      for (final call in calls) {
        await _save(txn, call);
      }
    });

    return calls.length;
  }

  Future<void> _save(Transaction db, Json data) async {
    final call = data['call'];
    final event = data['event'];

    // salvar call
    if (call != null) {
      final insertCall =
          'INSERT INTO call (\n'
          '    ${CallMapper.kLinkedId},\n'
          '    ${CallMapper.kCallDateTime},\n'
          '    ${CallMapper.kBillSec},\n'
          '    ${CallMapper.kPeerPhone},\n'
          '    ${CallMapper.kDirection},\n'
          '    ${CallMapper.kQueue},\n'
          '    ${CallMapper.kProtocol}\n'
          ')\n'
          'VALUES (?,?,?,?,?,?,?)\n'
          'ON CONFLICT(${CallMapper.kLinkedId})\n'
          'DO UPDATE SET\n'
          '    ${CallMapper.kBillSec} = MAX(call.${CallMapper.kBillSec}, excluded.${CallMapper.kBillSec}),\n'
          '    ${CallMapper.kProtocol} = COALESCE(call.${CallMapper.kProtocol}, excluded.${CallMapper.kProtocol}) \n'
          ';\n';
      // tentar upsert
      await db.rawInsert(insertCall, [
        call![CallMapper.kLinkedId],
        call![CallMapper.kCallDateTime],
        call![CallMapper.kBillSec],
        call![CallMapper.kPeerPhone],
        call![CallMapper.kDirection],
        call![CallMapper.kQueue],
        call![CallMapper.kProtocol],
      ]);
    }

    // salvar event
    if (event != null) {
      // criar agent se nao existe
      await db.insert('agent', {
        'code': event![ActivityMapper.kAgentCode],
        'name': event![ActivityMapper.kAgentName],
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      final insertEvent =
          'INSERT INTO call_activity (\n'
          '    ${ActivityMapper.kLinkedId},\n'
          '    ${ActivityMapper.kAgentCode},\n'
          '    ${ActivityMapper.kWaitTimeInSec},\n'
          '    ${ActivityMapper.kEventDateTime},\n'
          '    ${ActivityMapper.kStatus},\n'
          '    ${ActivityMapper.kHangupCause},\n'
          '    ${ActivityMapper.kEvent}\n'
          ')\n'
          'VALUES (?,?,?,?,?,?,?) '
          'ON CONFLICT DO NOTHING\n'
          ';\n';

      await db.rawInsert(insertEvent, [
        event![ActivityMapper.kLinkedId],
        event![ActivityMapper.kAgentCode],
        event![ActivityMapper.kWaitTimeInSec],
        event![ActivityMapper.kEventDateTime],
        event![ActivityMapper.kStatus],
        event![ActivityMapper.kHangupCause],
        event![ActivityMapper.kEvent],
      ]);
    }
  }
}
