import 'dart:convert';
import 'dart:typed_data';

import 'constants.dart';
import 'extensions.dart';

const _decoder = const Utf8Decoder();

const tupleSizeOfNull = 1;
const tupleSizeOfBool = 1;
const tupleSizeOfDouble = 9;

@inline
int tupleSizeOfInt(int number) {
  if (number >= -0x20) {
    return 1;
  }
  if (number >= -127 && number <= 127) {
    return 2;
  }
  if (number >= -327678 && number <= 0xFFFF) {
    return 3;
  }
  if (number >= -2147483648 && number <= 0xFFFFFFFF) {
    return 5;
  }
  return 9;
}

@inline
int tupleSizeOfString(int length) {
  if (length <= 0x1F) {
    return 1 + length;
  }
  if (length <= 0xFFFF) {
    return 2 + length;
  }
  if (length <= 0xFFFFFFFF) {
    return 3 + length;
  }
  return 5 + length;
}

@inline
int tupleSizeOfBinary(int length) {
  if (length <= 0xFF) {
    return 2 + length;
  }
  if (length <= 0xFFFF) {
    return 3 + length;
  }
  return 5 + length;
}

@inline
int tupleSizeOfList(int length) {
  if (length <= 0xF) {
    return 1;
  }
  if (length <= 0xFFFF) {
    return 3;
  }
  return 5;
}

@inline
int tupleSizeOfMap(int length) {
  if (length <= 0xF) {
    return 1;
  }
  if (length <= 0xFFFF) {
    return 3;
  }
  return 5;
}

@inline
int tupleWriteNull(ByteData data, int offset) {
  data.setUint8(offset++, 0xc0);
  return offset;
}

@inline
int tupleWriteBool(ByteData data, bool value, int offset) {
  data.setUint8(offset++, value ? 0xc3 : 0xc2);
  return offset;
}

@inline
int tupleWriteInt(ByteData data, int value, int offset) {
  if (value >= 0) {
    if (value <= 0x7f) {
      data.setUint8(offset++, value);
      return offset;
    }
    if (value <= 0xFF) {
      data.setUint8(offset++, 0xcc);
      data.setUint8(offset++, value);
    }
    if (value <= 0xFFFF) {
      data.setUint8(offset++, 0xcd);
      data.setUint16(offset, value);
      return offset + 2;
    }
    if (value <= 0xFFFFFFFF) {
      data.setUint8(offset++, 0xce);
      data.setUint32(offset, value);
      return offset + 4;
    }
    data.setUint8(offset++, 0xcf);
    data.setUint64(offset, value);
    return offset + 8;
  }
  if (value >= -0x20) {
    data.setUint8(offset++, value);
    return offset;
  }
  if (value >= -128) {
    data.setUint8(offset++, 0xd0);
    data.setInt8(offset++, value);
    return offset;
  }
  if (value >= -32768) {
    data.setUint8(offset++, 0xd1);
    data.setInt16(offset, value);
    return offset + 2;
  }
  if (value >= -2147483648) {
    data.setUint8(offset++, 0xd2);
    data.setInt32(offset, value);
    return offset + 4;
  }
  data.setUint8(offset++, 0xd3);
  data.setInt64(offset, value);
  return offset + 8;
}

@inline
int tupleWriteDouble(ByteData data, double value, int offset) {
  data.setUint8(offset++, 0xcb);
  data.setFloat64(offset, value);
  return offset + 8;
}

@inline
int tupleWriteString(Uint8List buffer, ByteData data, String value, int offset) {
  final length = value.length;
  if (length <= 0x1F) {
    data.setUint8(offset++, 0xA0 | length);
    value.encode(buffer, offset);
    return offset + length;
  }
  if (length <= 0xFF) {
    data.setUint8(offset++, 0xd9);
    data.setUint8(offset++, length);
    value.encode(buffer, offset);
    return offset + length;
  }
  if (length <= 0xFFFF) {
    data.setUint8(offset++, 0xda);
    data.setUint16(offset, length);
    offset += 2;
    value.encode(buffer, offset);
    return offset + length;
  }
  if (length <= 0xFFFFFFFF) {
    data.setUint8(offset++, 0xdb);
    data.setUint32(offset, length);
    offset += 4;
    value.encode(buffer, offset);
    return offset + length;
  }
  throw ArgumentError(TupleErrors.maxStringLength);
}

