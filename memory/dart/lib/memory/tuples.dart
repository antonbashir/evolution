import 'dart:ffi';
import 'dart:typed_data';

import 'bindings.dart';
import 'buffers.dart';

class MemoryTuples {
  final Pointer<memory_small_allocator> _small;
  final Pointer<memory_io_buffers> _buffers;

  late final (Pointer<Uint8>, int) emptyList;
  late final (Pointer<Uint8>, int) emptyMap;

  MemoryTuples(this._small, this._buffers) {
    emptyList = _createEmptyList();
    emptyMap = _createEmptyMap();
  }

  @inline
  int next(Pointer<Uint8> pointer, int offset) => memory_tuple_next(pointer.cast(), offset);

  @inline
  Pointer<Uint8> allocateSmall(int capacity) => memory_small_allocator_allocate(_small, capacity).cast();

  @inline
  (Pointer<Uint8>, Uint8List, ByteData) prepareSmall(int size) {
    final pointer = memory_small_allocator_allocate(_small, size).cast<Uint8>();
    final buffer = pointer.asTypedList(size);
    final data = ByteData.view(buffer.buffer, buffer.offsetInBytes);
    return (pointer, buffer, data);
  }

  @inline
  void freeSmall(Pointer<Uint8> tuple, int size) => memory_small_allocator_free(_small, tuple.cast(), size);

  ({Pointer<Uint8> tuple, int size, void Function() cleaner}) writeForInput(int size, int Function(Uint8List buffer, ByteData data, int offset) writer) {
    final inputBuffer = memory_io_buffers_allocate_input(_buffers, size);
    final reserved = inputBuffer.reserve(size);
    final buffer = reserved.cast<Uint8>().asTypedList(size);
    final data = ByteData.view(buffer.buffer, buffer.offsetInBytes);
    inputBuffer.finalize(writer(buffer, data, 0));
    return (tuple: inputBuffer.readPosition, size: size, cleaner: () => memory_io_buffers_free_input(_buffers, inputBuffer));
  }

  ({Pointer<iovec> content, int count, int fullSize, void Function() cleaner}) writeForOutput(int size, int Function(Uint8List buffer, ByteData data, int offset) writer) {
    final outputBuffer = memory_io_buffers_allocate_output(_buffers, size);
    final reserved = outputBuffer.reserve(size);
    final buffer = reserved.cast<Uint8>().asTypedList(size);
    final data = ByteData.view(buffer.buffer, buffer.offsetInBytes);
    outputBuffer.finalize(writer(buffer, data, 0));
    return (content: outputBuffer.content, count: outputBuffer.ref.content_count, fullSize: size, cleaner: () => memory_io_buffers_free_output(_buffers, outputBuffer));
  }

  (Pointer<Uint8>, int) _createEmptyList() {
    final size = tupleSizeOfList(0);
    final list = allocateSmall(size);
    final buffer = list.asTypedList(size);
    tupleWriteList(ByteData.view(buffer.buffer, buffer.offsetInBytes), 0, 0);
    return (list, size);
  }

  (Pointer<Uint8>, int) _createEmptyMap() {
    final size = tupleSizeOfMap(0);
    final map = allocateSmall(size);
    final buffer = map.asTypedList(size);
    tupleWriteMap(ByteData.view(buffer.buffer, buffer.offsetInBytes), 0, 0);
    return (map, size);
  }
}
