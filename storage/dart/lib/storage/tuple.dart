import 'dart:ffi';

import 'bindings.dart';

extension type StorageTuple(Pointer<storage_tuple> tuple) {
  @inline
  int get size => storage_tuple_size(tuple);

  @inline
  Pointer<Uint8> get data => storage_tuple_data(tuple).cast();

  @inline
  void release() => storage_tuple_release(tuple);
}
