// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../memory/bindings.dart';

final class memory_module_configuration extends Struct {
  @Uint8()
  external int library_package_mode;
}

final class memory_module extends Struct {
  @Uint32()
  external int id;
  external Pointer<Utf8> name;
  external Pointer<memory_module_configuration> configuration;
}

@Native<Pointer<memory_module> Function(Pointer<memory_module_configuration> configuration)>(isLeaf: true)
external Pointer<memory_module> memory_module_create(Pointer<memory_module_configuration> configuration);

@Native<Void Function(Pointer<memory_module> module)>(isLeaf: true)
external void memory_module_destroy(Pointer<memory_module> module);
