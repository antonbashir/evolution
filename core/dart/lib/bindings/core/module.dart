// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../core/bindings.dart';

final class core_module_configuration extends Opaque {}

final class core_module extends Struct {
  external Pointer<Utf8> name;
  external core_module_configuration configuration;
  external Pointer<system_library> library;
}

@Native<Pointer<core_module> Function(Pointer<core_module_configuration> configuration)>(isLeaf: true)
external Pointer<core_module> core_module_create(Pointer<core_module_configuration> configuration);

@Native<Void Function(Pointer<core_module> module)>(isLeaf: true)
external void core_module_destroy(Pointer<core_module> module);
