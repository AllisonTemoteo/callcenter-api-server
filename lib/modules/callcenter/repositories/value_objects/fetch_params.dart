import 'package:server/core/utils/extensions.dart';
import 'package:server/core/utils/value_objects.dart';

class FetchParams {
  const FetchParams({required this.range, this.params});
  final DateRange range;
  final Map<String, dynamic>? params;

  Map<String, dynamic> toMap() {
    return {
      'range': {'startingAt': range.start.iso, 'endingAt': range.end.iso},
      ...?params,
    };
  }
}
