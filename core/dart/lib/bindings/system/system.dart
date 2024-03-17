// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../core/bindings.dart';

@Native<Pointer<system_library> Function(Pointer<Utf8> path)>(isLeaf: true)
external Pointer<system_library> system_library_load(Pointer<Utf8> path);

@Native<Pointer<system_library> Function(Pointer<Utf8> path)>(isLeaf: true)
external Pointer<system_library> system_library_get(Pointer<Utf8> path);

@Native<Pointer<system_library> Function(Pointer<system_library> library)>(isLeaf: true)
external Pointer<system_library> system_library_reload(Pointer<system_library> library);

@Native<Void Function(Pointer<system_library> library)>(isLeaf: true)
external void system_library_unload(Pointer<system_library> library);