@inline
int tupleWriteBinary(Uint8List buffer, ByteData data, Uint8List value, int offset) {
  final length = value.length;
  if (length <= 0xFF) {
    data.setUint8(offset++, 0xc4);
    data.setUint8(offset++, length);
    buffer.setRange(offset, offset + length, value);
    return offset + length;
  }
  if (length <= 0xFFFF) {
    buffer[offset++] = 0xc5;
    data.setUint16(offset, length);
    offset += 2;
    buffer.setRange(offset, offset + length, value);
    return offset + length;
  }
  if (length <= 0xFFFFFFFF) {
    data.setUint8(offset++, 0xc6);
    data.setUint32(offset, length);
    offset += 4;
    buffer.setRange(offset, offset + length, value);
    return offset + length;
  }
  throw ArgumentError(TupleErrors.maxBinaryLength);
}

@inline
int tupleWriteList(ByteData data, int length, int offset) {
  if (length <= 0xF) {
    data.setUint8(offset++, 0x90 | length);
    return offset;
  }
  if (length <= 0xFFFF) {
    data.setUint8(offset++, 0xdc);
    data.setUint16(offset, length);
    return offset + 2;
  }
  if (length <= 0xFFFFFFFF) {
    data.setUint8(offset++, 0xdd);
    data.setUint32(offset, length);
    return offset + 4;
  }
  throw ArgumentError(TupleErrors.maxListLength);
}

@inline
int tupleWriteMap(ByteData data, int length, int offset) {
  if (length <= 0xF) {
    data.setUint8(offset++, 0x80 | length);
    return offset;
  }
  if (length <= 0xFFFF) {
    data.setUint8(offset++, 0xde);
    data.setUint16(offset, length);
    return offset + 2;
  }
  if (length <= 0xFFFFFFFF) {
    data.setUint8(offset++, 0xdf);
    data.setUint32(offset, length);
    return offset + 4;
  }
  throw ArgumentError(TupleErrors.maxMapLength);
}

@inline
({bool? value, int offset}) tupleReadBool(ByteData data, int offset) {
  final value = data.getUint8(offset);
  switch (value) {
    case 0xc2:
      return (value: false, offset: offset + 1);
    case 0xc3:
      return (value: true, offset: offset + 1);
    case 0xc0:
      return (value: null, offset: offset + 1);
  }
  throw FormatException(TupleErrors.notBool(value));
}

@inline
({int? value, int offset}) tupleReadInt(ByteData data, int offset) {
  final bytes = data.getUint8(offset);
  int? value;
  if (bytes <= 0x7f || bytes >= 0xe0) {
    value = data.getInt8(offset);
    return (value: value, offset: offset + 1);
  }
  switch (bytes) {
    case 0xcc:
      value = data.getUint8(++offset);
      return (value: value, offset: offset + 1);
    case 0xcd:
      value = data.getUint16(++offset);
      return (value: value, offset: offset + 2);
    case 0xce:
      value = data.getUint32(++offset);
      return (value: value, offset: offset + 4);
    case 0xcf:
      value = data.getUint64(++offset);
      return (value: value, offset: offset + 8);
    case 0xd0:
      value = data.getInt8(++offset);
      return (value: value, offset: offset + 1);
    case 0xd1:
      value = data.getInt16(++offset);
      return (value: value, offset: offset + 2);
    case 0xd2:
      value = data.getInt32(++offset);
      return (value: value, offset: offset + 4);
    case 0xd3:
      value = data.getInt64(++offset);
      return (value: value, offset: offset + 8);
    case 0xc0:
      value = null;
      return (value: value, offset: offset + 1);
  }
  throw FormatException(TupleErrors.notInt(value));
}

@inline
({double? value, int offset}) tupleReadDouble(ByteData data, int offset) {
  final bytes = data.getUint8(offset);
  double? value;
  switch (bytes) {
    case 0xca:
      value = data.getFloat32(++offset);
      return (value: value, offset: offset + 4);
    case 0xcb:
      value = data.getFloat64(++offset);
      return (value: value, offset: offset + 8);
    case 0xc0:
      value = null;
      return (value: value, offset: offset + 1);
  }
  throw FormatException(TupleErrors.notDouble(value));
}

