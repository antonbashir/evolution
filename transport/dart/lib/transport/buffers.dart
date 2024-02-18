import 'dart:async';
import 'dart:collection';
import 'dart:ffi';
import 'dart:typed_data';

import 'bindings.dart';
import 'constants.dart';

class TransportBuffers {
  final TransportBindings _bindings;
  final Pointer<iovec> buffers;
  final Queue<Completer<void>> _finalizers = Queue();
  final Pointer<transport_worker_t> _worker;

  late final int bufferSize;
  late final int buffersCount;

  TransportBuffers(this._bindings, this.buffers, this._worker) {
    bufferSize = _worker.ref.buffer_size;
    buffersCount = _worker.ref.buffers_count;
  }

  @inline
  void release(int bufferId) {
    _bindings.transport_worker_release_buffer(_worker, bufferId);
    if (_finalizers.isNotEmpty) _finalizers.removeLast().complete();
  }

  @inline
  Uint8List read(int bufferId) {
    final buffer = buffers.elementAt(bufferId);
    final bufferBytes = buffer.ref.iov_base.cast<Uint8>();
    return bufferBytes.asTypedList(buffer.ref.iov_len);
  }

  @inline
  void setLength(int bufferId, int length) => buffers.elementAt(bufferId).ref.iov_len = length;

  @inline
  void write(int bufferId, Uint8List bytes) {
    final buffer = buffers.elementAt(bufferId);
    buffer.ref.iov_base.cast<Uint8>().asTypedList(bytes.length).setAll(0, bytes);
    buffer.ref.iov_len = bytes.length;
  }

  @inline
  int? get() {
    final buffer = _bindings.transport_worker_get_buffer(_worker);
    if (buffer == transportBufferUsed) return null;
    return buffer;
  }

  Future<int> allocate() async {
    var bufferId = _bindings.transport_worker_get_buffer(_worker);
    while (bufferId == transportBufferUsed) {
      if (_finalizers.isNotEmpty) {
        await _finalizers.last.future;
        bufferId = _bindings.transport_worker_get_buffer(_worker);
        continue;
      }
      final completer = Completer();
      _finalizers.add(completer);
      await completer.future;
      bufferId = _bindings.transport_worker_get_buffer(_worker);
    }
    return bufferId;
  }

  Future<List<int>> allocateArray(int count) async {
    final bufferIds = <int>[];
    for (var index = 0; index < count; index++) bufferIds.add(get() ?? await allocate());
    return bufferIds;
  }

  @inline
  int available() => _bindings.transport_worker_available_buffers(_worker);

  @inline
  int used() => _bindings.transport_worker_used_buffers(_worker);

  @inline
  void releaseArray(List<int> buffers) {
    for (var id in buffers) release(id);
  }
}