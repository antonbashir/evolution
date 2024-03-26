// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../storage/bindings.dart';

final class storage_module_configuration extends Struct {
  external storage_boot_configuration boot_configuration;
  external storage_executor_configuration executor_configuration;
}

final class storage_module extends Struct {
  external Pointer<Utf8> name;
  external storage_module_configuration configuration;
  external Pointer<system_library> library;
}

@Native<Pointer<storage_module> Function(Pointer<storage_module_configuration> configuration)>(isLeaf: true)
external Pointer<storage_module> storage_module_create(Pointer<storage_module_configuration> configuration);

@Native<Void Function(Pointer<storage_module> module)>(isLeaf: true)
external void storage_module_destroy(Pointer<storage_module> module);
