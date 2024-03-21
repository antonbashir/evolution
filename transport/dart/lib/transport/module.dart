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
    final nativeTransport = using((arena) => transport_initialize(configuration.toNative(arena))).systemCheck();
    return Transport(nativeTransport, context().executor());
  }
}

class TransportModule extends Module<transport_module, TransportModuleConfiguration, TransportModuleState> {
  final name = transportModuleName;
  final state = TransportModuleState();
  final dependencies = {coreModuleName, memoryModuleName, executorModuleName};

  TransportModule({TransportModuleConfiguration configuration = TransportDefaults.module})
      : super(
          configuration,
          SystemLibrary.loadByName(transportLibraryName, transportModuleName),
          using((arena) => transport_module_create(configuration.toNative(arena))),
        );

  @entry
  TransportModule._load(int address)
      : super.load(
          address,
          (native) => SystemLibrary.load(native.ref.library),
          (native) => TransportModuleConfiguration.fromNative(native.ref.configuration),
        );
}

extension ContextProviderTransportExtensions on ContextProvider {
  ModuleProvider<transport_module, TransportModuleConfiguration, TransportModuleState> transportModule() => get(transportModuleName);

  Transport transport({TransportConfiguration configuration = TransportDefaults.transport}) => transportModule().state.transport(configuration: configuration);
}
