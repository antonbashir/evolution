import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'bindings.dart';

extension type StorageTuple(Pointer<storage_tuple> tuple) {
  @inline
  int get size => tuple == nullptr ? 0 : storage_tuple_size(tuple);

  @inline
  Pointer<Uint8> get data => tuple == nullptr ? nullptr : storage_tuple_data(tuple).cast();

  @inline
  void release() {
    if (tuple != nullptr) storage_tuple_release(tuple);
  }

  @inline
  String format() => tuple == nullptr ? empty : storage_tuple_to_string(tuple).toDartString();

  @inline
  int integer(int field) => storage_tuple_get_uint64(tuple, field);
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

  Iterable<StorageTuple> iterate() sync* {
    var iterator = port.ref.first;
    for (var i = 0; i < port.ref.size; i++) {
      yield StorageTuple(iterator.ref.tuple);
      iterator = iterator.ref.next;
    }
  }

  Stream<StorageTuple> stream() async* {
    var iterator = port.ref.first;
    for (var i = 0; i < port.ref.size; i++) {
      yield StorageTuple(iterator.ref.tuple);
      iterator = iterator.ref.next;
    }
  }

  @inline
  String format() => iterate().map((tuple) => tuple.format()).join(comma);
}
