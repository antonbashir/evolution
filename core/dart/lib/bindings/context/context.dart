// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../core/bindings.dart';

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

@Native<Void Function(Pointer<Utf8> name, Pointer<Void> module, Uint64 loader)>(isLeaf: true)
external void context_put_module(Pointer<Utf8> name, Pointer<Void> module, int loader);

@Native<Void Function(Pointer<Utf8> name)>(isLeaf: true)
external void context_remove_module(Pointer<Utf8> name);

@Native<Void Function()>(isLeaf: false)
external void context_load_modules();
