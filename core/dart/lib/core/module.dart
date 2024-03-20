import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import 'bindings.dart';
import 'configuration.dart';
import 'constants.dart';
import 'context.dart';
import 'defaults.dart';
import 'exceptions.dart';
import 'library.dart';
import 'printer.dart';

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

class CoreModule extends Module<core_module, CoreModuleConfiguration, CoreModuleState> {
  final name = coreModuleName;
  final state = CoreModuleState(printer: print, errorHandler: _defaultErrorHandler, exceptionHandler: _defaultExceptionHandler);

  CoreModule({CoreModuleConfiguration configuration = CoreDefaults.module}) : super(configuration, SystemLibrary.loadCore(), using((arena) => core_module_create(configuration.toNative(arena)))) {
    system_library_put(library.handle);
  }

  @entry
  CoreModule._load(int address)
      : super.load(
          address,
          (native) => SystemLibrary.load(native.ref.library),
          (native) => CoreModuleConfiguration.fromNative(native.ref.configuration),
        );

  @override
  void destroy() => core_module_destroy(native);
}

extension ContextProviderCoreExtensions on ContextProvider {
  ModuleProvider<core_module, CoreModuleConfiguration, CoreModuleState> coreModule() => get(coreModuleName);
}
