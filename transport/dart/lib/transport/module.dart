import 'dart:async';
import 'dart:ffi';

import 'package:ffi/ffi.dart';

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

  TransportModule(this.state);

  @override
  Pointer<transport_module> create(TransportModuleConfiguration configuration) => using((arena) => transport_module_create(configuration.toNative(arena)));

  @override
  void initialize() {}

  @override
  Future<void> shutdown({Duration? gracefulTimeout}) async {}

  @override
  TransportModuleConfiguration load(Pointer<transport_module> native) => TransportModuleConfiguration.fromNative(native.ref.configuration);
}

extension ContextProviderTransportExtensions on ContextProvider {
  ModuleProvider<transport_module, TransportModuleConfiguration, TransportModuleState> transportModule() => get(transportModuleName);

  Transport transport({TransportConfiguration configuration = TransportDefaults.transport}) => transportModule().state.transport(configuration: configuration);
}
