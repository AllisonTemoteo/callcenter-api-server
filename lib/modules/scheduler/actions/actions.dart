import 'package:server/core/bootstrap/dependency_injector.dart';
import 'package:server/core/utils/typedefs.dart';
import 'package:server/modules/callcenter/callcenter_module.dart';
import 'package:server/modules/scheduler/actions/schedule_enums.dart';

abstract class IAction {
  ActionType get type;

  static Map<ActionType, IAction> jobs = {
    ActionType.echo: _EchoAction(),
    ActionType.syncCalls: _SyncCallsAction(),
  };

  static IAction get(ActionType type) {
    return jobs[type]!;
  }

  static List<IAction> getAll() {
    return List.unmodifiable(jobs.values);
  }

  Future<void> execute(Json? configs);
}

class _EchoAction implements IAction {
  const _EchoAction();

  @override
  ActionType get type => ActionType.echo;

  @override
  Future<void> execute(Json? configs) async {
    print(configs?['message'] ?? 'Echo...');
  }
}

class _SyncCallsAction implements IAction {
  const _SyncCallsAction();

  @override
  ActionType get type => ActionType.syncCalls;

  @override
  Future<void> execute(Json? configs) async {
    final sync = di.get<SyncCallsService>();
    await sync();
  }
}
