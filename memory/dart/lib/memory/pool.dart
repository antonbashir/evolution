import 'dart:collection';

import 'package:core/core.dart';

class ObjectPool<T> {
  final T Function() _allocator;
  final void Function(T object) _releaser;
  final int initialCapacity;
  final int preallocation;
  final double maxExtensionFactor;
  final double shrinkFactor;

  final int _maxExtension;
  final int _shrinkSize;
  final ListQueue<T> _queue;

  ObjectPool(
    this._allocator,
    this._releaser, {
    required this.initialCapacity,
    required this.preallocation,
    required this.maxExtensionFactor,
    required this.shrinkFactor,
  })  : _queue = ListQueue(initialCapacity),
        _maxExtension = (initialCapacity * maxExtensionFactor).ceil(),
        _shrinkSize = (shrinkFactor * initialCapacity * maxExtensionFactor).floor() {
    for (var i = 0; i < preallocation; i++) {
      release(_allocator());
    }
  }

  @inline
  T allocate() {
    if (_queue.isEmpty) {
      final message = _allocator();
      release(message);
      return message;
    }
    return _queue.removeLast();
  }

  @inline
  void release(T message) {
    _queue.add(message);
    if (_queue.length > _maxExtension) Future.microtask(_shrink);
  }

  void _shrink() {
    var shrink = _shrinkSize;
    while (--shrink > 0 && _queue.isNotEmpty) {
      _releaser(_queue.removeLast());
    }
  }
}
