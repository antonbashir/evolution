import 'dart:ffi';

import 'package:ffi/ffi.dart';

import '../memory.dart';
import 'constants.dart';
import 'defaults.dart';

class MemoryModule {
  late final Pointer<memory_module_state> pointer;
  late final MemoryStaticBuffers staticBuffers;
  late final MemoryInputOutputBuffers inputOutputBuffers;
  late final MemoryStructurePools structures;
  late final MemorySmallData smallDatas;
  late final MemoryStructurePool<Double> doubles;

  static void load({String? libraryPath, LibraryPackageMode mode = LibraryPackageMode.static}) {
    if (libraryPath != null) {
      SystemLibrary.loadByPath(libraryPath);
      return;
    }
    SystemLibrary.loadByName(mode == LibraryPackageMode.shared ? memorySharedLibraryName : memoryLibraryName, memoryPackageName);
  }

  MemoryModule({String? libraryPath, bool load = true, LibraryPackageMode mode = LibraryPackageMode.static}) {
    if (load) MemoryModule.load(libraryPath: libraryPath, mode: mode);
  }

  void initialize({MemoryModuleConfiguration configuration = MemoryDefaults.module}) {
    final pointer = using((arena) => memory_module_state_create(configuration.toNativePointer(arena<memory_configuration>())));
    if (pointer == nullptr) {
      //throw MemoryException(systemError(result));
    }
    staticBuffers = MemoryStaticBuffers(pointer.ref.static_buffers);
    inputOutputBuffers = MemoryInputOutputBuffers(pointer.ref.io_buffers);
    structures = MemoryStructurePools(pointer.ref.memory_instance);
    smallDatas = MemorySmallData(memory_small_allocator_create(1.05, pointer.ref.memory_instance));
    doubles = structures.register(sizeOf<Double>());
  }

  void destroy() {
    memory_module_state_destroy(pointer);
  }
}
