import 'dart:io';

import 'package:core/core.dart';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import 'call.dart';
import 'threading.dart';

void main() {
  using((Arena arena) => dlopen("${dirname(Platform.script.toFilePath())}/../native/libmediatortest.so".toNativeUtf8(allocator: arena).cast(), rtldGlobal | rtldLazy));

  group("[call native]", testCallNative);
  group("[call dart]", testCallDart);
  group("[threading native]", () {
    for (var i = 0; i < 1000; i++) {
      testThreadingNative();
    }
  });
  group("[threading dart]", () {
    for (var i = 0; i < 1000; i++) {
      testThreadingDart();
    }
  });
}
