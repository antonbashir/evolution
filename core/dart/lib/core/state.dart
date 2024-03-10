import 'context.dart';

typedef PrinterFunction = void Function(String message);
typedef ErrorHandlerFunction = void Function(Error error, StackTrace stackTrace);
typedef ExceptionHandlerFunction = void Function(Exception exception, StackTrace stackTrace);

class CoreModuleState implements ModuleState {
  final PrinterFunction printer;
  final ErrorHandlerFunction errorHandler;
  final ExceptionHandlerFunction exceptionHandler;

  CoreModuleState({
    required this.printer,
    required this.errorHandler,
    required this.exceptionHandler,
  });
}
