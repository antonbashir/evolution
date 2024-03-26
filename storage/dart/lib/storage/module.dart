import 'dart:async';
import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'bindings.dart';
import 'configuration.dart';
import 'constants.dart';
import 'defaults.dart';
import 'exception.dart';
import 'executor.dart';

class StorageModuleState implements ModuleState {
  late final _box = calloc<storage_box>(sizeOf<storage_box>());
  late final Storage storage;

  Future<void> _boot() async {
    if (initialized()) return;
    storage = Storage(_box, context().broker());
    final configuration = context().storageModule().configuration;
    if (!using((Arena allocator) => storage_initialize(_box))) {
      throw StorageLauncherException(storage_initialization_error().cast<Utf8>().toDartString());
    }
    if (!initialized()) {
      throw StorageLauncherException(storage_initialization_error().cast<Utf8>().toDartString());
    }
    await storage.initialize();
    await storage.boot(configuration.bootConfiguration.launchConfiguration);
  }

  Future<void> _recreate() async {
    storage = Storage(_box, context().broker());
    await storage.initialize();
  }

  Future<void> _destroy() async {
    await storage.destroy();
  }

  Future<void> _shutdown() async {
    storage.stop();
    if (!storage_shutdown()) {
      throw StorageLauncherException(storage_shutdown_error().cast<Utf8>().toDartString());
    }
    await storage.destroy();
    calloc.free(_box.cast());
  }

  bool initialized() => storage_initialized();

  bool mutable() => storage_is_read_only() == 0;

  bool immutable() => storage_is_read_only() == 1;

  Future<void> waitInitialized() => Future.doWhile(() => Future.delayed(awaitStateDuration).then((value) => !initialized()));

  Future<void> waitShutdown() => Future.doWhile(() => Future.delayed(awaitStateDuration).then((value) => initialized()));

  Future<void> waitImmutable() => Future.doWhile(() => Future.delayed(awaitStateDuration).then((value) => !immutable()));

  Future<void> waitMutable() => Future.doWhile(() => Future.delayed(awaitStateDuration).then((value) => !mutable()));
}

class StorageModule extends Module<storage_module, StorageModuleConfiguration, StorageModuleState> {
  final name = storageModuleName;
  final dependencies = {executorModuleName, memoryModuleName, coreModuleName};
  final state = StorageModuleState();
  final _libraries = <SystemLibrary>[];

  StorageModule({StorageModuleConfiguration? configuration})
      : super(
          configuration ?? StorageDefaults.module,
          SystemLibrary.loadByName(storageLibraryName, storageModuleName),
          using((arena) => storage_module_create((configuration ?? StorageDefaults.module).toNative(arena))),
        );

  @entry
  StorageModule._load(int address)
      : super.load(
          address,
          (native) => SystemLibrary.load(native.ref.library),
          (native) => StorageModuleConfiguration.fromNative(native.ref.configuration),
        );

  @override
  FutureOr<void> initialize() {
    configuration.modules.forEach((module) => _libraries.add(SystemLibrary.loadByPath(module, storageModuleName)));
    return state._boot();
  }

  @override
  FutureOr<void> fork() async {
    configuration.modules.forEach((module) => _libraries.add(SystemLibrary.loadByPath(module, storageModuleName)));
    await state._recreate();
  }

  @override
  FutureOr<void> unfork() async {
    await state._destroy();
  }

  @override
  FutureOr<void> reload() async {
    final reloaded = _libraries.toList().map((library) => library.reload());
    _libraries.clear();
    _libraries.addAll(reloaded);
  }

  @override
  Future<void> shutdown() async {
    await state._shutdown();
    _libraries.forEach((library) => library.unload());
  }
}

extension StorageContextExtensions on ContextProvider {
  ModuleProvider<storage_module, StorageModuleConfiguration, StorageModuleState> storageModule() => get(storageModuleName);
  Storage storage({ExecutorConfiguration configuration = ExecutorDefaults.executor}) => storageModule().state.storage;
}
