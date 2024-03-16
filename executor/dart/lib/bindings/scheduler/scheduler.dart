// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../executor/bindings.dart';

final class executor_scheduler extends Struct {
  external Pointer<Utf8> initialization_error;
  external Pointer<Utf8> shutdown_error;
  @Int32()
  external int descriptor;
  @Bool()
  external bool active;
  @Bool()
  external bool initialized;
}

@Native<Pointer<executor_scheduler> Function(Pointer<executor_scheduler_configuration> configuration)>(isLeaf: true)
external Pointer<executor_scheduler> executor_scheduler_initialize(Pointer<executor_scheduler_configuration> configuration);

@Native<Bool Function(Pointer<executor_scheduler> scheduler)>(isLeaf: true)
external bool executor_scheduler_shutdown(Pointer<executor_scheduler> scheduler);

@Native<Void Function(Pointer<executor_scheduler> scheduler)>(isLeaf: true)
external void executor_scheduler_destroy(Pointer<executor_scheduler> scheduler);
