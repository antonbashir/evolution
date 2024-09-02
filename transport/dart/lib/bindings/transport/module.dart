// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../transport/bindings.dart';

final class transport_module_configuration extends Struct {
  external executor_configuration default_executor_configuration;
}

final class transport_module extends Struct {
  external Pointer<Utf8> name;
  external transport_module_configuration configuration;
  external Pointer<system_library> library;
}

final class transport_module_state extends Opaque {}

@Native<Pointer<transport_module> Function(Pointer<transport_module_configuration> configuration)>(isLeaf: true)
external Pointer<transport_module> transport_module_create(Pointer<transport_module_configuration> configuration);

@Native<Void Function(Pointer<transport_module> module)>(isLeaf: true)
external void transport_module_destroy(Pointer<transport_module> module);
