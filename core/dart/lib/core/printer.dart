import 'dart:isolate';

import 'constants.dart';
import 'context.dart';
import 'event.dart';
import 'module.dart';

class Printer {
  const Printer._();

  static void printOut(dynamic message) {
    if (!context().coreModule().configuration.silent) context().coreModule().state.outPrinter(message?.toString() ?? empty);
  }

  static void printError(dynamic message) {
    if (!context().coreModule().configuration.silent) context().coreModule().state.errorPrinter(message?.toString() ?? empty);
  }
}

void printEvent(Event event) {
  final configuration = context().coreModule().configuration;
  if (!configuration.silent && configuration.printLevel >= event.level) {
    if (event.level >= eventLevelError) {
      context().coreModule().state.errorPrinter(event.format());
      return;
    }
    context().coreModule().state.outPrinter(event.format());
  }
}

void printError(Error error, StackTrace stack) {
  final configuration = context().coreModule().configuration;
  if (!configuration.silent && configuration.printLevel >= eventLevelError) {
    final prefix = "[${DateTime.now()}] {${Isolate.current.debugName}} $eventLevelErrorLabel";
    final message = "$prefix: ${error.toString()}$newLine$errorStackPart$newLine${error.stackTrace}$newLine$catchStackPart$newLine$stack";
    Printer.printError(message);
  }
}

void printException(Exception exception, StackTrace stack) {
  final configuration = context().coreModule().configuration;
  if (!configuration.silent && configuration.printLevel >= eventLevelError) {
    final prefix = "[${DateTime.now()}] {${Isolate.current.debugName}} $eventLevelErrorLabel";
    Printer.printError("$prefix: ${exception.toString()}$newLine$stack$newLine");
  }
}
