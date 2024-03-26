// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../storage/bindings.dart';

@Native<Pointer<storage_box> Function()>(isLeaf: true)
external Pointer<storage_box> storage_get_box();

@Native<Bool Function()>(isLeaf: true)
external bool storage_initialize();

@Native<Bool Function()>(isLeaf: true)
external bool storage_initialized();

@Native<Pointer<Utf8> Function()>(isLeaf: true)
external Pointer<Utf8> storage_status();

@Native<Int32 Function()>(isLeaf: true)
external int storage_is_read_only();

@Native<Pointer<Utf8> Function()>(isLeaf: true)
external Pointer<Utf8> storage_initialization_error();

@Native<Pointer<Utf8> Function()>(isLeaf: true)
external Pointer<Utf8> storage_shutdown_error();

@Native<Bool Function()>(isLeaf: true)
external bool storage_shutdown();
