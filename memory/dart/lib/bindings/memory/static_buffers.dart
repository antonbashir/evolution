// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import '../../memory/bindings.dart';

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

@Native<Pointer<memory_static_buffers> Function(Size capacity, Size size)>(isLeaf: true)
external Pointer<memory_static_buffers> memory_static_buffers_create(int capacity, int size);

@Native<Void Function(Pointer<memory_static_buffers> pool)>(isLeaf: true)
external void memory_static_buffers_destroy(Pointer<memory_static_buffers> pool);

@Native<Void Function(Pointer<memory_static_buffers> pool, Int32 id)>(isLeaf: true)
external void memory_static_buffers_push(Pointer<memory_static_buffers> pool, int id);

@Native<Int32 Function(Pointer<memory_static_buffers> pool)>(isLeaf: true)
external int memory_static_buffers_pop(Pointer<memory_static_buffers> pool);

@Native<Int32 Function(Pointer<memory_static_buffers> pool)>(isLeaf: true)
external int memory_static_buffers_used(Pointer<memory_static_buffers> pool);
