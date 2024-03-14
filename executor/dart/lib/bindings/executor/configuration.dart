// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../executor/bindings.dart';

final class executor_configuration extends Struct {
  @Size()
  external int quota_size;
  @Size()
  external int preallocation_size;
  @Size()
  external int slab_size;
  @Size()
  external int static_buffers_capacity;
  @Size()
  external int static_buffer_size;
  @Size()
  external int ring_size;
  @Uint32()
  external int ring_flags;
  @Bool()
  external bool trace;
}

final class executor_scheduler_configuration extends Struct {
  @Size()
  external int ring_size;
  @Size()
  external int ring_flags;
  @Uint64()
  external int initialization_timeout_seconds;
  @Uint64()
  external int shutdown_timeout_seconds;
  @Bool()
  external bool trace;
}
