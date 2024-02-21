import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:interactor/interactor.dart';
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
    final keySize = tupleSizeOfList(1) + tupleSizeOfNull;
    final key = _tuples.allocate(keySize);
    final keyBuffer = key.asTypedList(keySize);
    tupleWriteList(ByteData.view(keyBuffer.buffer, keyBuffer.offsetInBytes), keySize, 0);
    return countBy(key, keySize, iteratorType: iteratorType).whenComplete(() => _tuples.free(key, keySize));
  }

  @inline
  int _completeCountBy(Pointer<interactor_message> message) {
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
  int _completeLength(Pointer<interactor_message> message) {
    final length = message.outputInt;
    _factory.releaseMessage(message);
    return length;
  }

  @inline
  Future<int> length() => _producer.indexLength(_descriptor, _factory.createIndexId(_spaceId, _indexId)).then(_completeLength);

  @inline
  Future<StorageIterator> iterator({StorageIteratorType iteratorType = StorageIteratorType.eq}) {
    final keySize = tupleSizeOfList(1) + tupleSizeOfNull;
    final key = _tuples.allocate(keySize);
    final keyBuffer = key.asTypedList(keySize);
    tupleWriteList(ByteData.view(keyBuffer.buffer, keyBuffer.offsetInBytes), keySize, 0);
    return iteratorBy(key, keySize, iteratorType: iteratorType).whenComplete(() => _tuples.free(key, keySize));
  }

  @inline
  StorageIterator _completeIteratorBy(Pointer<interactor_message> message) {
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
  Pointer<tarantool_tuple_t> _completeGet(Pointer<interactor_message> message) {
    final tuple = Pointer<tarantool_tuple_t>.fromAddress(message.outputInt);
    _factory.releaseIndex(message.getInputObject());
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple_t>> get(Pointer<Uint8> key, int keySize) => _producer.indexGet(_descriptor, _factory.createIndex(_spaceId, _indexId, key, keySize)).then(_completeGet);

  @inline
  Future<Pointer<tarantool_tuple_t>> min() {
    final keySize = tupleSizeOfList(1) + tupleSizeOfNull;
    final key = _tuples.allocate(keySize);
    final keyBuffer = key.asTypedList(keySize);
    tupleWriteList(ByteData.view(keyBuffer.buffer, keyBuffer.offsetInBytes), keySize, 0);
    return minBy(key, keySize).whenComplete(() => _tuples.free(key, keySize));
  }

  @inline
  Pointer<tarantool_tuple_t> _completeMin(Pointer<interactor_message> message) {
    final tuple = Pointer<tarantool_tuple_t>.fromAddress(message.outputInt);
    _factory.releaseIndex(message.getInputObject());
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple_t>> minBy(Pointer<Uint8> key, int keySize) => _producer.indexMin(_descriptor, _factory.createIndex(_spaceId, _indexId, key, keySize)).then(_completeMin);

  @inline
  Future<Pointer<tarantool_tuple_t>> max() {
    final keySize = tupleSizeOfList(1) + tupleSizeOfNull;
    final key = _tuples.allocate(keySize);
    final keyBuffer = key.asTypedList(keySize);
    tupleWriteList(ByteData.view(keyBuffer.buffer, keyBuffer.offsetInBytes), keySize, 0);
    return maxBy(key, keySize).whenComplete(() => _tuples.free(key, keySize));
  }

  @inline
  Pointer<tarantool_tuple_t> _completeMax(Pointer<interactor_message> message) {
    final tuple = Pointer<tarantool_tuple_t>.fromAddress(message.outputInt);
    _factory.releaseIndex(message.getInputObject());
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple_t>> maxBy(Pointer<Uint8> key, int keySize) => _producer.indexMax(_descriptor, _factory.createIndex(_spaceId, _indexId, key, keySize)).then(_completeMax);

  @inline
  Pointer<tarantool_tuple_t> _completeUpdateSingle(Pointer<interactor_message> message) {
    final tuple = Pointer<tarantool_tuple_t>.fromAddress(message.outputInt);
    _factory.releaseIndexUpdate(message.getInputObject());
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple_t>> updateSingle(
    Pointer<Uint8> key,
    int keySize,
    Pointer<Uint8> operations,
    int operationsSize,
  ) =>
      _producer.indexUpdateSingle(_descriptor, _factory.createIndexUpdate(_spaceId, _indexId, key, keySize, operations, operationsSize)).then(_completeUpdateSingle);

  @inline
  Pointer<tarantool_tuple_port_t> _completeUpdateMany(Pointer<interactor_message> message) {
    final tuple = Pointer<tarantool_tuple_port_t>.fromAddress(message.outputInt);
    _factory.releaseIndexUpdate(message.getInputObject());
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple_port_t>> updateMany(
    Pointer<Uint8> keys,
    int keysCount,
    Pointer<Uint8> operations,
    int operationsCount,
  ) =>
      _producer.indexUpdateMany(_descriptor, _factory.createIndexUpdate(_spaceId, _indexId, keys, keysCount, operations, operationsCount)).then(_completeUpdateMany);

  @inline
  Pointer<tarantool_tuple_port_t> _completeSelect(Pointer<interactor_message> message) {
    final tuple = Pointer<tarantool_tuple_port_t>.fromAddress(message.outputInt);
    _factory.releaseIndexSelect(message.getInputObject());
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple_port_t>> select({
    int offset = 0,
    int limit = int32MaxValue,
    StorageIteratorType iteratorType = StorageIteratorType.eq,
  }) {
    final keySize = tupleSizeOfList(1) + tupleSizeOfNull;
    final key = _tuples.allocate(keySize);
    final keyBuffer = key.asTypedList(keySize);
    tupleWriteList(ByteData.view(keyBuffer.buffer, keyBuffer.offsetInBytes), keySize, 0);
    return selectBy(key, keySize).whenComplete(() => _tuples.free(key, keySize));
  }

  @inline
  Future<Pointer<tarantool_tuple_port_t>> selectBy(
    Pointer<Uint8> key,
    int keySize, {
    int offset = 0,
    int limit = int32MaxValue,
    StorageIteratorType iteratorType = StorageIteratorType.eq,
  }) =>
      _producer.indexSelect(_descriptor, _factory.createIndexSelect(_spaceId, _indexId, key, keySize, offset, limit, iteratorType.index)).then(_completeSelect);
}
