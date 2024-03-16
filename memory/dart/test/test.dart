import 'dart:typed_data';

import 'package:memory/memory.dart';
import 'package:test/test.dart';

class TestData with Tuple {
  final int a;
  final String b;

  @override
  int get tupleSize => tupleSizeOfList(2) + tupleSizeOfInt(a) + tupleSizeOfString(b.length);

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
  String toString() => "$a $b";

  @override
  operator ==(Object other) => other is TestData && other.a == a && other.b == b;
}

void main(List<String> args) {
  test(
    "[tuples][dynamic][input]: read-write ",
    () => launch((creator) => creator.create(CoreModule(), CoreDefaults.module).create(MemoryModule(), MemoryDefaults.module)).activate(() {
      final data = TestData(1, "test");
      final buffer = context().inputOutputBuffers().allocateInputBuffer();
      final writer = context().tuples().dynamic.input(buffer);
      writer.writeList(10000);
      for (var i = 0; i < 10000; i++) writer.writeTuple(data);
      writer.flush();
      final reader = writer.buffer.wrapRead();
      var read = tupleReadList(reader.data, 0);
      expect(read.length, equals(10000));
      var offset = read.offset;
      for (var i = 0; i < read.length; i++) {
        final parsed = TestData.deserialize(reader.buffer, reader.data, offset);
        expect(parsed.data, equals(data));
        offset = parsed.offset;
      }
      context().inputOutputBuffers().freeInputBuffer(buffer);
    }),
  );
  test(
    "[tuples][dynamic][output]: read-write ",
    () => launch((creator) => creator.create(CoreModule(), CoreDefaults.module).create(MemoryModule(), MemoryDefaults.module)).activate(() {
      final data = TestData(1, "test");
      final buffer = context().inputOutputBuffers().allocateOutputBuffer();
      final writer = context().tuples().dynamic.output(buffer);
      writer.writeList(10000);
      for (var i = 0; i < 10000; i++) writer.writeTuple(data);
      writer.flush();
      final reader = writer.buffer.wrap();
      var read = tupleReadList(reader.data, 0);
      expect(read.length, equals(10000));
      var offset = read.offset;
      for (var i = 0; i < read.length; i++) {
        final parsed = TestData.deserialize(reader.buffer, reader.data, offset);
        expect(parsed.data, equals(data));
        offset = parsed.offset;
      }
      context().inputOutputBuffers().freeOutputBuffer(buffer);
    }),
  );
}
