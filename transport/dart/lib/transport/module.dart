import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:memory/memory/constants.dart';
import 'package:transport/transport.dart';

import 'bindings.dart';
import 'constants.dart';

class TransportModuleState implements ModuleState {
  Transport transport({TransportConfiguration configuration = TransportDefaults.transport}) {
    final nativeTransport = using((arena) => transport_initialize(configuration.toNative(arena))).check();
    return Transport(nativeTransport, context().executor());
  }
}

class TransportModule with Module<transport_module, TransportModuleConfiguration, TransportModuleState> {
  final name = transportModuleName;
  final state = TransportModuleState();
  final dependencies = {coreModuleName, memoryModuleName, executorModuleName};
  final loader = NativeCallable<ModuleLoader<transport_module>>.listener(_load);
  static void _load(Pointer<transport_module> native) => TransportModule().load(TransportModuleConfiguration.fromNative(native.ref.configuration));

  @override
  Pointer<transport_module> create(TransportModuleConfiguration configuration) {
    SystemLibrary.loadByName(transportLibraryName, transportPackageName);
    return using((arena) => transport_module_create(configuration.toNative(arena)));
  }
}

extension ContextProviderTransportExtensions on ContextProvider {
  ModuleProvider<transport_module, TransportModuleConfiguration, TransportModuleState> transportModule() => get(transportModuleName);

  Transport transport({TransportConfiguration configuration = TransportDefaults.transport}) => transportModule().state.transport(configuration: configuration);
}
