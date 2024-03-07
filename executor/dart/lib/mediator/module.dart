import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:core/core.dart';
import 'package:ffi/ffi.dart';
import 'package:memory/memory.dart';

import 'bindings.dart';
import 'configuration.dart';
import 'constants.dart';
import 'defaults.dart';
import 'exception.dart';

class ExecutorModule {
  final _workerClosers = <SendPort>[];
  final _workerPorts = <RawReceivePort>[];
  final _workerDestroyer = ReceivePort();

  late final Pointer<executor_scheduler> _notifier;

  static void load({String? libraryPath}) {
    CoreModule.load();
    if (libraryPath != null) {
      SystemLibrary.loadByPath(libraryPath);
      return;
    }
    SystemLibrary.loadByName(executorLibraryName, executorPackageName);
  }

  ExecutorModule({String? libraryPath, LibraryPackageMode memoryMode = LibraryPackageMode.static}) {
    load(libraryPath: libraryPath);
    MemoryModule.load(mode: memoryMode);
  }

  void initialize({ExecutorNotifierConfiguration configuration = ExecutorDefaults.notifier}) {
    _notifier = calloc<executor_scheduler>(sizeOf<executor_scheduler>());
    final result = using((Arena arena) => executor_scheduler_initialize(_notifier, configuration.toNative(arena<executor_scheduler_configuration>())));
    if (!result) {
      final error = _notifier.ref.initialization_error.cast<Utf8>().toDartString();
      calloc.free(_notifier);
      throw ExecutorException(error);
    }
  }

  Future<void> shutdown() async {
    _workerClosers.forEach((worker) => worker.send(null));
    await _workerDestroyer.take(_workerClosers.length).toList();
    _workerDestroyer.close();
    _workerPorts.forEach((port) => port.close());
    if (!executor_scheduler_shutdown(_notifier)) {
      final error = _notifier.ref.shutdown_error.cast<Utf8>().toDartString();
      calloc.free(_notifier);
      throw ExecutorException(error);
    }
  }

  SendPort executor({ExecutorConfiguration configuration = ExecutorDefaults.executor}) {
    final port = RawReceivePort((ports) async {
      SendPort toWorker = ports[0];
      _workerClosers.add(ports[1]);
      final executorPointer = calloc<executor>(sizeOf<executor>());
      if (executorPointer == nullptr) throw ExecutorException(ExecutorErrors.executorMemoryError);
      final result = using((arena) => executor_initialize(executorPointer, configuration.toNative(arena<executor_configuration>()), _notifier, _workerClosers.length));
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