@inline
({String? value, int offset}) tupleReadString(Uint8List buffer, ByteData data, int offset) {
  final byte = data.getUint8(offset);
  final innerBuffer = buffer.buffer;
  final offsetInBytes = buffer.offsetInBytes;
  if (byte == 0xc0) {
    return (value: null, offset: offset + 1);
  }
  int length;
  if (byte & 0xE0 == 0xA0) {
    length = byte & 0x1F;
    offset += 1;
    final view = innerBuffer.asUint8List(offsetInBytes + offset, length);
    return (value: _decoder.convert(view), offset: offset + length);
  }
  switch (byte) {
    case 0xc0:
      return (value: null, offset: offset + 1);
    case 0xd9:
      length = data.getUint8(++offset);
      offset += 1;
      return (value: _decoder.convert(innerBuffer.asUint8List(offsetInBytes + offset, length)), offset: offset + length);
    case 0xda:
      length = data.getUint16(++offset);
      offset += 2;
      return (value: _decoder.convert(innerBuffer.asUint8List(offsetInBytes + offset, length)), offset: offset + length);
    case 0xdb:
      length = data.getUint32(++offset);
      offset += 4;
      return (value: _decoder.convert(innerBuffer.asUint8List(offsetInBytes + offset, length)), offset: offset + length);
  }
  throw FormatException(TupleErrors.notString(byte));
}

@inline
({Uint8List value, int offset}) tupleReadBinary(Uint8List buffer, ByteData data, int offset) {
  final byte = data.getUint8(offset);
  final innerBuffer = buffer.buffer;
  final offsetInBytes = buffer.offsetInBytes;
  int length;
  switch (byte) {
    case 0xc4:
      length = data.getUint8(++offset);
      offset += 1;
      return (value: innerBuffer.asUint8List(offsetInBytes + offset, length), offset: offset + length);
    case 0xc0:
      length = 0;
      offset += 1;
      return (value: innerBuffer.asUint8List(offsetInBytes + offset, length), offset: offset + length);
    case 0xc5:
      length = data.getUint16(++offset);
      offset += 2;
      return (value: innerBuffer.asUint8List(offsetInBytes + offset, length), offset: offset + length);
    case 0xc6:
      length = data.getUint32(++offset);
      offset += 4;
      return (value: innerBuffer.asUint8List(offsetInBytes + offset, length), offset: offset + length);
  }
  throw FormatException(TupleErrors.notBinary(byte));
}

@inline
({int length, int offset}) tupleReadList(ByteData data, int offset) {
  final byte = data.getUint8(offset);
  if (byte & 0xF0 == 0x90) {
    return (length: byte & 0xF, offset: offset + 1);
  }
  switch (byte) {
    case 0xc0:
      return (length: offset += 1, offset: 0);
    case 0xdc:
      return (length: data.getUint16(++offset), offset: offset + 2);
    case 0xdd:
      return (length: data.getUint32(++offset), offset: offset + 4);
  }
  throw FormatException(TupleErrors.notList(byte));
}

@inline
({int length, int offset}) tupleReadMap(ByteData data, int offset) {
  final byte = data.getUint8(offset);
  if (byte & 0xF0 == 0x80) {
    return (length: byte & 0xF, offset: offset + 1);
  }
  switch (byte) {
    case 0xc0:
      return (length: offset += 1, offset: 0);
    case 0xde:
      return (length: data.getUint16(++offset), offset: offset + 2);
    case 0xdf:
      return (length: data.getUint32(++offset), offset: offset + 4);
  }
  throw FormatException(TupleErrors.notMap(byte));
}

