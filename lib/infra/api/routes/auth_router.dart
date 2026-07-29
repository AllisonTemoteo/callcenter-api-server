import 'package:server/core/bootstrap/dependency_injector.dart';
import 'package:server/infra/api/controllers/auth_controller.dart';
import 'package:shelf_router/shelf_router.dart';

Router authRoutes() {
  final controller = di.get<AuthController>();
  final router = Router();

  router.post('/login', controller.login);
  router.post('/signin', controller.signIn);

  return router;
}
