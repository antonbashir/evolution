import 'dart:ffi';
import 'dart:typed_data';

import '../memory.dart';

class MemoryTuples {
  final Pointer<memory_small_allocator> _small;
  final MemoryTupleFixedWriters fixed;
  final MemoryTupleDynamicWriter dynamic;

  late final ({Pointer<Uint8> value, int size}) emptyList;
  late final ({Pointer<Uint8> value, int size}) emptyMap;
  late final ({Pointer<Uint8> value, int size}) emptyString;
  late final ({Pointer<Uint8> value, int size}) emptyBinary;

  MemoryTuples(this._small, Pointer<memory_io_buffers> buffers, int dynamicWriterInitialCapacity)
      : fixed = MemoryTupleFixedWriters(buffers),
        dynamic = MemoryTupleDynamicWriter(buffers, dynamicWriterInitialCapacity) {
    emptyList = _createEmptyList();
    emptyMap = _createEmptyMap();
    emptyString = _createEmptyString();
    emptyBinary = _createEmptyBinary();
  }

  @inline
  int next(Pointer<Uint8> pointer, int offset) => memory_tuple_next(pointer.cast(), offset);

  @inline
  Pointer<Uint8> allocateSmall(int capacity) => memory_small_allocator_allocate(_small, capacity).cast();

  @inline
  ({Pointer<Uint8> tuple, Uint8List buffer, ByteData data}) wrapSmall(int size) {
    final pointer = memory_small_allocator_allocate(_small, size).cast<Uint8>();
    final buffer = pointer.asTypedList(size);
    final data = ByteData.view(buffer.buffer, buffer.offsetInBytes);
    return (tuple: pointer, buffer: buffer, data: data);
  }

  @inline
  void freeSmall(Pointer<Uint8> tuple, int size) => memory_small_allocator_free(_small, tuple.cast(), size);

  ({Pointer<Uint8> value, int size}) _createEmptyList() {
    final size = tupleSizeOfList(0);
    final value = allocateSmall(size);
    final buffer = value.asTypedList(size);
    tupleWriteList(ByteData.view(buffer.buffer, buffer.offsetInBytes), 0, 0);
    return (value: value, size: size);
  }

  ({Pointer<Uint8> value, int size}) _createEmptyMap() {
    final size = tupleSizeOfMap(0);
    final value = allocateSmall(size);
    final buffer = value.asTypedList(size);
    tupleWriteMap(ByteData.view(buffer.buffer, buffer.offsetInBytes), 0, 0);
    return (value: value, size: size);
  }

  ({Pointer<Uint8> value, int size}) _createEmptyString() {
    final size = tupleSizeOfMap(0);
    final value = allocateSmall(size);
    final buffer = value.asTypedList(size);
    tupleWriteString(buffer, ByteData.view(buffer.buffer, buffer.offsetInBytes), empty, 0);
    return (value: value, size: size);
  }

  ({Pointer<Uint8> value, int size}) _createEmptyBinary() {
    final size = tupleSizeOfMap(0);
    final value = allocateSmall(size);
    final buffer = value.asTypedList(size);
    tupleWriteBinary(buffer, ByteData.view(buffer.buffer, buffer.offsetInBytes), emptyBytes, 0);
    return (value: value, size: size);
  }
}

class MemoryTupleFixedWriters {
  final Pointer<memory_io_buffers> _buffers;

  MemoryTupleFixedWriters(this._buffers);

  ({Pointer<Uint8> tuple, int size, void Function() cleaner}) toInput(int size, int Function(Uint8List buffer, ByteData data, int offset) writer) {
    final inputBuffer = memory_io_buffers_allocate_input(_buffers, size);
    final reserved = inputBuffer.reserve(size);
    final buffer = reserved.cast<Uint8>().asTypedList(size);
    final data = ByteData.view(buffer.buffer, buffer.offsetInBytes);
    writer(buffer, data, 0);
    return (tuple: inputBuffer.readPosition, size: size, cleaner: () => memory_io_buffers_free_input(_buffers, inputBuffer));
  }

  ({Pointer<iovec> content, int count, int size, void Function() cleaner}) toOutput(int size, int Function(Uint8List buffer, ByteData data, int offset) writer) {
    final outputBuffer = memory_io_buffers_allocate_output(_buffers, size);
    final reserved = outputBuffer.reserve(size);
    final buffer = reserved.cast<Uint8>().asTypedList(size);
    final data = ByteData.view(buffer.buffer, buffer.offsetInBytes);
    writer(buffer, data, 0);
    return (content: outputBuffer.content, count: outputBuffer.ref.vectors, size: size, cleaner: () => memory_io_buffers_free_output(_buffers, outputBuffer));
  }
}

