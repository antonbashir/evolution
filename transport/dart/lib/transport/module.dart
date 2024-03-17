import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:memory/memory/constants.dart';

import 'bindings.dart';
import 'configuration.dart';
import 'constants.dart';
import 'defaults.dart';
import 'transport.dart';

class TransportModuleState implements ModuleState {
  Transport transport({TransportConfiguration configuration = TransportDefaults.transport}) {
    final nativeTransport = using((arena) => transport_initialize(configuration.toNative(arena))).check();
    return Transport(nativeTransport, context().executor());
  }
}

class TransportModule with Module<transport_module, TransportModuleConfiguration, TransportModuleState> {
  final String name = transportModuleName;
  final TransportModuleState state;
  final dependencies = {coreModuleName, memoryModuleName, executorModuleName};

  TransportModule({TransportModuleState? state}) : state = state ?? TransportModuleState();

  @override
  Pointer<transport_module> create(TransportModuleConfiguration configuration) => using((arena) => transport_module_create(configuration.toNative(arena)));

  @override
  TransportModuleConfiguration load(Pointer<transport_module> native) => TransportModuleConfiguration.fromNative(native.ref.configuration);
}

extension ContextProviderTransportExtensions on ContextProvider {
  ModuleProvider<transport_module, TransportModuleConfiguration, TransportModuleState> transportModule() => get(transportModuleName);

  Transport transport({TransportConfiguration configuration = TransportDefaults.transport}) => transportModule().state.transport(configuration: configuration);
}
