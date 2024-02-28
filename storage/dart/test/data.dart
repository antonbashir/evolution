import 'dart:ffi';
import 'dart:typed_data';

import 'package:memory/memory.dart';
import 'package:storage/storage.dart';
import 'package:storage/storage/tuple.dart';

class TestData implements MemoryTuple {
  final int a;
  final String b;
  final bool c;

  TestData(this.a, this.b, this.c);

  @override
  int serialize(Uint8List buffer, ByteData data, int offset) {
    offset = tupleWriteList(data, 3, offset);
    offset = a.writeToTuple(data, offset);
    offset = b.writeToTuple(buffer, data, offset);
    offset = c.writeToTuple(data, offset);
    return offset;
  }

  factory TestData.deserialize(Uint8List buffer, ByteData data, int offset) {
    final result = tupleReadList(data, offset);
    final a = tupleReadInt(data, result.offset);
    final b = tupleReadString(buffer, data, a.offset);
    final c = tupleReadBool(data, b.offset);
    return TestData(a.value!, b.value!, c.value!);
  }

  @override
  bool operator ==(Object other) => other is TestData && other.a == a && other.b == b && other.c == c;

  @override
  int get tupleSize => tupleSizeOfList(3) + a.tupleSize + b.tupleSize + c.tupleSize;
}

({Pointer<Uint8> tuple, int size, void Function() cleaner}) writeTestData(MemoryInputOutputBuffers buffers, TestData tuple) {
  final inputBuffer = buffers.allocateInputBuffer(tuple.tupleSize);
  final reserved = inputBuffer.reserve(tuple.tupleSize);
  final buffer = reserved.cast<Uint8>().asTypedList(tuple.tupleSize);
  final data = ByteData.view(buffer.buffer, buffer.offsetInBytes);
  inputBuffer.finalize(tuple.serialize(buffer, data, 0));
  return (tuple: inputBuffer.readPosition, size: tuple.tupleSize, cleaner: () => buffers.freeInputBuffer(inputBuffer));
}

TestData readTestData(MemoryTuples tuples, Pointer<tarantool_tuple> tuple) {
  int size = tuple.size;
  final pointer = tuple.data;
  final buffer = pointer.cast<Uint8>().asTypedList(size);
  final data = ByteData.view(buffer.buffer, buffer.offsetInBytes);
  return TestData.deserialize(buffer, data, 0);
}

({Pointer<Uint8> tuple, int size, void Function() cleaner}) writeTestKey(MemoryInputOutputBuffers buffers, List tuple) {
  final inputBuffer = buffers.allocateInputBuffer(tuple.computeTupleSize());
  final reserved = inputBuffer.reserve(tuple.computeTupleSize());
  final buffer = reserved.cast<Uint8>().asTypedList(tuple.computeTupleSize());
  final data = ByteData.view(buffer.buffer, buffer.offsetInBytes);
  inputBuffer.finalize(tuple.serializeToTuple(buffer, data, 0));
  return (tuple: inputBuffer.readPosition, size: tuple.computeTupleSize(), cleaner: () => buffers.freeInputBuffer(inputBuffer));
}
