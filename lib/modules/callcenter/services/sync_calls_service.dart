import 'package:clock/clock.dart';
import 'package:server/core/bootstrap/dependency_injector.dart';
import 'package:server/core/utils/extensions.dart';
import 'package:server/modules/callcenter/repositories/call_local_repository.dart';
import 'package:server/modules/callcenter/repositories/call_remote_repository.dart';
import 'package:server/core/utils/value_objects.dart';
import 'package:server/modules/callcenter/repositories/value_objects/fetch_params.dart';
import 'package:server/modules/configs/app_config.dart';

class SyncCallsService {
  const SyncCallsService(
    ICallRemoteRepository remote,
    ICallLocalRepository local,
  ) : _remote = remote,
      _local = local;

  final ICallRemoteRepository _remote;
  final ICallLocalRepository _local;

  Future<void> call() async {
    final config = di.get<AppConfig>();

    final currentDateTime = clock.now();
    final lastSyncDateTime = await config.get(
      ConfigKeys.npxLastSyncAt,
      fallback: clock.now().subtract(Duration(minutes: 10)),
    );

    final fetchParams = FetchParams(
      range: DateRange(start: lastSyncDateTime!, end: currentDateTime),
    );

    final maps = await _remote.fetchCalls(fetchParams);
    final count = await _local.saveAll(maps);

    await config.set(ConfigKeys.npxLastSyncAt, currentDateTime);

    count.debug();
  }
}
