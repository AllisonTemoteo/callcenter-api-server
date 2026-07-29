import 'dart:convert';

import 'package:server/core/utils/extensions.dart';
import 'package:server/modules/callcenter/models/call/call_mapper.dart';
import 'package:server/modules/callcenter/repositories/value_objects/call_criteria.dart';
import 'package:server/modules/callcenter/services/get_calls_service.dart';
import 'package:shelf/shelf.dart';

class CallcenterController {
  const CallcenterController(GetCallsService service) : _getCalls = service;
  final GetCallsService _getCalls;

  Future<Response> getCalls(Request req) async {
    try {
      final params = req.url.queryParameters;

      final criteria = CallCriteria(
        linkedId: params['linked_id'],
        startDate: params['start_date']?.toLocalDateTime,
        endDate: params['end_date']?.toLocalDateTime,
        protocol: params['protocol'],
        pageItemsCount: int.tryParse(params['limit'] ?? ''),
        page: int.tryParse(params['page'] ?? ''),
      );

      final calls = await _getCalls(criteria);
      final callsMaps = calls.map(CallMapper.toMap).toList();

      final headers = {'content-type': 'application/json'};
      final body = jsonEncode({'count': calls.length, 'content': callsMaps});

      return Response.ok(body, headers: headers);
    } catch (e) {
      return Response.internalServerError(
        body: {'ok': false, 'message': e.toString()},
      );
    }
  }
}
