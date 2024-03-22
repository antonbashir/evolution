// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../core/bindings.dart';

final class simple_map_modules_t extends Opaque {}

final class context_structure extends Struct {
  @Bool()
  external bool initialized;
  @Size()
  external int size;
  external Pointer<module_container> containers;
  external Pointer<simple_map_modules_t> modules;
}

@Native<Pointer<context_structure> Function()>(isLeaf: true)
external Pointer<context_structure> context_get();

@Native<Void Function()>(isLeaf: true)
external void context_create();

@Native<Pointer<Void> Function(Pointer<Utf8> name)>(isLeaf: true)
external Pointer<Void> context_get_module(Pointer<Utf8> name);

@Native<Void Function(Pointer<Utf8> name, Pointer<Void> module, Pointer<Utf8> type)>(isLeaf: true)
external void context_put_module(Pointer<Utf8> name, Pointer<Void> module, Pointer<Utf8> type);

@Native<Void Function(Pointer<Utf8> name)>(isLeaf: true)
external void context_remove_module(Pointer<Utf8> name);

@Native<Void Function(Pointer<event> event)>(isLeaf: true)
external void context_set_local_event(Pointer<event> event);

@Native<Void Function()>(isLeaf: false)
external void context_load();
