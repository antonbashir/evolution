import 'dart:async';
import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'bindings.dart';
import 'buffers.dart';
import 'configuration.dart';
import 'constants.dart';
import 'data.dart';
import 'defaults.dart';
import 'structures.dart';
import 'tuples.dart';

class MemoryModuleState implements ModuleState {
  final MemoryConfiguration configuration;
  late final Pointer<memory_instance> instance;
  late final MemoryStaticBuffers staticBuffers;
  late final MemoryInputOutputBuffers inputOutputBuffers;
  late final MemoryStructurePools structures;
  late final MemorySmallData smalls;
  late final MemoryStructurePool<Double> doubles;
  late final MemoryTuples tuples;

  MemoryModuleState({this.configuration = MemoryDefaults.memory});

  void create() {
    instance = memory_create(configuration.quotaSize, configuration.preallocationSize, configuration.slabSize).check();
    staticBuffers = MemoryStaticBuffers(memory_static_buffers_create(configuration.staticBuffersCapacity, configuration.staticBufferSize).check(() => memory_destroy(instance)));
    final nativeBuffers = memory_io_buffers_create(instance).check(() => memory_destroy(instance));
    inputOutputBuffers = MemoryInputOutputBuffers(nativeBuffers, configuration.preallocationSize);
    structures = MemoryStructurePools(instance);
    final nativeSmall = memory_small_allocator_create(instance, configuration.smallAllocationFactor).check(() => memory_destroy(instance));
    smalls = MemorySmallData(nativeSmall);
    doubles = structures.register(sizeOf<Double>());
    tuples = MemoryTuples(nativeSmall, inputOutputBuffers);
  }

  void destroy() {
    structures.destroy();
    smalls.destroy();
    inputOutputBuffers.destroy();
    staticBuffers.destroy();
    memory_destroy(instance);
  }
}

class MemoryModule with Module<memory_module, MemoryModuleConfiguration, MemoryModuleState> {
  final name = memoryModuleName;
  final dependencies = {coreModuleName};
  final MemoryModuleState state;

  MemoryModule({MemoryModuleState? state}) : state = state ?? MemoryModuleState();

  @override
  Pointer<memory_module> create(MemoryModuleConfiguration configuration) {
    SystemLibrary.loadByName(configuration.libraryPackageMode == LibraryPackageMode.shared ? memorySharedLibraryName : memoryLibraryName, memoryPackageName);
    return using((arena) => memory_module_create(configuration.toNative(arena)));
  }

  @override
  MemoryModuleConfiguration load(Pointer<memory_module> native) => MemoryModuleConfiguration.fromNative(native.ref.configuration);

  @override
  FutureOr<void> initialize() {
    state.create();
  }

  @override
  FutureOr<void> fork() {
    state.create();
  }

  @override
  void unfork() => state.destroy();

  @override
  FutureOr<void> shutdown() {
    state.destroy();
  }

  @override
  void destroy() {
    memory_module_destroy(native);
  }
}

extension ContextProviderMemoryExtensions on ContextProvider {
  ModuleProvider<memory_module, MemoryModuleConfiguration, MemoryModuleState> memory() => get(memoryModuleName);
  MemoryStaticBuffers staticBuffers() => memory().state.staticBuffers;
  MemoryInputOutputBuffers inputOutputBuffers() => memory().state.inputOutputBuffers;
  MemoryStructurePools structures() => memory().state.structures;
  MemorySmallData smalls() => memory().state.smalls;
  MemoryStructurePool<Double> doubles() => memory().state.doubles;
  MemoryTuples tuples() => memory().state.tuples;
}
