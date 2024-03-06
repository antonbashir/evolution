import 'dart:async';
import 'dart:ffi';

import 'package:core/core.dart';
import 'package:executor/executor.dart';
import 'package:memory/memory.dart';

import 'bindings.dart';
import 'constants.dart';
import 'executor.dart';
import 'factory.dart';
import 'iterator.dart';

class StorageIndex {
  final int _spaceId;
  final int _indexId;
  final int _descriptor;
  final MemoryTuples _tuples;
  final StorageFactory _factory;
  final StorageProducer _producer;

  StorageIndex(this._spaceId, this._indexId, this._descriptor, this._tuples, this._factory, this._producer);

  Future<int> count({List<dynamic> key = const [], StorageIteratorType iteratorType = StorageIteratorType.eq}) {
    final (key, keySize) = _tuples.emptyList;
    return countBy(key, keySize, iteratorType: iteratorType);
  }

  @inline
  int _completeCountBy(Pointer<executor_message> message) {
    final count = message.outputInt;
    _factory.releaseIndexCount(message.getInputObject());
    return count;
  }

  @inline
  Future<int> countBy(
    Pointer<Uint8> key,
    int keySize, {
    StorageIteratorType iteratorType = StorageIteratorType.eq,
  }) =>
      _producer.indexCount(_descriptor, _factory.createIndexCount(_spaceId, _indexId, key, keySize, iteratorType.index)).then(_completeCountBy);

  @inline
  int _completeLength(Pointer<executor_message> message) {
    final length = message.outputInt;
    _factory.releaseMessage(message);
    return length;
  }

  @inline
  Future<int> length() => _producer.indexLength(_descriptor, _factory.createIndexId(_spaceId, _indexId)).then(_completeLength);

  @inline
  Future<StorageIterator> iterator({StorageIteratorType iteratorType = StorageIteratorType.eq}) {
    final (key, keySize) = _tuples.emptyList;
    return iteratorBy(key, keySize, iteratorType: iteratorType);
  }

  @inline
  StorageIterator _completeIteratorBy(Pointer<executor_message> message) {
    final iterator = StorageIterator(message.outputInt, _descriptor, _factory, _producer);
    _factory.releaseIndexIterator(message.getInputObject());
    return iterator;
  }

  @inline
  Future<StorageIterator> iteratorBy(
    Pointer<Uint8> key,
    int keySize, {
    StorageIteratorType iteratorType = StorageIteratorType.eq,
  }) =>
      _producer.indexIterator(_descriptor, _factory.createIndexIterator(_spaceId, _indexId, iteratorType.index, key, keySize)).then(_completeIteratorBy);

  @inline
  Pointer<tarantool_tuple> _completeGet(Pointer<executor_message> message) {
    final tuple = Pointer<tarantool_tuple>.fromAddress(message.outputInt);
    _factory.releaseIndex(message.getInputObject());
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple>> get(Pointer<Uint8> key, int keySize) => _producer.indexGet(_descriptor, _factory.createIndex(_spaceId, _indexId, key, keySize)).then(_completeGet);

  @inline
  Future<Pointer<tarantool_tuple>> min() {
    final (key, keySize) = _tuples.emptyList;
    return minBy(key, keySize);
  }

  @inline
  Pointer<tarantool_tuple> _completeMin(Pointer<executor_message> message) {
    final tuple = Pointer<tarantool_tuple>.fromAddress(message.outputInt);
    _factory.releaseIndex(message.getInputObject());
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple>> minBy(Pointer<Uint8> key, int keySize) => _producer.indexMin(_descriptor, _factory.createIndex(_spaceId, _indexId, key, keySize)).then(_completeMin);

  @inline
  Future<Pointer<tarantool_tuple>> max() {
    final (key, keySize) = _tuples.emptyList;
    return maxBy(key, keySize);
  }

  @inline
  Pointer<tarantool_tuple> _completeMax(Pointer<executor_message> message) {
    final tuple = Pointer<tarantool_tuple>.fromAddress(message.outputInt);
    _factory.releaseIndex(message.getInputObject());
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple>> maxBy(Pointer<Uint8> key, int keySize) => _producer.indexMax(_descriptor, _factory.createIndex(_spaceId, _indexId, key, keySize)).then(_completeMax);

  @inline
  Pointer<tarantool_tuple> _completeUpdateSingle(Pointer<executor_message> message) {
    final tuple = Pointer<tarantool_tuple>.fromAddress(message.outputInt);
    _factory.releaseIndexUpdate(message.getInputObject());
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple>> updateSingle(
    Pointer<Uint8> key,
    int keySize,
    Pointer<Uint8> operations,
    int operationsSize,
  ) =>
      _producer.indexUpdateSingle(_descriptor, _factory.createIndexUpdate(_spaceId, _indexId, key, keySize, operations, operationsSize)).then(_completeUpdateSingle);

  @inline
  Pointer<tarantool_tuple_port> _completeUpdateMany(Pointer<executor_message> message) {
    final tuple = Pointer<tarantool_tuple_port>.fromAddress(message.outputInt);
    _factory.releaseIndexUpdate(message.getInputObject());
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple_port>> updateMany(
    Pointer<Uint8> keys,
    int keysCount,
    Pointer<Uint8> operations,
    int operationsCount,
  ) =>
      _producer.indexUpdateMany(_descriptor, _factory.createIndexUpdate(_spaceId, _indexId, keys, keysCount, operations, operationsCount)).then(_completeUpdateMany);

  @inline
  Pointer<tarantool_tuple_port> _completeSelect(Pointer<executor_message> message) {
    final tuple = Pointer<tarantool_tuple_port>.fromAddress(message.outputInt);
    _factory.releaseIndexSelect(message.getInputObject());
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
  }) =>
      _producer.indexSelect(_descriptor, _factory.createIndexSelect(_spaceId, _indexId, key, keySize, offset, limit, iteratorType.index)).then(_completeSelect);
}
