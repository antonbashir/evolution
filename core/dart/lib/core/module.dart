import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import '../core.dart';
import 'bindings.dart';
import 'configuration.dart';
import 'printer.dart';

void _defaultErrorHandler(Error error, StackTrace stack) {
  printError(error, stack);
  exit(-1);
}

void _defaultExceptionHandler(Exception exception, StackTrace stack) {
  if (exception is ModuleException) {
    Printer.printError(exception.toString());
    if (exception.event.level == EventLevel.panic) {
      exit(exception.event.has(CoreEventFields.code) ? exception.event.getInteger(CoreEventFields.code) : -1);
    }
    return;
  }
  printException(exception, stack);
}

typedef PrinterFunction = void Function(String message);
typedef ErrorHandlerFunction = void Function(Error error, StackTrace stackTrace);
typedef ExceptionHandlerFunction = void Function(Exception exception, StackTrace stackTrace);

class CoreModuleState implements ModuleState {
  final PrinterFunction outPrinter;
  final PrinterFunction errorPrinter;
  final ErrorHandlerFunction errorHandler;
  final ExceptionHandlerFunction exceptionHandler;

  CoreModuleState({
    required this.outPrinter,
    required this.errorPrinter,
    required this.errorHandler,
    required this.exceptionHandler,
  });
}

class CoreModule extends Module<core_module, CoreModuleConfiguration, CoreModuleState> {
  final name = coreModuleName;
  final state = CoreModuleState(
    outPrinter: stdout.writeln,
    errorPrinter: stderr.writeln,
    errorHandler: _defaultErrorHandler,
    exceptionHandler: _defaultExceptionHandler,
  );

  CoreModule({CoreModuleConfiguration configuration = CoreDefaults.module}) : super(configuration, SystemLibrary.loadCore(), using((arena) => core_module_create(configuration.toNative(arena)))) {
    system_library_put(library.handle);
  }

  @entry
  CoreModule._load(int address) : super.load(address, (native) => SystemLibrary.load(native.ref.library), (native) => CoreModuleConfiguration.fromNative(native.ref.configuration));

  @override
  void destroy() => core_module_destroy(native);
}

extension CoreContextExtensions on ContextProvider {
  ModuleProvider<core_module, CoreModuleConfiguration, CoreModuleState> coreModule() => get(coreModuleName);
}
