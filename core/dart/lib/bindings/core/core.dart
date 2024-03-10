import 'dart:ffi';

import 'package:ffi/ffi.dart';

final class core_module extends Struct {
  @Uint32()
  external int id;
  external Pointer<Utf8> name;
  external Pointer<core_module_configuration> configuration;
}

final class core_module_configuration extends Struct {
  @Uint8()
  external int print_level;
  external Pointer<Utf8> component;
}

@Native<Pointer<core_module> Function(Pointer<core_module_configuration>)>(isLeaf: true)
external Pointer<core_module> core_module_create(Pointer<core_module_configuration> configuration);

@Native<Void Function(Pointer<core_module>)>(isLeaf: true)
external void core_module_destroy(Pointer<core_module> module);

@Native<Pointer<core_module> Function()>(isLeaf: true)
external Pointer<core_module> core();
