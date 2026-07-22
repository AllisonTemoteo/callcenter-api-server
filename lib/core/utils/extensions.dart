import 'package:server/core/utils/logger.dart';

extension DateTimeExtensions on DateTime {
  String get iso => toIso8601String();
  String get date => iso.split('T').first;
  String get time => iso.split('T').last;
}

extension StringExtensions on String {
  DateTime get toLocalDateTime => DateTime.parse(this).toLocal();
}

extension LogHelper<T> on T {
  T debug([String? message]) {
    AppLogger.instance.d(message ?? toString());
    return this;
  }

  T warn([String? message]) {
    AppLogger.instance.w(message ?? toString());
    return this;
  }

  T error([String? message]) {
    AppLogger.instance.e(message ?? toString());
    return this;
  }
}
