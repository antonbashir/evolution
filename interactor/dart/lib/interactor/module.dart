import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:core/core.dart';
import 'package:ffi/ffi.dart';

import 'bindings.dart';
import 'configuration.dart';
import 'constants.dart';
import 'defaults.dart';
import 'exception.dart';

class InteractorModule {
  final _workerClosers = <SendPort>[];
  final _workerPorts = <RawReceivePort>[];
  final _workerDestroyer = ReceivePort();

  static void load({String? libraryPath}) {
    CoreModule.load();
    if (libraryPath != null) {
      SystemLibrary.loadByPath(libraryPath);
      return;
    }
    SystemLibrary.loadByName(interactorLibraryName, interactorPackageName);
  }

  InteractorModule({String? libraryPath}) {
    load(libraryPath: libraryPath);
  }

  Future<void> shutdown() async {
    _workerClosers.forEach((worker) => worker.send(null));
    await _workerDestroyer.take(_workerClosers.length).toList();
    _workerDestroyer.close();
    _workerPorts.forEach((port) => port.close());
  }

  SendPort interactor({InteractorModuleConfiguration configuration = InteractorDefaults.interactor}) {
    final port = RawReceivePort((ports) async {
      SendPort toWorker = ports[0];
      _workerClosers.add(ports[1]);
      final interactorPointer = calloc<interactor_dart>(sizeOf<interactor_dart>());
      if (interactorPointer == nullptr) throw InteractorException(InteractorErrors.workerMemoryError);
      final result = using((arena) => interactor_dart_initialize(interactorPointer, configuration.toNative(arena<interactor_module_dart_configuration>()), _workerClosers.length));
      if (result < 0) {
        interactor_dart_destroy(interactorPointer);
        calloc.free(interactorPointer);
        throw InteractorException(InteractorErrors.workerError(result));
      }
      final workerInput = [interactorPointer.address, _workerDestroyer.sendPort, result];
      toWorker.send(workerInput);
    });
    _workerPorts.add(port);
    return port.sendPort;
  }
}
