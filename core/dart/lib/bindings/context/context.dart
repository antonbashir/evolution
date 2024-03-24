// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../core/bindings.dart';

final class simple_map_modules_t extends Opaque {}

final class simple_map_string_values_t extends Opaque {}

final class context_structure extends Struct {
  @Bool()
  external bool initialized;
  @Size()
  external int size;
  external Pointer<module_container> containers;
  external Pointer<simple_map_modules_t> modules;
  external Pointer<simple_map_string_values_t> environment;
  external Pointer<bootstrap_configuration> configuration;
}

@Native<Pointer<context_structure> Function()>(isLeaf: true)
external Pointer<context_structure> context_get();

@Native<Void Function(Pointer<bootstrap_configuration> configuration)>(isLeaf: true)
external void context_create(Pointer<bootstrap_configuration> configuration);

@Native<Pointer<Void> Function(Pointer<Utf8> name)>(isLeaf: true)
external Pointer<Void> context_get_module(Pointer<Utf8> name);

@Native<Void Function(Pointer<Utf8> name, Pointer<Void> module, Pointer<Utf8> type)>(isLeaf: true)
external void context_put_module(Pointer<Utf8> name, Pointer<Void> module, Pointer<Utf8> type);

@Native<Void Function(Pointer<Utf8> name)>(isLeaf: true)
external void context_remove_module(Pointer<Utf8> name);

@Native<Void Function(Pointer<Utf8> key, Pointer<Utf8> value)>(isLeaf: true)
external void context_set_environment(Pointer<Utf8> key, Pointer<Utf8> value);

@Native<Pointer<Utf8> Function(Pointer<Utf8> key)>(isLeaf: true)
external Pointer<Utf8> context_get_environment(Pointer<Utf8> key);

@Native<Pointer<pointer_array> Function()>(isLeaf: true)
external Pointer<pointer_array> context_environment_entries();

@Native<Void Function()>(isLeaf: false)
external void context_load();
