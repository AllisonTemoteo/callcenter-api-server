import 'dart:convert';

import 'package:server/core/utils/serializable.dart';

class HttpRequest extends Serializable {
  HttpRequest({
    required this.authority,
    required this.url,
    required this.headers,
    required this.body,
  });

  final String authority;
  final String url;
  final Map<String, String> headers;
  final String body;

  @override
  Map<String, dynamic> toMap() {
    return {
      'authority': authority,
      'url': url,
      'headers': {...headers, 'Access-token': 'PRIVATE'},
      'body': jsonDecode(body),
    };
  }
}

class HttpResponse extends Serializable {
  const HttpResponse({required this.statusCode, required this.body});
  final int statusCode;
  final String body;

  @override
  Map<String, dynamic> toMap() {
    return {'statusCode': statusCode, 'body': jsonDecode(body)};
  }
}
