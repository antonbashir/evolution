import 'dart:ffi';

import 'package:core/core.dart';

import 'bindings.dart';

extension type StorageTuple(Pointer<tarantool_tuple> tuple) {
  @inline
  int get size => tarantool_tuple_size(tuple);

  @inline
  Pointer<Uint8> get data => tarantool_tuple_data(tuple).cast();

  @inline
  void release() => tarantool_tuple_release(tuple);
}
