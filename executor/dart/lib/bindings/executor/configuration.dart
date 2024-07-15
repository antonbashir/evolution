// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../executor/bindings.dart';

final class executor_configuration extends Struct {
  @Size()
  external int ring_size;
  @Uint32()
  external int ring_flags;
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
}
