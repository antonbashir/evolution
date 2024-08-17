import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'bindings.dart';

class StorageStrings {
  final Pointer<storage_factory> _factory;

  StorageStrings(this._factory);

  @inline
  (Pointer<Utf8>, int) allocate(String source) {
    final Pointer<Uint8> result = storage_create_string(_factory, source.length + 1).cast();
    final units = result.asTypedList(source.length + 1);
    final length = source.encode(units, 0);
    units[length] = 0;
    return (result.cast(), length);
  }

  @inline
  void free(Pointer<Utf8> string, int size) => storage_free_string(_factory, string, size + 1);
}
