import 'dart:async';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:memory/memory/constants.dart';

import 'bindings.dart';
import 'configuration.dart';
import 'constants.dart';
import 'defaults.dart';
import 'transport.dart';

class TransportModuleState implements ModuleState {
  final _transports = <Transport>[];

  Transport transport({TransportConfiguration configuration = TransportDefaults.transport}) {
    final native = using((arena) => transport_initialize(configuration.toNative(arena))).systemCheck();
    final transport = Transport(native, context().executor(), _transports.remove);
    _transports.add(transport);
    return transport;
  }

  Future<void> _destroy({Duration? gracefulTimeout}) => Future.wait(_transports.map((transport) => transport.shutdown(gracefulTimeout: gracefulTimeout)));
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

  @override
  FutureOr<void> shutdown() async {
    await state._destroy();
  }
}

extension ContextProviderTransportExtensions on ContextProvider {
  ModuleProvider<transport_module, TransportModuleConfiguration, TransportModuleState> transportModule() => get(transportModuleName);

  Transport transport({TransportConfiguration configuration = TransportDefaults.transport}) => transportModule().state.transport(configuration: configuration);
}
