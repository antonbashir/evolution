import 'dart:ffi';
import 'dart:math';

import 'bindings.dart';
import 'storage.dart';
import 'factory.dart';
import 'tuple.dart';

class StorageIterator {
  final int _iterator;
  final int _descriptor;
  final StorageFactory _factory;
  final StorageProducer _producer;

  const StorageIterator(this._iterator, this._descriptor, this._factory, this._producer);

  @inline
  StorageTuple _completeNextSingle(Pointer<executor_task> message) {
    final tuple = Pointer<storage_tuple>.fromAddress(message.outputInt);
    _factory.releaseMessage(message);
    return StorageTuple(tuple);
  }

  @inline
  Future<StorageTuple> nextSingle() {
    final request = _factory.createMessage();
    request.inputInt = _iterator;
    request.inputSize = 1;
    return _producer.iteratorNextSingle(_descriptor, request).then(_completeNextSingle);
  }

  @inline
  StorageTuplePort _completeNextMany(Pointer<executor_task> message) {
    final tuple = Pointer<storage_tuple_port>.fromAddress(message.outputInt);
    _factory.releaseMessage(message);
    return StorageTuplePort(tuple);
  }

  @inline
  Future<StorageTuplePort> nextMany({int count = 1}) {
    final request = _factory.createMessage();
    request.inputInt = _iterator;
    request.inputSize = count;
    return _producer.iteratorNextMany(_descriptor, request).then(_completeNextMany);
  }

  @inline
  void _completeDestroy(Pointer<executor_task> message) => _factory.releaseMessage(message);

  @inline
  Future<void> destroy() {
    final request = _factory.createMessage();
    request.inputInt = _iterator;
    return _producer.iteratorDestroy(_descriptor, request).then(_completeDestroy);
  }

  Future<List<StorageTuple>> collect({
    bool Function(StorageTuple value)? filter,
    dynamic Function(StorageTuple value)? map,
    int? limit,
    int? offset,
    int count = 1,
  }) =>
      stream(
        filter: filter,
        map: map,
        limit: limit,
        offset: offset,
        count: count,
      ).toList();

  Future<void> forEach(
    void Function(StorageTuple element) action, {
    bool Function(StorageTuple value)? filter,
    dynamic Function(StorageTuple value)? map,
    int? limit,
    int? offset,
    int count = 1,
  }) =>
      stream(
        filter: filter,
        map: map,
        limit: limit,
        offset: offset,
        count: count,
      ).forEach(action);

  Stream<StorageTuple> stream({
    bool Function(StorageTuple value)? filter,
    dynamic Function(StorageTuple value)? map,
    int? limit,
    int? offset,
    int count = 1,
  }) async* {
    var index = 0;
    if (limit != null) count = min(count, limit);
    if (filter == null) {
      StorageTuplePort tuples;
      while ((tuples = await nextMany(count: count)).isNotEmpty) {
        if (offset != null && index <= offset) {
          index += count;
          continue;
        }
        if (limit != null && index > limit) return;
        index += count;
        yield* tuples.stream().map((tuple) => map!(tuple));
      }
      await destroy();
      return;
    }

    StorageTuplePort tuples;
    while ((tuples = await nextMany(count: count)).isNotEmpty) {
      if (offset != null && index <= offset) {
        index += count;
        continue;
      }
      List<StorageTuple> filtered = tuples.iterate().where(filter).toList();
      if (filtered.isEmpty) continue;
      if (limit != null && index > limit) return;
      index += filtered.length;
      if (map != null) {
        for (var element in filtered) yield map(element);
        continue;
      }
      for (var element in filtered) yield element;
    }
    await destroy();
  }
}
