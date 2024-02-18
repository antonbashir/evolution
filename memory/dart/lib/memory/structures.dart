import 'dart:ffi';

import 'package:core/core.dart';

import '../memory/bindings.dart';
import 'constants.dart';
import 'exception.dart';

class MemoryStructures {
  final Map<int, Pointer<memory_dart_structure_pool>> _pools = {};

  final Pointer<memory_dart> _memory;

  MemoryStructures(this._memory);

  MemoryStructurePool<T> register<T extends Struct>(int size) {
    final pool = memory_dart_structure_pool_create(_memory, size);
    _pools[T.hashCode] = pool;
    return MemoryStructurePool<T>(pool);
  }

  @inline
  int size<T extends Struct>() => memory_dart_structure_pool_size(_pools[T.hashCode]!.cast());

  @inline
  Pointer<T> allocate<T extends Struct>() {
    final pool = _pools[T.hashCode];
    if (pool == null) throw MemoryRuntimeException(MemoryErrors.outOfMemory);
    return memory_dart_structure_allocate(pool).cast();
  }

  @inline
  void free<T extends Struct>(Pointer<T> payload) {
    final pool = _pools[T.hashCode];
    if (pool == null) return;
    memory_dart_structure_free(pool, payload.cast());
  }

  @inline
  void destroy() {
    _pools.values.forEach((pool) => memory_dart_structure_pool_destroy(pool));
    _pools.clear();
  }
}

class MemoryStructurePool<T extends Struct> {
  final Pointer<memory_dart_structure_pool> _pool;

  MemoryStructurePool(this._pool);

  @inline
  int size() => memory_dart_structure_pool_size(_pool);

  @inline
  Pointer<T> allocate() => memory_dart_structure_allocate(_pool).cast();

  @inline
  void free(Pointer<T> payload) => memory_dart_structure_free(_pool, payload.cast());
}
