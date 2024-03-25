// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../storage/bindings.dart';

final class storage_executor_configuration extends Struct {
  @Size()
  external int ring_size;
  @Size()
  external int ring_flags;
  external Pointer<storage_configuration> configuration;
  @Uint32()
  external int executor_id;
}

final class storage_configuration extends Struct {
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
  external storage_executor_configuration executor_configuration;
}
