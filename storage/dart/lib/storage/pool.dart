import 'dart:collection';
import 'dart:ffi';

import 'package:interactor/interactor.dart';

import 'constants.dart';

class MessagePool {
  final Pointer<interactor_message> Function() _allocator;
  final void Function(Pointer<interactor_message> message) _releaser;
  final int initialCapacity;
  final int preallocation;
  final int maxExtensionFactor;
  final int shrinkFactor;

  final int _maxExtension;
  final int _shrinkSize;
  final ListQueue<Pointer<interactor_message>> _queue;

  MessagePool(
    this._allocator,
    this._releaser, {
    required this.initialCapacity,
    required this.preallocation,
    required this.maxExtensionFactor,
    required this.shrinkFactor,
  })  : _queue = ListQueue(initialCapacity),
        _maxExtension = initialCapacity * maxExtensionFactor,
        _shrinkSize = shrinkFactor * initialCapacity * maxExtensionFactor {
    for (var i = 0; i < preallocation; i++) {
      release(_allocator());
    }
  }

  @pragma(preferInlinePragma)
  Pointer<interactor_message> allocate() {
    if (_queue.isEmpty) {
      final message = _allocator();
      release(message);
      return message;
    }
    return _queue.removeLast();
  }

  @pragma(preferInlinePragma)
  void release(Pointer<interactor_message> message) {
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
