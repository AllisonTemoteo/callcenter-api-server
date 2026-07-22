import 'package:server/infra/api/routes/callcenter_router.dart';
import 'package:shelf_router/shelf_router.dart';

Router apiRoutes() {
  final router = Router();
  router.mount('/callcenter/', callcenterRoutes().call);

  return router;
}
