import 'dart:ffi';

import 'package:core/core.dart';

import 'bindings.dart';

extension StorageTupleExtensions on Pointer<tarantool_tuple> {
  @inline
  int get size => tarantool_tuple_size(this);

  @inline
  Pointer<Uint8> get data => tarantool_tuple_data(this).cast();
}
