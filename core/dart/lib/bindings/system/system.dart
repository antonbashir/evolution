// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../core/bindings.dart';

@Native<Pointer<system_library> Function(Pointer<Utf8> path, Pointer<Utf8> module)>(isLeaf: true)
external Pointer<system_library> system_library_load(Pointer<Utf8> path, Pointer<Utf8> module);

@Native<Void Function(Pointer<system_library> library)>(isLeaf: true)
external void system_library_put(Pointer<system_library> library);

@Native<Pointer<system_library> Function(Pointer<Utf8> path)>(isLeaf: true)
external Pointer<system_library> system_library_get(Pointer<Utf8> path);

@Native<Pointer<system_library> Function(Pointer<Utf8> module)>(isLeaf: true)
external Pointer<system_library> system_library_by_module(Pointer<Utf8> module);

@Native<Pointer<system_library> Function(Pointer<system_library> library)>(isLeaf: true)
external Pointer<system_library> system_library_reload(Pointer<system_library> library);

@Native<Void Function(Pointer<system_library> library)>(isLeaf: true)
external void system_library_unload(Pointer<system_library> library);

@Native<Void Function(Pointer<Utf8> key, Pointer<Utf8> value)>(isLeaf: true)
external void system_set_environment(Pointer<Utf8> key, Pointer<Utf8> value);

@Native<Pointer<Utf8> Function(Pointer<Utf8> key)>(isLeaf: true)
external Pointer<Utf8> system_get_environment(Pointer<Utf8> key);

@Native<Pointer<pointer_array> Function()>(isLeaf: true)
external Pointer<pointer_array> system_environment_entries();
