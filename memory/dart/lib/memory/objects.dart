import 'dart:async';
import 'dart:collection';

import 'package:core/core.dart';

import 'configuration.dart';
import 'defaults.dart';

class MemoryObjects<T> {
  final T Function() _allocator;
  final void Function(T object) _releaser;
  final MemoryObjectsConfiguration configuration;

  final double _extensionFactor;
  final double _shrinkFactor;
  final ListQueue<T> _queue;

  MemoryObjects(this._allocator, this._releaser, {this.configuration = MemoryDefaults.objects})
      : _queue = ListQueue(configuration.initialCapacity),
        _extensionFactor = configuration.extensionFactor,
        _shrinkFactor = configuration.shrinkFactor {
    _extend(configuration.preallocation);
  }

  @inline
  T allocate() {
    if (_queue.isEmpty) {
      final message = _allocator();
      _queue.add(message);
      _extend((_queue.length * _extensionFactor).ceil());
      return message;
    }
    final allocated = _queue.removeLast();
    if (_queue.length < configuration.maximumAvailableCapacity) {
      unawaited(Future.microtask(() => _extend((_queue.length * _extensionFactor).ceil())));
    }
    return allocated;
  }

  @inline
  void release(T message) {
    _queue.add(message);
    if (_queue.length > configuration.maximumAvailableCapacity) unawaited(Future.microtask(_shrink));
  }

  void _shrink() {
    var shrink = _queue.length * _shrinkFactor;
    while (--shrink > 0 && _queue.isNotEmpty && _queue.length > configuration.minimumAvailableCapacity) {
      _releaser(_queue.removeLast());
    }
  }

  void _extend(int nextCapacity) {
    if (_queue.length >= nextCapacity) return;
    final toAllocate = nextCapacity - _queue.length;
    for (var i = 0; i < toAllocate && _queue.length < configuration.maximumAvailableCapacity; i++) _queue.add(_allocator());
  }
}
