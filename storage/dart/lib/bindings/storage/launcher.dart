// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../storage/bindings.dart';

@Native<Void Function(Pointer<Utf8> binary_path)>(isLeaf: true)
external void storage_launcher_launch(Pointer<Utf8> binary_path);

@Native<Void Function(Int32 code)>(isLeaf: true)
external void storage_launcher_shutdown(int code);
