import 'dart:async';
import 'dart:ffi';

import 'package:core/core/exceptions.dart';
import 'package:ffi/ffi.dart';

import '../memory.dart';
import 'constants.dart';
import 'defaults.dart';

class MemoryModuleState implements ModuleState {
  final MemoryConfiguration configuration;
  late final Pointer<memory_instance> instance;
  late final MemoryStaticBuffers staticBuffers;
  late final MemoryInputOutputBuffers inputOutputBuffers;
  late final MemoryStructurePools structures;
  late final MemorySmallData smallDatas;
  late final MemoryStructurePool<Double> doubles;
  late final MemoryTuples tuples;

  MemoryModuleState({this.configuration = MemoryDefaults.memory});

  void create() {
    instance = memory_create(configuration.quotaSize, configuration.preallocationSize, configuration.slabSize).check();
    staticBuffers = MemoryStaticBuffers(memory_static_buffers_create(configuration.staticBuffersCapacity, configuration.staticBufferSize).check(() => memory_destroy(instance)));
    final nativeBuffers = memory_io_buffers_create(instance).check(() => memory_destroy(instance));
    inputOutputBuffers = MemoryInputOutputBuffers(nativeBuffers);
    structures = MemoryStructurePools(instance);
    final nativeSmall = memory_small_allocator_create(configuration.smallAllocationFactor, instance).check(() => memory_destroy(instance));
    smallDatas = MemorySmallData(nativeSmall);
    doubles = structures.register(sizeOf<Double>());
    tuples = MemoryTuples(nativeSmall, nativeBuffers);
  }

  void destroy() {
    structures.destroy();
    smallDatas.destroy();
    inputOutputBuffers.destroy();
    staticBuffers.destroy();
    memory_destroy(instance);
  }
}

class MemoryModule with Module<memory_module, MemoryModuleConfiguration, MemoryModuleState> {
  final id = memoryModuleId;
  final name = memoryModuleName;
  final dependencies = {coreModuleName};
  final MemoryModuleState state;

  MemoryModule(this.state);

  @override
  Pointer<memory_module> create(MemoryModuleConfiguration configuration) {
    SystemLibrary.loadByName(configuration.libraryPackageMode == LibraryPackageMode.shared ? memorySharedLibraryName : memoryLibraryName, memoryPackageName);
    return using((arena) => memory_module_create(configuration.toNative(arena<memory_module_configuration>())));
  }

  @override
  MemoryModuleConfiguration load(Pointer<memory_module> native) => MemoryModuleConfiguration.fromNative(native.ref.configuration);

  @override
  FutureOr<void> initialize() {
    state.create();
  }

  @override
  void destroy() {
    state.destroy();
    memory_module_destroy(native);
  }
}

extension ContextProviderMemoryExtensions on ContextProvider {
  ModuleProvider<memory_module, MemoryModuleConfiguration, MemoryModuleState> memory() => get(memoryModuleId);
  MemoryStaticBuffers staticBuffers() => memory().state.staticBuffers;
  MemoryInputOutputBuffers inputOutputBuffers() => memory().state.inputOutputBuffers;
  MemoryStructurePools structures() => memory().state.structures;
  MemorySmallData smallDatas() => memory().state.smallDatas;
  MemoryStructurePool<Double> doubles() => memory().state.doubles;
  MemoryTuples tuples() => memory().state.tuples;
}
