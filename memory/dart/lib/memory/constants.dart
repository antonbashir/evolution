import 'dart:ffi';

const memoryBufferUsed = -1;

final memoryLibraryName = bool.fromEnvironment("DEBUG") ? "libmemory_debug_${Abi.current()}.so" : "libmemory_release_${Abi.current()}.so";
final memorySharedLibraryName = bool.fromEnvironment("DEBUG") ? "libmemory_debug_${Abi.current()}_shared.so" : "libmemory_release_${Abi.current()}_shared.so";
const memoryModuleId = 1;
const memoryModuleName = "memory";
const memoryPackageName = "memory";

class MemoryErrors {
  MemoryErrors._();

  static String unknownStructurePool(String type) => "Unknown structure pool: $type";
}
