import 'dart:ffi';

const rtldLazy = 0x00001;
const rtldGlobal = 0x00100;

final class iovec extends Struct {
  external Pointer<Void> iov_base;

  @Size()
  external int iov_len;
}

@Native<Int Function(Pointer<Void>)>()
external int dlclose(Pointer<Void> handle);

@Native<Pointer<Void> Function(Pointer<Char>, Int)>()
external Pointer<Void> dlopen(Pointer<Char> file, int mode);

@Native<Void Function(Int32)>(symbol: 'system_shutdown_descriptor', assetId: 'core-bindings', isLeaf: true)
external void system_shutdown_descriptor(int fd);
