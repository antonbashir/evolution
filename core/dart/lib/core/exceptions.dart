import 'dart:io';

import 'constants.dart';
import 'printer.dart';

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

void defaultErrorHandler(Error error, StackTrace stack) {
  Printer.printError(error, stack);
  exit(-1);
}

void defaultExceptionHandler(Exception exception, StackTrace stack) {
  if (exception is CoreException) {
    Printer.printException(exception, stack);
    exit(-1);
  }
  if (exception is SystemException) {
    Printer.printException(exception, stack);
    exit(-exception.code);
  }
  Printer.printException(exception, stack);
}
