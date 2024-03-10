import 'constants.dart';
import 'context.dart';
import 'module.dart';

class Printer {
  const Printer._();

  static void print(String message) {
    if (!context().core().configuration.silent) context().core().state.printer(message);
  }

  static void printError(Error error, StackTrace stack) {
    final configuration = context().core().configuration;
    if (!configuration.silent && configuration.printLevel >= printLevelError) print("[${DateTime.now()}] (error): ${error.toString()}\nError stack:\n${error.stackTrace}Zoned stack:\n$stack");
  }

  static void printException(Exception exception, StackTrace stack) {
    final configuration = context().core().configuration;
    if (!configuration.silent && configuration.printLevel >= printLevelError) print("[${DateTime.now()}] (exception): ${exception.toString()}\n$stack");
  }
}

void trace(String message) {
  final configuration = context().core().configuration;
  if (!configuration.silent && configuration.printLevel >= printLevelTrace) Printer.print("[${DateTime.now()}] (trace): $message");
}

void information(String message) {
  final configuration = context().core().configuration;
  if (!configuration.silent && configuration.printLevel >= printLevelInformation) Printer.print("[${DateTime.now()}] (information): $message");
}

void warning(String message) {
  final configuration = context().core().configuration;
  if (!configuration.silent && configuration.printLevel >= printLevelWarning) Printer.print("[${DateTime.now()}] (warning): $message");
}
