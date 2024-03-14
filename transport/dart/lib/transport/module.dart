import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:transport/transport/defaults.dart';

import 'bindings.dart' as bindings;
import 'bindings.dart';
import 'configuration.dart';
import 'constants.dart';
import 'exception.dart';

class TransportModule {
  final _transportClosers = <SendPort>[];
  final _transportPorts = <RawReceivePort>[];
  final _transportDestroyer = ReceivePort();
  final _executor = ExecutorModule();

  void initialize() {
    _executor.initialize();
  }

  Future<void> shutdown({Duration? gracefulTimeout}) async {
    _transportClosers.forEach((worker) => worker.send(gracefulTimeout));
    await _transportDestroyer.take(_transportClosers.length).toList();
    _transportDestroyer.close();
    _transportPorts.forEach((port) => port.close());
    await _executor.shutdown();
  }

  SendPort transport({TransportConfiguration configuration = TransportDefaults.transport}) {
    final port = RawReceivePort((ports) async {
      SendPort toTransport = ports[0];
      _transportClosers.add(ports[1]);
      final transportPointer = calloc<bindings.transport>(sizeOf<bindings.transport>());
      if (transportPointer == nullptr) throw TransportInitializationException(TransportMessages.workerMemoryError);
      final result = using(
        (arena) => bindings.transport_initialize(
          transportPointer,
          configuration.toNative(arena<transport_configuration>(), arena),
          _transportClosers.length,
        ),
      );
      if (result < 0) {
        bindings.transport_destroy(transportPointer);
        throw TransportInitializationException(TransportMessages.workerError(result));
      }
      final workerInput = [transportPointer.address, _transportDestroyer.sendPort, _executor.spawn()];
      toTransport.send(workerInput);
    });
    _transportPorts.add(port);
    return port.sendPort;
  }
}
