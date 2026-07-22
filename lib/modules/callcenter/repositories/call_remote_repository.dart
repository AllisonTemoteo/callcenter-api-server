import 'dart:convert';

import 'package:server/core/bootstrap/dependency_injector.dart';
import 'package:server/core/error/exceptions.dart';
import 'package:server/core/external/http/http_client.dart';
import 'package:server/core/external/http/value_objects/http.dart';
import 'package:server/core/utils/env.dart';
import 'package:server/core/utils/extensions.dart';
import 'package:server/core/utils/typedefs.dart';
import 'package:server/modules/callcenter/repositories/npx_mapper.dart';
import 'package:server/modules/callcenter/repositories/value_objects/fetch_params.dart';
import 'package:server/modules/callcenter/repositories/value_objects/npx_payload.dart';
import 'package:server/modules/configs/app_config.dart';

abstract class ICallRemoteRepository {
  Future<List<Json>> fetchCalls(FetchParams params);
}

class CallNpxRepository implements ICallRemoteRepository {
  const CallNpxRepository(IHttpClient client) : _client = client;
  final IHttpClient _client;

  static const _host = 'app.npxtech.com.br';

  @override
  Future<List<Json>> fetchCalls(FetchParams params) async {
    try {
      final config = di.get<AppConfig>();
      final queues = await config.get(
        ConfigKeys.npxMonitoredQueues,
        fallback: 'Proabakus_Suporte',
      );

      final request = HttpRequest(
        authority: _host,
        url: 'api/v2/callcenter/report',
        headers: {
          'Content-Type': 'application/json',
          'Access-token': Env.get('NPX_API_TOKEN'),
        },
        body: NpxPayload(
          reportType: ReportType.analytic,
          dateStartedAt: params.range.start,
          dateEndingAt: params.range.end,
          queues: queues!,
          filters: params.params,
        ).toJson(),
      );
      request.debug('API request: ${request.toMap()}');

      var response = await _client.post(request);
      response.debug(
        'API response: '
        '${response.toMap()}',
      );

      if (response.statusCode != 200) {
        warn('Unexpected status code: ${response.statusCode}');

        throw BadResponseException(
          'API request failure: unsuccessful response ${response.statusCode}',
        ).error();
      }

      var data = jsonDecode(response.body);

      if (data is Json && data.containsKey('message')) {
        warn(data['message']);
        return [];
      }

      if (data is List) {
        var maps = List<Json>.from(data);
        return maps //
            .map(NpxMapper.normalize)
            .toList();
      }

      warn('Unexpected response format');
      throw BadResponseException(
        'API request failure: unexpected response body',
      ).error();
    } on BadResponseException {
      rethrow;
    } catch (e, s) {
      throw ApiException(
        'Failed to fetch calls',
        exception: e,
        stackTrace: s,
      ).error();
    }
  }
}
