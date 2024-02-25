import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:math';

import 'package:core/core.dart';
import 'package:ffi/ffi.dart';
import 'package:interactor/interactor.dart';

import 'bindings.dart';
import 'configuration.dart';
import 'constants.dart';
import 'exception.dart';

class TransportModule {
  final _workerClosers = <SendPort>[];
  final _workerPorts = <RawReceivePort>[];
  final _workerDestroyer = ReceivePort();

  TransportModule({String? libraryPath}) {
    libraryPath == null ? SystemLibrary.loadByName(transportLibraryName, transportPackageName) : SystemLibrary.loadByPath(libraryPath);
    InteractorModule.load();
  }

  Future<void> shutdown({Duration? gracefulTimeout}) async {
    _workerClosers.forEach((worker) => worker.send(gracefulTimeout));
    await _workerDestroyer.take(_workerClosers.length).toList();
    _workerDestroyer.close();
    _workerPorts.forEach((port) => port.close());
  }

  SendPort worker(TransportWorkerConfiguration configuration) {
    final port = RawReceivePort((ports) async {
      SendPort toWorker = ports[0];
      _workerClosers.add(ports[1]);
      final workerPointer = calloc<transport>();
      if (workerPointer == nullptr) throw TransportInitializationException(TransportMessages.workerMemoryError);
      final result = using((arena) {
        final nativeConfiguration = arena<transport_configuration_t>();
        nativeConfiguration.ref.ring_flags = configuration.ringFlags;
        nativeConfiguration.ref.ring_size = configuration.ringSize;
        nativeConfiguration.ref.buffer_size = configuration.bufferSize;
        nativeConfiguration.ref.buffers_count = max(configuration.buffersCount, 2);
        nativeConfiguration.ref.timeout_checker_period_millis = configuration.timeoutCheckerPeriod.inMilliseconds;
        nativeConfiguration.ref.base_delay_micros = configuration.baseDelay.inMicroseconds;
        nativeConfiguration.ref.max_delay_micros = configuration.maxDelay.inMicroseconds;
        nativeConfiguration.ref.delay_randomization_factor = configuration.delayRandomizationFactor;
        nativeConfiguration.ref.cqe_peek_count = configuration.cqePeekCount;
        nativeConfiguration.ref.cqe_wait_count = configuration.cqeWaitCount;
        nativeConfiguration.ref.cqe_wait_timeout_millis = configuration.cqeWaitTimeout.inMilliseconds;
        nativeConfiguration.ref.trace = configuration.trace;
        return transport_initialize(workerPointer, nativeConfiguration, _workerClosers.length);
      });
      if (result < 0) {
        transport_destroy(workerPointer);
        throw TransportInitializationException(TransportMessages.workerError(result));
      }
      final workerInput = [workerPointer.address, _workerDestroyer.sendPort];
      toWorker.send(workerInput);
    });
    _workerPorts.add(port);
    return port.sendPort;
  }
}
