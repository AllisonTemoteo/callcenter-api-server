import 'package:server/core/bootstrap/dependency_injector.dart';
import 'package:server/infra/api/server.dart';
import 'package:server/modules/scheduler/services/scheduler.dart';

Future<void> main() async {
  initDi();

  final scheduler = di.get<Scheduler>();
  final apiServer = di.get<ApiServer>();

  scheduler.start();
  await apiServer();
}
