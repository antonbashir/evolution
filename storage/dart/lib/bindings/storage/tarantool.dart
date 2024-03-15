// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../storage/bindings.dart';

final class tarantool_configuration extends Struct {
  external Pointer<Utf8> initial_script;
  external Pointer<Utf8> library_path;
  external Pointer<Utf8> binary_path;
  @Uint64()
  external int cqe_wait_timeout_milliseconds;
  @Size()
  external int slab_size;
  @Size()
  external int ring_size;
  @Uint64()
  external int initialization_timeout_seconds;
  @Uint64()
  external int shutdown_timeout_seconds;
  @Size()
  external int box_output_buffer_capacity;
  @Size()
  external int executor_ring_size;
  @Int32()
  external int ring_flags;
  @Uint32()
  external int cqe_wait_count;
  @Uint32()
  external int cqe_peek_count;
}

@Native<Bool Function(Pointer<tarantool_configuration> configuration, Pointer<tarantool_box> box)>(isLeaf: true)
external bool tarantool_initialize(Pointer<tarantool_configuration> configuration, Pointer<tarantool_box> box);

@Native<Bool Function()>(isLeaf: true)
external bool tarantool_initialized();

@Native<Pointer<Utf8> Function()>(isLeaf: true)
external Pointer<Utf8> tarantool_status();

@Native<Int32 Function()>(isLeaf: true)
external int tarantool_is_read_only();

@Native<Pointer<Utf8> Function()>(isLeaf: true)
external Pointer<Utf8> tarantool_initialization_error();

@Native<Pointer<Utf8> Function()>(isLeaf: true)
external Pointer<Utf8> tarantool_shutdown_error();

@Native<Bool Function()>(isLeaf: true)
external bool tarantool_shutdown();