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

class MediatorModule {
  final _workerClosers = <SendPort>[];
  final _workerPorts = <RawReceivePort>[];
  final _workerDestroyer = ReceivePort();

  late final Pointer<mediator_dart_notifier> _notifier;

  static void load({String? libraryPath}) {
    CoreModule.load();
    if (libraryPath != null) {
      SystemLibrary.loadByPath(libraryPath);
      return;
    }
    SystemLibrary.loadByName(mediatorLibraryName, mediatorPackageName);
  }

  MediatorModule({String? libraryPath, LibraryPackageMode memoryMode = LibraryPackageMode.static}) {
    load(libraryPath: libraryPath);
    MemoryModule.load(mode: memoryMode);
  }

  void initialize({MediatorNotifierConfiguration configuration = MediatorDefaults.notifier}) {
    _notifier = calloc<mediator_dart_notifier>(sizeOf<mediator_dart_notifier>());
    final result = using((Arena arena) => mediator_dart_notifier_initialize(_notifier, configuration.toNative(arena<mediator_dart_notifier_configuration>())));
    if (!result) {
      final error = _notifier.ref.initialization_error.cast<Utf8>().toDartString();
      calloc.free(_notifier);
      throw MediatorException(error);
    }
  }

  Future<void> shutdown() async {
    _workerClosers.forEach((worker) => worker.send(null));
    await _workerDestroyer.take(_workerClosers.length).toList();
    _workerDestroyer.close();
    _workerPorts.forEach((port) => port.close());
    if (!mediator_dart_notifier_shutdown(_notifier)) {
      final error = _notifier.ref.shutdown_error.cast<Utf8>().toDartString();
      calloc.free(_notifier);
      throw MediatorException(error);
    }
  }

  SendPort mediator({MediatorConfiguration configuration = MediatorDefaults.mediator}) {
    final port = RawReceivePort((ports) async {
      SendPort toWorker = ports[0];
      _workerClosers.add(ports[1]);
      final mediatorPointer = calloc<mediator_dart>(sizeOf<mediator_dart>());
      if (mediatorPointer == nullptr) throw MediatorException(MediatorErrors.mediatorMemoryError);
      final result = using((arena) => mediator_dart_initialize(mediatorPointer, configuration.toNative(arena<mediator_dart_configuration>()), _notifier, _workerClosers.length));
      if (result < 0) {
        mediator_dart_destroy(mediatorPointer);
        calloc.free(mediatorPointer);
        throw MediatorException(MediatorErrors.mediatorError(result));
      }
      final workerInput = [mediatorPointer.address, _workerDestroyer.sendPort, result];
      toWorker.send(workerInput);
    });
    _workerPorts.add(port);
    return port.sendPort;
  }
}
