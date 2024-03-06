import 'dart:async';
import 'dart:collection';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:core/core.dart';

import '../memory/bindings.dart';
import 'constants.dart';

class MemoryStaticBuffers {
  final Pointer<iovec> native;
  final int bufferSize;
  final int buffersCapacity;
  final Queue<Completer<void>> _finalizers = Queue();
  final Pointer<memory_state> _memory;

  MemoryStaticBuffers(this._memory, this.buffersCapacity, this.bufferSize) : native = _memory.ref.static_buffers.ref.buffers;

  @inline
  void release(int bufferId) {
    memory_static_buffers_push(_memory.ref.static_buffers, bufferId);
    if (_finalizers.isNotEmpty) _finalizers.removeLast().complete();
  }

  @inline
  Uint8List read(int bufferId) {
    final buffer = native + bufferId;
    final bufferBytes = buffer.ref.iov_base.cast<Uint8>();
    return bufferBytes.asTypedList(buffer.ref.iov_len);
  }

  @inline
  void setLength(int bufferId, int length) => (native + bufferId).ref.iov_len = length;

  @inline
  void write(int bufferId, Uint8List bytes) {
    final buffer = native + bufferId;
    buffer.ref.iov_base.cast<Uint8>().asTypedList(bytes.length).setAll(0, bytes);
    buffer.ref.iov_len = bytes.length;
  }

  @inline
  int? get() {
    final buffer = memory_static_buffers_pop(_memory.ref.static_buffers);
    if (buffer == memoryBufferUsed) return null;
    return buffer;
  }

  Future<int> allocate() async {
    var bufferId = memory_static_buffers_pop(_memory.ref.static_buffers);
    while (bufferId == memoryBufferUsed) {
      if (_finalizers.isNotEmpty) {
        await _finalizers.last.future;
        bufferId = memory_static_buffers_pop(_memory.ref.static_buffers);
        continue;
      }
      final completer = Completer();
      _finalizers.add(completer);
      await completer.future;
      bufferId = memory_static_buffers_pop(_memory.ref.static_buffers);
    }
    return bufferId;
  }

  Future<List<int>> allocateArray(int count) async {
    final bufferIds = <int>[];
    for (var index = 0; index < count; index++) bufferIds.add(get() ?? await allocate());
    return bufferIds;
  }

  @inline
  int available() => _memory.ref.static_buffers.ref.available;

  @inline
  int used() => _memory.ref.static_buffers.ref.capacity - _memory.ref.static_buffers.ref.available;

  @inline
  void releaseArray(List<int> buffers) {
    for (var id in buffers) release(id);
  }
}

class MemoryInputOutputBuffers {
  final Pointer<memory_state> _memory;

  MemoryInputOutputBuffers(this._memory);

  @inline
  Pointer<memory_input_buffer> allocateInputBuffer(int capacity) => memory_io_buffers_allocate_input(_memory.ref.io_buffers, capacity);

  @inline
  Pointer<memory_output_buffer> allocateOutputBuffer(int capacity) => memory_io_buffers_allocate_output(_memory.ref.io_buffers, capacity);

  @inline
  void freeInputBuffer(Pointer<memory_input_buffer> buffer) => memory_io_buffers_free_input(_memory.ref.io_buffers, buffer);

  @inline
  void freeOutputBuffer(Pointer<memory_output_buffer> buffer) => memory_io_buffers_free_output(_memory.ref.io_buffers, buffer);
}

extension MemoryInputBufferExtensions on Pointer<memory_input_buffer> {
  @inline
  Pointer<Uint8> finalize(int delta) => memory_input_buffer_finalize(this, delta);

  @inline
  Pointer<Uint8> reserve(int size) => memory_input_buffer_reserve(this, size);

  @inline
  Pointer<Uint8> finalizeReserve(int delta, int size) => memory_input_buffer_finalize_reserve(this, delta, size);

  @inline
  Pointer<Uint8> get readPosition => ref.read_position;

  @inline
  Pointer<Uint8> get writePosition => ref.write_position;
}

extension MemoryOutputBufferExtensions on Pointer<memory_output_buffer> {
  @inline
  Pointer<Uint8> finalize(int delta) => memory_output_buffer_finalize(this, delta);

  @inline
  Pointer<Uint8> reserve(int size) => memory_output_buffer_reserve(this, size);

  @inline
  Pointer<Uint8> finalizeReserve(int delta, int size) => memory_output_buffer_finalize_reserve(this, delta, size);

  @inline
  Pointer<iovec> get content => ref.content;
}
