// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../executor/bindings.dart';

final class executor_module_configuration extends Struct {
  external executor_scheduler_configuration scheduler_configuration;
}

final class executor_module extends Struct {
  external Pointer<Utf8> name;
  external executor_module_configuration configuration;
  external Pointer<executor_scheduler> scheduler;
  @Uint32()
  external int executors;
}

final class executor_module_state extends Opaque {}

@Native<Pointer<executor_module> Function(Pointer<executor_module_configuration> configuration)>(isLeaf: true)
external Pointer<executor_module> executor_module_create(Pointer<executor_module_configuration> configuration);

@Native<Void Function(Pointer<executor_module> module)>(isLeaf: true)
external void executor_module_destroy(Pointer<executor_module> module);

@Native<Uint32 Function(Pointer<executor_module> module)>(isLeaf: true)
external int executor_next_id(Pointer<executor_module> module);
