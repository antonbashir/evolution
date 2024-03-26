// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../storage/bindings.dart';

final class storage_executor_configuration extends Struct {
  @Size()
  external int ring_size;
  @Size()
  external int ring_flags;
}

final class storage_launch_configuration extends Struct {
  external Pointer<Utf8> username;
  external Pointer<Utf8> password;
}

final class storage_boot_configuration extends Struct {
  external Pointer<Utf8> initial_script;
  external Pointer<Utf8> binary_path;
  @Uint64()
  external int initialization_timeout_seconds;
  @Uint64()
  external int shutdown_timeout_seconds;
  external storage_launch_configuration launch_configuration;
}
