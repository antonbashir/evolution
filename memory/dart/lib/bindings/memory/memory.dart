// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import '../../memory/bindings.dart';

final class memory_instance extends Opaque {}

final class memory_pool extends Struct {
  @Size()
  external int object_size;
}

final class memory_small_allocator extends Opaque {}

@Native<Pointer<memory_instance> Function(Size quota_size, Size preallocation_size, Size slab_size)>(isLeaf: true)
external Pointer<memory_instance> memory_create(int quota_size, int preallocation_size, int slab_size);

@Native<Void Function(Pointer<memory_instance> memory)>(isLeaf: true)
external void memory_destroy(Pointer<memory_instance> memory);

@Native<Pointer<memory_pool> Function(Pointer<memory_instance> memory, Size size)>(isLeaf: true)
external Pointer<memory_pool> memory_pool_create(Pointer<memory_instance> memory, int size);

@Native<Void Function(Pointer<memory_pool> pool)>(isLeaf: true)
external void memory_pool_destroy(Pointer<memory_pool> pool);

@Native<Pointer<Void> Function(Pointer<memory_pool> pool)>(isLeaf: true)
external Pointer<Void> memory_pool_allocate(Pointer<memory_pool> pool);

@Native<Void Function(Pointer<memory_pool> pool, Pointer<Void> ptr)>(isLeaf: true)
external void memory_pool_free(Pointer<memory_pool> pool, Pointer<Void> ptr);

@Native<Pointer<memory_small_allocator> Function(Pointer<memory_instance> memory, Float allocation_factor)>(isLeaf: true)
external Pointer<memory_small_allocator> memory_small_allocator_create(Pointer<memory_instance> memory, double allocation_factor);

@Native<Pointer<Void> Function(Pointer<memory_small_allocator> pool, Size size)>(isLeaf: true)
external Pointer<Void> memory_small_allocator_allocate(Pointer<memory_small_allocator> pool, int size);

@Native<Void Function(Pointer<memory_small_allocator> pool, Pointer<Void> ptr, Size size)>(isLeaf: true)
external void memory_small_allocator_free(Pointer<memory_small_allocator> pool, Pointer<Void> ptr, int size);

@Native<Void Function(Pointer<memory_small_allocator> pool)>(isLeaf: true)
external void memory_small_allocator_destroy(Pointer<memory_small_allocator> pool);
