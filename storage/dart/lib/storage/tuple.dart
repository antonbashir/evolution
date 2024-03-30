import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'bindings.dart';

extension type StorageTuple(Pointer<storage_tuple> tuple) {
  @inline
  int get size => storage_tuple_size(tuple);

  @inline
  Pointer<Uint8> get data => storage_tuple_data(tuple).cast();

  @inline
  void release() => storage_tuple_release(tuple);

  @inline
  String format() => storage_tuple_to_string(tuple).toDartString();
}

extension type StorageTuplePort(Pointer<storage_tuple_port> port) {
  @inline
  int get length => port.ref.size;

  @inline
  bool get isEmpty => port.ref.size == 0;
  
  @inline
  bool get isNotEmpty => port.ref.size != 0;

  @inline
  int get size {
    var size = 0;
    var iterator = port.ref.first;
    for (var i = 0; i < port.ref.size; i++) {
      size += StorageTuple(iterator.ref.tuple).size;
      iterator = iterator.ref.next;
    }
    return size;
  }

  @inline
  void forEach(void Function(StorageTuple tuple) functor) {
    var iterator = port.ref.first;
    for (var i = 0; i < port.ref.size; i++) {
      functor(StorageTuple(iterator.ref.tuple));
      iterator = iterator.ref.next;
    }
  }

  @inline
  Iterable<T> map<T>(T Function(StorageTuple tuple) mapper) sync* {
    var iterator = port.ref.first;
    for (var i = 0; i < port.ref.size; i++) {
      yield mapper(StorageTuple(iterator.ref.tuple));
      iterator = iterator.ref.next;
    }
  }

  @inline
  Stream<T> streamMap<T>(T Function(StorageTuple tuple) mapper) async* {
    var iterator = port.ref.first;
    for (var i = 0; i < port.ref.size; i++) {
      yield mapper(StorageTuple(iterator.ref.tuple));
      iterator = iterator.ref.next;
    }
  }

  @inline
  Iterable<StorageTuple> iterate() sync* {
    var iterator = port.ref.first;
    for (var i = 0; i < port.ref.size; i++) {
      yield StorageTuple(iterator.ref.tuple);
      iterator = iterator.ref.next;
    }
  }

  @inline
  Iterable<StorageTuple> filter(bool Function(StorageTuple value) filter) sync* {
    var iterator = port.ref.first;
    for (var i = 0; i < port.ref.size; i++) {
      if (filter(StorageTuple(iterator.ref.tuple))) yield StorageTuple(iterator.ref.tuple);
      iterator = iterator.ref.next;
    }
  }

  @inline
  String format() => map((tuple) => tuple.format()).join(comma);
}
