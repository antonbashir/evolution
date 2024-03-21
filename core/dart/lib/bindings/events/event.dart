// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../core/bindings.dart';

final class event extends Opaque {}

@Native<Void Function(Pointer<event> event, Pointer<Utf8> name, Bool value)>(isLeaf: true)
external void event_set_boolean(Pointer<event> event, Pointer<Utf8> name, bool value);

@Native<Void Function(Pointer<event> event, Pointer<Utf8> name, Int64 value)>(isLeaf: true)
external void event_set_signed(Pointer<event> event, Pointer<Utf8> name, int value);

@Native<Void Function(Pointer<event> event, Pointer<Utf8> name, Uint64 value)>(isLeaf: true)
external void event_set_unsigned(Pointer<event> event, Pointer<Utf8> name, int value);

@Native<Void Function(Pointer<event> event, Pointer<Utf8> name, Double value)>(isLeaf: true)
external void event_set_double(Pointer<event> event, Pointer<Utf8> name, double value);

@Native<Void Function(Pointer<event> event, Pointer<Utf8> name, Pointer<Utf8> value)>(isLeaf: true)
external void event_set_string(Pointer<event> event, Pointer<Utf8> name, Pointer<Utf8> value);

@Native<Void Function(Pointer<event> event, Pointer<Utf8> name, Pointer<Void> value)>(isLeaf: true)
external void event_set_address(Pointer<event> event, Pointer<Utf8> name, Pointer<Void> value);

@Native<Void Function(Pointer<event> event, Pointer<Utf8> name, Uint8 value)>(isLeaf: true)
external void event_set_character(Pointer<event> event, Pointer<Utf8> name, int value);

@Native<Bool Function(Pointer<event> event, Pointer<Utf8> name)>(isLeaf: true)
external bool event_has_field(Pointer<event> event, Pointer<Utf8> name);

@Native<Uint8 Function(Pointer<event> event, Pointer<Utf8> name)>(isLeaf: true)
external int event_get_character(Pointer<event> event, Pointer<Utf8> name);

@Native<Pointer<Void> Function(Pointer<event> event, Pointer<Utf8> name)>(isLeaf: true)
external Pointer<Void> event_get_address(Pointer<event> event, Pointer<Utf8> name);

@Native<Bool Function(Pointer<event> event, Pointer<Utf8> name)>(isLeaf: true)
external bool event_get_boolean(Pointer<event> event, Pointer<Utf8> name);

@Native<Int64 Function(Pointer<event> event, Pointer<Utf8> name)>(isLeaf: true)
external int event_get_signed(Pointer<event> event, Pointer<Utf8> name);

@Native<Uint64 Function(Pointer<event> event, Pointer<Utf8> name)>(isLeaf: true)
external int event_get_unsigned(Pointer<event> event, Pointer<Utf8> name);

@Native<Double Function(Pointer<event> event, Pointer<Utf8> name)>(isLeaf: true)
external double event_get_double(Pointer<event> event, Pointer<Utf8> name);

@Native<Pointer<Utf8> Function(Pointer<event> event, Pointer<Utf8> name)>(isLeaf: true)
external Pointer<Utf8> event_get_string(Pointer<event> event, Pointer<Utf8> name);

@Native<Bool Function(Pointer<event> event, Pointer<Utf8> name)>(isLeaf: true)
external bool event_field_is_signed(Pointer<event> event, Pointer<Utf8> name);

@Native<Bool Function(Pointer<event> event, Pointer<Utf8> name)>(isLeaf: true)
external bool event_field_is_unsigned(Pointer<event> event, Pointer<Utf8> name);

@Native<Pointer<Utf8> Function(Pointer<event> event)>(isLeaf: true)
external Pointer<Utf8> event_get_module(Pointer<event> event);

@Native<Uint8 Function(Pointer<event> event)>(isLeaf: true)
external int event_get_level(Pointer<event> event);

@Native<Pointer<Utf8> Function(Pointer<event> event)>(isLeaf: true)
external Pointer<Utf8> event_format(Pointer<event> event);
