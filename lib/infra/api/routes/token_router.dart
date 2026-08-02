import 'package:server/core/bootstrap/dependency_injector.dart';
import 'package:server/infra/api/controllers/auth_controller.dart';
import 'package:shelf_router/shelf_router.dart';

Router tokenRouter() {
  final controller = di.get<AuthController>();
  final router = Router();

  router.get('/validate', controller.validate);

  return router;
}
