import 'dart:ffi';

import 'package:core/core.dart';

import '../memory/bindings.dart';

class MemorySmallData {
  final Pointer<memory_dart> _memory;

  MemorySmallData(this._memory);

  @inline
  Pointer<Void> allocate(int size) => memory_dart_small_data_allocate(_memory, size);

  @inline
  void free(Pointer<Void> pointer, int size) => memory_dart_small_data_free(_memory, pointer, size);
}