int tupleDynamicSize(dynamic value) {
  if (value == null) {
    return tupleSizeOfNull;
  }
  if (value is int) {
    return value.tupleSize;
  }
  if (value is double) {
    return tupleSizeOfDouble;
  }
  if (value is bool) {
    return tupleSizeOfBool;
  }
  if (value is String) {
    return value.tupleSize;
  }
  if (value is Uint8List) {
    return value.tupleSize;
  }
  if (value is Iterable) {
    return value.computeTupleSize();
  }
  if (value is Map) {
    return value.computeTupleSize();
  }
  if (value is Tuple) {
    return value.tupleSize;
  }
  throw ArgumentError(TupleErrors.unknownType(value.runtimeType));
}

int tupleDynamicSerialize(dynamic value, Uint8List buffer, ByteData data, int offset) {
  if (value == null) {
    return tupleWriteNull(data, offset);
  }
  if (value is int) {
    return tupleWriteInt(data, value, offset);
  }
  if (value is double) {
    return tupleWriteDouble(data, value, offset);
  }
  if (value is bool) {
    return tupleWriteBool(data, value, offset);
  }
  if (value is String) {
    return tupleWriteString(buffer, data, value, offset);
  }
  if (value is Uint8List) {
    return tupleWriteBinary(buffer, data, value, offset);
  }
  if (value is Iterable) {
    return value.serializeToTuple(buffer, data, offset);
  }
  if (value is Map) {
    return value.serializeToTuple(buffer, data, offset);
  }
  if (value is Tuple) {
    return value.serialize(buffer, data, offset);
  }
  throw ArgumentError(TupleErrors.unknownType(value.runtimeType));
}

abstract mixin class Tuple {
  int get tupleSize;
  int serialize(Uint8List buffer, ByteData data, int offset);
}

extension TupleIntExtension on int {
  @inline
  int get tupleSize => tupleSizeOfInt(this);

  @inline
  int writeToTuple(ByteData data, int offset) => tupleWriteInt(data, this, offset);
}

extension TupleDoubleExtension on double {
  @inline
  int get tupleSize => tupleSizeOfDouble;

  @inline
  int writeToTuple(ByteData data, int offset) => tupleWriteDouble(data, this, offset);
}

extension TupleBooleanExtension on bool {
  @inline
  int get tupleSize => tupleSizeOfBool;

  @inline
  int writeToTuple(ByteData data, int offset) => tupleWriteBool(data, this, offset);
}

extension TupleStringExtension on String {
  @inline
  int get tupleSize => tupleSizeOfString(length);

  @inline
  int writeToTuple(Uint8List buffer, ByteData data, int offset) => tupleWriteString(buffer, data, this, offset);
}

extension TupleBinaryExtension on Uint8List {
  @inline
  int get tupleSize => tupleSizeOfBinary(length);

  @inline
  int writeToTuple(Uint8List buffer, ByteData data, int offset) => tupleWriteBinary(buffer, data, this, offset);
}

extension TupleMapExtension<K, V> on Map<K, V> {
  @inline
  int get tupleSize => tupleSizeOfMap(length);

  @inline
  int writeToTuple(Uint8List buffer, ByteData data, int offset) => tupleWriteMap(data, length, offset);

  @inline
  int computeTupleSize() {
    var size = tupleSize;
    for (var entry in entries) {
      size += tupleDynamicSize(entry.key);
      size += tupleDynamicSize(entry.value);
    }
    return size;
  }

  @inline
  int serializeToTuple(Uint8List buffer, ByteData data, int offset) {
    offset = tupleWriteMap(data, length, offset);
    for (var entry in entries) {
      offset = tupleDynamicSerialize(entry.key, buffer, data, offset);
      offset = tupleDynamicSerialize(entry.value, buffer, data, offset);
    }
    return offset;
  }
}

extension TupleIterableExtension<T> on Iterable<T> {
  @inline
  int get tupleSize => tupleSizeOfList(length);

  @inline
  int writeToTuple(Uint8List buffer, ByteData data, int offset) => tupleWriteList(data, length, offset);

  @inline
  int computeTupleSize() {
    var size = tupleSize;
    for (var entry in this) {
      size += tupleDynamicSize(entry);
    }
    return size;
  }

  @inline
  int serializeToTuple(Uint8List buffer, ByteData data, int offset) {
    offset = tupleWriteList(data, length, offset);
    for (var entry in this) {
      offset = tupleDynamicSerialize(entry, buffer, data, offset);
    }
    return offset;
  }
}