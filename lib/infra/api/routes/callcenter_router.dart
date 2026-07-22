import 'package:server/core/bootstrap/dependency_injector.dart';
import 'package:server/infra/api/controllers/callcenter_controller.dart';
import 'package:shelf_router/shelf_router.dart';

Router callcenterRoutes() {
  final controller = di.get<CallcenterController>();
  final router = Router();

  router.get('/report', controller.getCalls);

  return router;
}
