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

({Pointer<Uint8> tuple, int size, void Function() cleaner}) _primaryKey() {
  return context().tuples().fixed.toInput(testSingleData.tupleSize, testPrimaryKey.serializeToTuple);
}

({Pointer<Uint8> tuple, int size, void Function() cleaner}) _secondaryKey() {
  return context().tuples().fixed.toInput(testSecondaryKey.computeTupleSize(), testSecondaryKey.serializeToTuple);
}

({Pointer<Uint8> tuple, int size, void Function() cleaner}) _updateOperations(List<StorageUpdateOperation> operation) {
  return context().tuples().fixed.toInput(operation.computeTupleSize(), operation.serializeToTuple);
}

Future<TestData> _parseSingle(Future<StorageTuple> response, [void Function()? requestCleaner]) {
  return response.whenComplete(requestCleaner ?? () {}).then((value) => readTestData(storage.tuples, value));
}

Future<List<TestData>> _parseMultiple(Future<StorageTuplePort> response, [void Function()? requestCleaner]) async {
  final port = await response.whenComplete(requestCleaner ?? () {});
  return port.iterate().map((tuple) => readTestData(storage.tuples, tuple)).toList();
}

Future<void> _insertSingle() async {
  final data = _singleData();
  expect(await _parseSingle(space.insertSingle(data.tuple, data.size), data.cleaner), equals(testSingleData));
}

Future<void> _putSingle() async {
  final data = _singleData();
  expect(await _parseSingle(space.putSingle(data.tuple, data.size), data.cleaner), equals(testSingleData));
}

Future<void> _getSpace() async {
  final key = _primaryKey();
  expect(await _insertSingle().then((value) => _parseSingle(space.get(key.tuple, key.size), key.cleaner)), equals(testSingleData));
}

Future<void> _minSpace() async {
  expect(await _insertSingle().then((value) => _parseSingle(space.min())), equals(testSingleData));
}

Future<void> _maxSpace() async {
  expect(await _insertSingle().then((value) => _parseSingle(space.max())), equals(testSingleData));
}

Future<void> _isEmptySpace() async {
  expect(await space.isEmpty(), isTrue);
}

Future<void> _countSpace() async {
  expect(await _insertSingle().then((value) => space.count()), equals(1));
}

Future<void> _getIndex() async {
  final key = _secondaryKey();
  expect(await _insertSingle().then((value) => _parseSingle(index.get(key.tuple, key.size), key.cleaner)), equals(testSingleData));
}

Future<void> _minIndex() async {
  expect(await _insertSingle().then((value) => _parseSingle(index.min())), equals(testSingleData));
}

Future<void> _maxIndex() async {
  expect(await _insertSingle().then((value) => _parseSingle(index.max())), equals(testSingleData));
}

Future<void> _isEmptyIndex() async {
  expect(await index.isEmpty(), isTrue);
}

Future<void> _countIndex() async {
  expect(await _insertSingle().then((value) => index.count()), equals(1));
}

Future<void> _deleteSingle() async {
  final key = _primaryKey();
  expect(await _insertSingle().then((value) => _parseSingle(space.deleteSingle(key.tuple, key.size), key.cleaner)), equals(testSingleData));
  await _isEmptySpace();
}

Future<void> _updateSingleSpace() async {
  final key = _primaryKey();
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

Future<void> _selectSpace() async {
  final data = _multipleData();
  await space.insertMany(data.tuple, data.size);
  expect(await _parseMultiple(space.select()), equals(testMultipleData));
  expect(await _parseMultiple(index.select(), data.cleaner), equals(testMultipleData));
}

void testCrud() {
  test("insert", _insertSingle);
  test("put", _putSingle);
  test("[space] get", _getSpace);
  test("[space] min", _minSpace);
  test("[space] max", _maxSpace);
  test("[space] isEmpty", _isEmptySpace);
  test("[space] count", _countSpace);
  test("[index] get", _getIndex);
  test("[index] min", _minIndex);
  test("[index] max", _maxIndex);
  test("[index] isEmpty", _isEmptyIndex);
  test("[index] count", _countIndex);
  test("delete", _deleteSingle);
  test("update", _updateSingleSpace);
  test("select", _selectSpace);

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
