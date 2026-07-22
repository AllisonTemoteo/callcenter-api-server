import 'package:logger/logger.dart';
import 'package:intl/intl.dart';

class AppLogPrinter extends LogPrinter {
  final _dateFormat = DateFormat('dd-MM-yyyy HH:mm:ss');

  @override
  List<String> log(LogEvent event) {
    final timestamp = _dateFormat.format(DateTime.now());
    final level = _levelText(event.level);
    final color = _levelColor(event.level);
    final reset = '\x1B[0m';
    final message = event.message.toString();
    final logLine =
        '$color[$timestamp] '
        '[$level] '
        '$message$reset';

    final output = <String>[logLine];

    if (event.error != null) {
      output.add(
        '$color'
        'Error: ${event.error}'
        '$reset',
      );
    }

    if (event.stackTrace != null) {
      output.add(
        '$color'
        '${event.stackTrace}'
        '$reset',
      );
    }

    return output;
  }

  String _levelText(Level level) {
    return switch (level) {
      Level.trace => 'TRACE',
      Level.debug => 'DEBUG',
      Level.info => 'INFO',
      Level.warning => 'WARN',
      Level.error => 'ERROR',
      Level.fatal => 'FATAL',
      _ => 'UNKNOWN',
    };
  }

  String _levelColor(Level level) {
    return switch (level) {
      Level.trace => '\x1B[37m', // branco
      Level.debug => '\x1B[36m', // cyan
      Level.info => '\x1B[32m', // verde
      Level.warning => '\x1B[33m', // amarelo
      Level.error => '\x1B[31m', // vermelho
      Level.fatal => '\x1B[35m', // magenta
      _ => '\x1B[0m',
    };
  }
}

final class AppLogger {
  AppLogger._();
  static final Logger instance = Logger(printer: AppLogPrinter());

  static void debug([String? message]) {
    instance.d(message);
  }

  static void warn([String? message]) {
    instance.w(message);
  }

  static void error([String? message]) {
    instance.e(message);
  }
}
