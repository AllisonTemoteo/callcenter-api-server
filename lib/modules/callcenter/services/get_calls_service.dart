import 'package:server/modules/callcenter/models/call/call.dart';
import 'package:server/modules/callcenter/repositories/call_local_repository.dart';
import 'package:server/modules/callcenter/repositories/value_objects/call_criteria.dart';

class GetCallsService {
  const GetCallsService(ICallLocalRepository calls) : _calls = calls;
  final ICallLocalRepository _calls;

  Future<List<Call>> call(
    CallCriteria? criteria, {
    required int limit,
    required int page,
  }) async {
    return await _calls.get(criteria, limit: limit, page: page);
  }
}
