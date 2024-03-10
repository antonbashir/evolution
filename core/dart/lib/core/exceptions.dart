import 'constants.dart';

class CoreException implements Exception {
  final String message;

  const CoreException(this.message);

  @override
  String toString() => "[$coreModuleName]: $message";
}

class SystemException implements Exception {
  final int code;
  final String message;

  SystemException(this.code) : message = SystemErrors.of(code).message;

  @override
  String toString() => "[$printSystemExceptionTag]: ($code) $dash $message";
}
