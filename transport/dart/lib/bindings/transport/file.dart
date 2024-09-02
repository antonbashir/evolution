// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../transport/bindings.dart';

@Native<Int32 Function(Pointer<Utf8> path, Int32 mode, Bool truncate, Bool create)>(isLeaf: true)
external int transport_file_open(Pointer<Utf8> path, int mode, bool truncate, bool create);
