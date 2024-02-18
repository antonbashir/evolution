import 'dart:ffi';

import 'package:core/core.dart';
import 'package:ffi/ffi.dart' as ffi;

import 'bindings.dart';
import 'configuration.dart';
import 'constants.dart';
import 'defaults.dart';
import 'exceptions.dart';

class Memory {
  late final Pointer<memory_dart> _pointer;

  Memory({String? libraryPath, MemoryConfiguration configuration = MemoryDefaults.memory, bool load = true}) {
    if (load) {
      if (libraryPath != null) {
        SystemLibrary.loadByPath(libraryPath);
        return;
      }
      SystemLibrary.loadByName(memoryLibraryName, memoryPackageName);
    }
    _pointer = ffi.calloc<memory_dart>(sizeOf<memory_dart>());
    if (_pointer == nullptr) throw MemoryException(MemoryErrors.outOfMemory);
    final result = ffi.using((arena) {
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
      ffi.calloc.free(_pointer);
      throw MemoryException(CoreErrors.systemError(result));
    }
  }

  void destroy() {
    memory_dart_destroy(_pointer);
  }
}
