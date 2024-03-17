import 'dart:isolate';

import 'constants.dart';
import 'context.dart';
import 'module.dart';

class Printer {
  const Printer._();

  static void print(dynamic message) {
    if (!context().core().configuration.silent) context().core().state.printer(message?.toString() ?? empty);
  }

  static void printError(Error error, StackTrace stack) {
    final configuration = context().core().configuration;
    if (!configuration.silent && configuration.printLevel >= printLevelError) {
      print(
        "[${DateTime.now()}] {${Isolate.current.debugName}} $printLevelErrorLabel: ${error.toString()}$newLine$printErrorStackPart$newLine${error.stackTrace}$newLine$printCatchStackPart$newLine$stack",
      );
    }
  }

  static void printException(Exception exception, StackTrace stack) {
    final configuration = context().core().configuration;
    if (!configuration.silent && configuration.printLevel >= printLevelError) {
      print("[${DateTime.now()}] {${Isolate.current.debugName}} $printExceptionLabel: ${exception.toString()}$newLine$stack\n");
    }
  }
}

void trace(String message) {
  final configuration = context().core().configuration;
  if (!configuration.silent && configuration.printLevel >= printLevelTrace) {
    Printer.print("[${DateTime.now()}] {${Isolate.current.debugName}} $printLevelTraceLabel: $message");
  }
}

void information(String message) {
  final configuration = context().core().configuration;
  if (!configuration.silent && configuration.printLevel >= printLevelInformation) {
    Printer.print("[${DateTime.now()}] {${Isolate.current.debugName}} $printLevelInformationLabel: $message");
  }
}

void warning(String message) {
  final configuration = context().core().configuration;
  if (!configuration.silent && configuration.printLevel >= printLevelWarning) {
    Printer.print("[${DateTime.now()}] {${Isolate.current.debugName}} $printLevelWarningLabel: $message");
  }
}
