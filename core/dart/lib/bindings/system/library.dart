import 'dart:ffi';

const rtldLazy = 0x00001;
const rtldGlobal = 0x00100;

final class iovec extends Struct {
  external final Pointer<Uint8> iov_base;

  @Size()
  external int iov_len;
}

@Native<Int Function(Pointer<Void>)>()
external int dlclose(Pointer<Void> handle);

@Native<Pointer<Void> Function(Pointer<Char>, Int)>()
external Pointer<Void> dlopen(Pointer<Char> file, int mode);
