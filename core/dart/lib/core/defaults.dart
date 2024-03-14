import 'dart:io';

import 'configuration.dart';
import 'constants.dart';
import 'exceptions.dart';
import 'printer.dart';
import 'state.dart';

void _defaultErrorHandler(Error error, StackTrace stack) {
  Printer.printError(error, stack);
  exit(-1);
}

void _defaultExceptionHandler(Exception exception, StackTrace stack) {
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

class CoreDefaults {
  CoreDefaults._();

  static const CoreModuleConfiguration coreConfiguration = CoreModuleConfiguration(
    printLevel: printLevelInformation,
    silent: false,
  );

  static final CoreModuleState coreState = CoreModuleState(
    printer: print,
    errorHandler: _defaultErrorHandler,
    exceptionHandler: _defaultExceptionHandler,
  );
}
