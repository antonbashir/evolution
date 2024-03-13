// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';

final class core_module_configuration extends Struct {
  @Bool()
  external bool silent;
  @Uint8()
  external int print_level;
}

final class core_module extends Struct {
  @Uint32()
  external int id;
  external Pointer<Utf8> name;
  external Pointer<core_module_configuration> configuration;
}

@Native<Pointer<core_module> Function(Pointer<core_module_configuration> configuration)>(isLeaf: true)
external Pointer<core_module> core_module_create(Pointer<core_module_configuration> configuration);

@Native<Void Function(Pointer<core_module> module)>(isLeaf: true)
external void core_module_destroy(Pointer<core_module> module);
