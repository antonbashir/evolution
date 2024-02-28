import 'dart:async';
import 'dart:ffi';

import 'package:core/core.dart';
import 'package:interactor/interactor.dart';
import 'package:memory/memory.dart';

import 'bindings.dart';
import 'constants.dart';
import 'executor.dart';
import 'factory.dart';
import 'iterator.dart';

class StorageSpace {
  final int _id;
  final int _descriptor;
  final StorageProducer _producer;
  final MemoryTuples _tuples;
  final StorageFactory _factory;

  StorageSpace(
    this._id,
    this._descriptor,
    this._producer,
    this._factory,
    this._tuples,
  );

  @inline
  Future<int> count({StorageIteratorType iteratorType = StorageIteratorType.eq}) {
    final (key, keySize) = _tuples.emptyList;
    return countBy(key, keySize, iteratorType: iteratorType);
  }

  @inline
  int _completeCountBy(Pointer<interactor_message> message) {
    final count = message.outputInt;
    _factory.releaseSpaceCount(message.getInputObject());
    return count;
  }

  @inline
  Future<int> countBy(
    Pointer<Uint8> key,
    int keySize, {
    StorageIteratorType iteratorType = StorageIteratorType.eq,
  }) =>
      _producer.spaceCount(_descriptor, _factory.createSpaceCount(_id, iteratorType.index, key, keySize)).then(_completeCountBy);

  @inline
  Future<bool> isEmpty() => length().then((value) => value == 0);

  @inline
  Future<bool> isNotEmpty() => length().then((value) => value != 0);

  @inline
  int _completeLength(Pointer<interactor_message> message) {
    final length = message.outputInt;
    _factory.releaseMessage(message);
    return length;
  }

  @inline
  Future<int> length() => _producer.spaceLength(_descriptor, _factory.createMessage()..inputInt = _id).then(_completeLength);

  @inline
  Future<StorageIterator> iterator({StorageIteratorType iteratorType = StorageIteratorType.eq}) {
    final (key, keySize) = _tuples.emptyList;
    return iteratorBy(key, keySize, iteratorType: iteratorType);
  }

  @inline
  StorageIterator _completeIteratorBy(Pointer<interactor_message> message) {
    final iterator = StorageIterator(message.outputInt, _descriptor, _factory, _producer);
    _factory.releaseSpaceIterator(message.getInputObject());
    return iterator;
  }

  @inline
  Future<StorageIterator> iteratorBy(
    Pointer<Uint8> key,
    int keySize, {
    StorageIteratorType iteratorType = StorageIteratorType.eq,
  }) =>
      _producer.spaceIterator(_descriptor, _factory.createSpaceIterator(_id, iteratorType.index, key, keySize)).then(_completeIteratorBy);

  @inline
  Pointer<tarantool_tuple> _completeInsertSingle(Pointer<interactor_message> message) {
    final tuple = Pointer<tarantool_tuple>.fromAddress(message.outputInt);
    _factory.releaseSpace(message.getInputObject());
    return tuple;
  }

