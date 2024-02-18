import 'dart:ffi';

import 'bindings.dart';
import 'constants.dart';

extension StorageTupleExtensions on Pointer<tarantool_tuple_t> {
  @inline
  int get size => tarantool_tuple_size(this);

  @inline
  Pointer<Uint8> get data => tarantool_tuple_data(this).cast();
}
