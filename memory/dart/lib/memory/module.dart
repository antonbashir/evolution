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

  static void load({String? libraryPath, LibraryPackageMode mode = LibraryPackageMode.static}) {
    CoreModule.load();
    if (libraryPath != null) {
      SystemLibrary.loadByPath(libraryPath);
      return;
    }
    SystemLibrary.loadByName(mode == LibraryPackageMode.shared ? memorySharedLibraryName : memoryLibraryName, memoryPackageName);
  }

  MemoryModule({String? libraryPath, bool load = true, LibraryPackageMode mode = LibraryPackageMode.static}) {
    if (load) MemoryModule.load(libraryPath: libraryPath, mode: mode);
  }

  void initialize({MemoryModuleConfiguration configuration = MemoryDefaults.memory}) {
    pointer = calloc<memory_dart>(sizeOf<memory_dart>());
    if (pointer == nullptr) throw MemoryException(MemoryErrors.outOfMemory);
    final result = using((arena) => memory_dart_initialize(pointer, configuration.toNative(arena<memory_module_configuration>())));
    if (result < 0) {
      memory_dart_destroy(pointer);
      calloc.free(pointer);
      throw MemoryException(systemError(result));
    }
    staticBuffers = MemoryStaticBuffers(pointer, configuration.staticBuffersCapacity, configuration.staticBufferSize);
    inputOutputBuffers = MemoryInputOutputBuffers(pointer);
    structures = MemoryStructurePools(pointer);
    smallDatas = MemorySmallData(pointer);
    doubles = structures.register(sizeOf<Double>());
  }

  void destroy() {
    memory_dart_destroy(pointer);
  }
}
