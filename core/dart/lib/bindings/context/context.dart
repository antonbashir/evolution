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
  external Pointer<Pointer<Void>> modules;
}

@Native<Pointer<context> Function()>(isLeaf: true)
external Pointer<context> context_get();

@Native<Void Function()>(isLeaf: true)
external void context_create();

@Native<Pointer<Void> Function(Uint32 id)>(isLeaf: true)
external Pointer<Void> context_get_module(int id);

@Native<Void Function(Uint32 id, Pointer<Void> module)>(isLeaf: true)
external void context_put_module(int id, Pointer<Void> module);
