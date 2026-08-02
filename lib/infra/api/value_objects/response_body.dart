import 'package:server/core/utils/serializable.dart';
import 'package:server/core/utils/typedefs.dart';

class ResponseBody extends Serializable {
  const ResponseBody.ok({required this.message, this.content})
    : ok = true,
      errors = null;

  const ResponseBody.error({required this.message, required this.errors})
    : ok = false,
      content = null;

  final bool ok;
  final String message;
  final Json? content;
  final Json? errors;

  @override
  Map<String, dynamic> toMap() {
    return {
      'ok': '$ok',
      'message': message,
      if (content != null) 'content': content,
      if (errors != null) 'errors': errors,
    };
  }
}
