import 'constants.dart';

class CoreError extends Error {
  final String message;

  CoreError(this.message);

  @override
  String toString() => "[$coreModuleName] $message";
}

class SystemError {
  final int code;
  final String message;

  SystemError(this.code, this.message);

  @override
  String toString() => message;
}
