// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../storage/bindings.dart';

final class storage_tuple_port_entry extends Struct {
  external Pointer<storage_tuple_port_entry> next;
  external Pointer<storage_tuple> tuple;
  external Pointer<Uint32> message_pack_size;
  external Pointer<storage_tuple_format> mp_format;
}

final class storage_tuple_port extends Struct {
  external Pointer<storage_port_vtab> vtab;
  external Pointer<storage_tuple_port_entry> first;
  external Pointer<storage_tuple_port_entry> last;
  external storage_tuple_port_entry first_entry;
  @Int()
  external int size;
}

@Native<Size Function(Pointer<storage_tuple> tuple)>(isLeaf: true)
external int storage_tuple_size(Pointer<storage_tuple> tuple);

@Native<Pointer<Void> Function(Pointer<storage_tuple> tuple)>(isLeaf: true)
external Pointer<Void> storage_tuple_data(Pointer<storage_tuple> tuple);

@Native<Void Function(Pointer<storage_tuple> tuple)>(isLeaf: true)
external void storage_tuple_release(Pointer<storage_tuple> tuple);

@Native<Pointer<Utf8> Function(Pointer<storage_tuple> tuple)>(isLeaf: true)
external Pointer<Utf8> storage_tuple_to_string(Pointer<storage_tuple> tuple);
