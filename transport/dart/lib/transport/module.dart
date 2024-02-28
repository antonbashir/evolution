import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:core/core.dart';
import 'package:ffi/ffi.dart';
import 'package:interactor/interactor.dart';
import 'package:memory/memory.dart';
import 'package:transport/transport/defaults.dart';

import 'bindings.dart' as bindings;
import 'configuration.dart';
import 'constants.dart';
import 'exception.dart';

class TransportModule {
  final _transportClosers = <SendPort>[];
  final _workerPorts = <RawReceivePort>[];
  final _workerDestroyer = ReceivePort();

  TransportModule({String? libraryPath}) {
    libraryPath == null ? SystemLibrary.loadByName(transportLibraryName, transportPackageName) : SystemLibrary.loadByPath(libraryPath);
    InteractorModule.load();
  }

  Future<void> shutdown({Duration? gracefulTimeout}) async {
    _transportClosers.forEach((worker) => worker.send(gracefulTimeout));
    await _workerDestroyer.take(_transportClosers.length).toList();
    _workerDestroyer.close();
    _workerPorts.forEach((port) => port.close());
  }

  SendPort transport({TransportModuleConfiguration configuration = TransportDefaults.transport}) {
    final port = RawReceivePort((ports) async {
      SendPort toTransport = ports[0];
      _transportClosers.add(ports[1]);
      final transportPointer = calloc<bindings.transport>(sizeOf<bindings.transport>());
      if (transportPointer == nullptr) throw TransportInitializationException(TransportMessages.workerMemoryError);
      final result = using(
        (arena) => bindings.transport_initialize(
          transportPointer,
          configuration.toNative(arena<bindings.transport_module_configuration>(), arena<memory_module_configuration>()),
          _transportClosers.length,
        ),
      );
      if (result < 0) {
        bindings.transport_destroy(transportPointer);
        throw TransportInitializationException(TransportMessages.workerError(result));
      }
      final workerInput = [transportPointer.address, _workerDestroyer.sendPort];
      toTransport.send(workerInput);
    });
    _workerPorts.add(port);
    return port.sendPort;
  }
}
