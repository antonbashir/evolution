import 'dart:async';
import 'dart:io';

import 'package:storage/storage.dart';
import 'package:test/test.dart';

import 'crud.dart';
import 'data.dart';
import 'lua.dart';
import 'schema.dart';

late final StorageExecutor executor;
late final StorageModule storage;
late final StorageSpace space;
late final StorageIndex index;

final testKey = [10];
final testSingleData = TestData(10, "test", true);
final testMultipleData = Iterable.generate(10, (index) => [index + 1, "key-${index}", "value"]).toList();

Future<void> main() async {
  Directory.current.listSync().forEach((element) {
    if (element.path.contains("00000")) element.deleteSync();
  });
  storage = StorageModule();
  await storage.boot(
    StorageBootstrapScript(StorageDefaults.storage)..file(File("test/test.lua")),
    StorageDefaults.executor,
    bootConfiguration: StorageDefaults.boot(),
  );
  setUpAll(() async {
    executor = storage.executor;
    final spaceId = await executor.schema.spaceId("test");
    space = executor.schema.spaceById(spaceId);
    index = executor.schema.indexById(spaceId, await executor.schema.indexId(spaceId, "test"));
  });
  setUp(() async => await space.truncate());
  tearDownAll(() async {
    await storage.shutdown();
    Directory.current.listSync().forEach((element) {
      if (element.path.contains("00000")) element.deleteSync();
    });
  });

  test("[lua]", testLua);
  group(["schema"], testSchema);
  group("[crud]", testCrud);
  await Future.delayed(Duration(days: 1));

  // // group("[isolate crud]", () {
  // //   test("multi isolate batch", testMultiIsolateInsert);
  // //   test("multi isolate transactional batch", testMultiIsolateTransactionalInsert);
  // // });

  // group("[execution]", () {
  //   //   test("execute native", testExecuteNative);
  //   test("execute lua", testExecuteLua);
  // });
}


//
//Future<void> testExecuteNative() async => expect((await _executor.native.call(_storage.bindings.addresses.storage_is_read_only.cast())).address, equals(0));
//
//Future<void> testIterator() async {
//  await Future.wait(testMultipleData.map(_space.insertSingle));
//  expect((await (await _space.iterator()).next(count: 1))!.length, 1);
//  expect((await (await _space.iterator()).next())!.first, equals(testMultipleData[0]));
//  expect(await (await _space.iterator()).collect(), equals(testMultipleData));
//  expect(await (await _index.iterator()).collect(), equals(testMultipleData));
//  expect(
//    await (await _space.iterator()).collect(map: (value) => value[2], filter: (value) => value[0] != 3, offset: 1, limit: 3),
//    equals(testMultipleData.where((element) => element[0] != 3).skip(1).take(2).map((data) => data[2]).toList()),
//  );
//}
//
//Future<void> testMultiIsolateInsert() async {
//  final count = 1000;
//  final ports = <ReceivePort>[];
//  final data = [];
//  for (var i = 0; i < count; i++) {
//    ReceivePort port = ReceivePort();
//    ports.add(port);
//    final element = [...testSingleData];
//    element[0] = i + 1;
//    element[1] = "key-${i + 1}";
//    data.add(element);
//    Isolate.spawn<dynamic>((element) async {
//      final storage = Storage();
//      await storage.executor.schema.spaceByName("test").then((space) => space.insertSingle(element));
//      storage.close();
//    }, element, onExit: port.sendPort);
//  }
//  for (var port in ports) {
//    await port.first;
//  }
//  ports.forEach((port) => port.close());
//  expect(await _space.select(), equals(data));
//}