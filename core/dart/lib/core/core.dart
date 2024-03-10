import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'bindings.dart';
import 'configuration.dart';
import 'constants.dart';
import 'context.dart';

class CoreModule with Module<core_module, CoreModuleConfiguration> {
  final id = coreModuleId;
  final name = coreModuleName;

  @override
  Pointer<core_module> create(CoreModuleConfiguration configuration) {
    return using((arena) => core_module_create(configuration.toNative(arena)));
  }

  @override
  CoreModuleConfiguration load(Pointer<core_module> native) {
    return CoreModuleConfiguration.fromNative(native.ref.configuration);
  }

  @override
  void destroy() => core_module_destroy(native);
}

extension ContextProviderCorExtensions on ContextProvider {
  ModuleProvider<CoreModuleConfiguration> core() => get(coreModuleId) as ModuleProvider<CoreModuleConfiguration>;
}
