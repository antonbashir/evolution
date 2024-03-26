import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import 'bindings.dart';
import 'configuration.dart';
import 'constants.dart';
import 'defaults.dart';
import 'exception.dart';
import 'executor.dart';

class StorageModuleState implements ModuleState {
  final Map<String, SystemLibrary> _loadedModulesByName = {};
  final Map<String, SystemLibrary> _loadedModulesByPath = {};
  late final _box = calloc<storage_box>(sizeOf<storage_box>());
  late final Storage storage;

  StreamSubscription<ProcessSignal>? _reloadListener = null;

  void _create() {
    storage = Storage(_box, context().broker());
  }

  Future<void> _destroy() async {
    await storage.destroy();
  }

  Future<void> _boot() async {
    if (initialized()) return;
    _create();
    final configuration = context().storageModule().configuration;
    if (!using((Arena allocator) => storage_initialize(_box))) {
      throw StorageLauncherException(storage_initialization_error().cast<Utf8>().toDartString());
    }
    if (!initialized()) {
      throw StorageLauncherException(storage_initialization_error().cast<Utf8>().toDartString());
    }
    await storage.boot(configuration.bootConfiguration.launchConfiguration);
    if (configuration.activateReloader) _reloadListener = ProcessSignal.sighup.watch().listen((event) async => await reloadModules());
  }

  Future<void> _shutdown() async {
    _reloadListener?.cancel();
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

  SystemLibrary loadModuleByPath(String libraryPath) {
    if (_loadedModulesByPath.containsKey(libraryPath)) return _loadedModulesByPath[libraryPath]!;
    final module = SystemLibrary.loadByPath(libraryPath, storageModuleName);
    _loadedModulesByName[libraryPath] = module;
    return module;
  }

  SystemLibrary loadModuleByName(String libraryName) {
    if (_loadedModulesByName.containsKey(libraryName)) return _loadedModulesByName[libraryName]!;
    final module = SystemLibrary.loadByName(libraryName, storageModuleName);
    _loadedModulesByName[libraryName] = module;
    return module;
  }

  Future<void> reloadModules() async {
    _loadedModulesByName.entries.toList().forEach((entry) => _loadedModulesByName[entry.key] = entry.value.reload());
    _loadedModulesByPath.entries.toList().forEach((entry) => _loadedModulesByPath[entry.key] = entry.value.reload());
    await storage.call(LuaExpressions.reload);
  }
}

class StorageModule extends Module<storage_module, StorageModuleConfiguration, StorageModuleState> {
  final name = storageModuleName;
  final dependencies = {executorModuleName, memoryModuleName, coreModuleName};
  final state = StorageModuleState();

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
  FutureOr<void> initialize() => state._boot();

  @override
  FutureOr<void> fork() {
    state._create();
  }

  @override
  FutureOr<void> unfork() async {
    await state._destroy();
  }

  @override
  Future<void> shutdown() => state._shutdown();
}

extension StorageContextExtensions on ContextProvider {
  ModuleProvider<storage_module, StorageModuleConfiguration, StorageModuleState> storageModule() => get(storageModuleName);
  Storage storage({ExecutorConfiguration configuration = ExecutorDefaults.executor}) => storageModule().state.storage;
}
