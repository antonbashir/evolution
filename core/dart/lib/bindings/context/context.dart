import 'dart:ffi';

final class context extends Struct {
  @Size()
  external final int size;
  @Bool()
  external final bool initialized;
  external final Pointer<Pointer<Void>> modules;
}

@Native<Pointer<context> Function()>(isLeaf: true)
external Pointer<context> context_get();

@Native<Void Function()>(isLeaf: true)
external void context_create();

@Native<Void Function(Uint32 id, Pointer<Void> module)>(isLeaf: true)
external void context_put_module(int id, Pointer<Void> module);
