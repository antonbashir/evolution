import 'dart:ffi';

import 'package:core/core.dart';

const memoryBufferUsed = -1;

final memoryLibraryName = context().environment().debug ? "libmemory_debug_${Abi.current()}.so" : "libmemory_release_${Abi.current()}.so";
final memorySharedLibraryName = context().environment().debug ? "libmemory_debug_${Abi.current()}_shared.so" : "libmemory_release_${Abi.current()}_shared.so";
const memoryModuleName = "memory";

class MemoryErrors {
  MemoryErrors._();

  static String unknownStructurePool(String type) => "Unknown structure pool: $type";
  static String tupleComputeSizeImpossible(Type type) => "Compute tuple size impossible for $type";
}
