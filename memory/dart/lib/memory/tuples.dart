import 'dart:ffi';
import 'dart:typed_data';

import '../memory.dart';

class MemoryTuples {
  final Pointer<memory_small_allocator> _small;
  final MemoryTupleFixedStreams fixed;
  final MemoryTupleDynamicStreams dynamic;

  late final (Pointer<Uint8>, int) emptyList;
  late final (Pointer<Uint8>, int) emptyMap;

  MemoryTuples(this._small, Pointer<memory_io_buffers> buffers, int dynamicWriterInitialCapacity)
      : fixed = MemoryTupleFixedStreams(buffers),
        dynamic = MemoryTupleDynamicStreams(buffers, dynamicWriterInitialCapacity) {
    emptyList = _createEmptyList();
    emptyMap = _createEmptyMap();
  }

  @inline
  int next(Pointer<Uint8> pointer, int offset) => memory_tuple_next(pointer.cast(), offset);

  @inline
  Pointer<Uint8> allocateSmall(int capacity) => memory_small_allocator_allocate(_small, capacity).cast();

  @inline
  ({Pointer<Uint8> tuple, Uint8List buffer, ByteData data}) prepareSmall(int size) {
    final pointer = memory_small_allocator_allocate(_small, size).cast<Uint8>();
    final buffer = pointer.asTypedList(size);
    final data = ByteData.view(buffer.buffer, buffer.offsetInBytes);
    return (tuple: pointer, buffer: buffer, data: data);
  }

  @inline
  void freeSmall(Pointer<Uint8> tuple, int size) => memory_small_allocator_free(_small, tuple.cast(), size);

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

class MemoryTupleFixedStreams {
  final Pointer<memory_io_buffers> _buffers;

  MemoryTupleFixedStreams(this._buffers);

  ({Pointer<Uint8> tuple, int size, void Function() cleaner}) toInput(int size, int Function(Uint8List buffer, ByteData data, int offset) writer) {
    final inputBuffer = memory_io_buffers_allocate_input(_buffers, size);
    final reserved = inputBuffer.reserve(size);
    final buffer = reserved.cast<Uint8>().asTypedList(size);
    final data = ByteData.view(buffer.buffer, buffer.offsetInBytes);
    writer(buffer, data, 0);
    return (tuple: inputBuffer.readPosition, size: size, cleaner: () => memory_io_buffers_free_input(_buffers, inputBuffer));
  }

  ({Pointer<iovec> content, int count, int fullSize, void Function() cleaner}) toOutput(int size, int Function(Uint8List buffer, ByteData data, int offset) writer) {
    final outputBuffer = memory_io_buffers_allocate_output(_buffers, size);
    final reserved = outputBuffer.reserve(size);
    final buffer = reserved.cast<Uint8>().asTypedList(size);
    final data = ByteData.view(buffer.buffer, buffer.offsetInBytes);
    writer(buffer, data, 0);
    return (content: outputBuffer.content, count: outputBuffer.ref.content_count, fullSize: size, cleaner: () => memory_io_buffers_free_output(_buffers, outputBuffer));
  }
}

class MemoryTupleDynamicInputStream {
  final Pointer<memory_io_buffers> _buffers;
  late final Pointer<memory_input_buffer> _inputBuffer;
  Pointer<Uint8> _buffer = nullptr;
  int _position = 0;
  int _end = 0;
  int _result = 0;
  late Uint8List _bufferTyped;
  late ByteData _bufferData;

  @inline
  int get size => _result;

  @inline
  Pointer<memory_input_buffer> get buffer => _inputBuffer;

  @inline
  Pointer<Uint8> get readPosition => _inputBuffer.ref.read_position;

  @inline
  Pointer<Uint8> get writePosition => _inputBuffer.ref.write_position;

