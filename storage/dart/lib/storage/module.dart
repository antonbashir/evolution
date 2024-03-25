import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:memory/memory/constants.dart';

import 'bindings.dart';
import 'configuration.dart';
import 'constants.dart';
import 'defaults.dart';
import 'exception.dart';
import 'executor.dart';
import 'script.dart';

class StorageModuleState implements ModuleState {
  final SystemLibrary _library;
  final Map<String, SystemLibrary> _loadedModulesByName = {};
  final Map<String, SystemLibrary> _loadedModulesByPath = {};
  late final _box = calloc<storage_box>(sizeOf<storage_box>());
  late final Storage storage;

  late bool _hasStorageLuaModule;
  StreamSubscription<ProcessSignal>? _reloadListener = null;

  StorageModuleState(this._library);

  void _create() {
    storage = Storage(_box, context().broker());
  }

  Future<void> _destroy() async {
    await storage.destroy();
  }

  Future<void> _boot(StorageBootstrapScript script, StorageExecutorConfiguration executorConfiguration, {StorageBootConfiguration? bootConfiguration, activateReloader = false}) async {
    if (initialized()) return;
    _create();
    _hasStorageLuaModule = script.hasStorageLuaModule;
    if (!using((Arena allocator) => storage_initialize(executorConfiguration.native(_library.path, script.write(), allocator), _box))) {
      throw StorageLauncherException(storage_initialization_error().cast<Utf8>().toDartString());
    }
    if (!initialized()) {
      throw StorageLauncherException(storage_initialization_error().cast<Utf8>().toDartString());
    }
    if (_hasStorageLuaModule && bootConfiguration != null) {
      await storage.boot(bootConfiguration);
    }
    if (activateReloader) _reloadListener = ProcessSignal.sighup.watch().listen((event) async => await reload());
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

  Future<void> reload() async {
    _loadedModulesByName.entries.toList().forEach((entry) => _loadedModulesByName[entry.key] = entry.value.reload());
    _loadedModulesByPath.entries.toList().forEach((entry) => _loadedModulesByPath[entry.key] = entry.value.reload());
    if (_hasStorageLuaModule) await storage.call(LuaExpressions.reload);
  }
}

class StorageModule extends Module<storage_module, StorageModuleConfiguration, StorageModuleState> {
  final name = storageModuleName;
  final dependencies = {executorModuleName, memoryModuleName, coreModuleName};
  late final state = StorageModuleState(library);

  StorageModule({StorageModuleConfiguration configuration = StorageDefaults.module})
      : super(
          configuration,
          SystemLibrary.loadByName(storageLibraryName, storageModuleName),
          using((arena) => storage_module_create(configuration.toNative(arena))),
        );

  @entry
  StorageModule._load(int address)
      : super.load(
          address,
          (native) => SystemLibrary.load(native.ref.library),
          (native) => StorageModuleConfiguration.fromNative(native.ref.configuration),
        );

  @override
  FutureOr<void> initialize() => state._boot(
        configuration.script,
        configuration.executorConfiguration,
        bootConfiguration: configuration.bootConfiguration,
        activateReloader: configuration.activateReloader,
      );

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
