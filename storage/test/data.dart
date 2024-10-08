import 'dart:ffi';
import 'dart:typed_data';

import 'package:memory/memory.dart';
import 'package:storage/storage/tuple.dart';

class TestData implements Tuple {
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

  TestData copyWith({
    final int? a,
    final String? b,
    final bool? c,
  }) =>
      TestData(
        a ?? this.a,
        b ?? this.b,
        c ?? this.c,
      );
}

TestData readTestData(StorageTuple tuple) {
  final size = tuple.size;
  final pointer = tuple.data;
  final buffer = pointer.cast<Uint8>().asTypedList(size);
  final data = ByteData.view(buffer.buffer, buffer.offsetInBytes);
  return TestData.deserialize(buffer, data, 0);
}

final testPrimaryKey = [10];
final testSecondaryKey = ["test"];
final testSingleData = TestData(10, "test", true);
final testMultipleData = Iterable<TestData>.generate(10, (index) => TestData(index + 1, "key-${index}", true)).toList();
