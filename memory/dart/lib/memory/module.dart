import 'dart:ffi';

import 'package:core/core.dart';
import 'package:ffi/ffi.dart';

import '../memory.dart';
import 'configuration.dart';
import 'constants.dart';
import 'defaults.dart';
import 'exceptions.dart';

class MemoryModule {
  late final Pointer<memory_dart> pointer;
  late final MemoryStaticBuffers staticBuffers;
  late final MemoryInputOutputBuffers inputOutputBuffers;
  late final MemoryStructurePools structures;
  late final MemorySmallData smallDatas;
  late final MemoryStructurePool<Double> doubles;

  static void load({String? libraryPath, bool shared = false}) {
    CoreModule.load();
    if (libraryPath != null) {
      SystemLibrary.loadByPath(libraryPath);
      return;
    }
    SystemLibrary.loadByName(shared ? memorySharedLibraryName : memoryLibraryName, memoryPackageName);
  }

  MemoryModule({String? libraryPath, bool shared = false}) {
    load(libraryPath: libraryPath, shared: shared);
  }

  void initialize({MemoryConfiguration configuration = MemoryDefaults.memory}) {
    pointer = calloc<memory_dart>(sizeOf<memory_dart>());
    if (pointer == nullptr) throw MemoryException(MemoryErrors.outOfMemory);
    final result = using((arena) {
      final nativeConfiguration = arena<memory_dart_configuration>();
      nativeConfiguration.ref.static_buffer_size = configuration.staticBufferSize;
      nativeConfiguration.ref.static_buffers_capacity = configuration.staticBuffersCapacity;
      nativeConfiguration.ref.slab_size = configuration.slabSize;
      nativeConfiguration.ref.preallocation_size = configuration.preallocationSize;
      nativeConfiguration.ref.quota_size = configuration.quotaSize;
      return memory_dart_initialize(pointer, nativeConfiguration);
    });
    if (result < 0) {
      memory_dart_destroy(pointer);
      calloc.free(pointer);
      throw MemoryException(CoreErrors.systemError(result));
    }
    staticBuffers = MemoryStaticBuffers(pointer);
    inputOutputBuffers = MemoryInputOutputBuffers(pointer);
    structures = MemoryStructurePools(pointer);
    smallDatas = MemorySmallData(pointer);
    doubles = structures.register(sizeOf<Double>());
  }

  void destroy() {
    memory_dart_destroy(pointer);
  }
}
