// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../storage/bindings.dart';

final class tarantool_factory extends Struct {
  external Pointer<memory_instance> memory;
  external Pointer<memory_small_allocator> tarantool_datas;
}

final class tarantool_factory_configuration extends Struct {
  @Size()
  external int quota_size;
  @Size()
  external int slab_size;
  @Size()
  external int preallocation_size;
}

@Native<Int32 Function(Pointer<tarantool_factory> factory, Pointer<tarantool_factory_configuration> configuration)>(isLeaf: true)
external int tarantool_factory_initialize(Pointer<tarantool_factory> factory, Pointer<tarantool_factory_configuration> configuration);

@Native<Pointer<Utf8> Function(Pointer<tarantool_factory> factory, Size size)>(isLeaf: true)
external Pointer<Utf8> tarantool_create_string(Pointer<tarantool_factory> factory, int size);

@Native<Void Function(Pointer<tarantool_factory> factory, Pointer<Utf8> string, Size size)>(isLeaf: true)
external void tarantool_free_string(Pointer<tarantool_factory> factory, Pointer<Utf8> string, int size);

@Native<Void Function(Pointer<tarantool_factory> factory)>(isLeaf: true)
external void tarantool_factory_destroy(Pointer<tarantool_factory> factory);
