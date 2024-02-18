import 'dart:typed_data';

import 'constants.dart';

class ReactiveReadBuffer {
  var _data = <int>[];
  var _readerIndex = 0;
  var _capacity = 0;
  var _checkpointIndex = 0;

  int get readerIndex => _readerIndex;

  @inline
  void extend(Uint8List data) {
    _data.addAll(data);
    _capacity += data.length;
  }

  @inline
  void shrink() {
    _data = _data.sublist(_readerIndex);
    _capacity = _data.length;
    _readerIndex = 0;
  }

  @inline
  void reset() {
    _data = [];
    _capacity = 0;
    _readerIndex = 0;
    _checkpointIndex = 0;
  }

  @inline
  bool isReadable() => _readerIndex < _capacity;

  @inline
  void save() => _checkpointIndex = _readerIndex;

  @inline
  void restore() => _readerIndex = _checkpointIndex;

  @inline
  int? readInt8() {
    if (_readerIndex < _capacity) {
      var value = _data[_readerIndex];
      _readerIndex += 1;
      return value;
    }
    return null;
  }

  @inline
  int? readInt16() {
    final data = readBytes(2);
    return data == null ? null : _bytesToNumber(data);
  }

  @inline
  int? readInt24() {
    final data = readBytes(3);
    return data == null ? null : _bytesToNumber(data);
  }

  @inline
  int? readInt32() {
    final data = readBytes(4);
    return data == null ? null : _bytesToNumber(data);
  }

  @inline
  int? readInt64() {
    final data = readBytes(8);
    return data == null ? null : _bytesToNumber(data);
  }

  @inline
  List<int>? readBytes(int length) {
    if (_readerIndex + length <= _capacity) {
      final array = _data.sublist(_readerIndex, _readerIndex + length);
      _readerIndex += length;
      return array;
    }
    return null;
  }

  @inline
  Uint8List? readUint8List(int length) {
    final data = readBytes(length);
    return data == null ? null : Uint8List.fromList(data);
  }

  @inline
  int _bytesToNumber(List<int> data) {
    var value = 0;
    for (var element in data) {
      value = (value * 256) + element;
    }
    return value;
  }
}

class ReactiveWriteBuffer {
  var _data = <int>[];
  var _writerIndex = 0;
  var _capacity = 0;

  @inline
  void writeInt8(int value) {
    if (_writerIndex == _data.length) {
      _data.add(value);
      _updateCapacity();
      _writerIndex += 1;
      return;
    }
    _data[_writerIndex] = value;
    _writerIndex += 1;
  }

  @inline
  void writeInt16(int value) => writeBytes(_int16ToBytes(value));

  @inline
  void writeInt24(int value) => writeBytes(_int24ToBytes(value));

  @inline
  void writeInt32(int value) => writeBytes(_int32ToBytes(value));

  @inline
  void writeInt64(int value) => writeBytes(_int64ToBytes(value));

  @inline
  void insertInt24(int value) => insertBytes(_int24ToBytes(value));

  @inline
  void writeBytes(List<int> bytes) {
    final end = _writerIndex + bytes.length;
    if (_writerIndex == _data.length) {
      _data.addAll(bytes);
      _writerIndex = end;
      _updateCapacity();
      return;
    }
    _data.replaceRange(_writerIndex, end, bytes);
    _writerIndex = end;
    _updateCapacity();
  }

  @inline
  void insertBytes(List<int> bytes) {
    var end = _writerIndex + bytes.length;
    _data.insertAll(_writerIndex, bytes);
    _writerIndex = end;
    _updateCapacity();
  }

  @inline
  void writeUint8List(Uint8List data) => writeBytes(List.from(data));

  @inline
  bool isWritable() => _writerIndex < _capacity;

  @inline
  void resetWriterIndex() => _writerIndex = 0;

  @inline
  int capacity() => _capacity;

  @inline
  Uint8List toUint8Array() => Uint8List.fromList(_data);

  @inline
  void _updateCapacity() {
    if (_capacity < _data.length) {
      _capacity = _data.length;
    }
  }

  @inline
  Uint8List _int64ToBytes(int value) => Uint8List(8)..buffer.asByteData().setUint64(0, value, Endian.big);

  @inline
  Uint8List _int32ToBytes(int value) => Uint8List(4)..buffer.asByteData().setUint32(0, value, Endian.big);

  @inline
  Uint8List _int24ToBytes(int value) {
    var uint8list = Uint8List(4)..buffer.asByteData().setUint32(0, value, Endian.big);
    return uint8list.sublist(1);
  }

  @inline
  Uint8List _int16ToBytes(int value) => Uint8List(2)..buffer.asByteData().setUint16(0, value, Endian.big);
}

class ReactiveRequesterBuffer {
  final int _chunkSize;

  var _count = 0;
  var _chunks = <Uint8List>[];
  var _last = 0;

  ReactiveRequesterBuffer(this._chunkSize);

  List<Uint8List> get chunks => _chunks;
  int get count => _count;

  @inline
  void clear() {
    _last = 0;
    _count = 0;
    _chunks = [];
  }

  @inline
  List<Uint8List> add(Uint8List frame) {
    _count++;
    if (_chunks.isEmpty) {
      _chunks.add(frame);
      _last = 0;
      return _chunks;
    }
    final lastChunk = _chunks[_last];
    if (frame.length + lastChunk.length <= _chunkSize) {
      _chunks[_last] = Uint8List.fromList([...lastChunk, ...frame]);
      return _chunks;
    }
    _chunks.add(frame);
    _last++;
    return _chunks;
  }
}
