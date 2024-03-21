import 'constants.dart';

class CoreModuleError extends Error {
  final String message;

  CoreModuleError(this.message);

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
