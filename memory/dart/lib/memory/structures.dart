import 'dart:ffi';

import 'package:core/core.dart';
import 'package:ffi/ffi.dart';

import '../bindings/include/memory_structure_pool.dart';
import '../bindings/state/memory_state.dart';
import '../memory.dart';
import 'constants.dart';
import 'defaults.dart';
import 'exceptions.dart';

class MemoryStructurePools {
  final Map<int, Pointer<memory_structure_pool>> _pools = {};

  final Pointer<memory_state> _memory;

  MemoryStructurePools(this._memory);

  MemoryStructurePool<T> register<T extends NativeType>(int size) {
    final pool = memory_structure_pool_new();
    memory_structure_pool_create(pool, _memory.ref.memory_instance, size);
    _pools[T.hashCode] = pool;
    return MemoryStructurePool<T>(pool);
  }

  @inline
  int size<T extends Struct>() => _pools[T.hashCode]!.ref.size;

  @inline
  Pointer<T> allocate<T extends NativeType>() {
    final pool = _pools[T.hashCode];
    if (pool == null) throw MemoryException(MemoryErrors.outOfMemory);
    return memory_structure_pool_allocate(pool).cast();
  }

  @inline
  void free<T extends NativeType>(Pointer<T> payload) {
    final pool = _pools[T.hashCode];
    if (pool == null) return;
    memory_structure_pool_free(pool, payload.cast());
  }

  @inline
  void destroy() {
    _pools.values.forEach((pool) => memory_structure_pool_destroy(pool));
    _pools.values.forEach((pool) => calloc.free(pool));
    _pools.clear();
  }
}

class MemoryStructurePool<T extends NativeType> {
  final Pointer<memory_structure_pool> _pool;

  MemoryStructurePool(this._pool);

  MemoryObjects<Pointer<T>> asObjectPool({
    MemoryObjectsConfiguration configuration = MemoryDefaults.objects,
  }) =>
      MemoryObjects(
        allocate,
        free,
        configuration: configuration,
      );

  @inline
  int size() => _pool.ref.size;

  @inline
  Pointer<T> allocate() => memory_structure_pool_allocate(_pool).cast();

  @inline
  void free(Pointer<T> payload) {
    memory_structure_pool_free(_pool, payload.cast());
    calloc.free(_pool);
  }
}
