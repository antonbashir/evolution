import 'dart:io';

import 'package:core/core.dart';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import 'test/call.dart';
import 'test/threading.dart';

void main() {
  using((Arena arena) => dlopen("${Directory(dirname(Platform.script.toFilePath())).parent.path}/assets/libexecutor_test.so".toNativeUtf8(allocator: arena), rtldGlobal | rtldLazy));
  group("[call native]", testCallNative);
  // group("[call dart]", testCallDart);
  // group("[threading native]", testThreadingNative);
  // group("[threading dart]", testThreadingDart);
}
