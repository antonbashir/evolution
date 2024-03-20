// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../core/bindings.dart';

final class module_container extends Struct {
  @Uint32()
  external int id;
  external Pointer<Utf8> name;
  external Pointer<Void> module;
  @Uint64()
  external int loader;
}

final class system_library extends Struct {
  external Pointer<Utf8> path;
  external Pointer<Void> handle;
}
