import 'dart:ffi';

import 'package:core/core.dart';

extension Uint8StringExtensions on Pointer<Uint8> {
  set string(String value) {
    final buffer = asTypedList(value.length);
    final length = fastEncodeString(value, buffer, 0);
    buffer[length] = 0;
  }
}
