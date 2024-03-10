import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'bindings.dart';
import 'configuration.dart';
import 'constants.dart';
import 'context.dart';
import 'defaults.dart';
import 'state.dart';

class CoreModule with Module<core_module, CoreModuleConfiguration, CoreModuleState> {
  final id = coreModuleId;
  final name = coreModuleName;
  final CoreModuleState state;

  CoreModule({CoreModuleState? state}) : this.state = state ?? CoreDefaults.coreState;

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
