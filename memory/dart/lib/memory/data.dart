import 'dart:ffi';

import 'package:core/core.dart';

import '../bindings/memory/memory.dart';

class MemorySmallData {
  final Pointer<memory_small_allocator> _allocator;

  MemorySmallData(this._allocator);

  @inline
  Pointer<Void> allocate(int size) => memory_small_allocator_allocate(_allocator, size);

  @inline
  void free(Pointer<Void> pointer, int size) => memory_small_allocator_free(_allocator, pointer, size);
}
