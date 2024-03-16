import 'dart:typed_data';

import 'package:memory/memory.dart';

class TestData with Tuple {
  final int a;
  final String b;

  TestData(this.a, this.b);

  @override
  int serialize(Uint8List buffer, ByteData data, int offset) {
    offset = tupleWriteList(data, 2, offset);
    offset = tupleWriteInt(data, a, offset);
    offset = tupleWriteString(buffer, data, b, offset);
    return offset;
  }

  static ({TestData data, int offset}) deserialize(Uint8List buffer, ByteData data, int offset) {
    var read = tupleReadList(data, offset);
    var a = tupleReadInt(data, read.offset);
    var b = tupleReadString(buffer, data, a.offset);
    return (data: TestData(a.value!, b.value!), offset: b.offset);
  }

  @override
  int get tupleSize => tupleSizeOfList(2) + tupleSizeOfInt(a) + tupleSizeOfString(b.length);

  @override
  String toString() => "$a $b";
}
