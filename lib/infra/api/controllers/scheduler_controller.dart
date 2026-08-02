import 'dart:convert';

import 'package:server/core/error/exceptions.dart';
import 'package:server/core/utils/typedefs.dart';
import 'package:server/modules/scheduler/actions/schedule_enums.dart';
import 'package:server/modules/scheduler/services/scheduler.dart';
import 'package:shelf/shelf.dart';

class SchedulerController {
  const SchedulerController(Scheduler scheduler) : _scheduler = scheduler;
  final Scheduler _scheduler;

  Future<Response> createSchedule(Request req) async {
    try {
      final reqBody = await req.readAsString();
      final body = Json.from(jsonDecode(reqBody));

      if (!body.containsKey('action_type')) {
        throw ApiException("Required field not found: 'action_type'");
      }

      var type = ActionType.fromName(body['action_type']);
      var delay = Duration(seconds: body['delay'] ?? 0);
      var params = body['params'];

      DateTime? runAt;
      Duration? runInterval;

      if (body.containsKey('run_at')) {
        runAt = DateTime.parse(body['run_at']);
      }

      if (body.containsKey('run_interval')) {
        runInterval = Duration(seconds: body['run_interval']);
      }

      _scheduler.schedule(
        type,
        delay: delay,
        runAt: runAt,
        runInterval: runInterval,
        params: params,
      );

      return Response.ok(reqBody);
      //
    } on ApiException catch (e) {
      return Response.badRequest(
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'ok': false, 'message': e.message}),
      );
    } catch (e) {
      return Response.badRequest(
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'ok': false, 'message': e.toString()}),
      );
    }
  }

  Future<Response> cancelSchedule(Request req, String id) async {
    try {
      final scheduleId = int.parse(id);
      await _scheduler.cancel(scheduleId);
      return Response.ok('Schedule cancelled');
    } catch (e) {
      return Response.internalServerError(
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'ok': false, 'error': e.toString()}),
      );
    }
  }
}
