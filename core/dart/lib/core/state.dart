import 'context.dart';

typedef Printer = void Function(String message);
typedef ErrorPrinter = void Function(Error error, StackTrace stack);
typedef ExceptionPrinter = void Function(Exception exception, StackTrace stack);

class CoreModuleState implements ModuleState {
  final Printer printer;
  final ErrorPrinter errorPrinter;
  final ExceptionPrinter exceptionPrinter;

  CoreModuleState({
    required this.printer,
    required this.errorPrinter,
    required this.exceptionPrinter,
  });
}
