import 'package:server/core/utils/serializable.dart';
import 'package:server/core/utils/typedefs.dart';

class ActivityAgent extends Serializable {
  ActivityAgent({required this.code, required this.name});
  final String code;
  final String name;

  @override
  Map<String, dynamic> toMap() {
    return {'agent_code': code, 'operator_name': name};
  }

  static ActivityAgent fromMap(Json map) {
    return ActivityAgent(code: map['agent_code'], name: map['agent_name']);
  }
}
