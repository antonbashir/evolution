import 'dart:ffi';

import 'package:core/core.dart';

import 'bindings.dart';

class StorageStrings {
  final Pointer<tarantool_factory> _factory;

  StorageStrings(this._factory);

  @inline
  (Pointer<Char>, int) allocate(String source) {
    final Pointer<Uint8> result = tarantool_create_string(_factory, source.length + 1).cast();
    final units = result.asTypedList(source.length + 1);
    final length = fastEncodeString(source, units, 0);
    units[length] = 0;
    return (result.cast(), length);
  }

  @inline
  void free(Pointer<Char> string, int size) => tarantool_free_string(_factory, string, size + 1);
}
