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
  late final Pointer<memory_instance> instance;
  late final MemoryStaticBuffers staticBuffers;
  late final MemoryInputOutputBuffers inputOutputBuffers;
  late final MemoryStructurePools structures;
  late final MemorySmallData smalls;
  late final MemoryStructurePool<Double> doubles;
  late final MemoryTuples tuples;

  MemoryModuleState();

  void create() {
    final configuration = context().memoryModule().configuration.memoryConfiguration;
    instance = memory_create(configuration.quotaSize, configuration.preallocationSize, configuration.slabSize).systemCheck();
    staticBuffers = MemoryStaticBuffers(memory_static_buffers_create(configuration.staticBuffersCapacity, configuration.staticBufferSize).systemCheck());
    final nativeBuffers = memory_io_buffers_create(instance).systemCheck();
    inputOutputBuffers = MemoryInputOutputBuffers(nativeBuffers, configuration.preallocationSize);
    structures = MemoryStructurePools(instance);
    final nativeSmall = memory_small_allocator_create(instance, configuration.smallAllocationFactor).systemCheck();
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

class MemoryModule extends Module<memory_module, MemoryModuleConfiguration, MemoryModuleState> {
  final name = memoryModuleName;
  final dependencies = {coreModuleName};
  final state = MemoryModuleState();

  MemoryModule({MemoryModuleConfiguration configuration = MemoryDefaults.module})
      : super(
          configuration,
          SystemLibrary.loadByName(configuration.libraryPackageMode == LibraryPackageMode.shared ? memorySharedLibraryName : memoryLibraryName, memoryModuleName),
          using((arena) => memory_module_create(configuration.toNative(arena))),
        );

  @entry
  MemoryModule._load(int address)
      : super.load(
          address,
          (native) => SystemLibrary.load(native.ref.library),
          (native) => MemoryModuleConfiguration.fromNative(native.ref.configuration),
        );

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

extension MemoryExtensions on ContextProvider {
  ModuleProvider<memory_module, MemoryModuleConfiguration, MemoryModuleState> memoryModule() => get(memoryModuleName);
  MemoryStaticBuffers staticBuffers() => memoryModule().state.staticBuffers;
  MemoryInputOutputBuffers inputOutputBuffers() => memoryModule().state.inputOutputBuffers;
  MemoryStructurePools structures() => memoryModule().state.structures;
  MemorySmallData smalls() => memoryModule().state.smalls;
  MemoryStructurePool<Double> doubles() => memoryModule().state.doubles;
  MemoryTuples tuples() => memoryModule().state.tuples;
}
