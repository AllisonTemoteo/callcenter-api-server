import 'package:server/core/bootstrap/dependency_injector.dart';
import 'package:server/infra/api/controllers/scheduler_controller.dart';
import 'package:shelf_router/shelf_router.dart';

Router schedulerRoutes() {
  final controller = di.get<SchedulerController>();
  final router = Router();

  router.post('/create', controller.createSchedule);
  router.delete('/cancel/<id>', controller.cancelSchedule);

  return router;
}
