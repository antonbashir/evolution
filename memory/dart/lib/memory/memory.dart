import 'dart:ffi';

import 'package:core/core.dart';
import 'package:ffi/ffi.dart';

import '../memory.dart';
import 'bindings.dart';
import 'configuration.dart';
import 'constants.dart';
import 'defaults.dart';
import 'exceptions.dart';

class Memory {
  late final Pointer<memory_dart> _pointer;

  late final MemoryStaticBuffers staticBuffers;
  late final MemoryInputOutputBuffers inputOutputBuffers;
  late final MemoryStructurePools structures;
  late final MemorySmallData smallDatas;
  late final MemoryStructurePool<Double> doubles;

  Memory({String? libraryPath, MemoryConfiguration configuration = MemoryDefaults.memory, bool shared = false}) {
    if (libraryPath != null) {
      SystemLibrary.loadByPath(libraryPath);
      return;
    }
    SystemLibrary.loadByName(shared ? memorySharedLibraryName : memoryLibraryName, memoryPackageName);
    _pointer = calloc<memory_dart>(sizeOf<memory_dart>());
    if (_pointer == nullptr) throw MemoryException(MemoryErrors.outOfMemory);
    final result = using((arena) {
      final nativeConfiguration = arena<memory_dart_configuration>();
      nativeConfiguration.ref.static_buffer_size = configuration.staticBufferSize;
      nativeConfiguration.ref.static_buffers_capacity = configuration.staticBuffersCapacity;
      nativeConfiguration.ref.slab_size = configuration.slabSize;
      nativeConfiguration.ref.preallocation_size = configuration.preallocationSize;
      nativeConfiguration.ref.quota_size = configuration.quotaSize;
      return memory_dart_initialize(_pointer, nativeConfiguration);
    });
    if (result < 0) {
      memory_dart_destroy(_pointer);
      calloc.free(_pointer);
      throw MemoryException(CoreErrors.systemError(result));
    }
    staticBuffers = MemoryStaticBuffers(_pointer);
    inputOutputBuffers = MemoryInputOutputBuffers(_pointer);
    structures = MemoryStructurePools(_pointer);
    smallDatas = MemorySmallData(_pointer);
    doubles = structures.register(sizeOf<Double>());
  }

  void destroy() {
    memory_dart_destroy(_pointer);
  }
}
