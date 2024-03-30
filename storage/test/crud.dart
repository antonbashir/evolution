import 'dart:ffi';

import 'package:storage/storage.dart';
import 'package:test/test.dart';

import 'data.dart';
import 'test.dart';

({Pointer<Uint8> tuple, int size, void Function() cleaner}) _singleData() {
  return context().tuples().fixed.toInput(testSingleData.tupleSize, testSingleData.serialize);
}

({Pointer<Uint8> tuple, int size, void Function() cleaner}) _multipleData() {
  return context().tuples().fixed.toInput(testMultipleData.computeTupleSize(), testMultipleData.serializeToTuple);
}

({Pointer<Uint8> tuple, int size, void Function() cleaner}) _key() {
  return context().tuples().fixed.toInput(testSingleData.tupleSize, testKey.serializeToTuple);
}

({Pointer<Uint8> tuple, int size, void Function() cleaner}) _updateOperations(List<StorageUpdateOperation> operation) {
  return context().tuples().fixed.toInput(operation.computeTupleSize(), operation.serializeToTuple);
}

Future<TestData> _parseSingle(Future<StorageTuple> response, [void Function()? requestCleaner]) {
  return response.whenComplete(requestCleaner ?? () {}).then((value) => readTestData(storage.tuples, value));
}

Future<List<TestData>> _parseMultiple(Future<StorageTuplePort> response, [void Function()? requestCleaner]) async {
  final port = await response.whenComplete(requestCleaner ?? () {});
  return port.map((tuple) => readTestData(storage.tuples, tuple)).toList();
}

Future<void> _insertSingle() async {
  final data = _singleData();
  expect(await _parseSingle(space.insertSingle(data.tuple, data.size), data.cleaner), equals(testSingleData));
}

Future<void> _putSingle() async {
  final data = _singleData();
  expect(await _parseSingle(space.putSingle(data.tuple, data.size), data.cleaner), equals(testSingleData));
}

Future<void> _get() async {
  final key = _key();
  expect(await _insertSingle().then((value) => _parseSingle(space.get(key.tuple, key.size), key.cleaner)), equals(testSingleData));
}

Future<void> _min() async {
  expect(await _insertSingle().then((value) => _parseSingle(space.min())), equals(testSingleData));
}

Future<void> _max() async {
  expect(await _insertSingle().then((value) => _parseSingle(space.max())), equals(testSingleData));
}

Future<void> _isEmpty() async {
  expect(await space.isEmpty(), isTrue);
}

Future<void> _count() async {
  expect(await _insertSingle().then((value) => space.count()), equals(1));
}

Future<void> _deleteSingle() async {
  final key = _key();
  expect(await _insertSingle().then((value) => _parseSingle(space.deleteSingle(key.tuple, key.size), key.cleaner)), equals(testSingleData));
  await _isEmpty();
}

Future<void> _updateSingle() async {
  final key = _key();
  final operation = _updateOperations([StorageUpdateOperation.assign(1, "updated")]);
  expect(
    await _insertSingle().then(
      (value) => _parseSingle(space.updateSingle(key.tuple, key.size, operation.tuple, operation.size), () {
        key.cleaner();
        operation.cleaner();
      }),
    ),
    equals(testSingleData..b = "updated"),
  );
}

Future<void> _select() async {
  final data = _multipleData();
  await space.insertMany(data.tuple, data.size);
  expect(await _parseMultiple(space.select()), equals(testMultipleData));
  expect(await _parseMultiple(index.select(), data.cleaner), equals(testMultipleData));
}

void testCrud() {
  test("insert", _insertSingle);
  test("put", _putSingle);
  test("get", _get);
  test("min", _min);
  test("max", _max);
  test("isEmpty", _isEmpty);
  test("count", _count);
  test("delete", _deleteSingle);
  test("update", _updateSingle);
  test("select", _select);

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
