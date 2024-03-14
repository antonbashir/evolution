import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import 'bindings.dart';
import 'configuration.dart';
import 'constants.dart';
import 'context.dart';
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

class CoreModule with Module<core_module, CoreModuleConfiguration, CoreModuleState> {
  final id = coreModuleId;
  final name = coreModuleName;
  final CoreModuleState state;

  CoreModule({CoreModuleState? state})
      : this.state = state ??
            CoreModuleState(
              printer: print,
              errorHandler: _defaultErrorHandler,
              exceptionHandler: _defaultExceptionHandler,
            );

  @override
  Pointer<core_module> create(CoreModuleConfiguration configuration) => using((arena) => core_module_create(configuration.toNative(arena)));

  @override
  CoreModuleConfiguration load(Pointer<core_module> native) => CoreModuleConfiguration.fromNative(native.ref.configuration);

  @override
  void destroy() => core_module_destroy(native);
}

extension ContextProviderCoreExtensions on ContextProvider {
  ModuleProvider<core_module, CoreModuleConfiguration, CoreModuleState> core() => get(coreModuleId);
}
