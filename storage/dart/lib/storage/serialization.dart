import 'dart:ffi';

import 'package:core/core.dart';

import 'bindings.dart';

class StorageSerialization {
  final Pointer<tarantool_factory> _factory;

  StorageSerialization(this._factory);

  @inline
  (Pointer<Char>, int) createString(String source) {
    final Pointer<Uint8> result = tarantool_create_string(_factory, source.length + 1).cast();
    final units = result.asTypedList(source.length + 1);
    final length = fastEncodeString(source, units, 0);
    units[length] = 0;
    return (result.cast(), length + 1);
  }

  @inline
  void freeString(Pointer<Char> string, int size) => tarantool_free_string(_factory, string, size);
}
