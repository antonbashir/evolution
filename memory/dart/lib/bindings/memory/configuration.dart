// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../memory/bindings.dart';

final class memory_configuration extends Struct {
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
}
