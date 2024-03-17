// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';

final class module_container extends Struct {
  @Uint32()
  external int id;
  external Pointer<Utf8> name;
  external Pointer<Void> module;
}

final class context extends Struct {
  @Bool()
  external bool initialized;
  @Size()
  external int size;
  external Pointer<module_container> containers;
}

@Native<Pointer<context> Function()>(isLeaf: true)
external Pointer<context> context_get();

@Native<Void Function()>(isLeaf: true)
external void context_create();

@Native<Pointer<Void> Function(Pointer<Utf8> name)>(isLeaf: true)
external Pointer<Void> context_get_module(Pointer<Utf8> name);

@Native<Void Function(Pointer<Utf8> name, Pointer<Void> module)>(isLeaf: true)
external void context_put_module(Pointer<Utf8> name, Pointer<Void> module);

@Native<Void Function(Pointer<Utf8> name)>(isLeaf: true)
external void context_remove_module(Pointer<Utf8> name);
