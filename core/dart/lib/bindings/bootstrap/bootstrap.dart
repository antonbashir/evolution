// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../core/bindings.dart';

final class bootstrap_configuration extends Struct {
  @Bool()
  external bool silent;
  @Uint8()
  external int print_level;
}

@Native<Void Function(Pointer<bootstrap_configuration> configuration)>(isLeaf: true)
external void bootstrap_system(Pointer<bootstrap_configuration> configuration);

@Native<Pointer<bootstrap_configuration> Function()>(isLeaf: true)
external Pointer<bootstrap_configuration> bootstrap_configuration_get();
