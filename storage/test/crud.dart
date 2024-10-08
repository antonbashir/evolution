import 'dart:async';
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

Future<TestData> _parseSingle(Future<StorageTuple> response, [FutureOr<void> Function()? requestCleaner]) {
  return response.whenComplete(() async => await requestCleaner?.call()).then(readTestData);
}

Future<List<TestData>> _parseMultiple(Future<StorageTuplePort> response, [FutureOr<void> Function()? requestCleaner]) async {
  final port = await response.whenComplete(() async => await requestCleaner?.call());
  return port.iterate().map(readTestData).toList();
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
    equals(testSingleData.copyWith(b: "updated")),
  );
}

Future<void> _updateSingleIndex() async {
  final key = _secondaryKey();
  final operation = _updateOperations([StorageUpdateOperation.assign(1, "updated")]);
  expect(
    await _insertSingle().then(
      (value) => _parseSingle(index.updateSingle(key.tuple, key.size, operation.tuple, operation.size), () {
        key.cleaner();
        operation.cleaner();
      }),
    ),
    equals(testSingleData.copyWith(b: "updated")),
  );
}

Future<void> _select() async {
  final data = _multipleData();
  await space.insertMany(data.tuple, data.size);
  expect(await _parseMultiple(space.select()), equals(testMultipleData));
  expect(await _parseMultiple(index.select(), data.cleaner), equals(testMultipleData));
}

Future<void> _iterator() async {
  final data = _multipleData();
  await space.insertMany(data.tuple, data.size);
  final iterator = await space.iterator();
  final result = await iterator.collect();
  final output = result.map(readTestData).toList();
  expect(output.length, equals(testMultipleData.length));
  expect(output, orderedEquals(testMultipleData));
}

void testCrud() {
  test("[space] insert", _insertSingle);
  test("[space] put", _putSingle);
  test("[space] get", _getSpace);
  test("[space] min", _minSpace);
  test("[space] max", _maxSpace);
  test("[space] isEmpty", _isEmptySpace);
  test("[space] count", _countSpace);
  test("[space] delete", _deleteSingle);
  test("[space] update", _updateSingleSpace);
  test("[space] select", _select);
  test("[index] get", _getIndex);
  test("[index] min", _minIndex);
  test("[index] max", _maxIndex);
  test("[index] isEmpty", _isEmptyIndex);
  test("[index] count", _countIndex);
  test("[index] update", _updateSingleIndex);
  test("[space] iterator", _iterator);
}
