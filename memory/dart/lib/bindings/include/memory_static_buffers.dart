import 'dart:ffi';

import 'package:core/core.dart';

final class memory_static_buffers extends Struct {
  @Size()
  external int available;
  @Size()
  external int size;
  @Size()
  external int capacity;
  external Pointer<Int32> ids;
  external Pointer<iovec> buffers;
}

@Native<Int32 Function(Pointer<memory_static_buffers>, Size, Size)>(symbol: 'memory_static_buffers_create', assetId: 'memory-bindings', isLeaf: true)
external int memory_static_buffers_create(Pointer<memory_static_buffers> pool, int capacity, int size);

@Native<Void Function(Pointer<memory_static_buffers>)>(symbol: 'memory_static_buffers_destroy', assetId: 'memory-bindings', isLeaf: true)
external void memory_static_buffers_destroy(Pointer<memory_static_buffers> pool);

@Native<Void Function(Pointer<memory_static_buffers>, Int32)>(symbol: 'memory_static_buffers_push', assetId: 'memory-bindings', isLeaf: true)
external void memory_static_buffers_push(Pointer<memory_static_buffers> pool, int id);

@Native<Int32 Function(Pointer<memory_static_buffers>)>(symbol: 'memory_static_buffers_pop', assetId: 'memory-bindings', isLeaf: true)
external int memory_static_buffers_pop(Pointer<memory_static_buffers> pool);

@Native<Int32 Function(Pointer<memory_static_buffers>)>(symbol: 'memory_static_buffers_available', assetId: 'memory-bindings', isLeaf: true)
external int memory_static_buffers_available(Pointer<memory_static_buffers> pool);

@Native<Int32 Function(Pointer<memory_static_buffers>)>(symbol: 'memory_static_buffers_used', assetId: 'memory-bindings', isLeaf: true)
external int memory_static_buffers_used(Pointer<memory_static_buffers> pool);
