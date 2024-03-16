import 'dart:async';
import 'dart:collection';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:core/core/exceptions.dart';

import 'bindings.dart';

class MemoryStaticBuffers {
  final Pointer<memory_static_buffers> buffers;
  final Pointer<Int32> ids;
  final Pointer<iovec> contents;
  final Queue<Completer<void>> _finalizers = Queue();
  final int size;
  final int capacity;

  MemoryStaticBuffers(this.buffers)
      : ids = buffers.ref.ids,
        contents = buffers.ref.buffers,
        size = buffers.ref.size,
        capacity = buffers.ref.capacity;

  @inline
  void release(int bufferId) {
    memory_static_buffers_push(buffers, bufferId);
    if (_finalizers.isNotEmpty) _finalizers.removeLast().complete();
  }

  @inline
  Uint8List read(int bufferId) {
    final buffer = contents + bufferId;
    final bufferBytes = buffer.ref.iov_base.cast<Uint8>();
    return bufferBytes.asTypedList(buffer.ref.iov_len);
  }

  @inline
  void setLength(int bufferId, int length) => (contents + bufferId).ref.iov_len = length;

  @inline
  void write(int bufferId, Uint8List bytes) {
    final buffer = contents + bufferId;
    buffer.ref.iov_base.cast<Uint8>().asTypedList(bytes.length).setAll(0, bytes);
    buffer.ref.iov_len = bytes.length;
  }

  @inline
  int? get() {
    if (buffers.ref.available == 0) return null;
    return ids[--buffers.ref.available];
  }

  Future<int> allocate() async {
    var bufferId = get();
    while (bufferId == null) {
      if (_finalizers.isNotEmpty) {
        await _finalizers.last.future;
        bufferId = get();
        continue;
      }
      final completer = Completer();
      _finalizers.add(completer);
      await completer.future;
      bufferId = get();
    }
    return bufferId;
  }

  Future<List<int>> allocateArray(int count) async {
    final bufferIds = <int>[];
    for (var index = 0; index < count; index++) bufferIds.add(get() ?? await allocate());
    return bufferIds;
  }

  @inline
  int available() => buffers.ref.available;

  @inline
  int used() => buffers.ref.capacity - buffers.ref.available;

  @inline
  void releaseArray(List<int> buffers) {
    for (var id in buffers) release(id);
  }

  @inline
  void destroy() => memory_static_buffers_destroy(buffers);
}

class MemoryInputOutputBuffers {
  final Pointer<memory_io_buffers> _buffers;
  final int initialCapacity;

  MemoryInputOutputBuffers(this._buffers, this.initialCapacity);

  ({Uint8List buffer, ByteData data, void Function() cleaner}) wrapInput(int size) {
    final inputBuffer = SystemException.checkPointer(memory_io_buffers_allocate_input(_buffers, size));
    final reserved = inputBuffer.reserve(size);
    final buffer = reserved.cast<Uint8>().asTypedList(size);
    final data = ByteData.view(buffer.buffer, buffer.offsetInBytes);
    return (buffer: buffer, data: data, cleaner: () => memory_io_buffers_free_input(_buffers, inputBuffer));
  }

  ({Uint8List buffer, ByteData data, void Function() cleaner}) wrapOutput(int size) {
    final outputBuffer = SystemException.checkPointer(memory_io_buffers_allocate_output(_buffers, size));
    final reserved = outputBuffer.reserve(size);
    final buffer = reserved.cast<Uint8>().asTypedList(size);
    final data = ByteData.view(buffer.buffer, buffer.offsetInBytes);
    return (buffer: buffer, data: data, cleaner: () => memory_io_buffers_free_output(_buffers, outputBuffer));
  }

  @inline
  Pointer<memory_input_buffer> allocateInputBuffer({int? initialCapacity}) => SystemException.checkPointer(memory_io_buffers_allocate_input(_buffers, initialCapacity ?? this.initialCapacity));

  @inline
  Pointer<memory_output_buffer> allocateOutputBuffer({int? initialCapacity}) => SystemException.checkPointer(memory_io_buffers_allocate_output(_buffers, initialCapacity ?? this.initialCapacity));

  @inline
  void freeInputBuffer(Pointer<memory_input_buffer> buffer) => memory_io_buffers_free_input(_buffers, buffer);

  @inline
  void freeOutputBuffer(Pointer<memory_output_buffer> buffer) => memory_io_buffers_free_output(_buffers, buffer);

  @inline
  void destroy() => memory_io_buffers_destroy(_buffers);
}

extension MemoryInputBufferExtensions on Pointer<memory_input_buffer> {
  @inline
  Pointer<Uint8> get readPosition => ref.read_position;

  @inline
  Pointer<Uint8> get writePosition => ref.write_position;

  @inline
  int get used => ref.used;

  @inline
  int get unused => ref.unused;

  @inline
  ({Uint8List buffer, ByteData data}) wrapRead() {
    final buffer = readPosition.asTypedList(used);
    final data = ByteData.view(buffer.buffer, buffer.offsetInBytes);
    return (buffer: buffer, data: data);
  }

  @inline
  ({Uint8List buffer, ByteData data}) wrapWrite() {
    final buffer = writePosition.asTypedList(unused);
    final data = ByteData.view(buffer.buffer, buffer.offsetInBytes);
    return (buffer: buffer, data: data);
  }

  @inline
  Pointer<Uint8> finalize(int delta) => SystemException.checkPointer(memory_input_buffer_finalize(this, delta));

  @inline
  Pointer<Uint8> reserve(int size) => SystemException.checkPointer(memory_input_buffer_reserve(this, size));

  @inline
  Pointer<Uint8> finalizeReserve(int delta, int size) => SystemException.checkPointer(memory_input_buffer_finalize_reserve(this, delta, size));
}

extension MemoryOutputBufferExtensions on Pointer<memory_output_buffer> {
  @inline
  Pointer<iovec> get content => ref.content;

  @inline
  int get vectors => ref.vectors;

  @inline
  int get size => ref.size;

  @inline
  ({Uint8List buffer, ByteData data}) wrap() {
    final buffer = content.collect(vectors);
    final data = ByteData.view(buffer.buffer, buffer.offsetInBytes);
    return (buffer: buffer, data: data);
  }

  @inline
  Pointer<Uint8> finalize(int delta) => SystemException.checkPointer(memory_output_buffer_finalize(this, delta));

  @inline
  Pointer<Uint8> reserve(int size) => SystemException.checkPointer(memory_output_buffer_reserve(this, size));

  @inline
  Pointer<Uint8> finalizeReserve(int delta, int size) => SystemException.checkPointer(memory_output_buffer_finalize_reserve(this, delta, size));
}
