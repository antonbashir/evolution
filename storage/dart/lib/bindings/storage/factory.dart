// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../storage/bindings.dart';

final class storage_factory extends Struct {
  external Pointer<memory_instance> memory;
  external Pointer<memory_small_allocator> storage_datas;
}

final class storage_factory_configuration extends Struct {
  @Size()
  external int quota_size;
  @Size()
  external int slab_size;
  @Size()
  external int preallocation_size;
}

@Native<Int32 Function(Pointer<storage_factory> factory, Pointer<storage_factory_configuration> configuration)>(isLeaf: true)
external int storage_factory_initialize(Pointer<storage_factory> factory, Pointer<storage_factory_configuration> configuration);

@Native<Pointer<Utf8> Function(Pointer<storage_factory> factory, Size size)>(isLeaf: true)
external Pointer<Utf8> storage_create_string(Pointer<storage_factory> factory, int size);

@Native<Void Function(Pointer<storage_factory> factory, Pointer<Utf8> string, Size size)>(isLeaf: true)
external void storage_free_string(Pointer<storage_factory> factory, Pointer<Utf8> string, int size);

@Native<Void Function(Pointer<storage_factory> factory)>(isLeaf: true)
external void storage_factory_destroy(Pointer<storage_factory> factory);
