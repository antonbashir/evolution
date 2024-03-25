import 'dart:io';

import 'package:memory/memory.dart';
import 'package:storage/storage.dart';
import 'package:test/test.dart';

import 'test.dart';

Future<void> testLua() async {
  await storage.evaluate("function test() return {'test'} end");
  File("test.lua").writeAsStringSync("function testFile() return {'testFile'} end");
  await storage.file(File("test.lua"));
  File("test.lua").deleteSync();
  expect(tarantoolCallExtractList(await storage.call("test"), tupleReadString), equals(["test"]));
  expect(tarantoolCallExtractList(await storage.call("testFile"), tupleReadString), equals(["testFile"]));
}
