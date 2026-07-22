class AppException implements Exception {
  AppException(this.message, {this.exception, this.stackTrace});
  final String message;
  final Object? exception;
  final StackTrace? stackTrace;

  @override
  String toString() {
    return 'runtimeType: $message'
        '${exception != null ? '\n$exception' : ''}'
        '${stackTrace != null ? '\n$stackTrace' : ''}';
  }
}

class ApiException extends AppException {
  ApiException(super.message, {super.exception, super.stackTrace});
}

class DataParsingException extends AppException {
  DataParsingException(super.message, {super.exception, super.stackTrace});
}

class BadResponseException extends AppException {
  BadResponseException(super.message, {super.exception, super.stackTrace});
}

class InvalidCredentialsException extends AppException {
  InvalidCredentialsException(
    super.message, {
    super.exception,
    super.stackTrace,
  });
}
