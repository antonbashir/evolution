import 'dart:ffi';

@Native<Void Function(Int32)>(symbol: 'system_shutdown_descriptor', assetId: 'core-bindings', isLeaf: true)
external void system_shutdown_descriptor(int fd);

final class iovec extends Struct {
  external Pointer<void> iov_base;

  @Size()
  external int iov_len;
}
