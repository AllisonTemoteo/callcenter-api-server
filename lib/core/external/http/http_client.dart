import 'package:http/http.dart';
import 'package:server/core/external/http/value_objects/http.dart';

abstract class IHttpClient {
  Future<HttpResponse> post(HttpRequest request);
}

class HttpClient implements IHttpClient {
  const HttpClient(Client client) : _client = client;
  final Client _client;

  @override
  Future<HttpResponse> post(HttpRequest request) async {
    final url = Uri.https(request.authority, request.url);
    var response = await _client.post(
      url,
      body: request.body,
      headers: request.headers,
    );

    return HttpResponse(statusCode: response.statusCode, body: response.body);
  }
}
