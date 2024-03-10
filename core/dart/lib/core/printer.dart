import 'context.dart';
import 'module.dart';

class Printer {
  const Printer._();

  static void print(String message) {
    context().core().state.printer(message);
  }

  static void printError(Error error, StackTrace stack) {
    context().core().state.errorPrinter(error, stack);
  }

  static void printException(Exception exception, StackTrace stack) {
    context().core().state.exceptionPrinter(exception, stack);
  }
}
