// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../memory/bindings.dart';

final class memory_module_state extends Struct {
  external Pointer<memory_static_buffers> static_buffers;
  external Pointer<memory_io_buffers> io_buffers;
  external Pointer<memory> memory_instance;
}

@Native<Pointer<memory_module_state> Function(Pointer<memory_configuration> configuration)>(isLeaf: true)
external Pointer<memory_module_state> memory_module_state_create(Pointer<memory_configuration> configuration);

@Native<Void Function(Pointer<memory_module_state> state)>(isLeaf: true)
external void memory_module_state_destroy(Pointer<memory_module_state> state);