  MemoryTupleDynamicInputStream(this._buffers, int initialCapacity) {
    _inputBuffer = memory_io_buffers_allocate_input(_buffers, initialCapacity);
    _bufferTyped = Uint8List(initialCapacity);
    _bufferData = ByteData.view(_bufferTyped.buffer, _bufferTyped.offsetInBytes);
  }

  @inline
  void writeNull() => advance(tupleWriteNull(reserve(tupleSizeOfNull).data, 0));

  @inline
  void writeBool(bool value) => advance(tupleWriteBool(reserve(tupleSizeOfBool).data, value, 0));

  @inline
  void writeInt(int value) => advance(tupleWriteInt(reserve(tupleSizeOfInt(value)).data, value, 0));

  @inline
  void writeDouble(double value) => advance(tupleWriteDouble(reserve(tupleSizeOfDouble).data, value, 0));

  @inline
  void writeString(String value) {
    final reserved = reserve(tupleSizeOfString(value.length));
    advance(tupleWriteString(reserved.buffer, reserved.data, value, 0));
  }

  @inline
  void writeBinary(Uint8List value) {
    final reserved = reserve(tupleSizeOfBinary(value.length));
    advance(tupleWriteBinary(reserved.buffer, reserved.data, value, 0));
  }

  @inline
  void writeList(int length) => advance(tupleWriteList(reserve(tupleSizeOfList(length)).data, length, 0));

  @inline
  void writeMap(int length) => advance(tupleWriteMap(reserve(tupleSizeOfMap(length)).data, length, 0));

  @inline
  ({Uint8List buffer, ByteData data}) reserve(int size) {
    if (_position + size > _end) {
      if (_position != _buffer) {
        _inputBuffer.finalize(_position - _buffer.address);
      }
      _buffer = _inputBuffer.reserve(size);
      _bufferTyped = _buffer.asTypedList(size);
      _bufferData = ByteData.view(_bufferTyped.buffer, _bufferTyped.offsetInBytes);
      _position = _buffer.address;
      _end = _position + _inputBuffer.ref.last_reserved_size;
      return (buffer: _bufferTyped, data: _bufferData);
    }
    _bufferTyped = (_buffer + _bufferTyped.length).asTypedList(size);
    _bufferData = ByteData.view(_bufferTyped.buffer, _bufferTyped.offsetInBytes);
    return (buffer: _bufferTyped, data: _bufferData);
  }

  @inline
  void advance(int size) {
    _position += size;
    _result += size;
  }

  @inline
  void flush() {
    if (_position != _buffer.address) {
      memory_input_buffer_finalize(buffer, _position - _buffer.address);
    }
    _buffer = Pointer.fromAddress(_position);
  }

  @inline
  void destroy() => memory_io_buffers_free_input(_buffers, _inputBuffer);
}

class MemoryTupleDynamicOutputStream {
  final Pointer<memory_io_buffers> _buffers;
  late final Pointer<memory_output_buffer> _outputBuffer;
  Pointer<Uint8> _buffer = nullptr;
  int _position = 0;
  int _end = 0;
  int _result = 0;
  late Uint8List _bufferTyped;
  late ByteData _bufferData;

  @inline
  int get size => _result;

  @inline
  int get count => _outputBuffer.ref.content_count;

  @inline
  Pointer<iovec> get content => _outputBuffer.ref.content;

  @inline
  Pointer<memory_output_buffer> get buffer => _outputBuffer;

  MemoryTupleDynamicOutputStream(this._buffers, int initialCapacity) {
    _outputBuffer = memory_io_buffers_allocate_output(_buffers, initialCapacity);
    _bufferTyped = Uint8List(_result);
    _bufferData = ByteData.view(_bufferTyped.buffer, _bufferTyped.offsetInBytes);
  }

  @inline
  void writeNull() => advance(tupleWriteNull(reserve(tupleSizeOfNull).data, 0));

  @inline
  void writeBool(bool value) => advance(tupleWriteBool(reserve(tupleSizeOfBool).data, value, 0));