  @inline
  Pointer<tarantool_tuple_port> _completeInsertMany(Pointer<interactor_message> message) {
    final tuple = Pointer<tarantool_tuple_port>.fromAddress(message.outputInt);
    _factory.releaseSpace(message.getInputObject());
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple>> insertSingle(Pointer<Uint8> tuple, int tupleSize) {
    final request = _factory.createSpace(_id, tuple, tupleSize);
    return _producer.spaceInsertSingle(_descriptor, request).then(_completeInsertSingle);
  }

  @inline
  Future<Pointer<tarantool_tuple_port>> insertMany(Pointer<Uint8> tuples, int tuplesCount) {
    final request = _factory.createSpace(_id, tuples.cast(), tuplesCount);
    return _producer.spaceInsertMany(_descriptor, request).then(_completeInsertMany);
  }

  @inline
  Pointer<tarantool_tuple> _completePutSingle(Pointer<interactor_message> message) {
    final tuple = Pointer<tarantool_tuple>.fromAddress(message.outputInt);
    _factory.releaseSpace(message.getInputObject());
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple>> putSingle(Pointer<Uint8> tuple, int tupleSize) {
    final request = _factory.createSpace(_id, tuple, tupleSize);
    return _producer.spaceInsertSingle(_descriptor, request).then(_completePutSingle);
  }

  @inline
  Pointer<tarantool_tuple_port> _completePutMany(Pointer<interactor_message> message) {
    final tuple = Pointer<tarantool_tuple_port>.fromAddress(message.outputInt);
    _factory.releaseSpace(message.getInputObject());
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple_port>> putMany(Pointer<Uint8> tuples, int tuplesCount) {
    final request = _factory.createSpace(_id, tuples, tuplesCount);
    return _producer.spaceInsertMany(_descriptor, request).then(_completePutMany);
  }

  @inline
  Pointer<tarantool_tuple> _completeDeleteSingle(Pointer<interactor_message> message) {
    final tuple = Pointer<tarantool_tuple>.fromAddress(message.outputInt);
    _factory.releaseSpace(message.getInputObject());
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple>> deleteSingle(Pointer<Uint8> key, int keySize) {
    final request = _factory.createSpace(_id, key, keySize);
    return _producer.spaceDeleteSingle(_descriptor, request).then(_completeDeleteSingle);
  }

  @inline
  Pointer<tarantool_tuple_port> _completeDeleteMany(Pointer<interactor_message> message) {
    final tuple = Pointer<tarantool_tuple_port>.fromAddress(message.outputInt);
    _factory.releaseSpace(message.getInputObject());
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple_port>> deleteSingleMany(Pointer<Uint8> keys, int keysCount) {
    final request = _factory.createSpace(_id, keys, keysCount);
    return _producer.spaceDeleteMany(_descriptor, request).then(_completeDeleteMany);
  }

  @inline
  Pointer<tarantool_tuple> _completeGet(Pointer<interactor_message> message) {
    final tuple = Pointer<tarantool_tuple>.fromAddress(message.outputInt);
    _factory.releaseSpace(message.getInputObject());
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple>> get(Pointer<Uint8> key, int keySize) {
    final request = _factory.createSpace(_id, key, keySize);
    return _producer.spaceGet(_descriptor, request).then(_completeGet);
  }

  @inline
  Future<Pointer<tarantool_tuple>> min() {
    final (key, keySize) = _tuples.emptyList;
    return minBy(key, keySize);
  }

  @inline
  Pointer<tarantool_tuple> _completeMin(Pointer<interactor_message> message) {
    final tuple = Pointer<tarantool_tuple>.fromAddress(message.outputInt);
    _factory.releaseSpace(message.getInputObject());
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple>> minBy(Pointer<Uint8> key, int keySize) {
    final request = _factory.createSpace(_id, key, keySize);
    return _producer.spaceMin(_descriptor, request).then(_completeMin);
  }

  @inline
  Future<Pointer<tarantool_tuple>> max() {
    final (key, keySize) = _tuples.emptyList;
    return maxBy(key, keySize);
  }

  @inline
  Pointer<tarantool_tuple> _completeMax(Pointer<interactor_message> message) {
    final tuple = Pointer<tarantool_tuple>.fromAddress(message.outputInt);
    _factory.releaseSpace(message.getInputObject());
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple>> maxBy(Pointer<Uint8> key, int keySize) {
    final request = _factory.createSpace(_id, key, keySize);
    return _producer.spaceMax(_descriptor, request).then(_completeMax);
  }

  @inline
  Future<void> truncate() => _producer.spaceTruncate(_descriptor, _factory.createMessage()..inputInt = _id).then(_factory.releaseMessage);

  @inline
  Pointer<tarantool_tuple> _completeUpdateSingle(Pointer<interactor_message> message) {
    final tuple = Pointer<tarantool_tuple>.fromAddress(message.outputInt);
    _factory.releaseSpaceUpdate(message.getInputObject());
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple>> updateSingle(Pointer<Uint8> key, int keySize, Pointer<Uint8> operations, int operationsSize) {
    final request = _factory.createSpaceUpdate(_id, key, keySize, operations, operationsSize);
    return _producer.spaceUpdateSingle(_descriptor, request).then(_completeUpdateSingle);
  }

  @inline
  Pointer<tarantool_tuple_port> _completeUpdateMany(Pointer<interactor_message> message) {
    final tuple = Pointer<tarantool_tuple_port>.fromAddress(message.outputInt);
    _factory.releaseSpaceUpdate(message.getInputObject());
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple_port>> updateMany(Pointer<Uint8> keys, int keysCount, Pointer<Uint8> operations, int operationsCount) {
    final request = _factory.createSpaceUpdate(_id, keys, keysCount, operations, operationsCount);
    return _producer.spaceUpdateMany(_descriptor, request).then(_completeUpdateMany);
  }

  @inline
  Pointer<tarantool_tuple> _completeUpsert(Pointer<interactor_message> message) {
    final tuple = Pointer<tarantool_tuple>.fromAddress(message.outputInt);
    _factory.releaseSpaceUpsert(message.getInputObject());
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple>> upsert(Pointer<Uint8> tuple, int tupleSize, Pointer<Uint8> operations, int operationsSize) {
    final request = _factory.createSpaceUpsert(_id, tuple, tupleSize, operations, operationsSize);
    return _producer.spaceUpdateSingle(_descriptor, request).then(_completeUpsert);
  }

  @inline
  Pointer<tarantool_tuple_port> _completeSelect(Pointer<interactor_message> message) {
    final tuple = Pointer<tarantool_tuple_port>.fromAddress(message.outputInt);
    _factory.releaseSpaceSelect(message.getInputObject());
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple_port>> select({
    int offset = 0,
    int limit = int32MaxValue,
    StorageIteratorType iteratorType = StorageIteratorType.eq,
  }) {
    final (key, keySize) = _tuples.emptyList;
    return selectBy(key, keySize);
  }

  @inline
  Future<Pointer<tarantool_tuple_port>> selectBy(
    Pointer<Uint8> key,
    int keySize, {
    int offset = 0,
    int limit = int32MaxValue,
    StorageIteratorType iteratorType = StorageIteratorType.eq,
  }) {
    final request = _factory.createSpaceSelect(_id, key, keySize, offset, limit, iteratorType.index);
    return _producer.spaceInsertSingle(_descriptor, request).then(_completeSelect);
  }
}
