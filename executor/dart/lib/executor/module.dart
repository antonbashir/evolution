import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:core/core/exceptions.dart';
import 'package:ffi/ffi.dart';

import 'bindings.dart';
import 'configuration.dart';
import 'constants.dart';
import 'defaults.dart';
import 'exception.dart';

class ExecutorModule {
  final _workerClosers = <SendPort>[];
  final _workerPorts = <RawReceivePort>[];
  final _workerDestroyer = ReceivePort();
  late final Pointer<executor_scheduler> _scheduler;

  void initialize({ExecutorNotifierConfiguration configuration = ExecutorDefaults.notifier}) {
    final _scheduler = using((Arena arena) => executor_scheduler_initialize(configuration.toNative(arena<executor_scheduler_configuration>()))).check();
    if (!_scheduler.ref.initialized) {
      final error = _scheduler.ref.initialization_error.cast<Utf8>().toDartString();
      calloc.free(_scheduler);
      throw ExecutorException(error);
    }
  }

  Future<void> shutdown() async {
    _workerClosers.forEach((worker) => worker.send(null));
    await _workerDestroyer.take(_workerClosers.length).toList();
    _workerDestroyer.close();
    _workerPorts.forEach((port) => port.close());
    if (!executor_scheduler_shutdown(_scheduler)) {
      final error = _scheduler.ref.shutdown_error.cast<Utf8>().toDartString();
      calloc.free(_scheduler);
      throw ExecutorException(error);
    }
  }

  SendPort executor({ExecutorConfiguration configuration = ExecutorDefaults.executor}) {
    final port = RawReceivePort((ports) async {
      SendPort toWorker = ports[0];
      _workerClosers.add(ports[1]);
      final executorPointer = calloc<executor_instance>();
      if (executorPointer == nullptr) throw ExecutorException(ExecutorErrors.executorMemoryError);
      final result = using((arena) => executor_initialize(executorPointer, configuration.toNative(arena<executor_configuration>()), _scheduler, _workerClosers.length));
      if (result < 0) {
        executor_destroy(executorPointer);
        calloc.free(executorPointer);
        throw ExecutorException(ExecutorErrors.executorError(result));
      }
      final workerInput = [executorPointer.address, _workerDestroyer.sendPort, result];
      toWorker.send(workerInput);
    });
    _workerPorts.add(port);
    return port.sendPort;
  }
}
