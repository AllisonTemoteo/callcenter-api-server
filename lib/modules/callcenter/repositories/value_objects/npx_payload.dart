import 'package:server/core/utils/extensions.dart';
import 'package:server/core/utils/serializable.dart';

enum ReportType {
  synthetic('synthetic'),
  analytic('analytic');

  final String value;
  const ReportType(this.value);
}

class NpxPayload extends Serializable {
  const NpxPayload({
    required this.reportType,
    required this.dateStartedAt,
    required this.dateEndingAt,
    this.queues = 'Proabakus_Suporte',
    this.filters,
  });

  final ReportType reportType;
  final String queues;
  final DateTime dateStartedAt;
  final DateTime dateEndingAt;
  final Map<String, dynamic>? filters;

  @override
  Map<String, dynamic> toMap() {
    return {
      'report_type': reportType.value,
      'queues': queues,
      'date_started_at': dateStartedAt.date,
      'date_ended_at': dateEndingAt.date,
      'time_started_at': dateStartedAt.time,
      'time_ended_at': dateEndingAt.time,

      ...?filters,
    };
  }

  @override
  String toString() {
    return '$runtimeType: ${toMap()}';
  }
}
