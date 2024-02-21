import 'dart:collection';

import 'package:core/core.dart';

import 'configuration.dart';
import 'defaults.dart';

class MemoryObjectPool<T> {
  final T Function() _allocator;
  final void Function(T object) _releaser;
  final MemoryObjectPoolConfiguration configuration;

  final double _extensionFactor;
  final double _shrinkFactor;
  final ListQueue<T> _queue;

  MemoryObjectPool(this._allocator, this._releaser, {this.configuration = MemoryDefaults.objectPool})
      : _queue = ListQueue(configuration.initialCapacity),
        _extensionFactor = configuration.extensionFactor,
        _shrinkFactor = configuration.shrinkFactor {
    for (var i = 0; i < configuration.preallocation; i++) _queue.add(_allocator());
  }

  @inline
  T allocate() {
    if (_queue.isEmpty) {
      final message = _allocator();
      release(message);
      Future.microtask(() => _extend((_queue.length * _extensionFactor).ceil()));
      return message;
    }
    final allocated = _queue.removeLast();
    if (_queue.length < configuration.minimalAvailableCapacity) {
      Future.microtask(() => _extend((_queue.length * _extensionFactor).ceil()));
    }
    return allocated;
  }

  @inline
  void release(T message) {
    _queue.add(message);
    if (_queue.length > _extensionFactor) Future.microtask(_shrink);
  }

  void _shrink() {
    var shrink = _queue.length * _shrinkFactor;
    while (--shrink > 0 && _queue.isNotEmpty && _queue.length > configuration.minimalAvailableCapacity) {
      _releaser(_queue.removeLast());
    }
  }

  void _extend(int nextCapacity) {
    if (_queue.length >= nextCapacity) return;
    final toAllocate = nextCapacity - _queue.length;
    for (var i = 0; i < toAllocate; i++) _queue.add(_allocator());
  }
}