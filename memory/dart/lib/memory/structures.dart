import 'dart:ffi';

import 'bindings.dart';
import 'configuration.dart';
import 'constants.dart';
import 'defaults.dart';
import 'exceptions.dart';
import 'objects.dart';

class MemoryStructurePools {
  final Map<int, Pointer<memory_pool>> _pools = {};
  final Pointer<memory_instance> _memory;

  MemoryStructurePools(this._memory);

  MemoryStructurePool<T> register<T extends NativeType>(int size) {
    final pool = memory_pool_create(_memory, size).check();
    _pools[T.hashCode] = pool;
    return MemoryStructurePool<T>(T.hashCode, pool);
  }

  void unregister(MemoryStructurePool pool) {
    memory_pool_destroy(pool._pool);
    _pools.remove(pool._id);
  }

  @inline
  int size<T extends Struct>() => _pools[T.hashCode]!.ref.size;

  @inline
  Pointer<T> allocate<T extends NativeType>() {
    final pool = _pools[T.hashCode];
    if (pool == null) throw MemoryException(MemoryErrors.unknownStructurePool(T.toString()));
    return memory_pool_allocate(pool).check().cast();
  }

  @inline
  void free<T extends NativeType>(Pointer<T> payload) {
    final pool = _pools[T.hashCode];
    if (pool == null) return;
    memory_pool_free(pool, payload.cast());
  }

  @inline
  void destroy() {
    _pools.values.forEach(memory_pool_destroy);
    _pools.clear();
  }
}

class MemoryStructurePool<T extends NativeType> {
  final int _id;
  final Pointer<memory_pool> _pool;

  MemoryStructurePool(this._id, this._pool);

  MemoryObjects<Pointer<T>> asObjectPool({
    MemoryObjectsConfiguration configuration = MemoryDefaults.objects,
  }) =>
      MemoryObjects(allocate, free, configuration: configuration);

  @inline
  int size() => _pool.ref.size;

  @inline
  Pointer<T> allocate() => memory_pool_allocate(_pool).check().cast();

  @inline
  void free(Pointer<T> payload) => memory_pool_free(_pool, payload.cast());
}
