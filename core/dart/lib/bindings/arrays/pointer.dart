// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../core/bindings.dart';

final class pointer_array extends Struct {
  @Size()
  external int capacity;
  @Size()
  external int size;
  @Size()
  external int resize_factor;
  external Pointer<Pointer<Void>> memory;
}

@Native<Pointer<pointer_array> Function(Size initial_capacity, Size resize_factor)>(isLeaf: true)
external Pointer<pointer_array> pointer_array_create(int initial_capacity, int resize_factor);

@Native<Pointer<pointer_array> Function()>(isLeaf: true)
external Pointer<pointer_array> pointer_array_create_default();

@Native<Void Function(Pointer<pointer_array> array)>(isLeaf: true)
external void pointer_array_destroy(Pointer<pointer_array> array);

@Native<Void Function(Pointer<pointer_array> array)>(isLeaf: true)
external void pointer_array_grow(Pointer<pointer_array> array);

@Native<Pointer<Void> Function(Pointer<pointer_array> array, Size index)>(isLeaf: true)
external Pointer<Void> pointer_array_get(Pointer<pointer_array> array, int index);

@Native<Pointer<Void> Function(Pointer<pointer_array> array, Size index, Pointer<Void> value)>(isLeaf: true)
external Pointer<Void> pointer_array_set(Pointer<pointer_array> array, int index, Pointer<Void> value);

@Native<Void Function(Pointer<pointer_array> array, Size from, Size count)>(isLeaf: true)
external void pointer_array_remove_range(Pointer<pointer_array> array, int from, int count);

@Native<Pointer<Void> Function(Pointer<pointer_array> array, Size index)>(isLeaf: true)
external Pointer<Void> pointer_array_remove(Pointer<pointer_array> array, int index);

@Native<Pointer<Void> Function(Pointer<pointer_array> array)>(isLeaf: true)
external Pointer<Void> pointer_array_remove_last(Pointer<pointer_array> array);

@Native<Void Function(Pointer<pointer_array> array, Pointer<Void> value)>(isLeaf: true)
external void pointer_array_add(Pointer<pointer_array> array, Pointer<Void> value);
