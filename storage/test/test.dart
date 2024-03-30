import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:storage/storage.dart';
import 'package:test/test.dart';

import 'crud.dart';
import 'lua.dart';
import 'schema.dart';

late final Storage storage;
late final StorageSpace space;
late final StorageIndex index;

FutureOr<void> runTest(FutureOr<void> Function() test, {List<Module>? overrides}) => launch(
      () =>
          overrides ??
          [
            CoreModule(),
            MemoryModule(),
            ExecutorModule(),
            StorageModule(
              configuration: StorageDefaults.module.copyWith(
                bootConfiguration: StorageDefaults.module.bootConfiguration.copyWith(
                  initialScript: StorageBootstrapScript(StorageDefaults.storage).file(File(path.dirname(Platform.script.path) + '/test.lua')).write(),
                ),
              ),
            ),
          ],
      test,
    );

Future<void> main() async {
  Directory.current.listSync().forEach((element) {
    if (element.path.contains("00000")) element.deleteSync();
  });

  await runTest(() async {
    setUpAll(() async {
      storage = context().storage();
      final spaceId = await storage.schema.spaceId("test");
      space = storage.schema.spaceById(spaceId);
      index = storage.schema.indexById(spaceId, await storage.schema.indexId(spaceId, "test"));
    });
    setUp(() async => await space.truncate());
    tearDownAll(() async {
      Directory.current.listSync().forEach((element) {
        if (element.path.contains("00000")) element.deleteSync();
      });
      unblock();
    });

    test("[lua]", testLua);
    group(["schema"], testSchema);
    group("[crud]", testCrud);
    await block();
  });

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