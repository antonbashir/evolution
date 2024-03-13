// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../executor/bindings.dart';

final class executor_task extends Struct {
  @Uint64()
  external int id;
  @Uint64()
  external int source;
  @Uint64()
  external int target;
  @Uint64()
  external int owner;
  @Uint64()
  external int method;
  external Pointer<Void> input;
  @Size()
  external int input_size;
  external Pointer<Void> output;
  @Size()
  external int output_size;
  @Uint16()
  external int flags;
}

final class executor_completion_event extends Struct {
  @Uint64()
  external int user_data;
  @Int32()
  external int res;
  @Uint32()
  external int flags;
}
