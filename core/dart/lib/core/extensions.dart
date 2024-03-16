import 'dart:ffi';
import 'dart:typed_data';

import '../bindings/system/library.dart';

extension SystemIovecExtensions on Pointer<iovec> {
  Uint8List collect(int count) {
    final builder = BytesBuilder(copy: false);
    for (var i = 0; i < count; i++) {
      final current = this[i];
      builder.add(current.iov_base.asTypedList(current.iov_len));
    }
    return builder.takeBytes();
  }

  int collectTo(Uint8List output, int count) {
    var written = 0;
    for (var i = 0; i < count; i++) {
      final current = this[i];
      output.setRange(written, current.iov_len, current.iov_base.asTypedList(current.iov_len));
      written += output.length;
    }
    return written;
  }
}
