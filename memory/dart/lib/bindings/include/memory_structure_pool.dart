import 'dart:ffi';

import 'memory.dart';

final class memory_structure_pool extends Struct {
  @Size()
  external int size;
}

@Native<Int32 Function(Pointer<memory_structure_pool>, Pointer<memory>, Size)>(symbol: 'memory_structure_pool_create', assetId: 'memory-bindings', isLeaf: true)
external int memory_structure_pool_create(Pointer<memory_structure_pool> pool, Pointer<memory> memory, int structure_size);

@Native<Void Function(Pointer<memory_structure_pool>)>(symbol: 'memory_structure_pool_destroy', assetId: 'memory-bindings', isLeaf: true)
external void memory_structure_pool_destroy(Pointer<memory_structure_pool> pool);

@Native<Pointer<Void> Function(Pointer<memory_structure_pool>)>(symbol: 'memory_structure_pool_allocate', assetId: 'memory-bindings', isLeaf: true)
external Pointer<Void> memory_structure_pool_allocate(Pointer<memory_structure_pool> pool);

@Native<Void Function(Pointer<memory_structure_pool>, Pointer<Void>)>(symbol: 'memory_structure_pool_free', assetId: 'memory-bindings', isLeaf: true)
external void memory_structure_pool_free(Pointer<memory_structure_pool> pool, Pointer<Void> payload);

@Native<Pointer<memory_structure_pool> Function()>(symbol: 'memory_structure_pool_new', assetId: 'memory-bindings', isLeaf: true)
external Pointer<memory_structure_pool> memory_structure_pool_new();