class MemoryTupleDynamicInputWriter {
  final Pointer<memory_io_buffers> _buffers;
  late final Pointer<memory_input_buffer> _inputBuffer;
  Pointer<Uint8> _buffer = nullptr;
  int _position = 0;
  int _end = 0;
  int _currentOffset = 0;
  int _nextOffset = 0;
  late Uint8List _bufferTyped;
  late ByteData _bufferData;

  @inline
  Pointer<memory_input_buffer> get buffer => _inputBuffer;

  MemoryTupleDynamicInputWriter(this._buffers, int initialCapacity) {
    _inputBuffer = memory_io_buffers_allocate_input(_buffers, initialCapacity);
    _bufferTyped = Uint8List(initialCapacity);
    _bufferData = ByteData.view(_bufferTyped.buffer, _bufferTyped.offsetInBytes);
  }

  @inline
  void writeNull() {
    _nextOffset = tupleWriteNull(reserve(tupleSizeOfNull).data, _currentOffset);
    advance(_nextOffset - _currentOffset);
    _currentOffset = _nextOffset;
  }

  @inline
  void writeBool(bool value) {
    _nextOffset = tupleWriteBool(reserve(tupleSizeOfBool).data, value, _currentOffset);
    advance(_nextOffset - _currentOffset);
    _currentOffset = _nextOffset;
  }

  @inline
  void writeInt(int value) {
    _nextOffset = tupleWriteInt(reserve(tupleSizeOfInt(value)).data, value, _currentOffset);
    advance(_nextOffset - _currentOffset);
    _currentOffset = _nextOffset;
  }

  @inline
  void writeDouble(double value) {
    _nextOffset = tupleWriteDouble(reserve(tupleSizeOfDouble).data, value, _currentOffset);
    advance(_nextOffset - _currentOffset);
    _currentOffset = _nextOffset;
  }

  @inline
  void writeString(String value) {
    final reserved = reserve(tupleSizeOfString(value.length));
    _nextOffset = tupleWriteString(reserved.buffer, reserved.data, value, _currentOffset);
    advance(_nextOffset - _currentOffset);
    _currentOffset = _nextOffset;
  }

  @inline
  void writeBinary(Uint8List value) {
    final reserved = reserve(tupleSizeOfBinary(value.length));
    _nextOffset = tupleWriteBinary(reserved.buffer, reserved.data, value, _currentOffset);
    advance(_nextOffset - _currentOffset);
    _currentOffset = _nextOffset;
  }

  @inline
  void writeList(int length) {
    _nextOffset = tupleWriteList(reserve(tupleSizeOfList(length)).data, length, _currentOffset);
    advance(_nextOffset - _currentOffset);
    _currentOffset = _nextOffset;
  }

  @inline
  void writeMap(int length) {
    _nextOffset = tupleWriteMap(reserve(tupleSizeOfMap(length)).data, length, _currentOffset);
    advance(_nextOffset - _currentOffset);
    _currentOffset = _nextOffset;
  }

  @inline
  void writeTuple(Tuple tuple) {
    final reserved = reserve(tuple.tupleSize);
    _nextOffset = tuple.serialize(reserved.buffer, reserved.data, _currentOffset);
    advance(_nextOffset - _currentOffset);
    _currentOffset = _nextOffset;
  }

  @inline
  ({Uint8List buffer, ByteData data}) reserve(int size) {
    if (_position + size > _end) {
      if (_position != _buffer.address) {
        _inputBuffer.finalize(_position - _buffer.address);
      }
      _buffer = _inputBuffer.reserve(size);
      _position = _buffer.address;
      _end = _position + _inputBuffer.ref.unused;
      _bufferTyped = _buffer.asTypedList(_end);
      _bufferData = ByteData.view(_bufferTyped.buffer, _bufferTyped.offsetInBytes);
      _currentOffset = 0;
      return (buffer: _bufferTyped, data: _bufferData);
    }
    return (buffer: _bufferTyped, data: _bufferData);
  }

  @inline
  void advance(int size) => _position += size;

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

class MemoryTupleDynamicOutputWriter {
  final Pointer<memory_io_buffers> _buffers;
  late final Pointer<memory_output_buffer> _outputBuffer;
  Pointer<Uint8> _buffer = nullptr;
  int _position = 0;
  int _end = 0;
  int _currentOffset = 0;
  int _nextOffset = 0;
  late Uint8List _bufferTyped;
  late ByteData _bufferData;

  @inline
  Pointer<memory_output_buffer> get buffer => _outputBuffer;

  MemoryTupleDynamicOutputWriter(this._buffers, int initialCapacity) {
    _outputBuffer = memory_io_buffers_allocate_output(_buffers, initialCapacity);
    _bufferTyped = Uint8List(initialCapacity);
    _bufferData = ByteData.view(_bufferTyped.buffer, _bufferTyped.offsetInBytes);
  }

