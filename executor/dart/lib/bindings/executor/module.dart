// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../executor/bindings.dart';

final class executor_module_configuration extends Opaque {}

final class executor_module extends Struct {
  @Uint32()
  external int id;
  external Pointer<Utf8> name;
  external Pointer<executor_module_configuration> configuration;
}

@Native<Pointer<executor_module> Function(Pointer<executor_module_configuration> configuration)>(isLeaf: true)
external Pointer<executor_module> executor_module_create(Pointer<executor_module_configuration> configuration);

@Native<Void Function(Pointer<executor_module> module)>(isLeaf: true)
external void executor_module_destroy(Pointer<executor_module> module);
