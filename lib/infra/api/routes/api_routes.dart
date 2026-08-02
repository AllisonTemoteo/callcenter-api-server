// import 'package:server/infra/api/routes/auth_router.dart';
import 'package:server/infra/api/routes/callcenter_router.dart';
import 'package:server/infra/api/routes/scheduler_router.dart';
import 'package:server/infra/api/routes/token_router.dart';
import 'package:shelf_router/shelf_router.dart';

Router apiRoutes() {
  final router = Router();

  router.mount('/callcenter/', callcenterRoutes().call);
  router.mount('/scheduler/', schedulerRoutes().call);
  router.mount('/token/', tokenRouter().call);

  return router;
}
