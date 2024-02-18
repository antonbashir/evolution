import 'dart:ffi';

const memoryBufferUsed = -1;

final memoryLibraryName = bool.fromEnvironment("DEBUG") ? "libmemory_debug_${Abi.current()}.so" : "libmemory_release_${Abi.current()}.so";
final memorySharedLibraryName = bool.fromEnvironment("DEBUG") ? "libmemory_debug_${Abi.current()}_shared.so" : "libmemory_release_${Abi.current()}_shared.so";
const memoryPackageName = "memory";

class MemoryErrors {
  MemoryErrors._();

  static const outOfMemory = "Out of memory";
}