  @inline
  void writeInt(int value) => advance(tupleWriteInt(reserve(tupleSizeOfInt(value)).data, value, 0));

  @inline
  void writeDouble(double value) => advance(tupleWriteDouble(reserve(tupleSizeOfDouble).data, value, 0));

  @inline
  void writeString(String value) {
    final reserved = reserve(tupleSizeOfString(value.length));
    advance(tupleWriteString(reserved.buffer, reserved.data, value, 0));
  }

  @inline
  void writeBinary(Uint8List value) {
    final reserved = reserve(tupleSizeOfBinary(value.length));
    advance(tupleWriteBinary(reserved.buffer, reserved.data, value, 0));
  }

  @inline
  void writeList(int length) => advance(tupleWriteList(reserve(tupleSizeOfList(length)).data, length, 0));

  @inline
  void writeMap(int length) => advance(tupleWriteMap(reserve(tupleSizeOfMap(length)).data, length, 0));

  @inline
  ({Uint8List buffer, ByteData data}) reserve(int size) {
    if (_position + size > _end) {
      if (_position != _buffer.address) {
        _outputBuffer.finalize(_position - _buffer.address);
      }
      _buffer = _outputBuffer.reserve(size);
      _bufferTyped = _buffer.asTypedList(size);
      _bufferData = ByteData.view(_bufferTyped.buffer, _bufferTyped.offsetInBytes);
      _position = _buffer.address;
      _end = _position + _outputBuffer.ref.last_reserved_size;
      return (buffer: _bufferTyped, data: _bufferData);
    }
    _bufferTyped = (_buffer + _bufferTyped.length).asTypedList(size);
    _bufferData = ByteData.view(_bufferTyped.buffer, _bufferTyped.offsetInBytes);
    return (buffer: _bufferTyped, data: _bufferData);
  }

  @inline
  void advance(int size) {
    _position += size;
    _result += size;
  }

  @inline
  void flush() {
    if (_position != _buffer.address) {
      memory_output_buffer_finalize(buffer, _position - _buffer.address);
    }
    _buffer = Pointer.fromAddress(_position);
  }

  @inline
  void destroy() => memory_io_buffers_free_output(_buffers, _outputBuffer);
}

class MemoryTupleDynamicStreams {
  final Pointer<memory_io_buffers> _buffers;
  final int initialCapacity;

  MemoryTupleDynamicInputStream input({int? initialCapacity}) => MemoryTupleDynamicInputStream(_buffers, initialCapacity ?? this.initialCapacity);
  MemoryTupleDynamicOutputStream output({int? initialCapacity}) => MemoryTupleDynamicOutputStream(_buffers, initialCapacity ?? this.initialCapacity);

  MemoryTupleDynamicStreams(this._buffers, this.initialCapacity);

  ({Pointer<Uint8> tuple, int size, void Function() cleaner}) toInput(
    int Function(({Uint8List buffer, ByteData data}) Function(int size) reserve, void Function(int size) advance) writer, {
    int? initialCapacity,
  }) {
    final stream = input(initialCapacity: initialCapacity);
    writer(stream.reserve, stream.advance);
    stream.flush();
    return (tuple: stream._inputBuffer.readPosition, size: stream._result, cleaner: stream.destroy);
  }

  ({Pointer<iovec> content, int count, int fullSize, void Function() cleaner}) toOutput(
    int Function(({Uint8List buffer, ByteData data}) Function(int size) reserve, void Function(int size) advance) writer, {
    int? initialCapacity,
  }) {
    initialCapacity = initialCapacity ?? this.initialCapacity;
    final stream = output(initialCapacity: initialCapacity);
    writer(stream.reserve, stream.advance);
    stream.flush();
    return (
      content: stream._outputBuffer.content,
      count: stream._outputBuffer.ref.content_count,
      fullSize: stream._result,
      cleaner: stream.destroy,
    );
  }
}