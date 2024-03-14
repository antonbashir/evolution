// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../storage/bindings.dart';

final class tarantool_tuple extends Opaque {}

final class tarantool_port_vtab extends Opaque {}

final class tarantool_tuple_iterator extends Opaque {}

final class tarantool_tuple_port_entry extends Struct {
  external Pointer<tarantool_tuple_port_entry> next;
  external Pointer<tarantool_tuple> tuple;
  external Pointer<Uint32> message_pack_size;
}

final class tarantool_tuple_port extends Struct {
  external Pointer<tarantool_port_vtab> vtab;
  external Pointer<tarantool_tuple_port_entry> first;
  external Pointer<tarantool_tuple_port_entry> last;
  external tarantool_tuple_port_entry first_entry;
  @Int()
  external int size;
}

@Native<Size Function(Pointer<tarantool_tuple> tuple)>(isLeaf: true)
external int tarantool_tuple_size(Pointer<tarantool_tuple> tuple);

@Native<Pointer<Void> Function(Pointer<tarantool_tuple> tuple)>(isLeaf: true)
external Pointer<Void> tarantool_tuple_data(Pointer<tarantool_tuple> tuple);

@Native<Void Function(Pointer<tarantool_tuple> tuple)>(isLeaf: true)
external void tarantool_tuple_release(Pointer<tarantool_tuple> tuple);
