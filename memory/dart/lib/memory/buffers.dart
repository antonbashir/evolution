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
  final Pointer<memory_dart> _memory;

  MemoryStaticBuffers(this._memory, this.buffersCapacity, this.bufferSize) : native = memory_dart_static_buffers_inner(_memory);

  @inline
  void release(int bufferId) {
    memory_dart_static_buffers_release(_memory, bufferId);
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
    final buffer = memory_dart_static_buffers_get(_memory);
    if (buffer == memoryBufferUsed) return null;
    return buffer;
  }

  Future<int> allocate() async {
    var bufferId = memory_dart_static_buffers_get(_memory);
    while (bufferId == memoryBufferUsed) {
      if (_finalizers.isNotEmpty) {
        await _finalizers.last.future;
        bufferId = memory_dart_static_buffers_get(_memory);
        continue;
      }
      final completer = Completer();
      _finalizers.add(completer);
      await completer.future;
      bufferId = memory_dart_static_buffers_get(_memory);
    }
    return bufferId;
  }

  Future<List<int>> allocateArray(int count) async {
    final bufferIds = <int>[];
    for (var index = 0; index < count; index++) bufferIds.add(get() ?? await allocate());
    return bufferIds;
  }

  @inline
  int available() => memory_dart_static_buffers_available(_memory);

  @inline
  int used() => memory_dart_static_buffers_used(_memory);

  @inline
  void releaseArray(List<int> buffers) {
    for (var id in buffers) release(id);
  }
}

class MemoryInputOutputBuffers {
  final Pointer<memory_dart> _memory;

  MemoryInputOutputBuffers(this._memory);

  @inline
  Pointer<memory_input_buffer> allocateInputBuffer(int capacity) => memory_dart_io_buffers_allocate_input(_memory, capacity);

  @inline
  Pointer<memory_output_buffer> allocateOutputBuffer(int capacity) => memory_dart_io_buffers_allocate_output(_memory, capacity);

  @inline
  void freeInputBuffer(Pointer<memory_input_buffer> buffer) => memory_dart_io_buffers_free_input(_memory, buffer);

  @inline
  void freeOutputBuffer(Pointer<memory_output_buffer> buffer) => memory_dart_io_buffers_free_output(_memory, buffer);
}

extension MemoryInputBufferExtensions on Pointer<memory_input_buffer> {
  @inline
  Pointer<Uint8> allocate(buffer, int delta) => memory_dart_input_buffer_allocate(buffer, delta);

  @inline
  Pointer<Uint8> reserve(Pointer<memory_input_buffer> buffer, int size) => memory_dart_input_buffer_reserve(buffer, size);

  @inline
  Pointer<Uint8> allocateReserve(Pointer<memory_input_buffer> buffer, int delta, int size) => memory_dart_input_buffer_allocate_reserve(buffer, delta, size);

  @inline
  Pointer<Uint8> get readPosition => memory_dart_input_buffer_read_position(this);

  @inline
  Pointer<Uint8> get writePosition => memory_dart_input_buffer_write_position(this);
}

extension MemoryOutputBufferExtensions on Pointer<memory_output_buffer> {
  @inline
  Pointer<Uint8> allocate(Pointer<memory_output_buffer> buffer, int delta) => memory_dart_output_buffer_allocate(buffer, delta);

  @inline
  Pointer<Uint8> reserve(Pointer<memory_output_buffer> buffer, int size) => memory_dart_output_buffer_reserve(buffer, size);

  @inline
  Pointer<Uint8> allocateReserve(Pointer<memory_output_buffer> buffer, int delta, int size) => memory_dart_output_buffer_allocate_reserve(buffer, delta, size);

  @inline
  Pointer<iovec> get content => memory_dart_output_buffer_content(this);
}
