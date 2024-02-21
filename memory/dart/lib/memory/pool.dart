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
    for (var i = 0; i < configuration.preallocation; i++) {
      release(_allocator());
    }
  }

  @inline
  T allocate() {
    if (_queue.isEmpty) {
      final message = _allocator();
      release(message);
      Future.microtask(_extend);
      return message;
    }
    if (_queue.length < configuration.minimalAvailableCapacity) Future.microtask(_extend);
    return _queue.removeLast();
  }

  @inline
  void release(T message) {
    _queue.add(message);
    if (_queue.length > _extensionFactor) Future.microtask(_shrink);
  }

  void _shrink() {
    var shrink = _queue.length * _shrinkFactor;
    while (--shrink > 0 && _queue.isNotEmpty) {
      _releaser(_queue.removeLast());
    }
  }

  void _extend() {
    final newSize = _queue.length * _extensionFactor;
    final toAllocate = newSize - _queue.length;
    for (var i = 0; i < toAllocate; i++) {
      release(_allocator());
    }
  }
}
