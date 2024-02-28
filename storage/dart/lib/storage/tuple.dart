import 'dart:ffi';

import 'package:core/core.dart';

import 'bindings.dart';

extension StorageTupleExtensions on Pointer<tarantool_tuple> {
  @inline
  int get size => tarantool_tuple_size(this);

  @inline
  Pointer<Uint8> get data => tarantool_tuple_data(this).cast();

  @inline
  void release() => tarantool_tuple_release(this);
}

extension StorageTuplePortExtensions on Pointer<tarantool_tuple_port> {
  @inline
  Pointer<tarantool_tuple_port_entry> first() => tarantool_port_first(this);
}

extension StorageTuplePortEntryExtensions on Pointer<tarantool_tuple_port_entry> {
  @inline
  Pointer<tarantool_tuple_port_entry> next() => tarantool_port_entry_next(this);

  @inline
  Pointer<tarantool_tuple> tuple() => tarantool_port_entry_tuple(this);
}
