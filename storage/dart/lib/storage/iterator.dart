import 'dart:ffi';
import 'dart:math';

import 'bindings.dart';
import 'executor.dart';
import 'factory.dart';

class StorageIterator {
  final int _iterator;
  final int _descriptor;
  final StorageFactory _factory;
  final StorageProducer _producer;

  const StorageIterator(this._iterator, this._descriptor, this._factory, this._producer);

  @inline
  Pointer<storage_tuple> _completeNextSingle(Pointer<executor_task> message) {
    final tuple = Pointer<storage_tuple>.fromAddress(message.outputInt);
    _factory.releaseMessage(message);
    return tuple;
  }

  @inline
  Future<Pointer<storage_tuple>> nextSingle() {
    final request = _factory.createMessage();
    request.inputInt = _iterator;
    request.inputSize = 1;
    return _producer.iteratorNextSingle(_descriptor, request).then(_completeNextSingle);
  }

  @inline
  Pointer<storage_tuple_port> _completeNextMany(Pointer<executor_task> message) {
    final tuple = Pointer<storage_tuple_port>.fromAddress(message.outputInt);
    _factory.releaseMessage(message);
    return tuple;
  }

  @inline
  Future<Pointer<storage_tuple_port>> nextMany({int count = 1}) {
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

  Future<List<dynamic>> collect({
    bool Function(List<dynamic> value)? filter,
    dynamic Function(List<dynamic> value)? map,
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
    void Function(dynamic element) action, {
    bool Function(List<dynamic> value)? filter,
    dynamic Function(List<dynamic> value)? map,
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

  Stream<dynamic> stream({
    bool Function(List<dynamic> value)? filter,
    dynamic Function(List<dynamic> value)? map,
    int? limit,
    int? offset,
    int count = 1,
  }) async* {
    var index = 0;
    if (limit != null) count = min(count, limit);
    if (filter == null) {
      List<List<dynamic>>? tuples;
      //while ((tuples = await nextMany(count: count)) != null) {
      //  if (offset != null && index <= offset) {
      //    index += count;
      //    continue;
      //  }
      //  if (limit != null && index > limit) return;
      //  index += count;
      //  for (List<dynamic> tuple in tuples!) {
      //    yield (map == null ? tuple : map(tuple));
      //  }
      //}
      await destroy();
      return;
    }
    List<List<dynamic>>? tuples;
    // while ((tuples = await nextMany(count: count)) != null) {
    //   if (offset != null && index <= offset) {
    //     index += count;
    //     continue;
    //   }
    //   List<dynamic> filtered = [];
    //   for (List<dynamic> tuple in tuples!) {
    //     if (filter(tuple)) filtered.add(tuple);
    //   }
    //   if (filtered.isEmpty) continue;
    //   if (limit != null && index > limit) return;
    //   index += filtered.length;
    //   for (List<dynamic> tuple in tuples) {
    //     yield (map == null ? tuple : map(tuple));
    //   }
    // }
    await destroy();
  }
}
