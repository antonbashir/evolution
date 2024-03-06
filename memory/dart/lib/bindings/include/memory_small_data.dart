import 'dart:ffi';

import 'memory.dart';

@Native<Int32 Function(Pointer<memory_small_data>, Pointer<memory>)>(symbol: 'memory_small_data_create', assetId: 'memory-bindings', isLeaf: true)
external int memory_small_data_create(Pointer<memory_small_data> pool, Pointer<memory> memory);

@Native<Void Function(Pointer<memory_small_data>)>(symbol: 'memory_small_data_destroy', assetId: 'memory-bindings', isLeaf: true)
external void memory_small_data_destroy(Pointer<memory_small_data> pool);

@Native<Pointer<Void> Function(Pointer<memory_small_data>, Size)>(symbol: 'memory_small_data_allocate', assetId: 'memory-bindings', isLeaf: true)
external Pointer<Void> memory_small_data_allocate(Pointer<memory_small_data> pool, int data_size);

@Native<Void Function(Pointer<memory_small_data>, Pointer<Void>, Size)>(symbol: 'memory_small_data_free', assetId: 'memory-bindings', isLeaf: true)
external void memory_small_data_free(Pointer<memory_small_data> pool, Pointer<Void> data, int data_size);

final class memory_small_data extends Opaque {}