  @inline
  void writeNull() {
    _nextOffset = tupleWriteNull(reserve(tupleSizeOfNull).data, _currentOffset);
    advance(_nextOffset - _currentOffset);
    _currentOffset = _nextOffset;
  }

  @inline
  void writeBool(bool value) {
    _nextOffset = tupleWriteBool(reserve(tupleSizeOfBool).data, value, _currentOffset);
    advance(_nextOffset - _currentOffset);
    _currentOffset = _nextOffset;
  }

  @inline
  void writeInt(int value) {
    _nextOffset = tupleWriteInt(reserve(tupleSizeOfInt(value)).data, value, _currentOffset);
    advance(_nextOffset - _currentOffset);
    _currentOffset = _nextOffset;
  }

  @inline
  void writeDouble(double value) {
    _nextOffset = tupleWriteDouble(reserve(tupleSizeOfDouble).data, value, _currentOffset);
    advance(_nextOffset - _currentOffset);
    _currentOffset = _nextOffset;
  }

  @inline
  void writeString(String value) {
    final reserved = reserve(tupleSizeOfString(value.length));
    _nextOffset = tupleWriteString(reserved.buffer, reserved.data, value, _currentOffset);
    advance(_nextOffset - _currentOffset);
    _currentOffset = _nextOffset;
  }

  @inline
  void writeBinary(Uint8List value) {
    final reserved = reserve(tupleSizeOfBinary(value.length));
    _nextOffset = tupleWriteBinary(reserved.buffer, reserved.data, value, _currentOffset);
    advance(_nextOffset - _currentOffset);
    _currentOffset = _nextOffset;
  }

  @inline
  void writeList(int length) {
    _nextOffset = tupleWriteList(reserve(tupleSizeOfList(length)).data, length, _currentOffset);
    advance(_nextOffset - _currentOffset);
    _currentOffset = _nextOffset;
  }

  @inline
  void writeMap(int length) {
    _nextOffset = tupleWriteMap(reserve(tupleSizeOfMap(length)).data, length, _currentOffset);
    advance(_nextOffset - _currentOffset);
    _currentOffset = _nextOffset;
  }

  @inline
  void writeTuple(Tuple tuple) {
    final reserved = reserve(tuple.tupleSize);
    _nextOffset = tuple.serialize(reserved.buffer, reserved.data, _currentOffset);
    advance(_nextOffset - _currentOffset);
    _currentOffset = _nextOffset;
  }

  @inline
  ({Uint8List buffer, ByteData data}) reserve(int size) {
    if (_position + size > _end) {
      if (_position != _buffer.address) {
        _outputBuffer.finalize(_position - _buffer.address);
      }
      _buffer = _outputBuffer.reserve(size);
      _position = _buffer.address;
      _end = _position + _outputBuffer.ref.last_reserved_size;
      _bufferTyped = _buffer.asTypedList(_end);
      _bufferData = ByteData.view(_bufferTyped.buffer, _bufferTyped.offsetInBytes);
      _currentOffset = 0;
      return (buffer: _bufferTyped, data: _bufferData);
    }
    return (buffer: _bufferTyped, data: _bufferData);
  }

  @inline
  void advance(int size) => _position += size;

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

class MemoryTupleDynamicWriter {
  final Pointer<memory_io_buffers> _buffers;
  final int initialCapacity;

  MemoryTupleDynamicInputWriter input({int? initialCapacity}) => MemoryTupleDynamicInputWriter(_buffers, initialCapacity ?? this.initialCapacity);
  MemoryTupleDynamicOutputWriter output({int? initialCapacity}) => MemoryTupleDynamicOutputWriter(_buffers, initialCapacity ?? this.initialCapacity);

  MemoryTupleDynamicWriter(this._buffers, this.initialCapacity);

  ({Pointer<Uint8> tuple, int size, void Function() cleaner}) toInput(
    int Function(({Uint8List buffer, ByteData data}) Function(int size) reserve, void Function(int size) advance) serializer, {
    int? initialCapacity,
  }) {
    final writer = input(initialCapacity: initialCapacity);
    serializer(writer.reserve, writer.advance);
    writer.flush();
    return (tuple: writer.buffer.readPosition, size: writer.buffer.used, cleaner: writer.destroy);
  }

  ({Pointer<iovec> content, int count, int size, void Function() cleaner}) toOutput(
    int Function(({Uint8List buffer, ByteData data}) Function(int size) reserve, void Function(int size) advance) serializer, {
    int? initialCapacity,
  }) {
    initialCapacity = initialCapacity ?? this.initialCapacity;
    final writer = output(initialCapacity: initialCapacity);
    serializer(writer.reserve, writer.advance);
    writer.flush();
    return (content: writer.buffer.content, count: writer.buffer.vectors, size: writer.buffer.size, cleaner: writer.destroy);
  }
}
