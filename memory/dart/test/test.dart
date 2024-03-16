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

void main(List<String> args) {
  launch((creator) => creator.create(CoreModule(), CoreDefaults.module).create(MemoryModule(), MemoryDefaults.module)).activate(() {
    final writer = context().tuples().dynamic.input();
    writer.writeList(10000 * 3);
    final sw = Stopwatch();
    sw.start();
    for (var i = 0; i < 10000; i++) {
      writer.writeInt(123);
      writer.writeString("test");
      writer.writeTuple(TestData(1, "test"));
    }
    writer.flush();
    print(sw.elapsedMicroseconds);
  });
}
