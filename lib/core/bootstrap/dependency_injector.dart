import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:server/core/external/database/app_database.dart';
import 'package:server/core/external/http/http_client.dart';
import 'package:server/infra/api/controllers/callcenter_controller.dart';
import 'package:server/infra/api/server.dart';
import 'package:server/modules/callcenter/callcenter_module.dart';
import 'package:server/modules/callcenter/repositories/call_local_repository.dart';
import 'package:server/modules/callcenter/repositories/call_remote_repository.dart';
import 'package:server/modules/configs/app_config.dart';
import 'package:server/modules/scheduler/repositories/schedule_repository.dart';
import 'package:server/modules/scheduler/services/job_runner.dart';
import 'package:server/modules/scheduler/services/scheduler.dart';

final di = GetIt.instance;

void initDi() {
  // core
  di.registerLazySingleton<AppDatabase>(() => AppDatabase());
  di.registerLazySingleton<AppConfig>(() => AppConfig(di()));
  di.registerLazySingleton<Client>(() => Client()); // package http
  di.registerLazySingleton<IHttpClient>(() => HttpClient(di()));

  // callcenter
  di.registerLazySingleton<ICallRemoteRepository>(
    () => CallNpxRepository(di()),
  );
  di.registerLazySingleton<ICallLocalRepository>(
    () => CallSqliteRepository(di()),
  );
  di.registerLazySingleton<SyncCallsService>(
    () => SyncCallsService(di(), di()),
  );
  di.registerLazySingleton<GetCallsService>(() => GetCallsService(di()));

  // scheduler
  di.registerLazySingleton<IScheduleRepository>(() => ScheduleRepository(di()));
  di.registerLazySingleton<IJobRunner>(() => JobRunner(di()));
  di.registerLazySingleton<Scheduler>(() => Scheduler(di(), di()));

  // api
  di.registerLazySingleton<CallcenterController>(
    () => CallcenterController(di()),
  );
  di.registerLazySingleton<ApiServer>(() => ApiServer());
}
