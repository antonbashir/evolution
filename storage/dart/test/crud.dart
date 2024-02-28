import 'dart:ffi';

import 'package:storage/storage.dart';
import 'package:test/test.dart';

import 'data.dart';
import 'test.dart';

Future<({Pointer<Uint8> tuple, int size, void Function() cleaner})> _writeData() => Future.value(writeTestData(executor.memory.inputOutputBuffers, testSingleData));
Future<({Pointer<Uint8> tuple, int size, void Function() cleaner})> _writeKey() => Future.value(writeTestKey(executor.memory.inputOutputBuffers, testKey));
Future<TestData> _readData(Future<Pointer<tarantool_tuple>> response, void Function() requestCleaner) => response.whenComplete(requestCleaner).then((value) => readTestData(executor.tuples, value));

Future<void> _insert() async => expect(await _writeData().then((value) => _readData(space.insertSingle(value.tuple, value.size), value.cleaner)), equals(testSingleData));
Future<void> _put() async => expect(await _writeData().then((value) => _readData(space.putSingle(value.tuple, value.size), value.cleaner)), equals(testSingleData));
Future<void> _get() async => expect(await _insert().then((value) => _writeKey().then((key) => _readData(space.get(key.tuple, key.size), key.cleaner))), equals(testSingleData));
Future<void> _min() async => expect(await _insert().then((value) => _writeKey().then((key) => _readData(space.min(), key.cleaner))), equals(testSingleData));
Future<void> _max() async => expect(await _insert().then((value) => _writeKey().then((key) => _readData(space.max(), key.cleaner))), equals(testSingleData));
Future<void> _isEmpty() async => expect(await space.isEmpty(), isTrue);
Future<void> _count() async => expect(await _insert().then((value) => space.count()), equals(1));
Future<void> _delete() async {
  expect(await _insert().then((value) => _writeKey().then((key) => _readData(space.deleteSingle(key.tuple, key.size), key.cleaner))), equals(testSingleData));
  await _isEmpty();
}

void testCrud() {
  test("insert", _insert);
  test("put", _put);
  test("get", _get);
  test("min", _min);
  test("max", _max);
  test("isEmpty", _isEmpty);
  test("count", _count);
  test("delete", _delete);

  // test("update", () async {
  //   final data = [...testSingleData];
  //   _space.insert(data);
  //   data[2] = "updated";
  //   expect(await _space.update([1], [StorageUpdateOperation.assign(2, "updated")]), equals(data));
  // });

  // test("select", () async {
  //   await Future.wait(testMultipleData.map(_space.insert));
  //   expect(await _space.select(), equals(testMultipleData));
  //   expect(await _index.select(), equals(testMultipleData));
  // });

  // test("get by index", () async {
  //   _space.insert(testSingleData);
  //   expect(await _index.get(["key"]), equals(testSingleData));
  // });
  // test("min by index", () async {
  //   _space.insert(testSingleData);
  //   expect(await _index.min(), equals(testSingleData));
  // });
  // test("max by index", () async {
  //   _space.insert(testSingleData);
  //   expect(await _index.min(), equals(testSingleData));
  // });
  // test("update by index", () async {
  //   final data = [...testSingleData];
  //   _space.insert(data);
  //   data[2] = "updated by index";
  //   expect(await _index.update(["key"], [StorageUpdateOperation.assign(2, "updated by index")]), equals(data));
  // });

  // test("batch insert", () async {
  //   expect(await _space.batch((builder) => builder..insertMany(testMultipleData)), equals(testMultipleData));
  // });
  // test("batch put", () async {
  //   expect(await _space.batch((builder) => builder..putMany(testMultipleData)), equals(testMultipleData));
  // });
  // test("batch update", () async {
  //   await _space.batch((builder) => builder..insertMany(testMultipleData));
  //   final data = [];
  //   data.add([...testMultipleData[0]]);
  //   data.add([...testMultipleData[1]]);
  //   data[0][2] = "updated";
  //   data[1][2] = "updated";
  //   expect(
  //       await _space.batch((builder) => builder
  //         ..update([1], [StorageUpdateOperation.assign(2, "updated")])
  //         ..update([2], [StorageUpdateOperation.assign(2, "updated")])),
  //       equals(data));
  // });
  // test("batch index update", () async {
  //   await _space.batch((builder) => builder..insertMany(testMultipleData));
  //   final data = [];
  //   data.add([...testMultipleData[0]]);
  //   data.add([...testMultipleData[1]]);
  //   data[0][2] = "updated";
  //   data[1][2] = "updated";
  //   expect(
  //       await _index.batch((builder) => builder
  //         ..update(["key-0"], [StorageUpdateOperation.assign(2, "updated")])
  //         ..update(["key-1"], [StorageUpdateOperation.assign(2, "updated")])),
  //       equals(data));
  // });
  // test("pairs iterator", testIterator);
  // test("fail with error", () async {
  //   await _space.insert(testSingleData);
  //   expect(
  //       () async => await _space.insert(testSingleData),
  //       throwsA(predicate((exception) =>
  //           exception is StorageExecutionException &&
  //           exception.toString() == """Duplicate key exists in unique index "primary" in space "test" with old tuple - [1, "key", "value"] and new tuple - [1, "key", "value"]""")));
  // });
}
