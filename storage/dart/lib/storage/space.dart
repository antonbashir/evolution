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
    final keySize = tupleSizeOfList(1) + tupleSizeOfNull;
    final key = _tuples.allocate(keySize);
    final keyBuffer = key.asTypedList(keySize);
    tupleWriteList(ByteData.view(keyBuffer.buffer, keyBuffer.offsetInBytes), keySize, 0);
    return countBy(key, keySize, iteratorType: iteratorType).whenComplete(() => _tuples.free(key, keySize));
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
    tarantool_space_length_free(_factory, message);
    return length;
  }

  @inline
  Future<int> length() => _producer.spaceLength(_descriptor, tarantool_space_length_prepare(_factory, _id)).then(_completeLength);

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
    final iterator = StorageIterator(_factory, message.outputInt, _producer, _descriptor);
    tarantool_space_iterator_request_free(_factory, message);
    return iterator;
  }

  @inline
  Future<StorageIterator> iteratorBy(Pointer<Uint8> key, int keySize, {StorageIteratorType iteratorType = StorageIteratorType.eq}) {
    final request = tarantool_space_iterator_request_prepare(_factory, _id, iteratorType.index, key.cast(), keySize);
    return _producer.spaceIterator(_descriptor, request).then(_completeIteratorBy);
  }

  @inline
  Pointer<tarantool_tuple_t> _completeInsertSingle(Pointer<interactor_message> message) {
    final tuple = Pointer<tarantool_tuple_t>.fromAddress(message.outputInt);
    tarantool_index_select_request_free(_factory, message);
    return tuple;
  }

  @inline
  Pointer<tarantool_tuple_port_t> _completeInsertMany(Pointer<interactor_message> message) {
    final tuple = Pointer<tarantool_tuple_port_t>.fromAddress(message.outputInt);
    tarantool_index_select_request_free(_factory, message);
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple_t>> insertSingle(Pointer<Uint8> tuple, int tupleSize) {
    final request = tarantool_space_request_prepare(_factory, _id, tuple.cast(), tupleSize);
    return _producer.spaceInsertSingle(_descriptor, request).then(_completeInsertSingle);
  }

  @inline
  Future<Pointer<tarantool_tuple_port_t>> insertMany(Pointer<Uint8> tuples, int tuplesCount) {
    final request = tarantool_space_request_prepare(_factory, _id, tuples.cast(), tuplesCount);
    return _producer.spaceInsertMany(_descriptor, request).then(_completeInsertMany);
  }

  @inline
  Pointer<tarantool_tuple_t> _completePutSingle(Pointer<interactor_message> message) {
    final tuple = Pointer<tarantool_tuple_t>.fromAddress(message.outputInt);
    tarantool_space_request_free(_factory, message);
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple_t>> putSingle(Pointer<Uint8> tuple, int tupleSize) {
    final request = tarantool_space_request_prepare(_factory, _id, tuple.cast(), tupleSize);
    return _producer.spaceInsertSingle(_descriptor, request).then(_completePutSingle);
  }

  @inline
  Pointer<tarantool_tuple_port_t> _completePutMany(Pointer<interactor_message> message) {
    final tuple = Pointer<tarantool_tuple_port_t>.fromAddress(message.outputInt);
    tarantool_space_request_free(_factory, message);
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple_port_t>> putMany(Pointer<Uint8> tuples, int tuplesCount) {
    final request = tarantool_space_request_prepare(_factory, _id, tuples.cast(), tuplesCount);
    return _producer.spaceInsertMany(_descriptor, request).then(_completePutMany);
  }

  @inline
  Pointer<tarantool_tuple_t> _completeDeleteSingle(Pointer<interactor_message> message) {
    final tuple = Pointer<tarantool_tuple_t>.fromAddress(message.outputInt);
    tarantool_space_request_free(_factory, message);
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple_t>> deleteSingle(Pointer<Uint8> key, int keySize) {
    final request = tarantool_space_request_prepare(_factory, _id, key.cast(), keySize);
    return _producer.spaceDeleteSingle(_descriptor, request).then(_completeDeleteSingle);
  }

  @inline
  Pointer<tarantool_tuple_port_t> _completeDeleteMany(Pointer<interactor_message> message) {
    final tuple = Pointer<tarantool_tuple_port_t>.fromAddress(message.outputInt);
    tarantool_space_request_free(_factory, message);
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple_port_t>> deleteSingleMany(Pointer<Uint8> keys, int keysCount) {
    final request = tarantool_space_request_prepare(_factory, _id, keys.cast(), keysCount);
    return _producer.spaceDeleteMany(_descriptor, request).then(_completeDeleteMany);
  }

  @inline
  Pointer<tarantool_tuple_t> _completeGet(Pointer<interactor_message> message) {
    final tuple = Pointer<tarantool_tuple_t>.fromAddress(message.outputInt);
    tarantool_space_request_free(_factory, message);
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple_t>> get(Pointer<Uint8> key, int keySize) {
    final request = tarantool_space_request_prepare(_factory, _id, key.cast(), keySize);
    return _producer.spaceGet(_descriptor, request).then(_completeGet);
  }

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
    tarantool_space_request_free(_factory, message);
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple_t>> minBy(Pointer<Uint8> key, int keySize) {
    final request = tarantool_space_request_prepare(_factory, _id, key.cast(), keySize);
    return _producer.spaceMin(_descriptor, request).then(_completeMin);
  }

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
    tarantool_space_request_free(_factory, message);
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple_t>> maxBy(Pointer<Uint8> key, int keySize) {
    final request = tarantool_space_request_prepare(_factory, _id, key.cast(), keySize);
    return _producer.spaceMax(_descriptor, request).then(_completeMax);
  }

  @inline
  Future<void> truncate() {
    return _producer.spaceTruncate(_descriptor, tarantool_space_truncate_prepare(_factory, _id)).then((message) => tarantool_space_truncate_free(_factory, message));
  }

  @inline
  Pointer<tarantool_tuple_t> _completeUpdateSingle(Pointer<interactor_message> message) {
    final tuple = Pointer<tarantool_tuple_t>.fromAddress(message.outputInt);
    tarantool_space_update_request_free(_factory, message);
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple_t>> updateSingle(Pointer<Uint8> key, int keySize, Pointer<Uint8> operations, int operationsSize) {
    final request = tarantool_space_update_request_prepare(_factory, _id, key.cast(), keySize, operations.cast(), operationsSize);
    return _producer.spaceUpdateSingle(_descriptor, request).then(_completeUpdateSingle);
  }

  @inline
  Pointer<tarantool_tuple_port_t> _completeUpdateMany(Pointer<interactor_message> message) {
    final tuple = Pointer<tarantool_tuple_port_t>.fromAddress(message.outputInt);
    tarantool_space_update_request_free(_factory, message);
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple_port_t>> updateMany(Pointer<Uint8> keys, int keysCount, Pointer<Uint8> operations, int operationsCount) {
    final request = tarantool_space_update_request_prepare(_factory, _id, keys.cast(), keysCount, operations.cast(), operationsCount);
    return _producer.spaceUpdateMany(_descriptor, request).then(_completeUpdateMany);
  }

  @inline
  Pointer<tarantool_tuple_t> _completeUpsert(Pointer<interactor_message> message) {
    final tuple = Pointer<tarantool_tuple_t>.fromAddress(message.outputInt);
    tarantool_space_upsert_request_free(_factory, message);
    return tuple;
  }

  @inline
  Future<Pointer<tarantool_tuple_t>> upsert(Pointer<Uint8> tuple, int tupleSize, Pointer<Uint8> operations, int operationsSize) {
    final request = tarantool_space_upsert_request_prepare(_factory, _id, tuple.cast(), tupleSize, operations.cast(), operationsSize);
    return _producer.spaceUpdateSingle(_descriptor, request).then(_completeUpsert);
  }

  @inline
  Pointer<tarantool_tuple_port_t> _completeSelect(Pointer<interactor_message> message) {
    final tuple = Pointer<tarantool_tuple_port_t>.fromAddress(message.outputInt);
    tarantool_space_select_request_free(_factory, message);
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
  }) {
    final request = tarantool_space_select_request_prepare(_factory, _id, key.cast(), keySize, offset, limit, iteratorType.index);
    return _producer.spaceInsertSingle(_descriptor, request).then(_completeSelect);
  }
}
